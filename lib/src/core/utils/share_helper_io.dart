import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void nativeShare(BuildContext context, String text) {
  SharePlus.instance.share(ShareParams(text: text));
}
