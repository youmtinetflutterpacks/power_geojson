import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:power_geojson/power_geojson.dart';

class AssetGeoJSONMarkerPoints extends StatelessWidget {
  const AssetGeoJSONMarkerPoints({Key? key, this.mapController}) : super(key: key);
  final MapController? mapController;
  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.asset(
      'assets/geojsons/assets_points.geojson',
      bufferOptions: BufferOptions(
        buffer: 600,
        buffersOnly: false,
        polygonBufferProperties: const PolygonProperties(
          fillColor: Color(0xFF2BEB04),
          isFilled: true,
          layerProperties: {
            LayerPolygonIndexes.fillColor: 'color',
            LayerPolygonIndexes.label: 'color',
          },
        ),
      ),
      markerProperties: const MarkerProperties(),
      builder: (markerProps, props) {
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
  const AssetGeoJSONMarkerMultiPoints({Key? key, this.mapController}) : super(key: key);
  final MapController? mapController;
  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.asset(
      'assets/geojsons/assets_pointsmultiples.geojson',
      bufferOptions: BufferOptions(
        buffer: 400,
        polygonBufferProperties: const PolygonProperties(
          isFilled: true,
          layerProperties: {
            LayerPolygonIndexes.fillColor: 'color',
          },
        ),
      ),
      markerProperties: MarkerProperties(
        anchorPos: AnchorPos.exactly(Anchor(0, 0)),
      ),
      builder: (markerProps, props) {
        return SvgPicture.asset(
          "assets/icons/position.svg",
          color: const Color(0xff73EF28),
        );
      },
    );
  }
}
