const String dli = """
This script will convert an EsriJSON
dictionary to a GeoJSON dictionary

send a GeoJSON feature:
feature = json.loads(esri_input)
result = esri_to_geo(feature)
optional: response = json.dumps(result)

Still in the works:
- parse all geometry types
""";

Map esriToGeo(esrijson) {
  var geojson = {};
  // first, grab the properties
  var features = esrijson["features"] as List;
  var esriGeomType = esrijson["geometryType"];
  geojson["type"] = "FeatureCollection";

  // Not sure how to distinguish a single
  // Feature from an array of a single Feature
  // Or do I even have to?
  /* var count = features.length;
  if (count > 1) {
    geojson["type"] = "FeatureCollection";
  } else {
    geojson["type"] = "Feature";
  } */
  var feats = [];
  for (var feat in features) {
    feats.add(extract(feat, esriGeomType));
  }

  geojson["features"] = feats;

  return geojson;
}

extract(feature, esriGeomType) {
  var item = {};
  item["type"] = "Feature";
  // use the esri geometryType
  // to determine how the coordinates array
  // will be defined
  var geom = feature["geometry"];
  var geometry = {};
  geometry["type"] = getGeomType(esriGeomType);
  geometry["coordinates"] = getCoordinates(geom, geometry["type"]);
  item["geometry"] = geometry;
  // can just make a direct
  // copy of the attributes to properties
  item["properties"] = feature["attributes"];

  return item;
}

getGeomType(String esriType) {
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

getCoordinates(geom, geomType) {
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
