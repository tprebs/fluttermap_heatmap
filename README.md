# Flutter Map Heatmap plugin

A Simple heatmap plugin written for for [flutter_map](https://github.com/fleaflet/flutter_map) package. This plugin has been extracted from a larger app and the configuration options are limited to what was required for that application.

## example

![](https://github.com/tprebs/fluttermap_heatmap/blob/main/images/example.png)

A full example can be found under the example project.

## Usage

Add [`flutter_map`](https://github.com/fleaflet/flutter_map) and `flutter_map_heatmap` to your pubspec:

```yaml
dependencies:
  flutter_map: 0.14.0
  flutter_map_heatmap: any # or the latest version on Pub
```

Flutter heatmaps is implemented as a tile provider. 

Add it in your FlutterMap and configure it using `HeatMapOptions`.

```dart
  Widget build(BuildContext context) {
    return FlutterMap(
      options: new MapOptions(
          center: new LatLng(57.8827, -6.0400),
          zoom: 8.0
      ),
      layers: [
        new TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        new TileLayerOptions(
            backgroundColor: Colors.transparent,
            opacity: 1,
            tileSize: 256,
            tileProvider: HeatMapTilesProvider(data,
                heatMapOptions: HeatMapOptions(
                ),
                dataSource: InMemoryHeatMapDataSource(data: data))),
      ],
    );
  }
```

`InMemoryHeatMapDataSource` is provided out of the box but its easy to implement your own datasource 
provider by implementing `HeatMapDataSource`

## TODO
- [ x ] upgrade to flutter_map
- [ ] release to pub 
- [ ] complete GriddedHeatMapDataSource for gridding the data
- [ ] improve heatmaps at lower zoom levels by scaling the radius used during painting.
- [ ] Revisit new flutter_map API as this may be implementable outside of TileLayers
