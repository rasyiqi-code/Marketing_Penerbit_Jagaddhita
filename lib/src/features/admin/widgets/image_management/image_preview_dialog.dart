import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';

/// Dialog untuk menampilkan pratinjau gambar secara penuh.
class ImagePreviewDialog extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: InteractiveViewer(
        child: NetworkImageWeb(imageUrl: imageUrl),
      ),
    );
  }
}
