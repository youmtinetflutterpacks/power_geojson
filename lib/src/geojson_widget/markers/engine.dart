import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:power_geojson/power_geojson.dart';
export 'properties.dart';
export 'create_circle.dart';

Future<Widget> _fileMarkers(
  String path, {
  required MarkerProperties markerLayerProperties,
  required Widget Function(MarkerProperties, Map<String, dynamic>) builder,
  BufferOptions? bufferOptions,
  MapController? mapController,
  Key? key,
}) async {
  final file = File(path);
  var exists = await file.exists();
  if (exists) {
    var readasstring = await file.readAsString();
    return _string(
      readasstring,
      markerPropertie: markerLayerProperties,
      mapController: mapController,
      key: key,
      builder: builder,
      bufferOptions: bufferOptions,
    );
  } else {
    return const SizedBox();
  }
}

Future<Widget> _memoryMarkers(
  Uint8List list, {
  required MarkerProperties markerLayerProperties,
  required Widget Function(MarkerProperties, Map<String, dynamic>) builder,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Key? key,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    markerPropertie: markerLayerProperties,
    mapController: mapController,
    key: key,
    builder: builder,
    bufferOptions: bufferOptions,
  );
}

Future<Widget> _assetMarkers(
  String path, {
  required MarkerProperties markerProperties,
  BufferOptions? bufferOptions,
  MapController? mapController,
  required Widget Function(MarkerProperties, Map<String, dynamic>) builder,
  Key? key,
}) async {
  final string = await rootBundle.loadString(path);
  return _string(
    string,
    markerPropertie: markerProperties,
    bufferOptions: bufferOptions,
    mapController: mapController,
    key: key,
    builder: builder,
  );
}

Future<Widget> _networkMarkers(
  Uri urlString, {
  required MarkerProperties markerLayerProperties,
  Key? key,
  Client? client,
  Map<String, String>? headers,
  required Widget Function(MarkerProperties, Map<String, dynamic>) builder,
  MapController? mapController,
  BufferOptions? bufferOptions,
}) async {
  var method = client == null ? get : client.get;
  var response = await method(urlString, headers: headers);
  var string = response.body;
  return _string(
    string,
    markerPropertie: markerLayerProperties,
    mapController: mapController,
    key: key,
    builder: builder,
    bufferOptions: bufferOptions,
  );
}

class CercleMarker {
  PolygonLayer circleLayer;
  List<Marker> markers;
  CercleMarker({required this.circleLayer, required this.markers});
}

Widget _string(
  String string, {
  Key? key,
  //marker props
  required Widget Function(MarkerProperties, Map<String, dynamic>) builder,
  required MarkerProperties markerPropertie,
  BufferOptions? bufferOptions,
  // others
  MapController? mapController,
}) {
  final geojson = GeoJSONFeatureCollection.fromMap(jsonDecode(string));

  var features = geojson.features;
  Iterable<CercleMarker> markers = features.map((GeoJSONFeature? feature) {
    List<Marker> listMarkers = [];
    PolygonProperties polygonBufferProperties = const PolygonProperties();
    if (feature != null) {
      var geometry = feature.geometry;
      var properties = feature.properties;

      MarkerProperties markerPropsFromMap = MarkerProperties.fromMap(properties, markerPropertie);
      polygonBufferProperties = PolygonProperties.fromMap(properties, getBufferProperties(bufferOptions));

      if (geometry is GeoJSONPoint) {
        listMarkers = [
          geometry.coordinates.toMarker(
            markerProperties: markerPropsFromMap,
            builder: (buildContext) => builder(markerPropertie, properties ?? {}),
          )
        ];
      } else if (geometry is GeoJSONMultiPoint) {
        var coordinates = geometry.coordinates;
        listMarkers = coordinates
            .map(
              (e) => e.toMarker(
                markerProperties: markerPropsFromMap,
                builder: (buildContext) => builder(markerPropertie, properties ?? {}),
              ),
            )
            .toList();
      }
    }
    zoomTo(features, mapController);

    return CercleMarker(
      circleLayer: PolygonLayer(
        polygons: listMarkers.toBuffers(
          bufferOptions != null ? bufferOptions.buffer : 0,
          polygonBufferProperties,
        ),
        key: key,
      ),
      markers: listMarkers,
    );
  });

  return Stack(
    children: [
      if (bufferOptions != null) ...markers.map((e) => e.circleLayer),
      if ((bufferOptions != null && !bufferOptions.buffersOnly) || bufferOptions == null)
        ...markers.map(
          (e) {
            Marker firstMarker = e.markers.first;
            return MarkerLayer(
              rotate: firstMarker.rotate ?? false,
              rotateAlignment: firstMarker.rotateAlignment,
              rotateOrigin: firstMarker.rotateOrigin,
              markers: e.markers,
              anchorPos: firstMarker.anchorPos,
              key: key,
            );
          },
        ),
    ],
  );
}

PolygonProperties getBufferProperties(BufferOptions? bufferOptions) {
  PolygonProperties polygonProperties = const PolygonProperties();
  if (bufferOptions != null && bufferOptions.polygonBufferProperties != null) {
    var polygonBufferProperties = bufferOptions.polygonBufferProperties;
    if (polygonBufferProperties != null) {
      polygonProperties = polygonBufferProperties;
    }
  }
  return polygonProperties;
}

void zoomTo(List<GeoJSONFeature?> features, MapController? mapController) {
  var atLeast = features.first;
  if (atLeast == null) return;
  if (mapController == null) return;
  var bboxFirst = atLeast.bbox;
  if (bboxFirst == null) return;
  var firstBounds = LatLngBounds.fromPoints([
    latlong2.LatLng(bboxFirst[1], bboxFirst[0]),
    latlong2.LatLng(bboxFirst[3], bboxFirst[2]),
  ]);
  var latLngBounds = features.fold<LatLngBounds>(
    firstBounds,
    (previousValue, element) {
      if (element == null) return previousValue;
      var bbox = element.bbox;
      if (bbox == null) return previousValue;
      var elementBounds = LatLngBounds.fromPoints([
        latlong2.LatLng(bbox[1], bbox[0]),
        latlong2.LatLng(bbox[3], bbox[2]),
      ]);
      previousValue.extendBounds(elementBounds);
      return previousValue;
    },
  );
  mapController.fitBounds(latLngBounds, options: const FitBoundsOptions());
}

class PowerGeoJSONMarkers {
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    required Widget Function(MarkerProperties, Map<String, dynamic>) builder,
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    BufferOptions? bufferOptions,
  }) {
    var uriString = url.toUri();
    return FutureBuilder(
      future: _networkMarkers(
        uriString,
        headers: headers,
        client: client,
        markerLayerProperties: markerLayerProperties,
        bufferOptions: bufferOptions,
        builder: builder,
        mapController: mapController,
        key: key,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

  static Widget asset(
    String url, {
    required MarkerProperties markerProperties,
    BufferOptions? bufferOptions,
    MapController? mapController,
    required Widget Function(MarkerProperties, Map<String, dynamic>) builder,
    Key? key,
  }) {
    return FutureBuilder(
      future: _assetMarkers(
        url,
        markerProperties: markerProperties,
        bufferOptions: bufferOptions,
        mapController: mapController,
        builder: builder,
        key: key,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

  static Widget file(
    String path, {
    required MarkerProperties markerProperties,
    MapController? mapController,
    Key? key,
    BufferOptions? bufferOptions,
    required Widget Function(MarkerProperties, Map<String, dynamic>) builder,
  }) {
    return FutureBuilder(
      future: _fileMarkers(
        path,
        markerLayerProperties: markerProperties,
        mapController: mapController,
        builder: builder,
        bufferOptions: bufferOptions,
        key: key,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

  static Widget memory(
    Uint8List bytes, {
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    BufferOptions? bufferOptions,
    required Widget Function(MarkerProperties, Map<String, dynamic>) builder,
  }) {
    return FutureBuilder(
      future: _memoryMarkers(
        bytes,
        markerLayerProperties: markerLayerProperties,
        mapController: mapController,
        builder: builder,
        bufferOptions: bufferOptions,
        key: key,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

  static Widget string(
    String data, {
    required MarkerProperties markerProperties,
    MapController? mapController,
    Key? key,
    required Widget Function(MarkerProperties markerProperties, Map<String, dynamic> properties) builder,
    BufferOptions? bufferOptions,
  }) {
    return _string(
      data,
      markerPropertie: markerProperties,
      key: key,
      builder: builder,
      mapController: mapController,
      bufferOptions: bufferOptions,
    );
  }
}
