// ignore_for_file: avoid_web_libraries_in_flutter, uri_does_not_exist

import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

void nativeShare(BuildContext context, String text) {
  try {
    final navigator = js_util.getProperty(js_util.globalThis, 'navigator');
    final hasNativeShare = navigator != null && js_util.hasProperty(navigator, 'share');

    if (hasNativeShare) {
      SharePlus.instance.share(ShareParams(text: text));
    } else {
      _fallbackToClipboard(context, text);
    }
  } catch (e) {
    _fallbackToClipboard(context, text);
  }
}

void _fallbackToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Detail produk disalin ke clipboard!',
        style: GoogleFonts.outfit(),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      margin: const EdgeInsets.all(20),
    ),
  );
}
