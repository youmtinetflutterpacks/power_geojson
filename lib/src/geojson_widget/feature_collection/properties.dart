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
  String toString() => 'FeatureCollectionProperties(markerProperties: $markerProperties, polylineProperties: $polylineProperties, polygonProperties: $polygonProperties)';

  @override
  bool operator ==(covariant FeatureCollectionProperties other) {
    if (identical(this, other)) return true;

    return other.markerProperties == markerProperties && other.polylineProperties == polylineProperties && other.polygonProperties == polygonProperties;
  }

  @override
  int get hashCode => markerProperties.hashCode ^ polylineProperties.hashCode ^ polygonProperties.hashCode;
}

abstract class GeoFeature {
  Map<String, dynamic>? properties;
  List<double>? bbox;
  String? title;
  dynamic id;

  static List<GeoFeature> parseFeature(GeoJSONFeature feature) {
    var geometry = feature.geometry;
    var properties = feature.properties;
    var bbox = feature.bbox;
    var title = feature.title;
    var id = feature.id;
    return parseGeometry(geometry, properties: properties, bbox: bbox, title: title, id: id);
  }

  static List<GeoFeature> parseGeometry(
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
          GeoPoint(
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
        return [
          GeoMultiPoint(
            geometry: GeoJSONMultiPoint(coordinates),
            properties: properties,
            bbox: bbox,
            title: title,
            id: id,
          ),
        ];
      case GeoJSONType.lineString:
        var geom = geometry as GeoJSONLineString;
        var coordinates = geom.coordinates;
        return [
          GeoLineString(
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
        return [
          GeoMultiLineString(
            geometry: GeoJSONMultiLineString(coordinates),
            properties: properties,
            bbox: bbox,
            title: title,
            id: id,
          ),
        ];
      case GeoJSONType.polygon:
        var geom = geometry as GeoJSONPolygon;
        var coordinates = geom.coordinates;
        return [
          GeoPolygon(
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
        return [
          GeoMultiPolygon(
            geometry: GeoJSONMultiPolygon(coordinates),
            properties: properties,
            bbox: bbox,
            title: title,
            id: id,
          ),
        ];
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

  GeoFeature({
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
  bool operator ==(covariant GeoFeature other) {
    if (identical(this, other)) return true;

    return mapEquals(other.properties, properties) && foundation.listEquals(other.bbox, bbox) && other.title == title && other.id == id;
  }

  @override
  int get hashCode {
    return properties.hashCode ^ bbox.hashCode ^ title.hashCode ^ id.hashCode;
  }
}

class PowerGeoJSONFeatureCollection {
  List<GeoPoint> geoJSONPoints;
  List<GeoMultiPoint> geoJSONMultiPoints;
  List<GeoLineString> geoJSONLineStrings;
  List<GeoMultiLineString> geoJSONMultiLineStrings;
  List<GeoPolygon> geoJSONPolygons;
  List<GeoMultiPolygon> geoJSONMultiPolygons;
  PowerGeoJSONFeatureCollection({
    required this.geoJSONPoints,
    required this.geoJSONMultiPoints,
    required this.geoJSONLineStrings,
    required this.geoJSONMultiLineStrings,
    required this.geoJSONPolygons,
    required this.geoJSONMultiPolygons,
  });

  List<GeoPoint> addPoints(List<GeoPoint> geoJSONPoint) {
    geoJSONPoints.addAll(geoJSONPoint);
    return geoJSONPoints;
  }

  List<GeoMultiPoint> addMultiPoints(List<GeoMultiPoint> geoJSONPoint) {
    geoJSONMultiPoints.addAll(geoJSONPoint);
    return geoJSONMultiPoints;
  }

  List<GeoLineString> addLines(List<GeoLineString> geoJSONPoint) {
    geoJSONLineStrings.addAll(geoJSONPoint);
    return geoJSONLineStrings;
  }

  List<GeoMultiLineString> addMultiLines(List<GeoMultiLineString> geoJSONPoint) {
    geoJSONMultiLineStrings.addAll(geoJSONPoint);
    return geoJSONMultiLineStrings;
  }

  List<GeoPolygon> addPolygons(List<GeoPolygon> geoJSONPoint) {
    geoJSONPolygons.addAll(geoJSONPoint);
    return geoJSONPolygons;
  }

  List<GeoMultiPolygon> addMultiPolygons(List<GeoMultiPolygon> geoJSONPoint) {
    geoJSONMultiPolygons.addAll(geoJSONPoint);
    return geoJSONMultiPolygons;
  }

  @override
  String toString() {
    return 'FeatureCollection(geoJSONPoints: $geoJSONPoints, geoJSONMultiPoints: $geoJSONMultiPoints, geoJSONLineStrings: $geoJSONLineStrings, geoJSONMultiLineStrings: $geoJSONMultiLineStrings, geoJSONPolygons: $geoJSONPolygons, geoJSONMultiPolygons: $geoJSONMultiPolygons)';
  }

  PowerGeoJSONFeatureCollection copyWith({
    List<GeoPoint>? geoJSONPoints,
    List<GeoMultiPoint>? geoJSONMultiPoints,
    List<GeoLineString>? geoJSONLineStrings,
    List<GeoMultiLineString>? geoJSONMultiLineStrings,
    List<GeoPolygon>? geoJSONPolygons,
    List<GeoMultiPolygon>? geoJSONMultiPolygons,
  }) {
    return PowerGeoJSONFeatureCollection(
      geoJSONPoints: geoJSONPoints ?? this.geoJSONPoints,
      geoJSONMultiPoints: geoJSONMultiPoints ?? this.geoJSONMultiPoints,
      geoJSONLineStrings: geoJSONLineStrings ?? this.geoJSONLineStrings,
      geoJSONMultiLineStrings: geoJSONMultiLineStrings ?? this.geoJSONMultiLineStrings,
      geoJSONPolygons: geoJSONPolygons ?? this.geoJSONPolygons,
      geoJSONMultiPolygons: geoJSONMultiPolygons ?? this.geoJSONMultiPolygons,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'geoJSONPoints': geoJSONPoints.map((x) => x.toMap()).toList(),
      'geoJSONMultiPoints': geoJSONMultiPoints.map((x) => x.toMap()).toList(),
      'geoJSONLineStrings': geoJSONLineStrings.map((x) => x.toMap()).toList(),
      'geoJSONMultiLineStrings': geoJSONMultiLineStrings.map((x) => x.toMap()).toList(),
      'geoJSONPolygons': geoJSONPolygons.map((x) => x.toMap()).toList(),
      'geoJSONMultiPolygons': geoJSONMultiPolygons.map((x) => x.toMap()).toList(),
    };
  }

  factory PowerGeoJSONFeatureCollection.fromMap(Map<String, dynamic> json) {
    var type = json['type'];
    var featureCollectionDefault = PowerGeoJSONFeatureCollection(
      geoJSONPoints: [],
      geoJSONMultiPoints: [],
      geoJSONLineStrings: [],
      geoJSONMultiLineStrings: [],
      geoJSONPolygons: [],
      geoJSONMultiPolygons: [],
    );
    switch (type) {
      case 'Point':
        GeoJSONPoint point = GeoJSONPoint.fromMap(json);
        var featureCollectionPoint = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [GeoPoint(geometry: point)],
          geoJSONMultiPoints: [],
          geoJSONLineStrings: [],
          geoJSONMultiLineStrings: [],
          geoJSONPolygons: [],
          geoJSONMultiPolygons: [],
        );
        return featureCollectionPoint;

      case 'MultiPoint':
        GeoJSONMultiPoint multiPoint = GeoJSONMultiPoint.fromMap(json);
        List<double> bboxGeoJSONMultiPoint = multiPoint.bbox;
        var featureCollectionMultiPoint = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [],
          geoJSONMultiPoints: [GeoMultiPoint(geometry: multiPoint, bbox: bboxGeoJSONMultiPoint)],
          geoJSONLineStrings: [],
          geoJSONMultiLineStrings: [],
          geoJSONPolygons: [],
          geoJSONMultiPolygons: [],
        );
        return featureCollectionMultiPoint;

      case 'LineString':
        GeoJSONLineString lineString = GeoJSONLineString.fromMap(json);
        List<double> bboxGeoJSONLineString = lineString.bbox;
        var featureCollectionLineString = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [],
          geoJSONMultiPoints: [],
          geoJSONLineStrings: [GeoLineString(geometry: lineString, bbox: bboxGeoJSONLineString)],
          geoJSONMultiLineStrings: [],
          geoJSONPolygons: [],
          geoJSONMultiPolygons: [],
        );
        return featureCollectionLineString;

      case 'MultiLineString':
        GeoJSONMultiLineString multiLineString = GeoJSONMultiLineString.fromMap(json);
        List<double> bboxGeoJSONMultiLineString = multiLineString.bbox;
        var featureCollectionMultiLineString = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [],
          geoJSONMultiPoints: [],
          geoJSONLineStrings: [],
          geoJSONMultiLineStrings: [GeoMultiLineString(geometry: multiLineString, bbox: bboxGeoJSONMultiLineString)],
          geoJSONPolygons: [],
          geoJSONMultiPolygons: [],
        );
        return featureCollectionMultiLineString;

      case 'Polygon':
        GeoJSONPolygon polygon = GeoJSONPolygon.fromMap(json);
        List<double> bboxGeoJSONPolygon = polygon.bbox;
        var featureCollectionPolygon = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [],
          geoJSONMultiPoints: [],
          geoJSONLineStrings: [],
          geoJSONMultiLineStrings: [],
          geoJSONPolygons: [GeoPolygon(geometry: polygon, bbox: bboxGeoJSONPolygon)],
          geoJSONMultiPolygons: [],
        );
        return featureCollectionPolygon;

      case 'MultiPolygon':
        GeoJSONMultiPolygon multiPolygon = GeoJSONMultiPolygon.fromMap(json);
        List<double> bboxGeoJSONMultiPolygon = multiPolygon.bbox;
        var featureCollectionMultiPolygon = PowerGeoJSONFeatureCollection(
          geoJSONPoints: [],
          geoJSONMultiPoints: [],
          geoJSONLineStrings: [],
          geoJSONMultiLineStrings: [],
          geoJSONPolygons: [],
          geoJSONMultiPolygons: [GeoMultiPolygon(geometry: multiPolygon, bbox: bboxGeoJSONMultiPolygon)],
        );
        return featureCollectionMultiPolygon;

      case 'Feature':
        GeoJSONFeature feature = GeoJSONFeature.fromMap(json);
        List<GeoFeature> parsedFeature = GeoFeature.parseFeature(feature);
        PowerGeoJSONFeatureCollection featureCollectionFeature = PowerGeoJSONFeatureCollection(
          geoJSONPoints: parsedFeature.whereType<GeoPoint>().toList(),
          geoJSONMultiPoints: parsedFeature.whereType<GeoMultiPoint>().toList(),
          geoJSONLineStrings: parsedFeature.whereType<GeoLineString>().toList(),
          geoJSONMultiLineStrings: parsedFeature.whereType<GeoMultiLineString>().toList(),
          geoJSONPolygons: parsedFeature.whereType<GeoPolygon>().toList(),
          geoJSONMultiPolygons: parsedFeature.whereType<GeoMultiPolygon>().toList(),
        );
        return featureCollectionFeature;

      case 'GeometryCollection':
        GeoJSONGeometryCollection geometryCollection = GeoJSONGeometryCollection.fromMap(json);
        var featureCollectionGeometryCollection = geometryCollection.geometries.map((e) {
          var parseGeometry2 = GeoFeature.parseGeometry(e);
          return PowerGeoJSONFeatureCollection(
            geoJSONPoints: parseGeometry2.whereType<GeoPoint>().toList(),
            geoJSONMultiPoints: parseGeometry2.whereType<GeoMultiPoint>().toList(),
            geoJSONLineStrings: parseGeometry2.whereType<GeoLineString>().toList(),
            geoJSONMultiLineStrings: parseGeometry2.whereType<GeoMultiLineString>().toList(),
            geoJSONPolygons: parseGeometry2.whereType<GeoPolygon>().toList(),
            geoJSONMultiPolygons: parseGeometry2.whereType<GeoMultiPolygon>().toList(),
          );
        }).reduce((value, e) => value
          ..addPoints(e.geoJSONPoints)
          ..addLines(e.geoJSONLineStrings)
          ..addPolygons(e.geoJSONPolygons)
          ..addMultiPoints(e.geoJSONMultiPoints)
          ..addMultiLines(e.geoJSONMultiLineStrings)
          ..addMultiPolygons(e.geoJSONMultiPolygons));
        return featureCollectionGeometryCollection;

      case 'FeatureCollection':
        GeoJSONFeatureCollection geoJSONFeatureCollection = GeoJSONFeatureCollection.fromMap(json);

        var features = geoJSONFeatureCollection.features;

        List<GeoJSONFeature> listFeatures = features.where((element) => element != null).map((e) => e as GeoJSONFeature).toList();
        List<GeoFeature> listGeoFeatures = listFeatures.map(GeoFeature.parseFeature).expand((e) => e).toList();
        return PowerGeoJSONFeatureCollection(
          geoJSONPoints: listGeoFeatures.whereType<GeoPoint>().toList(),
          geoJSONMultiPoints: listGeoFeatures.whereType<GeoMultiPoint>().toList(),
          geoJSONLineStrings: listGeoFeatures.whereType<GeoLineString>().toList(),
          geoJSONMultiLineStrings: listGeoFeatures.whereType<GeoMultiLineString>().toList(),
          geoJSONPolygons: listGeoFeatures.whereType<GeoPolygon>().toList(),
          geoJSONMultiPolygons: listGeoFeatures.whereType<GeoMultiPolygon>().toList(),
        );
      default:
        return featureCollectionDefault;
    }
  }

  String toJson() => json.encode(toMap());

  factory PowerGeoJSONFeatureCollection.fromJson(String source) => PowerGeoJSONFeatureCollection.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant PowerGeoJSONFeatureCollection other) {
    if (identical(this, other)) return true;

    return foundation.listEquals(other.geoJSONPoints, geoJSONPoints) && foundation.listEquals(other.geoJSONMultiPoints, geoJSONMultiPoints) && foundation.listEquals(other.geoJSONLineStrings, geoJSONLineStrings) && foundation.listEquals(other.geoJSONMultiLineStrings, geoJSONMultiLineStrings) && foundation.listEquals(other.geoJSONPolygons, geoJSONPolygons) && foundation.listEquals(other.geoJSONMultiPolygons, geoJSONMultiPolygons);
  }

  @override
  int get hashCode {
    return geoJSONPoints.hashCode ^ geoJSONMultiPoints.hashCode ^ geoJSONLineStrings.hashCode ^ geoJSONMultiLineStrings.hashCode ^ geoJSONPolygons.hashCode ^ geoJSONMultiPolygons.hashCode;
  }
}

class GeoPoint extends GeoFeature {
  GeoJSONPoint geometry;
  GeoPoint({
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
  bool operator ==(covariant GeoPoint other) {
    if (identical(this, other)) return true;

    return other.geometry == geometry;
  }

  @override
  int get hashCode => geometry.hashCode;
}

class GeoMultiPoint extends GeoFeature {
  GeoJSONMultiPoint geometry;
  GeoMultiPoint({
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
  String toString() => 'GeoMultiPoint(geometry: $geometry)';

  @override
  bool operator ==(covariant GeoMultiPoint other) {
    if (identical(this, other)) return true;

    return other.geometry == geometry;
  }

  @override
  int get hashCode => geometry.hashCode;
}

class GeoLineString extends GeoFeature {
  GeoJSONLineString geometry;
  GeoLineString({
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
  bool operator ==(covariant GeoLineString other) {
    if (identical(this, other)) return true;

    return other.geometry == geometry;
  }

  @override
  int get hashCode => geometry.hashCode;
}

class GeoMultiLineString extends GeoFeature {
  GeoJSONMultiLineString geometry;
  GeoMultiLineString({
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
  String toString() => 'GeoMultiLineString(geometry: $geometry)';

  @override
  bool operator ==(covariant GeoMultiLineString other) {
    if (identical(this, other)) return true;

    return other.geometry == geometry;
  }

  @override
  int get hashCode => geometry.hashCode;
}

class GeoPolygon extends GeoFeature {
  GeoJSONPolygon geometry;
  GeoPolygon({
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
  bool operator ==(covariant GeoPolygon other) {
    if (identical(this, other)) return true;

    return other.geometry == geometry;
  }

  @override
  int get hashCode => geometry.hashCode;
}

class GeoMultiPolygon extends GeoFeature {
  GeoJSONMultiPolygon geometry;
  GeoMultiPolygon({
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
  String toString() => 'GeoMultiPolygon(geometry: $geometry)';

  @override
  bool operator ==(covariant GeoMultiPolygon other) {
    if (identical(this, other)) return true;

    return other.geometry == geometry;
  }

  @override
  int get hashCode => geometry.hashCode;
}
