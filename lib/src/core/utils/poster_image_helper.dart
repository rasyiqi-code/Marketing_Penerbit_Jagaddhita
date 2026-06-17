import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Helper class to handle image overlay generation and coordinate math.
class PosterImageHelper {
  /// Generates the overlay image bytes containing the contact text.
  static Future<Uint8List> createOverlayImageBytes({
    required String text,
    required double fontSize,
    required Color textColor,
    required Color bgColor,
    required double bgOpacity,
    required bool isBgEnabled,
    required double hPadding,
    required double vPadding,
    required double borderRadius,
  }) async {
    final textStyle = TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      shadows: !isBgEnabled
          ? [
              const Shadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ]
          : null,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final width = textPainter.width + hPadding * 2;
    final height = textPainter.height + vPadding * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (isBgEnabled) {
      final bgPaint = Paint()..color = bgColor.withValues(alpha: bgOpacity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, width, height),
          Radius.circular(borderRadius),
          ),
        bgPaint,
      );
    }

    textPainter.paint(canvas, Offset(hPadding, vPadding));

    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Calculates actual rendering position and scale factors relative to original image size.
  static Map<String, double> calculateRelativeCoordinates({
    required Size originalSize,
    required Size displaySize,
    required double relativeX,
    required double relativeY,
  }) {
    double scale = 1.0;
    double xOffset = 0.0;
    double yOffset = 0.0;

    final double aspectOriginal = originalSize.width / originalSize.height;
    final double aspectDisplay = displaySize.width / displaySize.height;

    if (aspectOriginal > aspectDisplay) {
      scale = displaySize.width / originalSize.width;
      yOffset = (displaySize.height - (originalSize.height * scale)) / 2;
    } else {
      scale = displaySize.height / originalSize.height;
      xOffset = (displaySize.width - (originalSize.width * scale)) / 2;
    }

    final double positionX = relativeX * displaySize.width;
    final double positionY = relativeY * displaySize.height;

    final double actualImageX = positionX - xOffset;
    final double actualImageY = positionY - yOffset;

    final dxRelative = (actualImageX / (originalSize.width * scale)).clamp(0.0, 1.0);
    final dyRelative = (actualImageY / (originalSize.height * scale)).clamp(0.0, 1.0);

    return {
      'dx': dxRelative,
      'dy': dyRelative,
      'scale': scale,
    };
  }
}
