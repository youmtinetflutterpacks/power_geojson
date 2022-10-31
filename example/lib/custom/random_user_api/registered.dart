import 'dart:convert';

import 'package:collection/collection.dart';

class Registered {
  DateTime? date;
  int? age;

  Registered({this.date, this.age});

  @override
  String toString() => 'Registered(date: $date, age: $age)';

  factory Registered.fromMap(Map<String, dynamic> data) => Registered(
        date: data['date'] == null
            ? null
            : DateTime.parse(data['date'] as String),
        age: data['age'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'date': date?.toIso8601String(),
        'age': age,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Registered].
  factory Registered.fromJson(String data) {
    return Registered.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Registered] to a JSON string.
  String toJson() => json.encode(toMap());

  Registered copyWith({
    DateTime? date,
    int? age,
  }) {
    return Registered(
      date: date ?? this.date,
      age: age ?? this.age,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Registered) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => date.hashCode ^ age.hashCode;
}
