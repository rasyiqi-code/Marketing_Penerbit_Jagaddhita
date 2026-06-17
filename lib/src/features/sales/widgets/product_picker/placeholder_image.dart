import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  final Color color;
  const PlaceholderImage({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 40,
          color: color.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
