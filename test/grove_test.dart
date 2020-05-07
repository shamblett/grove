/*
 * Package : mraa
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

import 'package:ffi/ffi.dart';
import 'package:grove/grove.dart';
import 'package:mockito/mockito.dart';
import 'package:mraa/mraa.dart';
import 'package:test/test.dart';

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print

@TestOn('VM')
class MockMraa extends Mock implements Mraa {}

int main() {
  group('Environment', () {
    // Mock the Mraa AIO interface
    final Mraa mraa = MockMraa();
    final context = allocate<MraaAioContext>();

    test('Light - Lux values 1024 bit', () {
      final light = GroveLight(mraa, context);
      var values = light.calculateLux(100, 1024);
      expect(values.lux.toStringAsFixed(2), '0.65');
      values = light.calculateLux(200, 1024);
      expect(values.lux.toStringAsFixed(2), '1.90');
      values = light.calculateLux(300, 1024);
      expect(values.lux.toStringAsFixed(2), '3.88');
      values = light.calculateLux(400, 1024);
      expect(values.lux.toStringAsFixed(2), '6.93');
      values = light.calculateLux(500, 1024);
      expect(values.lux.toStringAsFixed(2), '11.79');
      values = light.calculateLux(600, 1024);
      expect(values.lux.toStringAsFixed(2), '19.93');
      values = light.calculateLux(700, 1024);
      expect(values.lux.toStringAsFixed(2), '35.04');
      values = light.calculateLux(800, 1024);
      expect(values.lux.toStringAsFixed(2), '68.50');
      values = light.calculateLux(900, 1024);
      expect(values.lux.toStringAsFixed(2), '176.32');
      values = light.calculateLux(1000, 1024);
      expect(values.lux.toStringAsFixed(2), '1812.44');
    });
    test('Light - Lux values 4096 bit', () {
      final light = GroveLight(mraa, context);
      var values = light.calculateLux(100, 4096);
      expect(values.lux.toStringAsFixed(2), '0.09');
      values = light.calculateLux(400, 4096);
      expect(values.lux.toStringAsFixed(2), '0.65');
      values = light.calculateLux(1200, 4096);
      expect(values.lux.toStringAsFixed(2), '3.88');
      values = light.calculateLux(1600, 4096);
      expect(values.lux.toStringAsFixed(2), '6.93');
      values = light.calculateLux(2000, 4096);
      expect(values.lux.toStringAsFixed(2), '11.79');
      values = light.calculateLux(2400, 4096);
      expect(values.lux.toStringAsFixed(2), '19.93');
      values = light.calculateLux(2800, 4096);
      expect(values.lux.toStringAsFixed(2), '35.04');
      values = light.calculateLux(3200, 4096);
      expect(values.lux.toStringAsFixed(2), '68.50');
      values = light.calculateLux(3600, 4096);
      expect(values.lux.toStringAsFixed(2), '176.32');
      values = light.calculateLux(4000, 4096);
      expect(values.lux.toStringAsFixed(2), '1812.44');
    });
    test('Temperature', () {
      final temperature = GroveTemperature(mraa, context);
      var values = temperature.calculateCelsius(100);
      expect(values.celsius.toStringAsFixed(2), '-15.01');
      values = temperature.calculateCelsius(200);
      expect(values.celsius.toStringAsFixed(2), '-1.77');
      values = temperature.calculateCelsius(300);
      expect(values.celsius.toStringAsFixed(2), '7.77');
      values = temperature.calculateCelsius(400);
      expect(values.celsius.toStringAsFixed(2), '16.06');
      values = temperature.calculateCelsius(500);
      expect(values.celsius.toStringAsFixed(2), '24.07');
      values = temperature.calculateCelsius(600);
      expect(values.celsius.toStringAsFixed(2), '32.45');
      values = temperature.calculateCelsius(700);
      expect(values.celsius.toStringAsFixed(2), '42.00');
      values = temperature.calculateCelsius(800);
      expect(values.celsius.toStringAsFixed(2), '54.16');
      values = temperature.calculateCelsius(900);
      expect(values.celsius.toStringAsFixed(2), '73.05');
      values = temperature.calculateCelsius(1000);
      expect(values.celsius.toStringAsFixed(2), '131.44');
    });
  });

  return 0;
}
