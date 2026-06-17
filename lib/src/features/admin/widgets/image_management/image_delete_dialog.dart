import 'package:flutter/material.dart';

/// Dialog konfirmasi untuk menghapus gambar.
class ImageDeleteDialog extends StatelessWidget {
  final int count;

  const ImageDeleteDialog({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
    );
  }
}
