import 'dart:convert';

import 'package:collection/collection.dart';

class Timezone {
  String? offset;
  String? description;

  Timezone({this.offset, this.description});

  @override
  String toString() {
    return 'Timezone(offset: $offset, description: $description)';
  }

  factory Timezone.fromMap(Map<String, dynamic> data) => Timezone(
        offset: data['offset'] as String?,
        description: data['description'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'offset': offset,
        'description': description,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Timezone].
  factory Timezone.fromJson(String data) {
    return Timezone.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Timezone] to a JSON string.
  String toJson() => json.encode(toMap());

  Timezone copyWith({
    String? offset,
    String? description,
  }) {
    return Timezone(
      offset: offset ?? this.offset,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Timezone) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => offset.hashCode ^ description.hashCode;
}
