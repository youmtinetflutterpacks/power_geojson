import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:power_geojson/power_geojson.dart';
import 'package:power_geojson_example/lib.dart';

class NetworkGeoJSONMarker extends StatelessWidget {
  const NetworkGeoJSONMarker({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.network(
      "$url/others/network_points.json",
      markerProperties: const MarkerProperties(),
      /* builder: (context, markerProperties, mapProperties) {
        return SvgPicture.asset(
          "assets/icons/position.svg",
          color: HexColor.fromHex(mapProperties['color'], const Color(0xFFFFF238)),
        );
      }, */
      mapController: _mapController,
    );
  }
}

class NetworkGeoJSONMultiMarker extends StatelessWidget {
  const NetworkGeoJSONMultiMarker({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.network(
      "$url/others/network_pointsmultiples.json",
      markerProperties: const MarkerProperties(),
      builder: (context, markerProperties, mapProperties) {
        return SvgPicture.asset(
          "assets/icons/position.svg",
          color: HexColor.fromHex(mapProperties['color'], const Color(0xFF0FE24E)),
        );
      },
      mapController: _mapController,
    );
  }
}
