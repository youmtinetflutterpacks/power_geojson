import 'dart:convert';

import 'package:collection/collection.dart';

import 'info.dart';
import 'result.dart';

class RandomUserApi {
  List<Result>? results;
  Info? info;

  RandomUserApi({this.results, this.info});

  @override
  String toString() => 'RandomUserApi(results: $results, info: $info)';

  factory RandomUserApi.fromMap(Map<String, dynamic> data) => RandomUserApi(
        results: (data['results'] as List<dynamic>?)
            ?.map((e) => Result.fromMap(e as Map<String, dynamic>))
            .toList(),
        info: data['info'] == null
            ? null
            : Info.fromMap(data['info'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'results': results?.map((e) => e.toMap()).toList(),
        'info': info?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [RandomUserApi].
  factory RandomUserApi.fromJson(String data) {
    return RandomUserApi.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [RandomUserApi] to a JSON string.
  String toJson() => json.encode(toMap());

  RandomUserApi copyWith({
    List<Result>? results,
    Info? info,
  }) {
    return RandomUserApi(
      results: results ?? this.results,
      info: info ?? this.info,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! RandomUserApi) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => results.hashCode ^ info.hashCode;
}
