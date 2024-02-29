class PowerEsriJsonTransformer {
  ///This script will convert an EsriJSON
  ///dictionary to a GeoJSON dictionary
  ///
  ///send a GeoJSON feature:
  ///feature = json.loads(esri_input)
  ///result = esri_to_geo(feature)
  ///optional: response = json.dumps(result)
  ///
  ///Still in the works:
  ///- parse all geometry types

  Map esriToGeo(Map<String, Object?> esrijson) {
    var geojson = {};
    var features = esrijson["features"] as List;
    var esriGeomType = esrijson["geometryType"];
    geojson["type"] = "FeatureCollection";

    var feats = [];
    for (var feat in features) {
      feats.add(_extract(feat, esriGeomType));
    }

    geojson["features"] = feats;

    return geojson;
  }

  Object? _extract(feature, esriGeomType) {
    var geomType = _getGeomType(esriGeomType);

    return <String, Object?>{
      "type": "Feature",
      "geometry": {
        "type": geomType,
        "coordinates": _getCoordinates(feature["geometry"], geomType),
      },
      "properties": feature["attributes"],
    };
  }

  String _getGeomType(String esriType) {
    if (esriType == "esriGeometryPoint") {
      return "Point";
    } else if (esriType == "esriGeometryMultipoint") {
      return "MultiPoint";
    } else if (esriType == "esriGeometryPolyline") {
      return "LineString";
    } else if (esriType == "esriGeometryPolygon") {
      return "Polygon";
    } else {
      return "unknown";
    }
  }

  Object? _getCoordinates(geom, geomType) {
    if (geomType == "Polygon") {
      return geom["rings"];
    } else if (geomType == "LineString") {
      return geom["paths"];
    } else if (geomType == "Point") {
      return [geom["x"], geom["y"]];
    } else if (geomType == "MultiPoint") {
      return geom["points"];
    } else {
      return [];
    }
  }
}
