import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:power_geojson/power_geojson.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'properties.dart';
export 'create_circle.dart';

Future<File> _createFile() async {
  var instance = await SharedPreferences.getInstance();
  /* var pathShared = instance.getString('geojson'); */
  var list = await getExternalDir();
  var directory = ((list == null || list.isEmpty) ? Directory('path') : list[0]).path;
  final path = "$directory/asset-markers.json";
  final File file = File(path);
  var exists = await file.exists();
  if (!exists) {
    var savedFile = await file.writeAsString(geojsonfile);
    await instance.setString('geojson', savedFile.path);
    return savedFile;
  }
  return file;
}

Future<Widget> _fileMarkers(
  String path, {
  required MarkerProperties markerLayerProperties,
  Map<LayerPolygonIndexes, String>? layerBufferProperties,
  BufferOptions? bufferOptions,
  MapController? mapController,
  Map<LayerMarkerIndexes, String>? layerMarkerProperties,
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
      bufferOptions: bufferOptions,
      layerBufferProperties: layerBufferProperties,
      layerMarkerProperties: layerMarkerProperties,
    );
  } else {
    return const SizedBox();
  }
}

Future<Widget> _memoryMarkers(
  Uint8List list, {
  Map<LayerPolygonIndexes, String>? layerProperties,
  required MarkerProperties markerLayerProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Map<LayerMarkerIndexes, String>? layerMarkerProperties,
  Key? key,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    markerPropertie: markerLayerProperties,
    mapController: mapController,
    key: key,
    bufferOptions: bufferOptions,
    layerBufferProperties: layerProperties,
    layerMarkerProperties: layerMarkerProperties,
  );
}

Future<Widget> _assetMarkers(
  String path, {
  Map<LayerPolygonIndexes, String>? layerProperties,
  required MarkerProperties markerProperties,
  MapController? mapController,
  Map<LayerMarkerIndexes, String>? layerMarkerProperties,
  BufferOptions? bufferOptions,
  Key? key,
}) async {
  final string = await rootBundle.loadString(path);
  await _createFile();
  return _string(
    string,
    markerPropertie: markerProperties,
    mapController: mapController,
    key: key,
    bufferOptions: bufferOptions,
    layerMarkerProperties: layerMarkerProperties,
    layerBufferProperties: layerProperties,
  );
}

Future<Widget> _networkMarkers(
  Uri urlString, {
  required MarkerProperties markerLayerProperties,
  Key? key,
  Client? client,
  Map<String, String>? headers,
  Map<LayerPolygonIndexes, String>? layerProperties,
  Map<LayerMarkerIndexes, String>? layerMarkerProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
}) async {
  var method = client == null ? get : client.get;
  var response = await method(urlString, headers: headers);
  var string = response.body;
  return _string(
    string,
    markerPropertie: markerLayerProperties,
    layerMarkerProperties: layerMarkerProperties,
    mapController: mapController,
    key: key,
    bufferOptions: bufferOptions,
    layerBufferProperties: layerProperties,
  );
}

class CercleMarker {
  CircleLayer circleLayer;
  List<Marker> markers;
  CercleMarker({required this.circleLayer, required this.markers});
}

Widget _string(
  String string, {
  Key? key,
  //marker props
  required MarkerProperties markerPropertie,
  Map<LayerMarkerIndexes, String>? layerMarkerProperties,
  // buffer props
  Map<LayerPolygonIndexes, String>? layerBufferProperties,
  BufferOptions? bufferOptions,
  // others
  MapController? mapController,
}) {
  final geojson = GeoJSONFeatureCollection.fromMap(jsonDecode(string));

  var features = geojson.features;
//   List<CercleMarker> markers = List.generate(features.length, (int index) );
  Iterable<CercleMarker> markers = features.map((GeoJSONFeature? feature) {
    List<Marker> listMarkers = [];
    const PolygonProperties polygonDefault = PolygonProperties();
    PolygonProperties polygonProperties = polygonDefault;
    if (feature != null) {
      var geometry = feature.geometry;
      var props = feature.properties;
      var markerPropsFromMap = MarkerProperties.fromMap(props, layerMarkerProperties, markerPropertie);
      if (bufferOptions != null && bufferOptions.polygonBufferProperties != null) {
        var polygonBufferProperties = bufferOptions.polygonBufferProperties;
        if (polygonBufferProperties != null) {
          polygonProperties = polygonBufferProperties;
        }
      }
      polygonProperties = PolygonProperties.fromMap(props, layerBufferProperties, polygonLayerProperties: polygonProperties);

      zoomTo(feature, mapController);
      if (geometry is GeoJSONPoint) {
        listMarkers = [geometry.coordinates.toMarker(markerProperties: markerPropsFromMap)];
      } else if (geometry is GeoJSONMultiPoint) {
        var coordinates = geometry.coordinates;
        listMarkers = coordinates.map((e) => e.toMarker(markerProperties: markerPropsFromMap)).toList();
      }
    } else {
      listMarkers = ifElmNull;
    }

    return CercleMarker(
      circleLayer: CircleLayer(
        circles: listMarkers.toBuffers(
          bufferOptions != null ? bufferOptions.buffer : 0,
          polygonProperties,
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

List<Marker> get ifElmNull {
  return [
    Marker(
      point: const latlong2.LatLng(0, 0),
      builder: (BuildContext context) {
        return const SizedBox();
      },
    ),
  ];
}

void zoomTo(GeoJSONFeature elm, MapController? mapController) {
  var bbox = elm.bbox;
  if (bbox != null && mapController != null) {
    var latLngBounds = LatLngBounds(
      latlong2.LatLng(bbox[1], bbox[0]),
      latlong2.LatLng(bbox[3], bbox[2]),
    );
    mapController.fitBounds(latLngBounds);
  }
}

//format('#{:06%1%2%3}',rand(0,255),rand(0,255),rand(0,255))
class PowerGeoJSONMarkers {
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    Map<LayerMarkerIndexes, String>? layerMarkerProperties,
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
        layerProperties: layerBufferProperties,
        markerLayerProperties: markerLayerProperties,
        layerMarkerProperties: layerMarkerProperties,
        mapController: mapController,
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

  static Widget asset(
    String url, {
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    required MarkerProperties markerProperties,
    MapController? mapController,
    BufferOptions? bufferOptions,
    Key? key,
    Map<LayerMarkerIndexes, String>? layerMarkerProperties,
  }) {
    return FutureBuilder(
      future: _assetMarkers(
        url,
        layerProperties: layerBufferProperties,
        markerProperties: markerProperties,
        mapController: mapController,
        bufferOptions: bufferOptions,
        key: key,
        layerMarkerProperties: layerMarkerProperties,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            // Map<LayerPolygonIndexes, String> layerProps = layerBufferProperties ?? {LayerPolygonIndexes.fillColor:"color"};
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

// The argument type 'Map<LayerPolygonIndexes, String>?' can't be assigned to
//the parameter type 'Map<LayerPolygonIndexes, String>?'
  static Widget file(
    String path, {
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    BufferOptions? bufferOptions,
    Map<LayerMarkerIndexes, String>? layerMarkerProperties,
  }) {
    return FutureBuilder(
      future: _fileMarkers(
        path,
        layerBufferProperties: layerBufferProperties,
        markerLayerProperties: markerLayerProperties,
        mapController: mapController,
        bufferOptions: bufferOptions,
        key: key,
        layerMarkerProperties: layerMarkerProperties,
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
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    BufferOptions? bufferOptions,
    Map<LayerMarkerIndexes, String>? layerMarkerProperties,
  }) {
    return FutureBuilder(
      future: _memoryMarkers(
        bytes,
        layerProperties: layerBufferProperties,
        markerLayerProperties: markerLayerProperties,
        mapController: mapController,
        bufferOptions: bufferOptions,
        key: key,
        layerMarkerProperties: layerMarkerProperties,
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
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    Map<LayerMarkerIndexes, String>? layerMarkerProperties,
    BufferOptions? bufferOptions,
  }) {
    return _string(
      data,
      markerPropertie: markerLayerProperties,
      key: key,
      bufferOptions: bufferOptions,
      layerBufferProperties: layerBufferProperties,
      layerMarkerProperties: layerMarkerProperties,
    );
  }
}
