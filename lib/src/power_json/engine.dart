import 'dart:convert';

import 'package:flutter/material.dart';

class PowerJSON {
  final StringSink _buffer = StringBuffer('');
  final List<bool> _hasItemsOnLevel = List<bool>.of(<bool>[false]);
  final Map<String, Object?> _properties;
  final List<_PrivateContainer> _containerTypeOnLevel =
      List<_PrivateContainer>.of(<_PrivateContainer>[_PrivateContainer.root]);
  final String _startSquareBracket = '[';
  final String _endSquareBracket = ']';
  final String _startCurlyBracket = '{';
  final String _endCurlyBracket = '}';

  PowerJSON(this._properties) {
    _printMapEntryRecursive('', _properties);
  }

  bool _markItem() {
    final bool result = _hasItemsOnLevel.last;
    if (!result) {
      _hasItemsOnLevel[_hasItemsOnLevel.length - 1] = true;
    }
    return result;
  }

  void _printMapEntryRecursive(String name, Object? value) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (name.isNotEmpty) {
      // Fix: Avoid writing empty keys
      _buffer.write('"$name":');
    }
    if (value is Map<String, dynamic>) {
      _printMap(value);
    } else if (value is Iterable<dynamic>) {
      _printArray(value);
    } else {
      _printValue(value);
    }
  }

  void _printMap(Map<String, dynamic> map) {
    _startContainer(_PrivateContainer.propertyMap);
    _buffer.write(_startCurlyBracket);
    for (final MapEntry<String, dynamic> entry in map.entries) {
      _printMapEntryRecursive(entry.key, entry.value);
    }
    _buffer.write(_endCurlyBracket);
    _endContainer();
  }

  void _printArray(Iterable<dynamic> array) {
    _startContainer(_PrivateContainer.propertyArray);
    _buffer.write(_startSquareBracket);
    for (dynamic item in array) {
      _printArrayItemRecursive(item); // Fix: Allow any type, not just List
    }
    _buffer.write(_endSquareBracket);
    _endContainer();
  }

  void _printArrayItemRecursive(Object? value) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (value is Map<String, dynamic>) {
      _printMap(value);
    } else if (value is Iterable<dynamic>) {
      _printArray(value);
    } else {
      _printValue(value);
    }
  }

  void _startContainer(_PrivateContainer type) {
    _hasItemsOnLevel.add(false);
    _containerTypeOnLevel.add(type);
  }

  void _endContainer() {
    _hasItemsOnLevel.removeLast();
    _containerTypeOnLevel.removeLast();
  }

  void _printValue(Object? value) {
    if (value == null || value is bool || value is num || value is BigInt) {
      _buffer.write(value.toString());
    } else if (value is DateTime) {
      _buffer.write('"${value.toIso8601String()}"');
    } else if (value is Enum) {
      _buffer.write('"${value.name}"');
    } else if (value is TimeOfDay) {
      _buffer.write('"${value.toString()}"');
    } else {
      _buffer.write(jsonEncode(value));
    }
  }

  String toText() {
    return _buffer.toString(); // Fix: Don't arbitrarily cut characters
  }

  ////////////////////////
  ///
}

enum _PrivateContainer { root, propertyMap, propertyArray }
