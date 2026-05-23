import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PosterExportHelper {
  static Future<void> exportImage(Uint8List bytes, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Poster ini dibuat otomatis lewat Jagaddhita App');
    } catch (e) {
      debugPrint('Error exporting poster on mobile/desktop: $e');
      rethrow;
    }
  }
}
