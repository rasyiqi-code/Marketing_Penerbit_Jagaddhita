import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';

class InvoiceItem {
  final String name;
  final double price;
  final int quantity;

  InvoiceItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;
}

class InvoiceDataHelper {
  final SaleModel sale;
  final GlobalSettingsModel? settings;

  InvoiceDataHelper({
    required this.sale,
    required this.settings,
  });

  String get publisherName => settings?.publisherName ?? 'Penerbit Jagaddhita';
  String get publisherSlogan => settings?.publisherSlogan ?? 'Edukasi Bangsa';

  String get bankName => settings?.invoiceBankName ?? 'BCA';
  String get bankAccountNo => settings?.invoiceBankAccountNo ?? '1234-5678-910';
  String get bankAccountName => settings?.invoiceBankAccountName ?? publisherName;
  String get contactPhone => settings?.invoiceContactPhone ?? '+62 822-8493-2038';
  String get contactEmail => settings?.invoiceContactEmail ?? 'info@jagaddhita.id';
  
  String get displayWeb {
    final webUrl = settings?.webBaseUrl ?? 'www.jagaddhita.id';
    return webUrl
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .split('/')
        .first;
  }

  String get formattedDate {
    return DateFormat(
      'dd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(sale.createdAt);
  }

  String get paymentStatusUpper => sale.paymentStatus.toUpperCase();

  bool get isLunas => paymentStatusUpper == 'LUNAS';
  bool get isComplete => paymentStatusUpper == 'COMPLETE';
  bool get isDp => paymentStatusUpper == 'DP';
  bool get isPending => paymentStatusUpper == 'PENDING';
  bool get isCod => paymentStatusUpper == 'COD';

  String get stampText {
    if (isComplete || isLunas) {
      return 'PAID / LUNAS';
    } else if (isDp) {
      return 'DP / SEBAGIAN';
    } else if (isPending) {
      return 'PENDING';
    } else if (isCod) {
      return 'COD / BAYAR DI TEMPAT';
    } else {
      return paymentStatusUpper;
    }
  }

  String get stampColorHex {
    if (isComplete || isLunas) {
      return '#4CAF50'; // Green
    } else if (isDp) {
      return '#FF9800'; // Orange
    } else if (isPending) {
      return '#9E9E9E'; // Grey
    } else if (isCod) {
      return '#2196F3'; // Blue
    } else {
      return '#F44336'; // Red
    }
  }

  double get totalOutstanding => sale.totalPrice - sale.paidAmount;

  List<InvoiceItem> get items {
    final names = sale.productNames;
    final prices = sale.productPrices;
    final quantities = sale.productQuantities;
    
    return List.generate(names.length, (idx) {
      final name = names[idx];
      final price = prices.length > idx ? prices[idx] : 0.0;
      final qty = quantities.length > idx ? quantities[idx] : 1;
      return InvoiceItem(
        name: name,
        price: price,
        quantity: qty,
      );
    });
  }
}
