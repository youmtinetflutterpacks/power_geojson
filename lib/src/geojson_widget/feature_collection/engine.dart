import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:power_geojson/power_geojson.dart';
export 'properties.dart';

/// A default file load builder that reads the contents of a file from the specified [path].
///
/// This function is used for loading data from local files.
///
/// - [path]: The path to the file to be read.
///
/// Returns a [Future] that completes with the contents of the file as a string.
Future<String> _defaultFileLoadBuilder(String path) async {
  final file = File(path);
  var readAsString = await file.readAsString();
  return readAsString;
}

/// A default network data loader that retrieves data from the specified [uri] using an optional [client] and [headers].
///
/// This function is used for making HTTP GET requests to fetch data from a network resource.
///
/// - [client]: An optional HTTP client. If not provided, the default client is used.
/// - [uri]: The URI of the network resource.
/// - [headers]: Optional HTTP headers to include in the request.
///
/// Returns a [Future] that completes with the response body as a string.
Future<String> _defaultNetworkLoader(
    Client? client, Uri uri, Map<String, String>? headers) async {
  var method = client == null ? get : client.get;
  var response = await method(uri, headers: headers);
  var string = response.body;
  return string;
}

/// Loads and displays a feature collection from a file specified by [path] as a [Widget].
///
/// This function is used to read a feature collection from a file, process it using a provided
/// [builder] function, and return the result as a [Widget].
///
/// - [path]: The path to the file containing the feature collection data.
/// - [featureCollectionLayerProperties]: Properties of the feature collection layer.
/// - [builder]: A function that takes the [featureCollectionLayerProperties] and a map of feature properties
///   and returns a [Widget] to render the features.
/// - [fileLoadBuilder]: A function that loads the file specified by [path] and returns its contents as a string.
/// - [mapController]: An optional [MapController] for controlling the map view.
/// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
/// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
/// - [key]: An optional [Key] for identifying the returned [Widget].
///
/// Returns a [Future] that completes with a [Widget] displaying the feature collection.
Future<Widget> _fileFeatureCollections(
  String path, {
  required FeatureCollectionProperties featureCollectionLayerProperties,
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  required Future<String> Function(String filePath) fileLoadBuilder,
  MapController? mapController,
  bool polylineCulling = false,
  bool polygonCulling = false,
  Key? key,
}) async {
  final readAsString = await fileLoadBuilder(path);
  return _string(
    checkEsri(readAsString),
    featureCollectionPropertie: featureCollectionLayerProperties,
    mapController: mapController,
    key: key,
    polygonCulling: polygonCulling,
    polylineCulling: polylineCulling,
    builder: builder,
  );
}

/// Loads and displays a feature collection from memory as a [Widget].
///
/// This function is used to read a feature collection from memory (in the form of a [Uint8List]),
/// process it using a provided [builder] function, and return the result as a [Widget].
///
/// - [list]: The [Uint8List] containing the feature collection data.
/// - [featureCollectionLayerProperties]: Properties of the feature collection layer.
/// - [builder]: A function that takes the [featureCollectionLayerProperties] and a map of feature properties
///   and returns a [Widget] to render the features.
/// - [mapController]: An optional [MapController] for controlling the map view.
/// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
/// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
/// - [key]: An optional [Key] for identifying the returned [Widget].
///
/// Returns a [Future] that completes with a [Widget] displaying the feature collection.
Future<Widget> _memoryFeatureCollections(
  Uint8List list, {
  required FeatureCollectionProperties featureCollectionLayerProperties,
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  MapController? mapController,
  bool polylineCulling = false,
  bool polygonCulling = false,
  Key? key,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    checkEsri(string),
    featureCollectionPropertie: featureCollectionLayerProperties,
    mapController: mapController,
    key: key,
    polygonCulling: polygonCulling,
    polylineCulling: polylineCulling,
    builder: builder,
  );
}

/// Loads and displays a feature collection from an asset file as a [Widget].
///
/// This function is used to read a feature collection from an asset file, process it using a provided
/// [builder] function, and return the result as a [Widget].
///
/// - [path]: The asset path to the file containing the feature collection data.
/// - [featureCollectionProperties]: Properties of the feature collection layer.
/// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
/// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
/// - [mapController]: An optional [MapController] for controlling the map view.
/// - [builder]: A function that takes the [featureCollectionProperties] and a map of feature properties
///   and returns a [Widget] to render the features.
/// - [key]: An optional [Key] for identifying the returned [Widget].
///
/// Returns a [Future] that completes with a [Widget] displaying the feature collection.
Future<Widget> _assetFeatureCollections(
  String path, {
  required FeatureCollectionProperties featureCollectionProperties,
  bool polylineCulling = false,
  bool polygonCulling = false,
  MapController? mapController,
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  Key? key,
}) async {
  final string = await rootBundle.loadString(path);
  return _string(
    checkEsri(string),
    featureCollectionPropertie: featureCollectionProperties,
    mapController: mapController,
    key: key,
    polygonCulling: polygonCulling,
    polylineCulling: polylineCulling,
    builder: builder,
  );
}

/// Loads and displays a feature collection from a network resource as a [Widget].
///
/// This function is used to make an HTTP GET request to fetch a feature collection from a network resource,
/// process it using a provided [builder] function, and return the result as a [Widget].
///
/// - [uri]: The URI of the network resource.
/// - [featureCollectionLayerProperties]: Properties of the feature collection layer.
/// - [key]: An optional [Key] for identifying the returned [Widget].
/// - [client]: An optional HTTP client. If not provided, the default client is used.
/// - [headers]: Optional HTTP headers to include in the request.
/// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
/// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
/// - [builder]: A function that takes the [featureCollectionProperties] and a map of feature properties
///   and returns a [Widget] to render the features.
/// - [networkLoadBuilder]: A function that loads data from the network resource and returns it as a string.
/// - [mapController]: An optional [MapController] for controlling the map view.
///
/// Returns a [Future] that completes with a [Widget] displaying the feature collection.
Future<Widget> _networkFeatureCollections(
  Uri uri, {
  required FeatureCollectionProperties featureCollectionProperties,
  Key? key,
  Client? client,
  Map<String, String>? headers,
  bool polylineCulling = false,
  bool polygonCulling = false,
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  required Future<String> Function(
          Client? client, Uri uri, Map<String, String>? map)
      networkLoadBuilder,
  MapController? mapController,
}) async {
  String string = await networkLoadBuilder(client, uri, headers);
  return _string(
    checkEsri(string),
    featureCollectionPropertie: featureCollectionProperties,
    mapController: mapController,
    key: key,
    polygonCulling: polygonCulling,
    polylineCulling: polylineCulling,
    builder: builder,
  );
}

/// Converts a GeoJSON string [json] into a [Widget] for rendering on the map.
///
/// This function parses the GeoJSON string, processes its features using the provided [builder] function,
/// and returns a [Widget] that displays the features on the map.
///
/// - [json]: The GeoJSON string representing the feature collection.
/// - [key]: An optional [Key] for identifying the returned [Widget].
/// - [builder]: A function that takes the [featureCollectionProperties] and a map of feature properties
///   and returns a [Widget] to render the features.
/// - [featureCollectionProperties]: Properties of the feature collection layer.
/// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
/// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
/// - [mapController]: An optional [MapController] for controlling the map view.
///
/// Returns a [Widget] that displays the feature collection.
Widget _string(
  String json, {
  Key? key,
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  required FeatureCollectionProperties featureCollectionPropertie,
  bool polylineCulling = false,
  bool polygonCulling = false,
  MapController? mapController,
}) {
  PowerGeoJSONFeatureCollection parseGeoJSON =
      PowerGeoJSONFeatureCollection.fromJson(checkEsri(json));
  var points = parseGeoJSON.geoJSONPoints
      .map(
        (e) => e.geometry.coordinates.toMarker(
          markerProperties: featureCollectionPropertie.markerProperties,
          child: builder(
            featureCollectionPropertie,
            e.properties,
          ),
        ),
      )
      .toList();
  var firstMarker = points.firstOrNull;
  return Stack(
    key: key,
    children: [
      MarkerLayer(
        rotate: firstMarker?.rotate ?? false,
        alignment: firstMarker?.alignment ?? Alignment.bottomCenter,
        markers: points,
      ),
      PolylineLayer(
        polylines: parseGeoJSON.geoJSONLineStrings
            .map(
              (e) => e.geometry.coordinates.toPolyline(
                polylineProperties:
                    featureCollectionPropertie.polylineProperties,
              ),
            )
            .toList(),
        polylineCulling: polylineCulling,
      ),
      PolygonLayer(
        polygons: parseGeoJSON.geoJSONPolygons
            .map(
              (e) => e.geometry.coordinates.toPolygon(
                polygonProperties: featureCollectionPropertie.polygonProperties,
              ),
            )
            .toList(),
        polygonCulling: polygonCulling,
      ),
    ],
  );
}

/// A utility class for fetching and displaying GeoJSON feature collections as widgets.
class PowerGeoJSONFeatureCollections {
  /// Fetches GeoJSON feature collections from a network source and returns a [Widget] to display them.
  ///
  /// - [url]: The URL of the network resource containing the GeoJSON data.
  /// - [client]: An optional HTTP client to use for the network request.
  /// - [headers]: Optional HTTP headers to include in the request.
  /// - [builder]: A function that takes the [featureCollectionProperties] and a map of feature properties
  ///   and returns a [Widget] to render the features.
  /// - [featureCollectionProperties]: Properties to customize the appearance of the feature collections.
  /// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
  /// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
  /// - [mapController]: An optional [MapController] for controlling the map view.
  /// - [networkLoadBuilder]: A function that loads data from the network resource and returns it as a string.
  /// - [key]: An optional [Key] for identifying the returned [Widget].
  ///
  /// Returns a [Widget] displaying the fetched GeoJSON feature collections.
  static Future<Widget> network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    required Widget Function(
      FeatureCollectionProperties featureCollectionProperties,
      Map<String, dynamic>? map,
    ) builder,
    required FeatureCollectionProperties featureCollectionProperties,
    bool polylineCulling = false,
    bool polygonCulling = false,
    MapController? mapController,
    Future<String> Function(Client? client, Uri uri, Map<String, String>? map)?
        networkLoadBuilder,
    Key? key,
  }) {
    var uri = url.toUri();
    return _networkFeatureCollections(
      uri,
      headers: headers,
      client: client,
      featureCollectionProperties: featureCollectionProperties,
      networkLoadBuilder: networkLoadBuilder ?? _defaultNetworkLoader,
      builder: builder,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      mapController: mapController,
      key: key,
    );
  }

  /// Loads and displays GeoJSON feature collections from an asset file as a [Widget].
  ///
  /// - [url]: The asset path to the file containing the GeoJSON data.
  /// - [featureCollectionProperties]: Properties to customize the appearance of the feature collections.
  /// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
  /// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
  /// - [mapController]: An optional [MapController] for controlling the map view.
  /// - [builder]: A function that takes the [featureCollectionProperties] and a map of feature properties
  ///   and returns a [Widget] to render the features.
  /// - [key]: An optional [Key] for identifying the returned [Widget].
  ///
  /// Returns a [Widget] displaying the GeoJSON feature collections from the asset file.
  static Future<Widget> asset(
    String url, {
    required FeatureCollectionProperties featureCollectionProperties,
    bool polylineCulling = false,
    bool polygonCulling = false,
    MapController? mapController,
    required Widget Function(
            FeatureCollectionProperties featureCollectionProperties,
            Map<String, dynamic>? map)
        builder,
    Key? key,
  }) {
    return _assetFeatureCollections(
      url,
      featureCollectionProperties: featureCollectionProperties,
      mapController: mapController,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      builder: builder,
      key: key,
    );
  }

  /// Loads and displays GeoJSON feature collections from a local file as a [Widget].
  ///
  /// - [path]: The path to the local file containing the GeoJSON data.
  /// - [featureCollectionProperties]: Properties to customize the appearance of the feature collections.
  /// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
  /// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
  /// - [mapController]: An optional [MapController] for controlling the map view.
  /// - [fileLoadBuilder]: A function that reads the file and returns its content as a string.
  /// - [builder]: A function that takes the [featureCollectionProperties] and a map of feature properties
  ///   and returns a [Widget] to render the features.
  /// - [key]: An optional [Key] for identifying the returned [Widget].
  ///
  /// Returns a [Widget] displaying the GeoJSON feature collections from the local file.
  static Future<Widget> file(
    String path, {
    required FeatureCollectionProperties featureCollectionProperties,
    bool polylineCulling = false,
    bool polygonCulling = false,
    MapController? mapController,
    Key? key,
    Future<String> Function(String)? fileLoadBuilder,
    required Widget Function(
            FeatureCollectionProperties featureCollectionProperties,
            Map<String, dynamic>? map)
        builder,
  }) {
    return _fileFeatureCollections(
      path,
      featureCollectionLayerProperties: featureCollectionProperties,
      mapController: mapController,
      builder: builder,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      fileLoadBuilder: fileLoadBuilder ?? _defaultFileLoadBuilder,
      key: key,
    );
  }

  /// Loads and displays GeoJSON feature collections from memory as a [Widget].
  ///
  /// - [bytes]: The GeoJSON data as a [Uint8List].
  /// - [featureCollectionProperties]: Properties to customize the appearance of the feature collections.
  /// - [mapController]: An optional [MapController] for controlling the map view.
  /// - [key]: An optional [Key] for identifying the returned [Widget].
  /// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
  /// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
  /// - [builder]: A function that takes the [featureCollectionProperties] and a map of feature properties
  ///   and returns a [Widget] to render the features.
  ///
  /// Returns a [Widget] displaying the GeoJSON feature collections from memory.
  static Future<Widget> memory(
    Uint8List bytes, {
    required FeatureCollectionProperties featureCollectionLayerProperties,
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    bool polygonCulling = false,
    required Widget Function(
            FeatureCollectionProperties featureCollectionProperties,
            Map<String, dynamic>? map)
        builder,
  }) {
    return _memoryFeatureCollections(
      bytes,
      featureCollectionLayerProperties: featureCollectionLayerProperties,
      mapController: mapController,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      builder: builder,
      key: key,
    );
  }

  /// Parses and displays GeoJSON feature collections from a string as a [Widget].
  ///
  /// - [data]: The GeoJSON data as a string.
  /// - [featureCollectionProperties]: Properties to customize the appearance of the feature collections.
  /// - [polylineCulling]: A boolean indicating whether polyline culling is enabled (default is false).
  /// - [polygonCulling]: A boolean indicating whether polygon culling is enabled (default is false).
  /// - [mapController]: An optional [MapController] for controlling the map view.
  /// - [key]: An optional [Key] for identifying the returned [Widget].
  /// - [builder]: A function that takes the [featureCollectionProperties] and a map of feature properties
  ///   and returns a [Widget] to render the features.
  ///
  /// Returns a [Widget] displaying the parsed GeoJSON feature collections.
  static Widget string(
    String data, {
    required FeatureCollectionProperties featureCollectionProperties,
    bool polylineCulling = false,
    bool polygonCulling = false,
    MapController? mapController,
    Key? key,
    required Widget Function(
            FeatureCollectionProperties featureCollectionProperties,
            Map<String, dynamic>? properties)
        builder,
  }) {
    return _string(
      data,
      featureCollectionPropertie: featureCollectionProperties,
      key: key,
      builder: builder,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      mapController: mapController,
    );
  }
}
