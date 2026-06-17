import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/image_management/image_grid_item.dart';

class ImageManagementScreen extends StatefulWidget {
  final bool isPicker;

  const ImageManagementScreen({super.key, this.isPicker = false});

  @override
  State<ImageManagementScreen> createState() => _ImageManagementScreenState();
}

class _ImageManagementScreenState extends State<ImageManagementScreen> {
  bool _isLoading = false;
  List<StorageItem> _images = [];
  final Set<String> _selectedKeys = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final images = await storage.listFiles();
      if (mounted) {
        setState(() {
          _images = images;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading images: $e')));
      }
    }
  }

  void _toggleSelection(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
        if (_selectedKeys.isEmpty) _isSelectionMode = false;
      } else {
        _selectedKeys.add(key);
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedKeys.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Gambar?'),
        content: Text(
          'Anda yakin ingin menghapus $count gambar terpilih? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final storage = Provider.of<StorageService>(context, listen: false);
      final keysToDelete = List<String>.from(_selectedKeys);

      final results = await Future.wait(
        keysToDelete.map((key) async {
          try {
            await storage.deleteFile(key);
            return true;
          } catch (e) {
            debugPrint('Failed to delete $key: $e');
            return false;
          }
        }),
      );

      final successCount = results.where((s) => s).length;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil menghapus $successCount gambar.')),
        );
        _selectedKeys.clear();
        _isSelectionMode = false;
        _loadImages();
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final storage = Provider.of<StorageService>(context, listen: false);
        final file = File(pickedFile.path);
        await storage.uploadFile(file, 'admin_uploads');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gambar berhasil diunggah!')),
          );
          _loadImages();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal unggah: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isPicker
              ? 'Pilih Gambar'
              : _isSelectionMode
                  ? '${_selectedKeys.length} Dipilih'
                  : 'Kelola Gambar',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedKeys.clear();
                    _isSelectionMode = false;
                  });
                },
              )
            : null,
        actions: [
          if (!widget.isPicker && _isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteSelected,
            )
          else if (!widget.isPicker)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadImages),
        ],
      ),
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton(
              onPressed: _pickAndUploadImage,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada gambar tersimpan.',
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadImages,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      final item = _images[index];
                      final isSelected = _selectedKeys.contains(item.key);

                      return ImageGridItem(
                        imageUrl: item.url,
                        imageKey: item.key,
                        isSelected: isSelected,
                        isPicker: widget.isPicker,
                        lastModified: item.lastModified,
                        onLongPress: () {
                          if (!widget.isPicker) _toggleSelection(item.key);
                        },
                        onTap: () {
                          if (widget.isPicker) {
                            Navigator.pop(context, item.url);
                            return;
                          }
                          if (_isSelectionMode) {
                            _toggleSelection(item.key);
                          } else {
                            showDialog(
                              context: context,
                              builder: (ctx) => Dialog(
                                child: InteractiveViewer(
                                  child: NetworkImageWeb(imageUrl: item.url),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
