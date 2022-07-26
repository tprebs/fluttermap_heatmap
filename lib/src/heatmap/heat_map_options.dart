import 'package:flutter/material.dart';

class HeatMapOptions{

  static final Map<double, MaterialColor> defaultGradient = { 0.25: Colors.blue, 0.55: Colors.green, 0.85: Colors.yellow, 1.0: Colors.red};

  /// Default radius.
  /// Color gradient used for the heat map
  /// the minimum opacity used when calculating the heatmap of an area. accepts a number
  /// between 0 and 1.
  double radius = 40;
  Map<double, MaterialColor> gradient;
  double minOpacity = 0.3;

  HeatMapOptions({this.radius = 40, this.minOpacity, Map<double, MaterialColor> gradient}):
      gradient = gradient ?? defaultGradient;

}

class HeatMapDataPoint{

  HeatMapDataPoint(this.x, this.y, {this.intensity = 1});

  /// x coordinate of the [HeatMapDataPoint]
  double x;

  /// y coordinate of the [HeatMapDataPoint]
  double y;

  /// intensity of the [HeatMapDataPoint] defaulting to 1
  double intensity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HeatMapDataPoint &&
              runtimeType == other.runtimeType &&
              x == other.x &&
              y == other.y &&
              intensity == other.intensity;

  @override
  int get hashCode =>
      hashValues(x,y,intensity);

  void merge(double x,double y, double intensity){
    this.x = (x*intensity + this.x*this.intensity) / intensity + this.intensity;
    this.y = (y*intensity + this.y*this.intensity) / intensity + this.intensity;
    this.intensity +=intensity;
  }

}