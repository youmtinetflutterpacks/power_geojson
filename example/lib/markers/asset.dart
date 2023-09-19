import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:power_geojson/power_geojson.dart';

class AssetGeoJSONMarkerPoints extends StatelessWidget {
  const AssetGeoJSONMarkerPoints({Key? key, this.mapController})
      : super(key: key);
  final MapController? mapController;
  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.asset(
      'assets/geojsons/assets_points.geojson',
      markerProperties: const MarkerProperties(),
      builder: (context, markerProps, props) {
        return Transform.rotate(
          angle: pi,
          child: SvgPicture.asset(
            "assets/icons/position.svg",
            color: const Color(0xFF72077C),
          ),
        );
      },
    );
  }
}

class AssetGeoJSONMarkerMultiPoints extends StatelessWidget {
  const AssetGeoJSONMarkerMultiPoints({Key? key, this.mapController})
      : super(key: key);
  final MapController? mapController;
  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.asset(
      'assets/geojsons/assets_pointsmultiples.geojson',
      markerProperties: MarkerProperties(
        anchorPos: AnchorPos.exactly(Anchor(0, 0)),
      ),
      /* builder: (context, markerProps, props) {
        return SvgPicture.asset(
          "assets/icons/position.svg",
          color: const Color(0xff73EF28),
        );
      }, */
    );
  }
}
