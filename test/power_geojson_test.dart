import 'package:flutter_test/flutter_test.dart';

class MockPowerGeojsonPlatform {
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {}
