import 'dart:convert';

import 'package:collection/collection.dart';

class Street {
  int? number;
  String? name;

  Street({this.number, this.name});

  @override
  String toString() => 'Street(number: $number, name: $name)';

  factory Street.fromMap(Map<String, dynamic> data) => Street(
        number: data['number'] as int?,
        name: data['name'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'number': number,
        'name': name,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Street].
  factory Street.fromJson(String data) {
    return Street.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Street] to a JSON string.
  String toJson() => json.encode(toMap());

  Street copyWith({
    int? number,
    String? name,
  }) {
    return Street(
      number: number ?? this.number,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Street) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => number.hashCode ^ name.hashCode;
}
