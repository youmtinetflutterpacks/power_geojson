import 'dart:convert';

import 'package:console_tools/console_tools.dart';
import 'package:power_geojson/power_geojson.dart';

const List<String> _esriFields = <String>[
  "displayFieldName",
  "fieldAliases",
  "geometryType",
  "spatialReference",
  "fields",
];

String checkEsri(String readasstring) {
  Map<String, Object?> map = jsonDecode(readasstring) as Map<String, Object?>;
  bool isEsri = map.keys.every((String field) => _esriFields.contains(field));
  String checkEsri = isEsri
      ? PowerJSON(PowerEsriJSON(map).toGeoJSON()).toText()
      : readasstring;
  return checkEsri;
}

class PowerEsriJSON {
  final Map<String, dynamic> data;

  PowerEsriJSON(this.data);
  Map<String, Object?> toGeoJSON() {
    final Map<String, Object?> output = <String, Object?>{
      "type": "FeatureCollection",
      "features": <dynamic>[],
    };
    final List<dynamic> data2 = data['features'] as List<dynamic>;
    final int fl = data2.length;
    int i = 0;
    while (fl > i) {
      final Map<String, dynamic> ft =
          data['features'][i] as Map<String, dynamic>;
      /* as only ESRI based products care if all the features are the same type of geometry, check for geometry type at a feature level*/
      final Map<String, Object?> outFT = <String, Object?>{
        "type": "Feature",
        "properties": _prop(ft['attributes'] as Map<String, dynamic>),
      };
      final Map<String, dynamic> geometry =
          ft['geometry'] as Map<String, dynamic>;
      if (geometry['x'] != null) {
        //check if it's a point
        outFT['geometry'] = _point2D(geometry);
      } else if (geometry['points'] != null) {
        //check if it is a multipoint
        outFT['geometry'] = _points2D(geometry);
      } else if (geometry['paths'] != null) {
        //check if a line (or "ARC" in ESRI terms)
        outFT['geometry'] = _line2D(geometry);
      } else if (geometry['rings'] != null) {
        outFT['geometry'] = _polygon(geometry);
      }
      final List<dynamic> outPut2 = output['features'] as List<dynamic>;
      outPut2.add(outFT);
      i++;
    }
    Console.log('outPut = ${json.encode(output)}');
    return output;
  }

  // \.(points|x|y|paths|rings)
  Map<String, Object?> _point2D(Map<String, Object?> geometry) {
    //this one is easy
    return <String, Object?>{
      "type": "Point",
      "coordinates": <Object?>[geometry['x'], geometry['y']],
    };
  }

  Map<String, Object?> _points2D(Map<String, dynamic> geometry) {
    //checks if the multipoint only has one point, if so exports as point instead
    final List<dynamic> points = geometry['points'] as List<dynamic>;
    if (points.length == 1) {
      return <String, Object?>{"type": "Point", "coordinates": points[0]};
    } else {
      return <String, Object?>{"type": "MultiPoint", "coordinates": points};
    }
  }

  Map<String, Object?> _line2D(Map<String, dynamic> geometry) {
    //checks if their are multiple paths or just one
    final List<dynamic> paths = geometry['paths'] as List<dynamic>;
    if (paths.length == 1) {
      return <String, Object?>{"type": "LineString", "coordinates": paths[0]};
    } else {
      return <String, Object?>{"type": "MultiLineString", "coordinates": paths};
    }
  }

  Map<String, Object?> _polygon(Map<String, dynamic> geometry) {
    //first we check for some easy cases, like if their is only one ring
    final List<dynamic> rings = geometry['rings'] as List<dynamic>;
    if (rings.length == 1) {
      return <String, Object?>{"type": "Polygon", "coordinates": rings};
    } else {
      /*if it isn't that easy then we have to start checking ring direction, basically the ring goes clockwise its part of the polygon,
            if it goes counterclockwise it is a hole in the polygon, but geojson does it by haveing an array with the first element be the polygons 
            and the next elements being holes in it*/
      return _decodePolygon(rings);
    }
  }

  Map<String, Object?> _decodePolygon(List<dynamic> a) {
    //returns the feature
    final List<List<dynamic>> coords = <List<dynamic>>[];
    String type;
    final int len = a.length;
    int i = 0;
    int len2 = coords.length - 1;
    while (len > i) {
      if (_ringIsClockwise(a[i] as List<dynamic>)) {
        coords.add(<dynamic>[a[i]]);
        len2++;
      } else {
        final List<dynamic> coord = coords[len2];
        coord.add(a[i]);
      }
      i++;
    }
    if (coords.length == 1) {
      type = "Polygon";
    } else {
      type = "MultiPolygon";
    }
    return <String, Object?>{
      "type": type,
      "coordinates": (coords.length == 1) ? coords[0] : coords,
    };
  }

  bool _ringIsClockwise(List<dynamic> ringToTest) {
    num total = 0;
    final int rLength = ringToTest.length;
    List<dynamic> pt1 = ringToTest[0] as List<dynamic>;
    for (int i = 0; i < rLength - 1; i++) {
      final List<dynamic> pt2 = ringToTest[i + 1] as List<dynamic>;
      final num pt22 = pt2[0] as num;
      final num pt12 = pt1[0] as num;
      final num pt23 = pt2[1] as num;
      final num pt13 = pt1[1] as num;
      total += (pt22 - pt12) * (pt23 + pt13);
      pt1 = pt2;
    }
    return (total >= 0);
  }

  Map<String, Object?> _prop(Map<String, dynamic> a) {
    final Map<String, Object?> p = <String, Object?>{};
    for (final String k in a.keys) {
      if (a[k] != null) {
        p[k] = a[k];
      }
    }
    return p;
  }
}
