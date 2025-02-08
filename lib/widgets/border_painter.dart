// Painter for the Border Around the Transparent Hole
import 'package:flutter/material.dart';

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white // Border color
      ..strokeWidth = 5 // Border thickness
      ..style = PaintingStyle.stroke; // Stroke (no fill)

    RRect borderRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 300, // Same size as transparent hole
        height: 200,
      ),
      Radius.circular(20), // Same border radius
    );

    canvas.drawRRect(borderRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}