import 'dart:convert';

import 'package:collection/collection.dart';

class Name {
  String? title;
  String? first;
  String? last;

  Name({this.title, this.first, this.last});

  @override
  String toString() => 'Name(title: $title, first: $first, last: $last)';

  factory Name.fromMap(Map<String, dynamic> data) => Name(
        title: data['title'] as String?,
        first: data['first'] as String?,
        last: data['last'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'first': first,
        'last': last,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Name].
  factory Name.fromJson(String data) {
    return Name.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Name] to a JSON string.
  String toJson() => json.encode(toMap());

  Name copyWith({
    String? title,
    String? first,
    String? last,
  }) {
    return Name(
      title: title ?? this.title,
      first: first ?? this.first,
      last: last ?? this.last,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Name) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => title.hashCode ^ first.hashCode ^ last.hashCode;
}
