import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:power_geojson/power_geojson.dart';
export 'properties.dart';

Future<List<int>> loadAssetImage() async {
  final ByteData data =
      await rootBundle.load('packages/power_geojson/icons/drop-pin.png');
  final List<int> bytes = data.buffer.asUint8List();
  return bytes;
}

Widget _defaultMarkerBuilder(BuildContext context,
    MarkerProperties markerProperties, Map<String, dynamic>? properties) {
  return FutureBuilder<List<int>>(
      future: loadAssetImage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var uint8list = Uint8List.fromList(snapshot.data!);
          return Image(
            image: MemoryImage(uint8list),
            height: markerProperties.height,
            width: markerProperties.width,
          );
        } else {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
      });
}

Future<Widget> _fileMarkers(
  String path, {
  required MarkerProperties markerLayerProperties,
  required Widget Function(BuildContext context,
          MarkerProperties markerProperties, Map<String, dynamic>? map)?
      builder,
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
  required Widget Function(BuildContext context,
          MarkerProperties markerProperties, Map<String, dynamic>? map)?
      builder,
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
  required Widget Function(BuildContext context,
          MarkerProperties markerProperties, Map<String, dynamic>? map)?
      builder,
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
  required Widget Function(BuildContext context,
          MarkerProperties markerProperties, Map<String, dynamic>? map)?
      builder,
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
  Widget Function(BuildContext context, MarkerProperties markerProperties,
          Map<String, dynamic>? map)?
      builder,
  required MarkerProperties markerPropertie,
  // others
  MapController? mapController,
}) {
  final geojson = PowerGeoJSONFeatureCollection.fromJson(string);

  var markers = geojson.geoJSONPoints.map(
    (e) {
      return e.geometry.coordinates.toMarker(
        markerProperties:
            MarkerProperties.fromMap(e.properties, markerPropertie),
        builder: (BuildContext context) => (builder ?? _defaultMarkerBuilder)(
            context, markerPropertie, e.properties),
      );
    },
  ).toList();

  List<List<double>?> bbox = geojson.geoJSONPoints.map((e) => e.bbox).toList();
  zoomTo(bbox, mapController);

  Marker firstMarker = markers.first;
  return MarkerLayer(
    markers: markers,
    rotate: firstMarker.rotate ?? false,
    rotateAlignment: firstMarker.rotateAlignment,
    rotateOrigin: firstMarker.rotateOrigin,
    anchorPos: firstMarker.anchorPos,
    key: key,
  );
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
    Widget Function(BuildContext context, MarkerProperties markerProperties,
            Map<String, dynamic>? map)?
        builder,
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
    Widget Function(BuildContext context, MarkerProperties markerProperties,
            Map<String, dynamic>? map)?
        builder,
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
    Widget Function(BuildContext context, MarkerProperties markerProperties,
            Map<String, dynamic>? map)?
        builder,
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
    Widget Function(BuildContext context, MarkerProperties markerProperties,
            Map<String, dynamic>? map)?
        builder,
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
    Widget Function(BuildContext context, MarkerProperties markerProperties,
            Map<String, dynamic>? properties)?
        builder,
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
