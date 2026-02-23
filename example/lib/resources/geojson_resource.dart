import 'package:uuid/uuid.dart';

// ─── Enumerations ─────────────────────────────────────────────────────────────

enum GeoJsonSourceType { network, file, string }

enum GeoJsonGeomType { auto, polygon, polyline, point }

// ─── Model ────────────────────────────────────────────────────────────────────

class GeoJsonResource {
  GeoJsonResource({String? id, required this.label, required this.sourceType, this.geomType = GeoJsonGeomType.auto, this.data, this.url, this.isCustom = true}) : id = id ?? const Uuid().v4();

  final String id;
  final String label;
  final GeoJsonSourceType sourceType;
  final GeoJsonGeomType geomType;

  /// Raw GeoJSON string — used for [GeoJsonSourceType.string] and cached files.
  final String? data;

  /// Remote URL — used for [GeoJsonSourceType.network].
  final String? url;

  /// Custom resources can be deleted; predefined ones cannot.
  final bool isCustom;

  // ── Serialisation ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'sourceType': sourceType.name, 'geomType': geomType.name, 'data': data, 'url': url, 'isCustom': isCustom};

  factory GeoJsonResource.fromJson(Map<String, dynamic> json) => GeoJsonResource(id: json['id'] as String, label: json['label'] as String, sourceType: GeoJsonSourceType.values.byName(json['sourceType'] as String), geomType: GeoJsonGeomType.values.byName(json['geomType'] as String), data: json['data'] as String?, url: json['url'] as String?, isCustom: json['isCustom'] as bool? ?? true);

  GeoJsonResource copyWith({String? label, GeoJsonSourceType? sourceType, GeoJsonGeomType? geomType, String? data, String? url, bool? isCustom}) => GeoJsonResource(id: id, label: label ?? this.label, sourceType: sourceType ?? this.sourceType, geomType: geomType ?? this.geomType, data: data ?? this.data, url: url ?? this.url, isCustom: isCustom ?? this.isCustom);
}
