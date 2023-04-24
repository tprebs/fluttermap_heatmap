import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_heatmap/src/heatmap/bitmap.dart';

class HeatMap {
  HeatMap(this.options, this.width, this.height, this.data) {
    _initColorPalette();
  }

  final HeatMapOptions options;
  final double width;
  final double height;
  final List<DataPoint> data;

  late ByteData _palette;
  final Completer<Null> ready = Completer<Null>();

  /// Base Shapes used to represent each point
  final Map<double, ui.Image> _baseShapes = {};

  Future<Null> get onReady => ready.future;

  /// generates a 256 color palette used to colorize the heatmap
  _initColorPalette() async {
    List<double> stops = [];
    List<Color> colors = [];

    for (final entry in options.gradient.entries) {
      colors.add(entry.value);
      stops.add(entry.key);
    }

    Gradient colorGradient = LinearGradient(colors: colors, stops: stops);
    var paletteRect = const Rect.fromLTRB(0, 0, 256, 1);

    var shader = colorGradient.createShader(paletteRect,
        textDirection: TextDirection.ltr);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, paletteRect);

    Paint palettePaint = Paint()..shader = shader;
    canvas.drawRect(paletteRect, palettePaint);
    final picture = recorder.endRecording();
    var image = await picture.toImage(256, 1);
    _palette = (await image.toByteData())!;
    ready.complete();
  }

  Future<ui.Image> _getBaseShape() async {
    final radius = options.radius;
    if (_baseShapes.containsKey(radius)) {
      return _baseShapes[radius]!;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final baseCirclePainter = AltBaseCirclePainter(radius: radius);
    Size size = Size.fromRadius(radius);
    baseCirclePainter.paint(canvas, size);
    final picture = recorder.endRecording();
    final image = await picture.toImage(radius.round() * 2, radius.round() * 2);

    _baseShapes[radius] = image;
    return image;
  }

  _grayscaleHeatmap(ui.Image baseCircle) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = GrayScaleHeatMapPainter(
        baseCircle: baseCircle,
        data: data,
        minOpacity: options.minOpacity);
    painter.paint(
        canvas, Size(width + options.radius, height + options.radius));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    return image;
  }

  Future<Bitmap> _colorize(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    for (var i = 0, len = byteData!.lengthInBytes, j; i < len; i += 4) {
      j = byteData.getUint8(i + 3) * 4;
      if (i < 40) {}
      if (j != null && j > 0) {
        byteData.setUint8(i, _palette.getUint8(j));
        byteData.setUint8(i + 1, _palette.getUint8(j + 1));
        byteData.setUint8(i + 2, _palette.getUint8(j + 2));
        byteData.setUint8(i + 3, byteData.getUint8(i + 3) + 255);
      }
      if (i < 40) {}
    }

    final bitmap = Bitmap.fromHeadless(
        image.width, image.height, byteData.buffer.asUint8List());

    return bitmap;
  }

  Future<Uint8List> generate() async {
    await ready.future;
    // generate shape to be used for all points on the heatmap
    final baseShape = await _getBaseShape();

    final grayscale = await _grayscaleHeatmap(baseShape);

    final heatmapBytes = await _colorize(grayscale);

    return heatmapBytes.buildHeaded();
  }
}
