
import 'package:flutter/material.dart' hide Image;

@Deprecated("use AltBaseCirclePainter instead")
class BaseCirclePainter extends CustomPainter {
  final double radius;
  final double? blurFactor;

  BaseCirclePainter({required this.radius, this.blurFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final _width = size.width;
    final _height = size.height;

    var pointPaint = Paint()..color = Colors.green;

    pointPaint.strokeWidth = 4;

    final circlePaint = Paint();
    final rect = Rect.fromCircle(
        center: Offset(_width / 2, _height / 2), radius: radius);

    // create radial gradient
    final gradient = const RadialGradient(
            colors: [Color.fromRGBO(0, 0, 0, 1), Color.fromRGBO(0, 0, 0, 0)],
            stops: [0, 1],
            radius: 0.5,
            focalRadius: 0.85)
        .createShader(rect);

    circlePaint.shader = gradient;

    canvas.drawCircle(rect.center, radius, circlePaint);
    canvas.drawCircle(rect.center, radius, circlePaint);
  }

  @override
  bool shouldRepaint(BaseCirclePainter oldDelegate) {
    return false;
  }
}
