import 'package:flutter/material.dart';

/// Dialog konfirmasi berbahaya untuk mereset seluruh data sistem.
class ConfirmResetDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmResetDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<ConfirmResetDialog> createState() => _ConfirmResetDialogState();
}

class _ConfirmResetDialogState extends State<ConfirmResetDialog> {
  final _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Semua Data?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERINGATAN: Tindakan ini akan MENGHAPUS SEMUA data (Produk, Penjualan, Riwayat Saldo, Notifikasi, dan Reset Saldo Pengguna) secara permanen.\n\nData yang dihapus TIDAK BISA dipulihkan. Ketik "HAPUS" untuk mengonfirmasi.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'HAPUS',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              setState(() {
                _canDelete = val.trim() == 'HAPUS';
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: _canDelete ? widget.onConfirm : null,
          style: TextButton.styleFrom(
            foregroundColor: _canDelete ? Colors.red : Colors.grey,
          ),
          child: const Text('Hapus Semuanya'),
        ),
      ],
    );
  }
}
