import 'dart:convert';

class PowerEsriJsonTransform {
  _stripJSON(String str) {
    return str.replaceAll('\\n', "\n").replaceAll('\\t', "\t");
  }

  Map<String, dynamic> _jsonToObject(String stringIn) {
    Map<String, dynamic> data = {};
    try {
      data = json.decode(_stripJSON(stringIn));
    } catch (err) {
      // data = null;
    }
    return data;
  }

// still not sure on how to translate some of these types
  String _parseGeometryType(String type) {
    if (type == "esriGeometryPoint") {
      return "Point";
    } else if (type == "esriGeometryMultipoint") {
      return "MultiPoint";
    } else if (type == "esriGeometryPolyline") {
      return "LineString";
    } else if (type == "esriGeometryPolygon") {
      return "Polygon";
    } else {
      return "Empty";
    }
  }

  Map<String, Object?> _featureToGeo(
      Map<String, dynamic> featureIn, String geomType) {
    Map<String, dynamic> geometry = {};
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
    geometry['coordinates'] = coordinates;

    // convert attributes to properties
    var properties = {};
    var attr = featureIn['attributes'] as Map<String, dynamic>;
    for (var field in attr.keys) {
      properties[field] = attr[field];
    }

    var featureOut = <String, Object?>{};
    featureOut['type'] = "Feature";
    featureOut['geometry'] = geometry;
    featureOut['properties'] = properties;

    return featureOut;
  }

  Map<String, Object?> deserialize(js) {
    var o = _jsonToObject(js);
    var geomType = _parseGeometryType(o['geometryType']);

    var features = [];
    var o2 = o['features'] as List<dynamic>;
    for (var i = 0,
            feature = {'string': '', 'int': 0, 'object': {}, 'null': null};
        i < o2.length;
        i++) {
      // prepare the main parts of the GeoJSON
      feature = o2[i];
      var feat = _featureToGeo(feature, geomType);
      features.add(feat);
    }

    var featColl = <String, Object?>{};
    featColl['type'] = "FeatureCollection";
    featColl['features'] = features;

    return featColl;
  }
}
