import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/admin_product_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/admin_product_empty_state.dart';
import 'package:provider/provider.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kelola Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/admin/products/add');
            },
          ),
        ],
      ),
      body: const ProductList(houseType: 1),
    );
  }
}

class ProductList extends StatelessWidget {
  final int houseType;

  const ProductList({super.key, required this.houseType});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);

    return StreamBuilder<List<ProductModel>>(
      stream: productService.getProducts(houseType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return AdminProductEmptyState(houseType: houseType);
        }

        final products = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final product = products[index];
            return AdminProductCard(
              product: product,
              productService: productService,
              houseType: houseType,
            );
          },
        );
      },
    );
  }
}
