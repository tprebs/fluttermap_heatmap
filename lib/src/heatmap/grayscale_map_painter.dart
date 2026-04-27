import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

/// Painter for creating a grayscale intensity map by stamping the base circle
/// image at each data point. The resulting image is later colorized via palette.
class GrayScaleHeatMapPainter extends CustomPainter {
  final Image baseCircle;
  double? min;
  double? max;
  double buffer;
  final List<DataPoint> data;
  final double minOpacity;

  GrayScaleHeatMapPainter({
    required this.baseCircle,
    this.buffer = 0,
    required this.data,
    // ── FIX: was typed as dynamic `minOpacity = 0.5`, now properly typed ──
    this.minOpacity = 0.05,
    this.min,
    this.max,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (min == null || max == null) {
      min = 0;
      max = 2;
    }

    // offsets for centering the baseCircle when stamping
    final yOffset = baseCircle.height / 2;
    final xOffset = baseCircle.width / 2;

    for (final point in data) {
      // ── FIX: use minOpacity field instead of hardcoded value ──
      // Original code used a local `minOpacity = 0.5` parameter that
      // shadowed nothing — the value was never actually configurable.
      final alpha = math.min(math.max(point.z / max!, minOpacity), 1.0);

      canvas.drawImage(
        baseCircle,
        Offset(point.x + buffer - xOffset, point.y + buffer - yOffset),
        Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
      );
    }
  }

  @override
  bool shouldRepaint(GrayScaleHeatMapPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

/// Data point representing an x, y coordinate with an intensity value.
class DataPoint {
  double x;
  double y;
  double z;

  DataPoint(this.x, this.y, this.z);

  factory DataPoint.fromOffset(Offset offset) {
    return DataPoint(offset.dx, offset.dy, 1);
  }

  void merge(double x, double y, double intensity) {
    this.x = (x * intensity + this.x * z) / (intensity + z);
    this.y = (y * intensity + this.y * z) / (intensity + z);
    z = z + intensity;
  }
}
