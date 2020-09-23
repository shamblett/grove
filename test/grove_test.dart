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

@TestOn('VM')
class MockMraa extends Mock implements Mraa {}
class MockMraaAio extends Mock implements MraaAio {}

int main() {
  group('Environment', () {
    // Mock the Mraa AIO interface
    final Mraa mraa = MockMraa();
    final MraaAio mraaAio = MockMraaAio();
    final context = allocate<MraaAioContext>();
    when(mraa.aio).thenReturn(mraaAio);

    group('Light', () {
      test('Lux values 1024 bit', () {
        final light = GroveLightLM358(mraa, context);
        // Response values
        final lightResponses = <int>[
          100,
          200,
          300,
          400,
          500,
          600,
          700,
          800,
          900,
          1000
        ];
        when(mraaAio.getBit(context)).thenReturn(10);
        when(mraaAio.read(context)).thenAnswer((_) =>
            lightResponses.removeAt(0));
        var values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '0.65');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '1.90');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '3.88');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '6.95');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '11.82');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '20.00');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '35.19');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '68.91');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '178.24');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '1918.26');
      });
      test('Lux values 4096 bit', () {
        final light = GroveLightLM358(mraa, context);
        // Response values
        final lightResponses = <int>[
          100,
          400,
          1200,
          1600,
          2000,
          2400,
          2800,
          3200,
          3600,
          4000
        ];
        when(mraaAio.getBit(context)).thenReturn(12);
        when(mraaAio.read(context)).thenAnswer((_) =>
            lightResponses.removeAt(0));
        var values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '0.09');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '0.65');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '3.88');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '6.94');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '11.79');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '19.95');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '35.08');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '68.60');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '176.80');
        values = light.getValues();
        expect(values.lux.toStringAsFixed(2), '1837.92');
      });
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
