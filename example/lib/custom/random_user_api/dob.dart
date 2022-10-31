import 'dart:convert';

import 'package:collection/collection.dart';

class Dob {
  DateTime? date;
  int? age;

  Dob({this.date, this.age});

  @override
  String toString() => 'Dob(date: $date, age: $age)';

  factory Dob.fromMap(Map<String, dynamic> data) => Dob(
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
  /// Parses the string and returns the resulting Json object as [Dob].
  factory Dob.fromJson(String data) {
    return Dob.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Dob] to a JSON string.
  String toJson() => json.encode(toMap());

  Dob copyWith({
    DateTime? date,
    int? age,
  }) {
    return Dob(
      date: date ?? this.date,
      age: age ?? this.age,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Dob) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => date.hashCode ^ age.hashCode;
}
