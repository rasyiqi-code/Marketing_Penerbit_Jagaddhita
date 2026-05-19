import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';

class SalesTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const SalesTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.prefixText,
    this.inputFormatters,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      icon: icon,
      keyboardType: keyboardType,
      prefixText: prefixText,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator ?? (v) => v!.isEmpty ? 'Wajib diisi ya' : null,
    );
  }
}
