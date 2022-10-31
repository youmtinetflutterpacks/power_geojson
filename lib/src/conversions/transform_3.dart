import 'dart:convert';

import 'package:console_tools/console_tools.dart';

stripJSON(String str) {
  return str.replaceAll('\\n', "\\n").replaceAll('\\t', "\\t");
}

Map<String, dynamic> jsonToObject(stringIn) {
  Map<String, dynamic> data = {};
  try {
    data = json.decode(stripJSON(stringIn));
    Console.log("json converted to object");
  } catch (err) {
    // data = null;
  }
  return data;
}

// still not sure on how to translate some of these types
parseGeometryType(String type) {
  if (type == "esriGeometryPoint") {
    return "Point";
  } else if (type == "esriGeometryMultipoint") {
    return "MultiPoint";
  } else if (type == "esriGeometryPolyline") {
    return "LineString";
  } else if (type == "esriGeometryPolygon") {
    return "Polygon";
  } /* else if (type === "esriGeometryPolygon") {
        return "MultiLineString";
    } else if (type === "esriGeometryPolygon") {
        return "MultiPolygon";
    }*/
  else {
    return "Empty";
  }
}

featureToGeo(Map<String, dynamic> featureIn, String geomType) {
  Map<String, dynamic> geometry = {};
  Console.log(geometry['type'], color: ConsoleColors.middleBluePurple);
  geometry['type'] = geomType;

  // grab the rings to coordinates
  var geom = featureIn['geometry'];

  dynamic coordinates;
  if (geomType == "Polygon") {
    coordinates = geom['rings'];
  } else if (geomType == "LineString") {
    coordinates = geom['paths'];
  } else if (geomType == "Point") {
    coordinates = [geom['x'], geom['y']];
  }
  Console.log('geom $geom');
  geometry['coordinates'] = coordinates;

  // convert attributes to properties
  var properties = {};
  var attr = featureIn['attributes'] as Map<String, dynamic>;
  for (var field in attr.keys) {
    properties[field] = attr[field];
  }

  var featureOut = {};
  featureOut['type'] = "Feature";
  featureOut['geometry'] = geometry;
  featureOut['properties'] = properties;

  return featureOut;
}

deserialize(js) {
  Console.log("begin parsing json");

  var o = jsonToObject(js);
  String result;
  /* if (null != o) { */
  Console.log(o['geometryType'], color: ConsoleColors.roseRed);
  var geomType = parseGeometryType(o['geometryType']);

  var features = [];
  var o2 = o['features'] as List<dynamic>;
  for (var i = 0,
          feature = {'string': '', 'int': 0, 'object': {}, 'null': null};
      i < o2.length;
      i++) {
    // Console.log(o['features']);
    // prepare the main parts of the GeoJSON
    feature = o2[i];
    var feat = featureToGeo(feature, geomType);
    features.add(feat);
  }

  var featColl = {};
  featColl['type'] = "FeatureCollection";
  featColl['features'] = features;

  result = json.encode(featColl, toEncodable: (
    value,
  ) {
    if (value is num && !value.isFinite) {
      return '$value';
    }
    return value;
  });

  Console.log("json parsed, return it");
  /* } else {
    result = "Sorry, JSON could not be parsed.";
  } */
  Console.log('result = $result');
}
