// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;
import 'package:geojson_vi/geojson_vi.dart';
import 'package:power_geojson/power_geojson.dart';

class FeatureCollectionProperties {
  final MarkerProperties markerProperties;
  final PolylineProperties polylineProperties;
  final PolygonProperties polygonProperties;

  const FeatureCollectionProperties({
    this.markerProperties = const MarkerProperties(),
    this.polylineProperties = const PolylineProperties(),
    this.polygonProperties = const PolygonProperties(),
  });

  FeatureCollectionProperties copyWith({
    MarkerProperties? markerProperties,
    PolylineProperties? polylineProperties,
    PolygonProperties? polygonProperties,
  }) {
    return FeatureCollectionProperties(
      markerProperties: markerProperties ?? this.markerProperties,
      polylineProperties: polylineProperties ?? this.polylineProperties,
      polygonProperties: polygonProperties ?? this.polygonProperties,
    );
  }

  @override
  String toString() =>
      'FeatureCollectionProperties(markerProperties: $markerProperties, polylineProperties: $polylineProperties, polygonProperties: $polygonProperties)';

  @override
  bool operator ==(covariant FeatureCollectionProperties other) {
    if (identical(this, other)) return true;

    return other.markerProperties == markerProperties &&
        other.polylineProperties == polylineProperties &&
        other.polygonProperties == polygonProperties;
  }

  @override
  int get hashCode =>
      markerProperties.hashCode ^
      polylineProperties.hashCode ^
      polygonProperties.hashCode;
}

abstract class PowerGeoFeature {
  Map<String, dynamic>? properties;
  List<double>? bbox;
  String? title;
  dynamic id;

  static List<PowerGeoFeature> parseFeature(GeoJSONFeature feature) {
    var geometry = feature.geometry;
    var properties = feature.properties;
    var bbox = feature.bbox;
    var title = feature.title;
    var id = feature.id;
    return parseGeometry(geometry,
        properties: properties, bbox: bbox, title: title, id: id);
  }

  static List<PowerGeoFeature> parseGeometry(
    GeoJSONGeometry geometry, {
    Map<String, dynamic>? properties,
    List<double>? bbox,
    String? title,
    dynamic id,
  }) {
    switch (geometry.type) {
      case GeoJSONType.point:
        var geom = geometry as GeoJSONPoint;
        var coordinates = geom.coordinates;
        return [
          PowerGeoPoint(
            geometry: GeoJSONPoint(coordinates),
            properties: properties,
            bbox: bbox,
            title: title,
            id: id,
          ),
        ];
      case GeoJSONType.multiPoint:
        var geom = geometry as GeoJSONMultiPoint;
        var coordinates = geom.coordinates;
        return coordinates
            .map((e) => PowerGeoPoint(
                  geometry: GeoJSONPoint(e),
                  properties: properties,
                  bbox: bbox,
                  title: title,
                  id: id,
                ))
            .toList();
      case GeoJSONType.lineString:
        var geom = geometry as GeoJSONLineString;
        var coordinates = geom.coordinates;
        return [
          PowerGeoLineString(
            geometry: GeoJSONLineString(coordinates),
            properties: properties,
            bbox: bbox,
            title: title,
            id: id,
          ),
        ];
      case GeoJSONType.multiLineString:
        var geom = geometry as GeoJSONMultiLineString;
        var coordinates = geom.coordinates;
        return coordinates
            .map((e) => PowerGeoLineString(
                  geometry: GeoJSONLineString(e),
                  properties: properties,
                  bbox: bbox,
                  title: title,
                  id: id,
                ))
            .toList();
      case GeoJSONType.polygon:
        var geom = geometry as GeoJSONPolygon;
        var coordinates = geom.coordinates;
        return [
          PowerGeoPolygon(
            geometry: GeoJSONPolygon(coordinates),
            properties: properties,
            bbox: bbox,
            title: title,
            id: id,
          ),
        ];
      case GeoJSONType.multiPolygon:
        var geom = geometry as GeoJSONMultiPolygon;
        var coordinates = geom.coordinates;
        return coordinates
            .map((e) => PowerGeoPolygon(
                  geometry: GeoJSONPolygon(e),
                  properties: properties,
                  bbox: bbox,
                  title: title,
                  id: id,
                ))
            .toList();
      case GeoJSONType.feature:
        var geom = geometry as GeoJSONFeature;
        return parseGeometry(
          geom.geometry,
          properties: properties,
          bbox: bbox,
          title: title,
          id: id,
        );
      case GeoJSONType.featureCollection:
        var geom = geometry as GeoJSONFeatureCollection;
        var features = geom.features;
        var featuresParse = features.where((e) => e != null).map(
              (e) => parseGeometry(
                e!.geometry,
                properties: properties,
                bbox: bbox,
                title: title,
                id: id,
              ),
            );
        return featuresParse.expand((e) => e).toList();
      case GeoJSONType.geometryCollection:
        var geom = geometry as GeoJSONGeometryCollection;
        var coordinates = geom.geometries.map(
          (e) => parseGeometry(
            e,
            properties: properties,
            bbox: bbox,
            title: title,
            id: id,
          ),
        );
        return coordinates.expand((e) => e).toList();
    }
  }

  PowerGeoFeature({
    this.properties,
    this.bbox,
    this.title,
    required this.id,
  });

  @override
  String toString() {
    return 'GeoFeature(properties: $properties, bbox: $bbox, title: $title, id: $id)';
  }

  @override
  bool operator ==(covariant PowerGeoFeature other) {
    if (identical(this, other)) return true;

    return mapEquals(other.properties, properties) &&
        foundation.listEquals(other.bbox, bbox) &&
        other.title == title &&
        other.id == id;
  }

  @override
  int get hashCode {
    return properties.hashCode ^ bbox.hashCode ^ title.hashCode ^ id.hashCode;
  }
}

class PowerGeoJSONFeatureCollection {
  List<PowerGeoPoint> geoJSONPoints;
  List<PowerGeoLineString> geoJSONLineStrings;
  List<PowerGeoPolygon> geoJSONPolygons;
  PowerGeoJSONFeatureCollection({
    required this.geoJSONPoints,
    required this.geoJSONLineStrings,
    required this.geoJSONPolygons,
  });

  List<PowerGeoPoint> addPoints(List<PowerGeoPoint> geoJSONPoint) {
    geoJSONPoints.addAll(geoJSONPoint);
    return geoJSONPoints;
  }

  List<PowerGeoLineString> addLines(List<PowerGeoLineString> geoJSONPoint) {
    geoJSONLineStrings.addAll(geoJSONPoint);
    return geoJSONLineStrings;
  }

  List<PowerGeoPolygon> addPolygons(List<PowerGeoPolygon> geoJSONPoint) {
    geoJSONPolygons.addAll(geoJSONPoint);
    return geoJSONPolygons;
  }

  @override
  String toString() {
    return 'FeatureCollection(geoJSONPoints: $geoJSONPoints, geoJSONLineStrings: $geoJSONLineStrings, geoJSONPolygons: $geoJSONPolygons)';
  }

  PowerGeoJSONFeatureCollection copyWith({
    List<PowerGeoPoint>? geoJSONPoints,
    List<PowerGeoLineString>? geoJSONLineStrings,
    List<PowerGeoPolygon>? geoJSONPolygons,
  }) {
    return PowerGeoJSONFeatureCollection(
      geoJSONPoints: geoJSONPoints ?? this.geoJSONPoints,
      geoJSONLineStrings: geoJSONLineStrings ?? this.geoJSONLineStrings,
      geoJSONPolygons: geoJSONPolygons ?? this.geoJSONPolygons,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'geoJSONPoints': geoJSONPoints.map((x) => x.toMap()).toList(),
      'geoJSONLineStrings': geoJSONLineStrings.map((x) => x.toMap()).toList(),
      'geoJSONPolygons': geoJSONPolygons.map((x) => x.toMap()).toList(),
    };
  }

  factory PowerGeoJSONFeatureCollection.fromMap(Map<String, dynamic> json) {
    var type = json['type'];
    var featureCollectionDefault = PowerGeoJSONFeatureCollection(
      geoJSONPoints: [],
      geoJSONLineStrings: [],
      geoJSONPolygons: [],
    );
    switch (type) {
      case 'Point':
        GeoJSONPoint point = GeoJSONPoint.fromMap(json);
        var featureCollectionPoint = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [PowerGeoPoint(geometry: point)],
          geoJSONLineStrings: [],
          geoJSONPolygons: [],
        );
        return featureCollectionPoint;

      case 'MultiPoint':
        GeoJSONMultiPoint multiPoint = GeoJSONMultiPoint.fromMap(json);
        // List<double> bboxGeoJSONMultiPoint = multiPoint.bbox;
        var featureCollectionMultiPoint = PowerGeoJSONFeatureCollection(
          geoJSONPoints: multiPoint.coordinates.map((e) {
            var geometry = GeoJSONPoint(e);
            return PowerGeoPoint(geometry: geometry, bbox: geometry.bbox);
          }).toList(),
          geoJSONLineStrings: [],
          geoJSONPolygons: [],
        );
        return featureCollectionMultiPoint;

      case 'LineString':
        GeoJSONLineString lineString = GeoJSONLineString.fromMap(json);
        List<double> bboxGeoJSONLineString = lineString.bbox;
        var featureCollectionLineString = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [],
          geoJSONLineStrings: [
            PowerGeoLineString(
                geometry: lineString, bbox: bboxGeoJSONLineString)
          ],
          geoJSONPolygons: [],
        );
        return featureCollectionLineString;

      case 'MultiLineString':
        GeoJSONMultiLineString multiLineString =
            GeoJSONMultiLineString.fromMap(json);
        // List<double> bboxGeoJSONMultiLineString = multiLineString.bbox;
        var featureCollectionMultiLineString = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [],
          geoJSONLineStrings: multiLineString.coordinates.map((e) {
            var geometry = GeoJSONLineString(e);
            return PowerGeoLineString(geometry: geometry, bbox: geometry.bbox);
          }).toList(),
          geoJSONPolygons: [],
        );
        return featureCollectionMultiLineString;

      case 'Polygon':
        GeoJSONPolygon polygon = GeoJSONPolygon.fromMap(json);
        List<double> bboxGeoJSONPolygon = polygon.bbox;
        var featureCollectionPolygon = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [],
          geoJSONLineStrings: [],
          geoJSONPolygons: [
            PowerGeoPolygon(geometry: polygon, bbox: bboxGeoJSONPolygon)
          ],
        );
        return featureCollectionPolygon;

      case 'MultiPolygon':
        GeoJSONMultiPolygon multiPolygon = GeoJSONMultiPolygon.fromMap(json);
        // List<double> bboxGeoJSONMultiPolygon = multiPolygon.bbox;
        var featureCollectionMultiPolygon = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [],
          geoJSONLineStrings: [],
          geoJSONPolygons: multiPolygon.coordinates.map((e) {
            var geometry = GeoJSONPolygon(e);
            return PowerGeoPolygon(geometry: geometry, bbox: geometry.bbox);
          }).toList(),
        );
        return featureCollectionMultiPolygon;

      case 'Feature':
        GeoJSONFeature feature = GeoJSONFeature.fromMap(json);
        List<PowerGeoFeature> parsedFeature =
            PowerGeoFeature.parseFeature(feature);
        PowerGeoJSONFeatureCollection featureCollectionFeature =
            PowerGeoJSONFeatureCollection(
          geoJSONPoints: parsedFeature.whereType<PowerGeoPoint>().toList(),
          geoJSONLineStrings:
              parsedFeature.whereType<PowerGeoLineString>().toList(),
          geoJSONPolygons: parsedFeature.whereType<PowerGeoPolygon>().toList(),
        );
        return featureCollectionFeature;

      case 'GeometryCollection':
        GeoJSONGeometryCollection geometryCollection =
            GeoJSONGeometryCollection.fromMap(json);
        var featureCollectionGeometryCollection =
            geometryCollection.geometries.map((e) {
          var parseGeometry2 = PowerGeoFeature.parseGeometry(e);
          return PowerGeoJSONFeatureCollection(
            geoJSONPoints: parseGeometry2.whereType<PowerGeoPoint>().toList(),
            geoJSONLineStrings:
                parseGeometry2.whereType<PowerGeoLineString>().toList(),
            geoJSONPolygons:
                parseGeometry2.whereType<PowerGeoPolygon>().toList(),
          );
        }).reduce((value, e) => value
              ..addPoints(e.geoJSONPoints)
              ..addLines(e.geoJSONLineStrings)
              ..addPolygons(e.geoJSONPolygons));
        return featureCollectionGeometryCollection;

      case 'FeatureCollection':
        GeoJSONFeatureCollection geoJSONFeatureCollection =
            GeoJSONFeatureCollection.fromMap(json);

        var features = geoJSONFeatureCollection.features;

        List<GeoJSONFeature> listFeatures = features
            .where((element) => element != null)
            .map((e) => e as GeoJSONFeature)
            .toList();
        List<PowerGeoFeature> listGeoFeatures = listFeatures
            .map(PowerGeoFeature.parseFeature)
            .expand((e) => e)
            .toList();
        return PowerGeoJSONFeatureCollection(
          geoJSONPoints: listGeoFeatures.whereType<PowerGeoPoint>().toList(),
          geoJSONLineStrings:
              listGeoFeatures.whereType<PowerGeoLineString>().toList(),
          geoJSONPolygons:
              listGeoFeatures.whereType<PowerGeoPolygon>().toList(),
        );
      default:
        return featureCollectionDefault;
    }
  }

  String toJson() => json.encode(toMap());

  factory PowerGeoJSONFeatureCollection.fromJson(String source) =>
      PowerGeoJSONFeatureCollection.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant PowerGeoJSONFeatureCollection other) {
    if (identical(this, other)) return true;

    return foundation.listEquals(other.geoJSONPoints, geoJSONPoints) &&
        foundation.listEquals(other.geoJSONLineStrings, geoJSONLineStrings) &&
        foundation.listEquals(other.geoJSONPolygons, geoJSONPolygons);
  }

  @override
  int get hashCode {
    return geoJSONPoints.hashCode ^
        geoJSONLineStrings.hashCode ^
        geoJSONPolygons.hashCode;
  }
}

class PowerGeoPoint extends PowerGeoFeature {
  GeoJSONPoint geometry;
  PowerGeoPoint({
    Map<String, dynamic>? properties,
    List<double>? bbox,
    String? title,
    dynamic id,
    required this.geometry,
  }) : super(properties: properties, bbox: bbox, title: title, id: id);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'geometry': geometry.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'GeoPoint(geometry: $geometry)';

  @override
  bool operator ==(covariant PowerGeoPoint other) {
    if (identical(this, other)) return true;

    return other.geometry == geometry;
  }

  @override
  int get hashCode => geometry.hashCode;
}

class PowerGeoLineString extends PowerGeoFeature {
  GeoJSONLineString geometry;
  PowerGeoLineString({
    Map<String, dynamic>? properties,
    List<double>? bbox,
    String? title,
    dynamic id,
    required this.geometry,
  }) : super(properties: properties, bbox: bbox, title: title, id: id);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'geometry': geometry.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'GeoLineString(geometry: $geometry)';

  @override
  bool operator ==(covariant PowerGeoLineString other) {
    if (identical(this, other)) return true;

    return other.geometry == geometry;
  }

  @override
  int get hashCode => geometry.hashCode;
}

class PowerGeoPolygon extends PowerGeoFeature {
  GeoJSONPolygon geometry;
  PowerGeoPolygon({
    Map<String, dynamic>? properties,
    List<double>? bbox,
    String? title,
    dynamic id,
    required this.geometry,
  }) : super(properties: properties, bbox: bbox, title: title, id: id);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'geometry': geometry.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'GeoPolygon(geometry: $geometry)';

  @override
  bool operator ==(covariant PowerGeoPolygon other) {
    if (identical(this, other)) return true;

    return other.geometry == geometry;
  }

  @override
  int get hashCode => geometry.hashCode;
}
