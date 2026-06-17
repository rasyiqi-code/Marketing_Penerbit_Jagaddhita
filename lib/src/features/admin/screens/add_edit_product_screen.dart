import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/screens/image_management_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/product/product_form_widgets.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _copywritingController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final productService =
          Provider.of<ProductService>(context, listen: false);

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

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadPosterImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null) return;
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Uploading image...')));

      final storage = Provider.of<StorageService>(context, listen: false);
      final bytes = await image.readAsBytes();
      final url = await storage.uploadBytes(bytes, image.name, 'products');

      if (!mounted) return;
      setState(() => _uploadedImageUrl = url);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Upload Successful!')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
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

              // ── SIBI Toggle ────────────────────────────────────────────────
              SibiToggleCard(
                value: _isSibi,
                onChanged: (val) => setState(() => _isSibi = val),
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

              // ── Multi-Image Section ────────────────────────────────────────
              ProductImagePickerSection(
                imageUrls: _productImageUrls,
                onAdd: (url) => setState(() => _productImageUrls.add(url)),
                onRemove: (index) =>
                    setState(() => _productImageUrls.removeAt(index)),
                onSetPrimary: (index) => setState(() {
                  final primary = _productImageUrls.removeAt(index);
                  _productImageUrls.insert(0, primary);
                }),
              ),

              const SizedBox(height: 16),
              const Divider(),

              // ── Marketing Kit (Poster) ─────────────────────────────────────
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
                            builder: (_) =>
                                const ImageManagementScreen(isPicker: true),
                          ),
                        );
                        if (selectedUrl != null && mounted) {
                          setState(() => _uploadedImageUrl = selectedUrl);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cloud_upload),
                      tooltip: 'Upload Baru',
                      onPressed: _uploadPosterImage,
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
