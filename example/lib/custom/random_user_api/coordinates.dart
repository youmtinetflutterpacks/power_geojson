import 'dart:convert';

import 'package:collection/collection.dart';

class Coordinates {
  String? latitude;
  String? longitude;

  Coordinates({this.latitude, this.longitude});

  @override
  String toString() {
    return 'Coordinates(latitude: $latitude, longitude: $longitude)';
  }

  factory Coordinates.fromMap(Map<String, dynamic> data) => Coordinates(
        latitude: data['latitude'] as String?,
        longitude: data['longitude'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Coordinates].
  factory Coordinates.fromJson(String data) {
    return Coordinates.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Coordinates] to a JSON string.
  String toJson() => json.encode(toMap());

  Coordinates copyWith({
    String? latitude,
    String? longitude,
  }) {
    return Coordinates(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Coordinates) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
