import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_interceptor/http_interceptor.dart';

void main() {
  const MethodChannel channel = MethodChannel('http_interceptor');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await HttpInterceptor.platformVersion, '42');
  });
}
