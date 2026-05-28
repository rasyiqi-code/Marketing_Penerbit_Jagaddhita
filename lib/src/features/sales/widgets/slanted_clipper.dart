import 'package:flutter/material.dart';

class SlantedClipper extends CustomClipper<Path> {
  final bool slantLeft;
  final bool slantRight;
  final double slantWidth;

  const SlantedClipper({
    required this.slantLeft,
    required this.slantRight,
    this.slantWidth = 12.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final topLeftX = slantLeft ? slantWidth : 0.0;
    final topRightX = size.width;
    final bottomRightX = slantRight ? size.width - slantWidth : size.width;
    final bottomLeftX = slantLeft ? 0.0 : 0.0;

    path.moveTo(topLeftX, 0);
    path.lineTo(topRightX, 0);
    path.lineTo(bottomRightX, size.height);
    path.lineTo(bottomLeftX, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant SlantedClipper oldClipper) {
    return oldClipper.slantLeft != slantLeft ||
        oldClipper.slantRight != slantRight ||
        oldClipper.slantWidth != slantWidth;
  }
}

class SlantedContainer extends StatelessWidget {
  final Color color;
  final double slantWidth;
  final bool slantLeft;
  final bool slantRight;
  final double? height;
  final double? width;
  final Widget child;

  const SlantedContainer({
    super.key,
    required this.color,
    required this.child,
    this.slantWidth = 12.0,
    this.slantLeft = false,
    this.slantRight = false,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SlantedClipper(
        slantLeft: slantLeft,
        slantRight: slantRight,
        slantWidth: slantWidth,
      ),
      child: Container(
        width: width,
        height: height,
        color: color,
        child: child,
      ),
    );
  }
}
