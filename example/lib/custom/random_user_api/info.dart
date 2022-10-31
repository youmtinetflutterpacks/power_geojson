import 'dart:convert';

import 'package:collection/collection.dart';

class Info {
  String? seed;
  int? results;
  int? page;
  String? version;

  Info({this.seed, this.results, this.page, this.version});

  @override
  String toString() {
    return 'Info(seed: $seed, results: $results, page: $page, version: $version)';
  }

  factory Info.fromMap(Map<String, dynamic> data) => Info(
        seed: data['seed'] as String?,
        results: data['results'] as int?,
        page: data['page'] as int?,
        version: data['version'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'seed': seed,
        'results': results,
        'page': page,
        'version': version,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Info].
  factory Info.fromJson(String data) {
    return Info.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Info] to a JSON string.
  String toJson() => json.encode(toMap());

  Info copyWith({
    String? seed,
    int? results,
    int? page,
    String? version,
  }) {
    return Info(
      seed: seed ?? this.seed,
      results: results ?? this.results,
      page: page ?? this.page,
      version: version ?? this.version,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Info) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode =>
      seed.hashCode ^ results.hashCode ^ page.hashCode ^ version.hashCode;
}
