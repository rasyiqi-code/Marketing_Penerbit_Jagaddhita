import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExcelExportHelper {
  static Future<void> exportExcel(Uint8List bytes, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Laporan Penjualan Penerbit Jagaddhita',
        ),
      );
    } catch (e) {
      debugPrint('Error exporting excel on mobile/desktop: $e');
      rethrow;
    }
  }
}
