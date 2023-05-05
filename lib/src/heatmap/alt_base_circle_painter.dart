import 'dart:math' as math;
import 'package:flutter/material.dart' hide Image;

class AltBaseCirclePainter extends CustomPainter {

  /// radius of the circle to be painted
  final double radius;
  /// radius of the gradient applied to the painted circle
  final double blurFactor;

  AltBaseCirclePainter({required this.radius, this.blurFactor = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final _width = size.width;
    final _height = size.height;
    final r2 = radius;

    final rect = Rect.fromPoints(Offset(_width / 2 - r2, _height / 2 - r2),
        Offset(_width / 2 + r2, _height / 2 + r2));

    var pointPaint = Paint()..color = Colors.black;

    pointPaint.strokeWidth = 4;

    final gradient = RadialGradient(
            colors: const [Color.fromRGBO(0, 0, 0, 1), Color.fromRGBO(0, 0, 0, 0)],
            stops: const [0, 1],
            radius: blurFactor)
        .createShader(rect);

    canvas.drawPath(
        Path()
          ..addArc(rect, 0, math.pi * 2)
          ..close(),
        Paint()..shader = gradient);
  }

  @override
  bool shouldRepaint(AltBaseCirclePainter oldDelegate) {
    return false;
  }
}
