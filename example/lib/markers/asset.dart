import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:power_geojson/power_geojson.dart';

class AssetGeoJSONMarker extends StatelessWidget {
  const AssetGeoJSONMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.asset(
      'assets/multipoints-assets.geojson',
      bufferOptions: BufferOptions(
        buffer: 150,
        buffersOnly: true,
        polygonBufferProperties: const PolygonProperties(fillColor: Color(0xFF887D20)),
      ),
      markerProperties: MarkerProperties(
        builder: (p0) {
          return SvgPicture.asset("assets/icons/position.svg", color: Colors.blue);
        },
      ),
    );
  }
}

class AssetGeoJSONMarkerExample2 extends StatelessWidget {
  const AssetGeoJSONMarkerExample2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.asset(
      'assets/points-assets.geojson',
      bufferOptions: BufferOptions(
        buffer: 400,
        polygonBufferProperties: const PolygonProperties(isFilled: false),
      ),
      layerBufferProperties: {LayerPolygonIndexes.fillColor: 'color'},
      markerProperties: MarkerProperties(
        builder: (p0) {
          return SvgPicture.asset(
            "assets/icons/position.svg",
            color: const Color(0xFFFFF238),
          );
        },
      ),
    );
  }
}
