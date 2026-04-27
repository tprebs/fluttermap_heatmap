import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'transparent.dart';

class HeatMap {
  HeatMap(this.options, this.width, this.height, this.data) {
    _initColorPalette();
  }

  final HeatMapOptions options;
  final int width;
  final int height;
  final List<DataPoint> data;

  late ByteData _palette;
  final Completer<void> ready = Completer<void>();

  final Map<double, ui.Image> _baseShapes = {};

  Future<void> get onReady => ready.future;

  /// Generates a 256-color palette from the gradient options.
  /// Now accepts Map<double, Color> (any Color, not just MaterialColor).
  _initColorPalette() async {
    final entries = options.gradient.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final List<Color> colors = entries.map((e) => e.value).toList();
    final List<double> stops = entries.map((e) => e.key).toList();

    final colorGradient = LinearGradient(colors: colors, stops: stops);
    const paletteRect = Rect.fromLTRB(0, 0, 256, 1);

    final shader =
        colorGradient.createShader(paletteRect, textDirection: TextDirection.ltr);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, paletteRect);
    canvas.drawRect(paletteRect, Paint()..shader = shader);
    final picture = recorder.endRecording();
    final image = await picture.toImage(256, 1);
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
    final painter =
        AltBaseCirclePainter(radius: radius, blurFactor: options.blurFactor);
    painter.paint(canvas, Size.fromRadius(radius));
    final picture = recorder.endRecording();
    final image =
        await picture.toImage(radius.round() * 2, radius.round() * 2);

    _baseShapes[radius] = image;
    return image;
  }

  Future<ui.Image> _grayscaleHeatmap(ui.Image baseCircle) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final painter = GrayScaleHeatMapPainter(
      baseCircle: baseCircle,
      data: data,
      minOpacity: options.minOpacity,
    );
    painter.paint(canvas, Size(width + options.radius, height + options.radius));

    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  Future<Uint8List> _colorize(ui.Image image) async {
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final byteCount = byteData?.lengthInBytes;
    var transparentByteCount = 0;

    for (var i = 0, len = byteData!.lengthInBytes; i < len; i += 4) {
      final j = byteData.getUint8(i + 3) * 4;
      if (j > 0) {
        byteData.setUint8(i, _palette.getUint8(j));
        byteData.setUint8(i + 1, _palette.getUint8(j + 1));
        byteData.setUint8(i + 2, _palette.getUint8(j + 2));
        byteData.setUint8(i + 3, byteData.getUint8(i + 3) + 255);
      } else {
        transparentByteCount += 4;
      }
    }

    if (transparentByteCount == byteCount) {
      return kTransparentImage;
    }

    return Bitmap.fromHeadless(
      image.width,
      image.height,
      byteData.buffer.asUint8List(),
    ).buildHeaded();
  }

  Future<Uint8List> generate() async {
    await ready.future;

    if (data.isEmpty) {
      return kTransparentImage;
    }

    final baseShape = await _getBaseShape();
    final grayscale = await _grayscaleHeatmap(baseShape);
    return _colorize(grayscale);
  }
}
