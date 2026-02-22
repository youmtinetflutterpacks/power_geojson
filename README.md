<div align="center">

# Flutter power_geojson

[![pub package](https://img.shields.io/pub/v/power_geojson.svg)](https://pub.dev/packages/power_geojson)
[![pub likes](https://img.shields.io/pub/likes/power_geojson.svg)](https://pub.dev/packages/power_geojson/score)
[![pub points](https://img.shields.io/pub/points/power_geojson.svg?color=blue)](https://pub.dev/packages/power_geojson/score)
[![platform](https://img.shields.io/badge/platform-flutter-blue)](https://flutter.dev)

[![GitHub stars](https://img.shields.io/github/stars/ymrabti/power_geojson.svg?style=flat&logo=github&colorB=&label=Stars)](https://github.com/ymrabti/power_geojson/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/ymrabti/power_geojson.svg?style=flat&logo=github&colorB=&label=Issues)](https://github.com/ymrabti/power_geojson/issues)
[![GitHub license](https://img.shields.io/github/license/ymrabti/power_geojson.svg?style=flat&logo=github&colorB=&label=License)](https://github.com/ymrabti/power_geojson/blob/main/LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/ymrabti/power_geojson.svg?style=flat&logo=github&colorB=&label=Last%20Commit)](https://github.com/ymrabti/power_geojson/commits/main)


[![Build status](https://github.com/ymrabti/power_geojson/workflows/Publish%20to%20pub.dev/badge.svg?style=flat&logo=github&colorB=&label=Build)](https://github.com/youmtinetflutterpacks/power_geojson)


</div>
Render GeoJSON (and Esri JSON) FeatureCollections on top of `flutter_map` with one-liners for markers, polygons, and polylines. Includes clustering, fallbacks, property-driven styling, and a tiny JSON helper for DateTime/Enum-safe serialization.

## Highlights

- Markers, polygons, and polylines driven directly from GeoJSON/Esri JSON.
- Load from network, assets, files, memory (`Uint8List`), or raw strings.
- Built-in marker clustering via `PowerMarkerClusterOptions` and HTTP fallbacks.
- Property-based styling through `MarkerProperties`, `PolygonProperties`, and `PolylineProperties`.
- PowerJSON helper for safe JSON string building (DateTime, Enum, TimeOfDay).

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
    power_geojson: ^3.38.9
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:power_geojson/power_geojson.dart';

class GeoMap extends StatelessWidget {
    const GeoMap({super.key});

    @override
    Widget build(BuildContext context) {
        return FlutterMap(
            options: const MapOptions(
                initialCenter: LatLng(33.59, -7.62),
                initialZoom: 11,
            ),
            children: [
                TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.power_geojson_example',
                ),
                PowerGeoJSONPolygons.asset(
                    'assets/polygons.geojson',
                    polygonProperties: PolygonProperties(
                        color: Colors.blue.withOpacity(0.2),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 1.5,
                    ),
                ),
                PowerGeoJSONPolylines.network(
                    'https://example.com/lines.geojson',
                    polylineProperties: const PolylineProperties(
                        color: Colors.orange,
                        strokeWidth: 3,
                    ),
                    fallback: (status) => Text('Network error: $status'),
                ),
                PowerGeoJSONMarkers.network(
                    'https://example.com/points.geojson',
                    markerProperties: const MarkerProperties(height: 40, width: 40),
                    powerClusterOptions: PowerMarkerClusterOptions(
                        maxClusterRadius: 40,
                        builder: (context, markers) => const Icon(
                            Icons.location_on,
                            color: Colors.red,
                        ),
                    ),
                ),
            ],
        );
    }
}
```

## Pick a data source

- **Asset**: `PowerGeoJSONPolygons.asset('assets/polygons.geojson')`
- **Network with fallback**: `PowerGeoJSONPolylines.network(url, fallback: (status) => Text('Status $status'))`
- **File**: `PowerGeoJSONMarkers.file('/tmp/points.geojson', markerProperties: MarkerProperties(height: 32, width: 32))`
- **Memory/String**: `PowerGeoJSONPolygons.memory(bytes)` or `PowerGeoJSONPolylines.string(jsonString)`

## PowerJSON quick helper

```dart
final jsonText = PowerJSON({
    'id': 7,
    'timestamp': DateTime.now(),
    'role': UserRole.admin,
    'tags': ['geo', 'power'],
}).toText();
```

## Documentation

Full API docs live on [pub.dev](https://pub.dev/packages/power_geojson).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for recent updates.

## Issues and contributions

- [GitHub repository](https://github.com/youmtinet-flutter-packs/power_geojson)
- [GitLab repository](https://gitlab.com/flutter381/power_geojson)
- [BitBucket repository](https://bitbucket.org/youmti/power_geojson)

Contributions are welcome!

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE).

## 🔗 More Packages

- [PopupMenu2](https://pub.dev/packages/popup_menu_2)
- [Flutter Azimuth](https://pub.dev/packages/flutter_azimuth)
- [Map Contextual Menu](https://pub.dev/packages/longpress_popup)
- [Simple Logger](https://pub.dev/packages/console_tools)

---

## 👨‍💻 Developer Card

<div align="center">
    <img src="https://avatars.githubusercontent.com/u/47449165?v=4" alt="Younes M'rabti avatar" width="120" height="120" style="border-radius: 50%;" />

### Younes M'rabti

📧 Email: [admin@youmti.net](mailto:admin@youmti.net)  
🌐 Website: [youmti.net](https://www.youmti.net/)  
💼 LinkedIn: [younesmrabti1996](https://www.linkedin.com/in/younesmrabti1996/)
</div>
