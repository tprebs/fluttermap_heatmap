[![Pub.dev](https://img.shields.io/pub/v/flutter_map_heatmap.svg?label=Latest+Version)](https://pub.dev/packages/flutter_map_heatmap)

# Flutter Map Heatmap plugin

A Simple heatmap plugin written for for [flutter_map](https://github.com/fleaflet/flutter_map) package.

## example

![](https://github.com/tprebs/fluttermap_heatmap/blob/main/images/example.png)

A full example can be found under the example project.

## Usage

Add [`flutter_map`](https://github.com/fleaflet/flutter_map) and `flutter_map_heatmap` to your pubspec:

```yaml
dependencies:
  flutter_map: ^6.0.0
  flutter_map_heatmap: any # or the latest version on Pub
  latlong2: ^0.9.0
```

Flutter heatmaps is implemented as a tile provider. 

Add it in your FlutterMap and configure it using `HeatMapOptions`.

```dart
  Widget build(BuildContext context) {
    return FlutterMap(
      options: new MapOptions(initialCenter: new LatLng(57.8827, -6.0400), initialZoom: 8.0),
      children: [
        TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
        if (data.isNotEmpty) HeatMapLayer(
          heatMapDataSource: InMemoryHeatMapDataSource(data: data),
          heatMapOptions: HeatMapOptions(gradient: this.gradients[this.index],
          minOpacity: 0.1),
          reset: _rebuildStream.stream,
        )
      ],
    );
  }
```

See the [`full example`](example/lib/main.dart)

`InMemoryHeatMapDataSource` is provided out of the box but its easy to implement your own datasource 
provider by implementing `HeatMapDataSource`

## TODO
- [ ] complete GriddedHeatMapDataSource for gridding the data
- [ ] improve heatmaps at lower zoom levels by scaling the radius used during painting.
