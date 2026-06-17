import 'package:flutter/material.dart';

class SocialMediaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;
  final TextInputType keyboardType;
  final bool isDark;

  const SocialMediaTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.keyboardType = TextInputType.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12),
        prefixIcon: Icon(icon, color: iconColor, size: 18),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}
