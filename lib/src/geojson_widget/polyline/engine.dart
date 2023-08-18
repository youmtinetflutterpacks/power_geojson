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

Future<File> _createFile() async {
  var instance = await SharedPreferences.getInstance();
  /* var pathShared = instance.getString('geojson'); */
  var list = await getExternalDir();
  var directory = ((list == null || list.isEmpty) ? Directory('path') : list[0]).path;
  final path = "$directory/geojson.json";
  final File file = File(path);
  var exists = await file.exists();
  if (!exists) {
    var savedFile = await file.writeAsString(geojsonfile);
    await instance.setString('geojson', savedFile.path);
    return savedFile;
  }
  return file;
}

Future<List<Polyline>> _filePolylines(
  String path, {
  Map<LayerPolylineIndexes, String>? layerProperties,
  required PolylineProperties polylineLayerProperties,
  MapController? mapController,
}) async {
  final file = File(path);
  var exists = await file.exists();
  if (exists) {
    var readasstring = await file.readAsString();
    return _string(
      readasstring,
      layerMap: layerProperties,
      polylinePropertie: polylineLayerProperties,
      mapController: mapController,
    );
  } else {
    return [];
  }
}

Future<List<Polyline>> _memoryPolylines(
  Uint8List list, {
  Map<LayerPolylineIndexes, String>? layerProperties,
  required PolylineProperties polylineLayerProperties,
  MapController? mapController,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    layerMap: layerProperties,
    polylinePropertie: polylineLayerProperties,
    mapController: mapController,
  );
}

Future<List<Polyline>> _assetPolylines(
  String path, {
  Map<LayerPolylineIndexes, String>? layerProperties,
  required PolylineProperties polylineProperties,
  MapController? mapController,
}) async {
  final string = await rootBundle.loadString(path);
  await _createFile();
  return _string(
    string,
    layerMap: layerProperties,
    polylinePropertie: polylineProperties,
    mapController: mapController,
  );
}

Future<List<Polyline>> _networkPolylines(
  Uri urlString, {
  Client? client,
  Map<String, String>? headers,
  Map<LayerPolylineIndexes, String>? layerProperties,
  required PolylineProperties polylineLayerProperties,
  MapController? mapController,
}) async {
  var method = client == null ? get : client.get;
  var response = await method(urlString, headers: headers);
  var string = response.body;
  return _string(
    string,
    layerMap: layerProperties,
    polylinePropertie: polylineLayerProperties,
    mapController: mapController,
  );
}

List<Polyline> _string(
  String string, {
  Map<LayerPolylineIndexes, String>? layerMap,
  required PolylineProperties polylinePropertie,
  MapController? mapController,
}) {
  final geojson = GeoJSONFeatureCollection.fromMap(jsonDecode(string));

  List<List<Polyline>> polylines = geojson.features.map((elm) {
    if (elm != null) {
      var geometry = elm.geometry;
      var properties = elm.properties;
      var polylineProperties = PolylineProperties.fromMap(
        properties,
        layerMap,
        polylineLayerProperties: polylinePropertie,
      );
      if (geometry is GeoJSONLineString) {
        return [geometry.coordinates.toPolyline(polylineProperties: polylineProperties)];
      } else if (geometry is GeoJSONMultiLineString) {
        var coordinates = geometry.coordinates;
        return coordinates.map((e) {
          return e.toPolyline(polylineProperties: polylineProperties);
        }).toList();
      }
      var bbox = elm.bbox;
      if (bbox != null && mapController != null) {
        var latLngBounds = LatLngBounds(
          latlong2.LatLng(bbox[1], bbox[0]),
          latlong2.LatLng(bbox[3], bbox[2]),
        );
        mapController.fitBounds(latLngBounds);
      }
    }
    return [Polyline(points: [])];
  }).toList();
  return polylines.expand((element) => element).toList();
}

class PowerGeoJSONPolylines {
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    Map<LayerPolylineIndexes, String>? layerProperties,
    PolylineProperties polylineLayerProperties = const PolylineProperties(),
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    BufferOptions? bufferOptions,
  }) {
    var uriString = url.toUri();
    return FutureBuilder(
      future: _networkPolylines(
        uriString,
        headers: headers,
        client: client,
        layerProperties: layerProperties,
        polylineLayerProperties: polylineLayerProperties,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            var polylines2 = snap.data ?? [];
            return Stack(
              children: [
                PolylineLayer(
                  polylines: polylines2,
                  key: key,
                  polylineCulling: polylineCulling,
                ),
                if (bufferOptions != null)
                  PolygonLayer(
                    polygons: polylines2.toBuffers(
                      bufferOptions.buffer,
                      bufferOptions.polygonBufferProperties ?? const PolygonProperties(),
                    ),
                  ),
              ],
            );
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
    Map<LayerPolylineIndexes, String>? layerProperties,
    PolylineProperties polylineProperties = const PolylineProperties(),
    MapController? mapController,
    Key? key,
    BufferOptions? bufferOptions,
    bool polylineCulling = false,
  }) {
    return FutureBuilder(
      future: _assetPolylines(
        url,
        layerProperties: layerProperties,
        polylineProperties: polylineProperties,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            var polylines2 = snap.data ?? [];
            return Stack(
              children: [
                PolylineLayer(
                  polylines: polylines2,
                  key: key,
                  polylineCulling: polylineCulling,
                ),
                if (bufferOptions != null)
                  PolygonLayer(
                    polygons: polylines2.toBuffers(
                      bufferOptions.buffer,
                      bufferOptions.polygonBufferProperties ?? const PolygonProperties(),
                    ),
                  ),
              ],
            );
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
    Map<LayerPolylineIndexes, String>? layerProperties,
    PolylineProperties polylineLayerProperties = const PolylineProperties(),
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _filePolylines(
        path,
        layerProperties: layerProperties,
        polylineLayerProperties: polylineLayerProperties,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            var polylines2 = snap.data ?? [];
            return Stack(
              children: [
                PolylineLayer(
                  polylines: polylines2,
                  key: key,
                  polylineCulling: polylineCulling,
                ),
                if (bufferOptions != null)
                  PolygonLayer(
                    polygons: polylines2.toBuffers(
                      bufferOptions.buffer,
                      bufferOptions.polygonBufferProperties ?? const PolygonProperties(),
                    ),
                  ),
              ],
            );
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
    Map<LayerPolylineIndexes, String>? layerProperties,
    PolylineProperties polylineLayerProperties = const PolylineProperties(),
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _memoryPolylines(
        bytes,
        layerProperties: layerProperties,
        polylineLayerProperties: polylineLayerProperties,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            var polylines2 = snap.data ?? [];
            return Stack(
              children: [
                PolylineLayer(
                  polylines: polylines2,
                  key: key,
                  polylineCulling: polylineCulling,
                ),
                if (bufferOptions != null)
                  PolygonLayer(
                    polygons: polylines2.toBuffers(
                      bufferOptions.buffer,
                      bufferOptions.polygonBufferProperties ?? const PolygonProperties(),
                    ),
                  ),
              ],
            );
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
    Map<LayerPolylineIndexes, String>? layerProperties,
    PolylineProperties polylineLayerProperties = const PolylineProperties(),
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    BufferOptions? bufferOptions,
  }) {
    var string = _string(
      data,
      polylinePropertie: polylineLayerProperties,
    );
    return Stack(
      children: [
        PolylineLayer(
          polylines: string,
          key: key,
          polylineCulling: polylineCulling,
        ),
        if (bufferOptions != null)
          PolygonLayer(
            polygons: string.toBuffers(
              bufferOptions.buffer,
              bufferOptions.polygonBufferProperties ?? const PolygonProperties(),
            ),
          ),
      ],
    );
  }
}
