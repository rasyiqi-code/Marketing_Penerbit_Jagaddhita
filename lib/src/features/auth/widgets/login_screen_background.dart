import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

/// Latar belakang dekoratif login — 5 lingkaran berwarna di pojok layar.
class LoginScreenBackground extends StatelessWidget {
  const LoginScreenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        // Merah — lingkaran pojok kanan atas
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryColor.withValues(alpha: 0.3),
            ),
          ),
        ),
        // Kuning — dot kanan tengah atas
        Positioned(
          top: 30,
          right: 20,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentColor,
            ),
          ),
        ),
        // Merah — dot kecil kiri bawah
        Positioned(
          bottom: 70,
          left: 28,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        // Kuning — dot kecil kanan bawah
        Positioned(
          bottom: 36,
          right: 52,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentColor.withValues(alpha: 0.85),
            ),
          ),
        ),
        // Hijau — dot kecil bawah kiri
        Positioned(
          bottom: 110,
          left: 64,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}
