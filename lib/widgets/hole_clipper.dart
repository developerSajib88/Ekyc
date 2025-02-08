// Custom Clipper for Transparent Rounded Rectangle
import 'package:flutter/material.dart';

class HoleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Define the transparent rounded rectangle
    RRect transparentRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 300, // Adjust size as needed
        height: 200,
      ),
      Radius.circular(20), // Adjust border radius as needed
    );

    path.addRRect(transparentRect);
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}