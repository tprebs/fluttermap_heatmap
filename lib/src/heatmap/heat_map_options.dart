import 'package:flutter/material.dart';

class HeatMapOptions {
  static final Map<double, MaterialColor> defaultGradient = {
    0.25: Colors.blue,
    0.55: Colors.green,
    0.85: Colors.yellow,
    1.0: Colors.red
  };

  /// Opacity of the heatmap layer when displayed on a map
  double layerOpacity;

  /// Default radius size applied during the painting of each point.
  double radius;

  /// Color gradient used for the heat map
  Map<double, MaterialColor> gradient;

  /// the minimum opacity used when calculating the heatmap of an area. accepts a number
  /// between 0 and 1.
  double? minOpacity;

  /// The blur factor applied during the painting of each point. the higher the number the higher
  /// the intensity.
  /// accepts a number value between 0 and 1.
  double blurFactor;

  HeatMapOptions(
      {this.radius = 30,
      this.minOpacity = 0.3,
      double blurFactor = 0.5,
      double layerOpacity = 0.75,
      Map<double, MaterialColor>? gradient})
      : gradient = gradient ?? defaultGradient,
      layerOpacity = layerOpacity >= 0 && layerOpacity <=1 ? layerOpacity : 0.75,
      blurFactor = blurFactor >= 0 && blurFactor <=1 ? blurFactor : 0.75;
}

class HeatMapDataPoint {
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
  int get hashCode => Object.hash(x, y, intensity);

  void merge(double x, double y, double intensity) {
    this.x =
        (x * intensity + this.x * this.intensity) / intensity + this.intensity;
    this.y =
        (y * intensity + this.y * this.intensity) / intensity + this.intensity;
    this.intensity += intensity;
  }
}
