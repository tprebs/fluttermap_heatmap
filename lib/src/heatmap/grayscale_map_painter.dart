import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

/// Painter for creating a grayscale version of the heatmap by painting the base image
/// for each provided data point.
class GrayScaleHeatMapPainter extends CustomPainter {
  double minOpacity = 0.3;
  final Image baseCircle;
  double min;
  double max;
  double buffer;
  final List<DataPoint> data;

  GrayScaleHeatMapPainter(
      {this.baseCircle, this.buffer = 0, this.data, minOpacity = 0.5, this.min, this.max});

  @override
  void paint(Canvas canvas, Size size) {
    if (min == null || max == null) {
      min = 0;
      max = 2;

    }

    var pointPaint = Paint()..color = Colors.green;

    pointPaint.strokeWidth = 4;

    final paint = Paint()..color = const Color.fromRGBO(0, 0, 0, 1);

    for (final point in data) {
      final alpha = math.min(math.max(point.z / max, minOpacity ?? 0.05), 1.0);

      paint.color = Color.fromRGBO(0, 0, 0, alpha);

      canvas.drawImage(
          baseCircle, Offset(point.x + buffer, point.y + buffer), paint);
    }

  }

  @override
  bool shouldRepaint(GrayScaleHeatMapPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

/// data point representing an x, y coordinate with an intensity
class DataPoint {
  double x;
  double y;
  double z;

  DataPoint(this.x, this.y, this.z);

  factory DataPoint.fromOffset(Offset offset) {
    return DataPoint(offset.dx, offset.dy, null);
  }

  void merge(double x, double y, double intensity) {
    this.x = (x * intensity + this.x * z) / (intensity + z);
    this.y = (y * intensity + this.y * z) / (intensity + z);
    z += intensity;
  }
}
