import 'dart:math' as math;
import 'package:flutter/material.dart' hide Image;

class AltBaseCirclePainter extends CustomPainter {
  final double radius;
  final double blurFactor;

  AltBaseCirclePainter({required this.radius, this.blurFactor = 15});

  @override
  void paint(Canvas canvas, Size size) {
    final _width = size.width;
    final _height = size.height;
    final r2 = radius;

    final rect = Rect.fromPoints(Offset(_width / 2 - r2, _height / 2 - r2),
        Offset(_width / 2 + r2, _height / 2 + r2));

    var pointPaint = Paint()..color = Colors.green;

    pointPaint.strokeWidth = 4;

    final circlePaint = Paint();

    final gradient = const RadialGradient(
      colors: [Color.fromRGBO(0, 0, 0, 1), Color.fromRGBO(0, 0, 0, 0)],
      stops: [0, 1],
      radius: 0.5,
    ).createShader(rect);

    circlePaint.shader = gradient;

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
