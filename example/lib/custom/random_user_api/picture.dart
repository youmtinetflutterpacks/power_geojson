import 'dart:convert';

import 'package:collection/collection.dart';

class Picture {
  String? large;
  String? medium;
  String? thumbnail;

  Picture({this.large, this.medium, this.thumbnail});

  @override
  String toString() {
    return 'Picture(large: $large, medium: $medium, thumbnail: $thumbnail)';
  }

  factory Picture.fromMap(Map<String, dynamic> data) => Picture(
        large: data['large'] as String?,
        medium: data['medium'] as String?,
        thumbnail: data['thumbnail'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'large': large,
        'medium': medium,
        'thumbnail': thumbnail,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Picture].
  factory Picture.fromJson(String data) {
    return Picture.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Picture] to a JSON string.
  String toJson() => json.encode(toMap());

  Picture copyWith({
    String? large,
    String? medium,
    String? thumbnail,
  }) {
    return Picture(
      large: large ?? this.large,
      medium: medium ?? this.medium,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Picture) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => large.hashCode ^ medium.hashCode ^ thumbnail.hashCode;
}
