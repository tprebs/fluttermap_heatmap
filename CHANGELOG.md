[0.0.1] - Initial Alpha release
* Initial release after extracting into stand alone plugin

[0.0.2] - Fix reset issue
* Code clean up
* HeatMap now correctly resets after reset requested

[0.0.3] - 2023/05/08
* flutter_map v4 support
* disable zoom level 0 to avoid error. this will be fixed and re-enabled in subsequent release
* configurable layer opacity (default 75%)
* configurable blur factor
* configurable point radius

[0.0.4] - 2023/07/12
* (web) empty heatmap tiles are now transparent not black

[0.0.4+1] - 2023/07/14
* correct offset when rendering each heatmap point, centering the heatmap image on the point

[0.0.4+2] - 2023/08/02
* add tileDisplay to override default tile provider behaviour

[0.0.5] - 2023/09/12
* adds maxZoom param to override TileLayer's default

[0.0.6] - 2023/11/24
* support FlutterMap 6

[0.0.7] - 2023/12/19
* HeatMapImage - replace deprecated ImageProvider.load with ImageProvider.loadImage

[0.0.8] - 2024/12/19
* Support FlutterMap 7