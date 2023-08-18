import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:power_geojson/power_geojson.dart';

class AssetGeoJSONMarkerExample1 extends StatelessWidget {
  const AssetGeoJSONMarkerExample1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.asset(
      'assets/geojsons/assets_multipoints.geojson',
      bufferOptions: BufferOptions(
        buffer: 100,
        buffersOnly: false,
        polygonBufferProperties: const PolygonProperties(
          fillColor: Color(0xFF2BEB04),
        ),
      ),
      layerBufferProperties: {
        LayerPolygonIndexes.fillColor: 'color',
        LayerPolygonIndexes.label: 'color',
      },
      markerProperties: MarkerProperties(
        builder: (contexte) {
          return SvgPicture.asset(
            "assets/icons/position.svg",
            color: const Color(0xFF72077C),
          );
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
      'assets/geojsons/assets_multipoints.geojson',
      bufferOptions: BufferOptions(
        buffer: 400,
        polygonBufferProperties: const PolygonProperties(isFilled: false),
      ),
      layerBufferProperties: {
        LayerPolygonIndexes.fillColor: 'color',
      },
      markerProperties: MarkerProperties(
        anchorPos: AnchorPos.exactly(Anchor(0, 0)),
        builder: (contexte) {
          return SvgPicture.asset(
            "assets/icons/position.svg",
            color: const Color(0xFFFFF238),
          );
        },
      ),
    );
  }
}
