import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class PosterExportHelper {
  static Future<void> exportImage(Uint8List bytes, String fileName) async {
    try {
      final jsBytes = bytes.toJS;
      final blob = web.Blob([jsBytes].toJS, web.BlobPropertyBag(type: 'image/png'));
      final url = web.URL.createObjectURL(blob);
      
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = fileName;
      anchor.style.display = 'none';
      
      web.document.body?.appendChild(anchor);
      anchor.click();
      
      web.document.body?.removeChild(anchor);
      web.URL.revokeObjectURL(url);
    } catch (e) {
      debugPrint('Error exporting poster on Web: $e');
      rethrow;
    }
  }
}
