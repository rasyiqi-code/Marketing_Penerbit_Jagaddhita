import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/image_management_screen.dart';
import 'package:provider/provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _copywritingController;

  int _houseType = 1;
  String? _uploadedImageUrl;
  bool _isSibi = false;
  List<String> _productImageUrls = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _uploadedImageUrl = p?.marketingKitUrl;
    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _priceController = TextEditingController(
      text: p?.price.toStringAsFixed(0) ?? '',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _copywritingController = TextEditingController(text: p?.copywriting ?? '');
    _houseType = p?.houseType ?? 1;
    _isSibi = p?.isSibi ?? false;
    _productImageUrls = List<String>.from(p?.imageUrls ?? []);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final productService = Provider.of<ProductService>(context, listen: false);

      final product = ProductModel(
        id: widget.product?.id ?? '',
        houseType: _houseType,
        name: _nameController.text,
        category: _categoryController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        description: _descriptionController.text,
        copywriting: _copywritingController.text,
        imageUrls: _productImageUrls,
        marketingKitUrl: _uploadedImageUrl,
        isSibi: _isSibi,
      );

      if (widget.product == null) {
        await productService.addProduct(product);
      } else {
        await productService.updateProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _copywritingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              AppTextField(
                controller: _nameController,
                label: 'Product Name',
                icon: Icons.label_important_outline,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _categoryController,
                label: 'Category',
                icon: Icons.category_outlined,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.indigo.withValues(alpha: 0.15),
                  ),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Katalog SIBI Kemendikbud',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  subtitle: const Text(
                    'Aktifkan jika produk ini merupakan Buku SIBI Kemendikbud. Jika tidak aktif, produk masuk kategori Jagaddhita (JGD).',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _isSibi,
                  onChanged: (val) {
                    setState(() {
                      _isSibi = val;
                    });
                  },
                  secondary: const Icon(
                    Icons.account_balance,
                    color: Colors.indigo,
                  ),
                  activeThumbColor: Colors.indigo,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _priceController,
                label: 'Base Price (Rp)',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gambar Produk (Multiple)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.collections_outlined),
                        tooltip: 'Pilih dari Galeri',
                        onPressed: () async {
                          final String? selectedUrl = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ImageManagementScreen(isPicker: true),
                            ),
                          );

                          if (selectedUrl != null && mounted) {
                            setState(() {
                              _productImageUrls.add(selectedUrl);
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cloud_upload_outlined),
                        tooltip: 'Upload Baru',
                        onPressed: () async {
                          try {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1080,
                              maxHeight: 1080,
                              imageQuality: 85,
                            );

                            if (image == null) return;
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Uploading image...')),
                            );

                            final storage = Provider.of<StorageService>(
                              context,
                              listen: false,
                            );

                            final bytes = await image.readAsBytes();
                            final url = await storage.uploadBytes(
                              bytes,
                              image.name,
                              'products',
                            );

                            if (!context.mounted) return;

                            setState(() {
                              _productImageUrls.add(url);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Upload Successful!')),
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Upload failed: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _productImageUrls.isEmpty
                  ? Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada gambar produk.\nTambahkan dari galeri atau upload baru.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _productImageUrls.length,
                        itemBuilder: (context, index) {
                          final url = _productImageUrls[index];
                          final isPrimary = index == 0;
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: NetworkImageWeb(
                                    imageUrl: url,
                                    width: 100,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (isPrimary)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Utama',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _productImageUrls.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isPrimary)
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          final primary =
                                              _productImageUrls.removeAt(index);
                                          _productImageUrls.insert(0, primary);
                                        });
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Set Utama',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Marketing Kit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _copywritingController,
                label: 'Copywriting Text',
                icon: Icons.edit_note_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Poster Image'),
                subtitle: _uploadedImageUrl != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          NetworkImageWeb(
                            imageUrl: _uploadedImageUrl!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ],
                      )
                    : Text(
                        widget.product?.marketingKitUrl ?? 'No image uploaded',
                      ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.collections_outlined),
                      tooltip: 'Pilih dari Galeri',
                      onPressed: () async {
                        final String? selectedUrl = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ImageManagementScreen(isPicker: true),
                          ),
                        );

                        if (selectedUrl != null && mounted) {
                          setState(() {
                            _uploadedImageUrl = selectedUrl;
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cloud_upload),
                      tooltip: 'Upload Baru',
                      onPressed: () async {
                        try {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth:
                                1080, // Resize before upload (Server-size optimization)
                            maxHeight: 1080,
                            imageQuality: 85, // Compress to ~85% quality
                          );

                          if (image == null) return;
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Uploading image...')),
                          );

                          final storage = Provider.of<StorageService>(
                            context,
                            listen: false,
                          );

                          // For web support we would need readAsBytes, but for mobile File is fine.
                          // Since we are likely targeted for mobile (based on file paths), we use File.
                          // However, cross-platform safety:
                          final bytes = await image.readAsBytes();
                          final url = await storage.uploadBytes(
                            bytes,
                            image.name,
                            'products',
                          );

                          if (!context.mounted) return;

                          setState(() {
                            _uploadedImageUrl = url;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Upload Successful!')),
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Upload failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
