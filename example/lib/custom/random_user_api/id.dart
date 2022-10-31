import 'dart:convert';

import 'package:collection/collection.dart';

class Id {
  String? name;
  dynamic value;

  Id({this.name, this.value});

  @override
  String toString() => 'Id(name: $name, value: $value)';

  factory Id.fromMap(Map<String, dynamic> data) => Id(
        name: data['name'] as String?,
        value: data['value'] as dynamic,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'value': value,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Id].
  factory Id.fromJson(String data) {
    return Id.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Id] to a JSON string.
  String toJson() => json.encode(toMap());

  Id copyWith({
    String? name,
    dynamic value,
  }) {
    return Id(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Id) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}
