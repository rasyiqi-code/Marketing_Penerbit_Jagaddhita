import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SalesService salesService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    salesService = SalesService(firestore: fakeFirestore);
  });

  group('SalesService Tests', () {
    test('addSale with COMPLETE status should update user balances', () async {
      final userId = 'user123';
      
      // Create user document
      await fakeFirestore.collection('users').doc(userId).set({
        'name': 'Test User',
        'commission_balance': 0,
        'pulsa_balance': 0,
        'total_sales_count': 0,
      });

      final sale = SaleModel(
        id: '',
        userId: userId,
        productId: 'prod1',
        details: {
          'product_name': 'Book A',
          'buyer_name': 'Buyer 1',
        },
        paymentStatus: SaleModel.statusComplete,
        totalPrice: 100000,
        bonusAmount: 15000,
        commissionAmount: 10000,
        pulsaBonusAmount: 5000,
        createdAt: DateTime.now(),
      );

      await salesService.addSale(sale);

      final userDoc = await fakeFirestore.collection('users').doc(userId).get();
      expect(userDoc.data()?['commission_balance'], 10000);
      expect(userDoc.data()?['pulsa_balance'], 5000);
      expect(userDoc.data()?['total_sales_count'], 1);

      final historyCount = await fakeFirestore.collection('wallet_history').count().get();
      expect(historyCount.count, 2); // Commission + Pulsa
    });

    test('updateSaleStatus to COMPLETE should only grant Pulsa Bonus once per month', () async {
      final userId = 'user456';
      final now = DateTime.now();
      
      // Create user document with a bonus already received this month
      await fakeFirestore.collection('users').doc(userId).set({
        'name': 'Bonus User',
        'commission_balance': 0,
        'pulsa_balance': 5000,
        'last_pulsa_bonus_at': now,
      });

      // Create a pending sale
      final saleId = 'sale_pending';
      final sale = SaleModel(
        id: saleId,
        userId: userId,
        productId: 'prod2',
        details: {
          'product_name': 'Book B',
          'buyer_name': 'Buyer 2',
        },
        paymentStatus: SaleModel.statusPending,
        totalPrice: 100000,
        bonusAmount: 15000,
        commissionAmount: 10000,
        pulsaBonusAmount: 5000,
        createdAt: now,
      );
      await fakeFirestore.collection('sales').doc(saleId).set(sale.toMap());

      // Update status to COMPLETE
      await salesService.updateSaleStatus(sale, SaleModel.statusComplete);

      final userDoc = await fakeFirestore.collection('users').doc(userId).get();
      
      // Commission should be added (0 + 10000 = 10000)
      expect(userDoc.data()?['commission_balance'], 10000);
      
      // Pulsa Bonus should NOT be added (stays 5000) because it was already given this month
      expect(userDoc.data()?['pulsa_balance'], 5000);
      
      final saleDoc = await fakeFirestore.collection('sales').doc(saleId).get();
      expect(saleDoc.data()?['pulsa_bonus_amount'], 0); // Should be zeroed out in sale doc too
    });

    test('updateSaleStatus to COMPLETE should grant bonus if first time this month', () async {
      final userId = 'user789';
      final lastMonth = DateTime.now().subtract(const Duration(days: 40));
      
      await fakeFirestore.collection('users').doc(userId).set({
        'name': 'New Month User',
        'commission_balance': 0,
        'pulsa_balance': 5000,
        'last_pulsa_bonus_at': lastMonth,
      });

      final saleId = 'sale_new_month';
      final sale = SaleModel(
        id: saleId,
        userId: userId,
        productId: 'prod3',
        details: {
          'product_name': 'Book C',
          'buyer_name': 'Buyer 3',
        },
        paymentStatus: SaleModel.statusPending,
        totalPrice: 100000,
        bonusAmount: 15000,
        commissionAmount: 10000,
        pulsaBonusAmount: 5000,
        createdAt: DateTime.now(),
      );
      await fakeFirestore.collection('sales').doc(saleId).set(sale.toMap());

      await salesService.updateSaleStatus(sale, SaleModel.statusComplete);

      final userDoc = await fakeFirestore.collection('users').doc(userId).get();
      expect(userDoc.data()?['commission_balance'], 10000);
      expect(userDoc.data()?['pulsa_balance'], 10000); // 5000 + 5000
    });
  });
}
