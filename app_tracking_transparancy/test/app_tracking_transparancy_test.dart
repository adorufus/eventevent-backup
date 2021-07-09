import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_tracking_transparancy/app_tracking_transparancy.dart';

void main() {
  const MethodChannel channel = MethodChannel('app_tracking_transparancy');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await AppTrackingTransparancy.platformVersion, '42');
  });
}
