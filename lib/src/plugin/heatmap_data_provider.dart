import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';

import 'latlong.dart';


abstract class HeatMapDataSource {
  /// provides data for the given bounds and zoom level
  List<WeightedLatLng> getData(LatLngBounds bounds, double z);
}

class InMemoryHeatMapDataSource extends HeatMapDataSource {
  final List<WeightedLatLng> data;
  final LatLngBounds bounds;

  InMemoryHeatMapDataSource({required this.data})
      : bounds = LatLngBounds.fromPoints(data.map((e) => e.latLng).toList());

  ///Filters in memory data returning the data ungridded
  @override
  List<WeightedLatLng> getData(LatLngBounds bounds, double z) {
    if (bounds.isOverlapping(bounds)) {
      if (data.isEmpty) {
        return [];
      }
      return data.where((point) => bounds.contains(point.latLng)).toList();
    }
    return [];
  }
}

class GriddedHeatMapDataSource extends HeatMapDataSource {
  final List<WeightedLatLng> data;
  final LatLngBounds bounds;
  final crs = const Epsg3857();
  final double radius;

  final Map<double, List<WeightedLatLng>> _gridCache = {};

  GriddedHeatMapDataSource({required this.data, required this.radius})
      : bounds = LatLngBounds.fromPoints(data.map((e) => e.latLng).toList());

  ///Filters in memory data returning the data ungridded
  @override
  List<WeightedLatLng> getData(LatLngBounds bounds, double z) {
    if (data.isNotEmpty && bounds.isOverlapping(bounds)) {
      var griddedData = _getGriddedData(z);
      if (griddedData.isEmpty) {
        return [];
      }
      return griddedData
          .where((point) => bounds.contains(point.latLng))
          .toList();
    }
    return [];
  }

  List<WeightedLatLng> _getGriddedData(double z) {
    if (_gridCache.containsKey(z)) {
      return _gridCache[z]!;
    }
    var leftBound = crs.latLngToOffset(bounds.northWest, z);

    var rightBound = crs.latLngToOffset(bounds.southEast, z);

    var size = Rect.fromPoints(leftBound, rightBound).size;

    final cellSize = radius / 2;

    List<List<WeightedLatLng?>> grid = []..length =
        (size.height / cellSize).ceil() + 2;

    List<WeightedLatLng> griddedData = [];

    final v = 1 / math.pow(2, math.max(0, math.min(20 - 2, 12)));

    var localMin = 0.0;
    var localMax = 0.0;
    for (final point in data) {
      var globalPixel = crs.latLngToOffset(point.latLng, z);
      var pixel =
          math.Point(globalPixel.dx - leftBound.dx, globalPixel.dy - leftBound.dy);

      final x = ((pixel.x) ~/ cellSize) + 2;
      final y = ((pixel.y) ~/ cellSize) + 2;

      grid[y] = grid[y]..length = (size.height / cellSize).ceil() + 2;
      var cell = grid[y][x];

      if (cell == null) {
        grid[y][x] = WeightedLatLng(point.latLng, 1);
        cell = grid[y][x];
      } else {
        cell.merge(point.latLng.longitude, point.latLng.latitude, 1);
      }
      localMax = math.max(cell!.intensity, localMax);
      localMin = math.min(cell.intensity, localMin);
    }

    for (var i = 0, len = grid.length; i < len; i++) {
      for (var j = 0, len2 = grid[i].length; j < len2; j++) {
        var cell = grid[i][j];
        if (cell != null) {
          griddedData.add(cell);
        }
      }
    }
    _gridCache[z] = griddedData;

    return griddedData;
  }
}
