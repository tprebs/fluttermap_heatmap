import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';

import 'latlong.dart';

abstract class HeatMapDataSource {
  /// Provides data for the given bounds and zoom level.
  List<WeightedLatLng> getData(LatLngBounds bounds, double z);
}

class InMemoryHeatMapDataSource extends HeatMapDataSource {
  final List<WeightedLatLng> data;
  late final LatLngBounds? _bounds;

  InMemoryHeatMapDataSource({required this.data})
      : _bounds = data.isNotEmpty
            ? LatLngBounds.fromPoints(data.map((e) => e.latLng).toList())
            : null;

  @override
  List<WeightedLatLng> getData(LatLngBounds bounds, double z) {
    if (data.isEmpty || _bounds == null) return [];
    // Fixed: was incorrectly checking bounds.isOverlapping(bounds) (always true)
    if (!bounds.isOverlapping(_bounds!)) return [];
    return data.where((point) => bounds.contains(point.latLng)).toList();
  }
}

class GriddedHeatMapDataSource extends HeatMapDataSource {
  final List<WeightedLatLng> data;
  late final LatLngBounds? _bounds;
  final crs = const Epsg3857();
  final double radius;

  final Map<double, List<WeightedLatLng>> _gridCache = {};

  GriddedHeatMapDataSource({required this.data, required this.radius})
      : _bounds = data.isNotEmpty
            ? LatLngBounds.fromPoints(data.map((e) => e.latLng).toList())
            : null;

  @override
  List<WeightedLatLng> getData(LatLngBounds bounds, double z) {
    if (data.isEmpty || _bounds == null) return [];
    // Fixed: was incorrectly checking bounds.isOverlapping(bounds) (always true)
    if (!bounds.isOverlapping(_bounds!)) return [];
    final griddedData = _getGriddedData(z);
    if (griddedData.isEmpty) return [];
    return griddedData
        .where((point) => bounds.contains(point.latLng))
        .toList();
  }

  List<WeightedLatLng> _getGriddedData(double z) {
    if (_gridCache.containsKey(z)) {
      return _gridCache[z]!;
    }

    final leftBound = crs.latLngToOffset(_bounds!.northWest, z);
    final rightBound = crs.latLngToOffset(_bounds!.southEast, z);
    final size = Rect.fromPoints(leftBound, rightBound).size;

    final cellSize = radius / 2;

    List<List<WeightedLatLng?>> grid = List.filled(
      (size.height / cellSize).ceil() + 2,
      [],
      growable: true,
    );

    final List<WeightedLatLng> griddedData = [];

    for (final point in data) {
      final globalPixel = crs.latLngToOffset(point.latLng, z);
      final pixel = math.Point(
        globalPixel.dx - leftBound.dx,
        globalPixel.dy - leftBound.dy,
      );

      final x = ((pixel.x) ~/ cellSize) + 2;
      final y = ((pixel.y) ~/ cellSize) + 2;

      if (y >= grid.length) continue;
      grid[y] = List.from(grid[y])
        ..length = math.max(
          grid[y].length,
          (size.width / cellSize).ceil() + 2,
        );
      if (x >= grid[y].length) continue;

      var cell = grid[y][x];
      if (cell == null) {
        grid[y][x] = WeightedLatLng(point.latLng, 1);
      } else {
        cell.merge(point.latLng.longitude, point.latLng.latitude, 1);
      }
    }

    for (final row in grid) {
      for (final cell in row) {
        if (cell != null) griddedData.add(cell);
      }
    }

    _gridCache[z] = griddedData;
    return griddedData;
  }
}
