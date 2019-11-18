/*
 * Package : mraa
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:grove/grove.dart';
import 'package:mockito/mockito.dart';
import 'package:mraa/mraa.dart';
import 'package:test/test.dart';

@TestOn('VM')
class MockMraa extends Mock implements Mraa {}

int main() {
  group('Environment', () {
    // Mock the Mraa AIO interface
    final Mraa mraa = MockMraa();
    Pointer<MraaAioContext> context = allocate<MraaAioContext>();

    test('Light - Lux values 1024 bit', () {
      final GroveLight light = GroveLight(mraa, context);
      GroveLightValues values = light.calculateLux(100, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '0.65');
      values = light.calculateLux(200, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '1.90');
      values = light.calculateLux(300, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '3.88');
      values = light.calculateLux(400, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '6.93');
      values = light.calculateLux(500, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '11.79');
      values = light.calculateLux(600, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '19.93');
      values = light.calculateLux(700, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '35.04');
      values = light.calculateLux(800, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '68.50');
      values = light.calculateLux(900, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '176.32');
      values = light.calculateLux(1000, 1024);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '1812.44');
    });
    test('Light - Lux values 4096 bit', () {
      final GroveLight light = GroveLight(mraa, context);
      GroveLightValues values = light.calculateLux(100, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '0.09');
      values = light.calculateLux(400, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '0.65');
      values = light.calculateLux(1200, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '3.88');
      values = light.calculateLux(1600, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '6.93');
      values = light.calculateLux(2000, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '11.79');
      values = light.calculateLux(2400, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '19.93');
      values = light.calculateLux(2800, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '35.04');
      values = light.calculateLux(3200, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '68.50');
      values = light.calculateLux(3600, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '176.32');
      values = light.calculateLux(4000, 4096);
      print('${values.lux.toStringAsFixed(2)}');
      expect(values.lux.toStringAsFixed(2), '1812.44');
    });
  });

  return 0;
}
