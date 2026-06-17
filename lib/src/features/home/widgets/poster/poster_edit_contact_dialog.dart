import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

class PosterEditContactDialog extends StatefulWidget {
  final String initialName;
  final String initialPhone;

  const PosterEditContactDialog({
    super.key,
    required this.initialName,
    required this.initialPhone,
  });

  @override
  State<PosterEditContactDialog> createState() => _PosterEditContactDialogState();
}

class _PosterEditContactDialogState extends State<PosterEditContactDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit Kontak',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      content: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Nomor WhatsApp'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final phone = _phoneController.text.trim();
            final cleanPhone = phone.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
            
            if (name.length < 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nama harus minimal 2 karakter')),
              );
              return;
            }
            if (cleanPhone.length < 8) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nomor WhatsApp harus minimal 8 karakter alfanumerik')),
              );
              return;
            }
            
            Navigator.pop(context, (name, phone));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
