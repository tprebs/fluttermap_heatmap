import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

class HeatMapPaint extends StatefulWidget {
  final HeatMapOptions options;
  final double width;
  final double height;
  final List<DataPoint> data;

  const HeatMapPaint({
    super.key,
    required this.options,
    required this.width,
    required this.height,
    required this.data,
  });

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
  void initState() {
    super.initState();
    _initHeatmap();
  }

  Future<ByteData> _initColorPalette() async {
    final entries = widget.options.gradient.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final colors = entries.map((e) => e.value).toList();
    final stops = entries.map((e) => e.key).toList();

    final colorGradient = LinearGradient(colors: colors, stops: stops);
    const paletteRect = Rect.fromLTRB(0, 0, 256, 1);
    final shader = colorGradient.createShader(paletteRect, textDirection: TextDirection.ltr);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, paletteRect);
    canvas.drawRect(paletteRect, Paint()..shader = shader);
    final image = await recorder.endRecording().toImage(256, 1);
    return (await image.toByteData())!;
  }

  Future<void> _initHeatmap() async {
    final colorPalette = await _initColorPalette();
    final radius = widget.options.radius;

    final recorder = ui.PictureRecorder();
    AltBaseCirclePainter(radius: radius).paint(Canvas(recorder), Size.fromRadius(radius));
    final image = await recorder.endRecording().toImage(radius.round() * 2, radius.round() * 2);

    setState(() {
      _palette = colorPalette;
      _baseImage = image;
      ready.complete();
    });
  }

  Future<void> _colorize(ui.Image baseCircle) async {
    if (!ready.isCompleted) return;

    final recorder = ui.PictureRecorder();
    GrayScaleHeatMapPainter(baseCircle: baseCircle, data: widget.data)
        .paint(Canvas(recorder), Size(widget.width, widget.height));
    final image = await recorder.endRecording().toImage(widget.width.toInt(), widget.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    for (var i = 0, len = byteData!.lengthInBytes; i < len; i += 4) {
      final j = byteData.getUint8(i + 3) * 4;
      if (j > 0) {
        byteData.setUint8(i, _palette.getUint8(j));
        byteData.setUint8(i + 1, _palette.getUint8(j + 1));
        byteData.setUint8(i + 2, _palette.getUint8(j + 2));
        byteData.setUint8(i + 3, byteData.getUint8(i + 3) + 255);
      }
    }

    final bitmap = Bitmap.fromHeadless(image.width, image.height, byteData.buffer.asUint8List());
    setState(() {
      _heatmapImage = (bitmap..buildHeaded()) as ui.Image;
      _heatmap = bitmap.buildHeaded();
    });
  }

  @override
  void didUpdateWidget(HeatMapPaint oldWidget) {
    _colorize(_baseImage);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [Positioned(top: 0, left: 0, child: Image.memory(_heatmap))]);
  }
}

class HeatMapPainter extends CustomPainter {
  final ui.Image heatMapImage;
  HeatMapPainter(this.heatMapImage);

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawImage(heatMapImage, Offset.zero, Paint());

  @override
  bool shouldRepaint(HeatMapPainter oldDelegate) => true;
}

class HeatMapState {
  final HeatMapOptions options;
  StreamController<ui.Image>? imageSink;

  HeatMapState(this.options) {
    imageSink = StreamController.broadcast();
  }

  void dispose() => imageSink?.close();
}
