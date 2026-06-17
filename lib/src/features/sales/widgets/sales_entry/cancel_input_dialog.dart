import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

/// Dialog konfirmasi ketika pengguna ingin membatalkan input penjualan yang sedang berjalan.
class CancelInputDialog extends StatelessWidget {
  const CancelInputDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Batal Menginput?',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Apakah Anda yakin ingin keluar? Semua data form yang telah diisi akan hilang.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Ya, Keluar',
            style: TextStyle(color: AppTheme.secondaryColor),
          ),
        ),
      ],
    );
  }
}
