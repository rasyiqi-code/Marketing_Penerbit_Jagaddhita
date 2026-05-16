import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markating_kbm_app/src/core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? prefixText;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? helperText;
  final Color? fillColor;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.prefixText,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.helperText,
    this.fillColor,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.outfit(fontSize: 16),
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: _inputDecoration(context),
      onChanged: onChanged,
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      helperText: helperText,
      prefixText: prefixText,
      prefixStyle: GoogleFonts.outfit(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      filled: true,
      fillColor: fillColor ??
          Theme.of(context).inputDecorationTheme.fillColor ??
          Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }
}
