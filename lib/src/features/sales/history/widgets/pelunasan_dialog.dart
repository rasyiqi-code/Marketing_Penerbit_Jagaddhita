import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

/// Dialog konfirmasi dan upload bukti pelunasan DP.
class PelunasanDialog extends StatefulWidget {
  final double remainingAmount;
  final Function(XFile) onConfirm;

  const PelunasanDialog({
    super.key,
    required this.remainingAmount,
    required this.onConfirm,
  });

  @override
  State<PelunasanDialog> createState() => _PelunasanDialogState();
}

class _PelunasanDialogState extends State<PelunasanDialog> {
  XFile? _imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _imageFile = file);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pelunasan Transaksi'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sisa Pembayaran: ${AppFormatters.currency(widget.remainingAmount)}',
          ),
          const SizedBox(height: 16),
          if (_imageFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: kIsWeb
                  ? Image.network(_imageFile!.path,
                      height: 150, fit: BoxFit.cover)
                  : Image.file(File(_imageFile!.path),
                      height: 150, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _pickImage, child: const Text('Ganti Foto')),
          ] else
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Bukti Transfer'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed:
              _imageFile != null ? () => widget.onConfirm(_imageFile!) : null,
          child: const Text('Kirim Pelunasan'),
        ),
      ],
    );
  }
}
