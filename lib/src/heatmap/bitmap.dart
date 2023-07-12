import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

const int bitmapPixelLength = 4;
const int rgba32HeaderSize = 122;

/// Common BitMap functions for adding bitmap header information to raw RGBA data
class Bitmap {
  Bitmap.fromHeadless(this.width, this.height, this.content);

  final int width;
  final int height;
  final Uint8List content;

  int get size => (width * height) * bitmapPixelLength;

  Bitmap cloneHeadless() {
    return Bitmap.fromHeadless(
      width,
      height,
      Uint8List.fromList(content),
    );
  }

  Future<ui.Image> buildImage() async {
    final Completer<ui.Image> imageCompleter = Completer();
    final headedContent = buildHeaded();
    ui.decodeImageFromList(headedContent, (ui.Image img) {
      imageCompleter.complete(img);
    });
    return imageCompleter.future;
  }

  Uint8List buildHeaded() {
    final header = RGBA32BitmapHeader(size, width, height)
      ..applyContent(content);
    return header.headerIntList;
  }
}

class RGBA32BitmapHeader {
  late Uint8List headerIntList;

  RGBA32BitmapHeader(this.contentSize, int width, int height) {
    headerIntList = Uint8List(fileLength);

    final ByteData bd = headerIntList.buffer.asByteData();
    bd.setUint8(0x0, 0x42);
    bd.setUint8(0x1, 0x4d);
    bd.setInt32(0x2, fileLength, Endian.little);
    bd.setInt32(0xa, rgba32HeaderSize, Endian.little);
    bd.setUint32(0xe, 108, Endian.little);
    bd.setUint32(0x12, width, Endian.little);
    bd.setUint32(0x16, -height, Endian.little);
    bd.setUint16(0x1a, 1, Endian.little);
    bd.setUint32(0x1c, 32, Endian.little); // pixel size
    bd.setUint32(0x1e, 3, Endian.little); //BI_BITFIELDS
    bd.setUint32(0x22, contentSize, Endian.little);
    bd.setUint32(0x36, 0x000000ff, Endian.little);
    bd.setUint32(0x3a, 0x0000ff00, Endian.little);
    bd.setUint32(0x3e, 0x00ff0000, Endian.little);
    bd.setUint32(0x42, 0xff000000, Endian.little);
  }

  int contentSize;

  void applyContent(Uint8List contentIntList) {
    headerIntList.setRange(
      rgba32HeaderSize,
      fileLength,
      contentIntList,
    );
  }

  int get fileLength => contentSize + rgba32HeaderSize;
}
