import 'package:flutter/material.dart';

/// Painter khusus untuk menggambar representasi visual kode QR buatan (mock).
class MockQrPainter extends CustomPainter {
  const MockQrPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    // Menggambar finder patterns (kotak penanda di sudut QR)
    void drawFinderPattern(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 12, 12), paint);
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(x + 2, y + 2, 8, 8), whitePaint);
      canvas.drawRect(Rect.fromLTWH(x + 4, y + 4, 4, 4), paint);
    }

    drawFinderPattern(0, 0);
    drawFinderPattern(size.width - 12, 0);
    drawFinderPattern(0, size.height - 12);

    // Menggambar blok-blok QR tiruan
    canvas.drawRect(Rect.fromLTWH(16, 2, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(20, 6, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(16, 16, 8, 4), paint);
    canvas.drawRect(Rect.fromLTWH(4, 16, 4, 8), paint);
    canvas.drawRect(Rect.fromLTWH(16, 24, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(24, 16, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(28, 20, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(20, 28, 8, 4), paint);
    canvas.drawRect(Rect.fromLTWH(28, 28, 4, 4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
