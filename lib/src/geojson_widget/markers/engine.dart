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

Widget _defaultMarkerBuilder(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> properties) {
  return Image.asset(
    'assets/icons/drop-pin.png',
    height: markerProperties.height,
    width: markerProperties.width,
  );
}

Future<Widget> _fileMarkers(
  String path, {
  required MarkerProperties markerLayerProperties,
  required Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> mapProperties)? builder,
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
    );
  } else {
    return const SizedBox();
  }
}

Future<Widget> _memoryMarkers(
  Uint8List list, {
  required MarkerProperties markerLayerProperties,
  required Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> mapProperties)? builder,
  MapController? mapController,
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
  );
}

Future<Widget> _assetMarkers(
  String path, {
  required MarkerProperties markerProperties,
  MapController? mapController,
  required Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> mapProperties)? builder,
  Key? key,
}) async {
  final string = await rootBundle.loadString(path);
  return _string(
    string,
    markerPropertie: markerProperties,
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
  required Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> mapProperties)? builder,
  MapController? mapController,
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
  );
}

Widget _string(
  String string, {
  Key? key,
  //marker props
  Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> mapProperties)? builder,
  required MarkerProperties markerPropertie,
  // others
  MapController? mapController,
}) {
  final geojson = GeoJSONFeatureCollection.fromMap(jsonDecode(string));

  var features = geojson.features;
  Iterable<List<Marker>> markers = features.map((GeoJSONFeature? feature) {
    List<Marker> listMarkers = [];
    if (feature != null) {
      var geometry = feature.geometry;
      var properties = feature.properties;

      MarkerProperties markerPropsFromMap = MarkerProperties.fromMap(properties, markerPropertie);

      if (geometry is GeoJSONPoint) {
        listMarkers = [
          geometry.coordinates.toMarker(
            markerProperties: markerPropsFromMap,
            builder: (BuildContext context) => (builder ?? _defaultMarkerBuilder)(context, markerPropertie, properties ?? {}),
          )
        ];
      } else if (geometry is GeoJSONMultiPoint) {
        var coordinates = geometry.coordinates;
        listMarkers = coordinates
            .map(
              (e) => e.toMarker(
                markerProperties: markerPropsFromMap,
                builder: (BuildContext context) => (builder ?? _defaultMarkerBuilder)(context, markerPropertie, properties ?? {}),
              ),
            )
            .toList();
      }
    }
    zoomTo(features, mapController);

    return listMarkers;
  });

  return Stack(
    children: markers.map(
      (e) {
        Marker firstMarker = e.first;
        return MarkerLayer(
          rotate: firstMarker.rotate ?? false,
          rotateAlignment: firstMarker.rotateAlignment,
          rotateOrigin: firstMarker.rotateOrigin,
          markers: e,
          anchorPos: firstMarker.anchorPos,
          key: key,
        );
      },
    ).toList(),
  );
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
  /// Fetches markers from a network source.
  ///
  /// [polygonProperties] is a map containing properties to customize the appearance of markers.
  /// [layerProperties] specifies the layer options for rendering the markers.
  ///
  /// Returns a [Widget] representing the fetched markers.
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> mapProperties)? builder,
    required MarkerProperties markerProperties,
    MapController? mapController,
    Key? key,
  }) {
    var uriString = url.toUri();
    return FutureBuilder(
      future: _networkMarkers(
        uriString,
        headers: headers,
        client: client,
        markerLayerProperties: markerProperties,
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
    MapController? mapController,
    Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> mapProperties)? builder,
    Key? key,
  }) {
    return FutureBuilder(
      future: _assetMarkers(
        url,
        markerProperties: markerProperties,
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
    Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> mapProperties)? builder,
  }) {
    return FutureBuilder(
      future: _fileMarkers(
        path,
        markerLayerProperties: markerProperties,
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

  static Widget memory(
    Uint8List bytes, {
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> mapProperties)? builder,
  }) {
    return FutureBuilder(
      future: _memoryMarkers(
        bytes,
        markerLayerProperties: markerLayerProperties,
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

  static Widget string(
    String data, {
    required MarkerProperties markerProperties,
    MapController? mapController,
    Key? key,
    Widget Function(BuildContext context, MarkerProperties markerProperties, Map<String, dynamic> properties)? builder,
  }) {
    return _string(
      data,
      markerPropertie: markerProperties,
      key: key,
      builder: builder,
      mapController: mapController,
    );
  }
}
