import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

class HeatMapPaint extends StatefulWidget {
  final HeatMapOptions options;
  final double width;
  final double height;
  final List<DataPoint> data;

  const HeatMapPaint(
      {super.key,
      required this.options,
      required this.width,
      required this.height,
      required this.data});

  @override
  _HeatMapPaintState createState() => _HeatMapPaintState();
}

class _HeatMapPaintState extends State<HeatMapPaint> {
  late ByteData _palette;
  late ui.Image _baseImage;
  late ui.Image _heatmapImage;
  late Uint8List _heatmap;
  final Completer<void> ready = Completer<void>();

  Future<void> get onReady => ready.future;

  @override
  initState() {
    super.initState();

    _initHeatmap();
  }

  _initColorPalette() async {
    List<double> stops = [];
    List<Color> colors = [];

    for (final entry in widget.options.gradient.entries) {
      colors.add(entry.value);
      stops.add(entry.key);
    }
    Gradient colorGradient = LinearGradient(colors: colors, stops: stops);
    var pallateRect = const Rect.fromLTRB(0, 0, 256, 1);
    var shader = colorGradient.createShader(pallateRect,
        textDirection: TextDirection.ltr);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, pallateRect);
    Paint palettePaint = Paint()..shader = shader;
    canvas.drawRect(pallateRect, palettePaint);
    final picture = recorder.endRecording();
    var image = await picture.toImage(256, 1);
    return await image.toByteData();
  }

  // initialize the palette and image
  _initHeatmap() async {
    var colorPalette = await _initColorPalette();
    final radius = widget.options.radius;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final baseCirclePainter = AltBaseCirclePainter(radius: radius);
    Size size = Size.fromRadius(radius);
    baseCirclePainter.paint(canvas, size);
    final picture = recorder.endRecording();
    final image = await picture.toImage(radius.round() * 2, radius.round() * 2);
    setState(() {
      _palette = colorPalette;
      _baseImage = image;
      ready.complete();
    });
  }

  _colorize(ui.Image baseCircle) async {
    if (ready.isCompleted) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final painter =
          GrayScaleHeatMapPainter(baseCircle: baseCircle, data: widget.data);
      painter.paint(canvas, Size(widget.width, widget.height));
      final image = await recorder
          .endRecording()
          .toImage(widget.width.toInt(), widget.height.toInt());
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);

      for (var i = 0, len = byteData!.lengthInBytes, j = 0; i < len; i += 4) {
        j = byteData.getUint8(i + 3) * 4;
        if (i < 40) {}
        if (j > 0) {
          byteData.setUint8(i, _palette.getUint8(j));
          byteData.setUint8(i + 1, _palette.getUint8(j + 1));
          byteData.setUint8(i + 2, _palette.getUint8(j + 2));
          byteData.setUint8(i + 3, byteData.getUint8(i + 3) + 255);
        }
        if (i < 40) {}
      }

      final headeredImage = await Bitmap.fromHeadless(
              image.width, image.height, byteData.buffer.asUint8List())
          .buildImage();
      final headered = Bitmap.fromHeadless(
              image.width, image.height, byteData.buffer.asUint8List())
          .buildHeaded();

      setState(() {
        _heatmapImage = headeredImage;
        _heatmap = headered;
      });
    }
  }

  @override
  void didUpdateWidget(HeatMapPaint oldWidget) {
    _colorize(_baseImage);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [Positioned(top: 0, left: 0, child: Image.memory(_heatmap))],
    );
  }
}

class HeatMapPainter extends CustomPainter {
  final ui.Image heatMapImage;

  HeatMapPainter(this.heatMapImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImage(heatMapImage, const Offset(0, 0), paint);
  }

  @override
  bool shouldRepaint(HeatMapPainter oldDelegate) {
    return true;
  }
}

class HeatMapState {
  final HeatMapOptions options;

  StreamController<ui.Image>? imageSink;

  HeatMapState(this.options) {
    imageSink = StreamController.broadcast();
  }

  void dispose() {
    imageSink?.close();
  }
}
