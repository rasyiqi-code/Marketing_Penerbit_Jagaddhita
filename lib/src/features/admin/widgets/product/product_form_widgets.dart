import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/image_management_screen.dart';
import 'package:provider/provider.dart';

/// Seksi pengelolaan multiple gambar produk (pilih/upload/hapus/set-utama).
class ProductImagePickerSection extends StatelessWidget {
  final List<String> imageUrls;
  final void Function(String url) onAdd;
  final void Function(int index) onRemove;
  final void Function(int index) onSetPrimary;

  const ProductImagePickerSection({
    super.key,
    required this.imageUrls,
    required this.onAdd,
    required this.onRemove,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        builder: (_) =>
                            const ImageManagementScreen(isPicker: true),
                      ),
                    );
                    if (selectedUrl != null) onAdd(selectedUrl);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cloud_upload_outlined),
                  tooltip: 'Upload Baru',
                  onPressed: () async {
                    try {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(
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

                      final storage =
                          Provider.of<StorageService>(context, listen: false);
                      final bytes = await image.readAsBytes();
                      final url = await storage.uploadBytes(
                        bytes,
                        image.name,
                        'products',
                      );

                      if (!context.mounted) return;
                      onAdd(url);
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
        imageUrls.isEmpty
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
                  itemCount: imageUrls.length,
                  itemBuilder: (_, index) {
                    final url = imageUrls[index];
                    final isPrimary = index == 0;
                    return _ProductImageTile(
                      url: url,
                      isPrimary: isPrimary,
                      onRemove: () => onRemove(index),
                      onSetPrimary: () => onSetPrimary(index),
                    );
                  },
                ),
              ),
      ],
    );
  }
}

class _ProductImageTile extends StatelessWidget {
  final String url;
  final bool isPrimary;
  final VoidCallback onRemove;
  final VoidCallback onSetPrimary;

  const _ProductImageTile({
    required this.url,
    required this.isPrimary,
    required this.onRemove,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
          if (!isPrimary)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: InkWell(
                onTap: onSetPrimary,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Set Utama',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Toggle SIBI Kemendikbud untuk produk.
class SibiToggleCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SibiToggleCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.15)),
      ),
      child: SwitchListTile(
        title: const Text(
          'Katalog SIBI Kemendikbud',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        subtitle: const Text(
          'Aktifkan jika produk ini merupakan Buku SIBI Kemendikbud. Jika tidak aktif, produk masuk kategori Jagaddhita (JGD).',
          style: TextStyle(fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
        secondary: const Icon(Icons.account_balance, color: Colors.indigo),
        activeThumbColor: Colors.indigo,
      ),
    );
  }
}
