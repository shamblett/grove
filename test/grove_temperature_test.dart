/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

@TestOn('vm')

import 'package:ffi/ffi.dart';
import 'package:grove/grove.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mraa/mraa.dart';
import 'package:test/test.dart';

class MockMraa extends Mock implements Mraa {}

class MockMraaAio extends Mock implements MraaAio {}

int main() {
  setUpAll(() {
    final mraaAioContextAddr = MraaAioContext.fromAddress(1);
    registerFallbackValue(mraaAioContextAddr);
  });

  group('V12', () {
    // Mock the Mraa AIO interface
    final Mraa mraa = MockMraa();
    final MraaAio mraaAio = MockMraaAio();
    final contextAddr = calloc.allocate<MraaAioContext>(1).address;
    final context = MraaAioContext.fromAddress(contextAddr);
    when(() => mraa.aio).thenReturn(mraaAio);

    test('Values', () {
      final temperature = GroveTemperatureV12(mraa, context);
      final temperatureResponses = <int>[
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
      when(() => mraaAio.read(context))
          .thenAnswer((_) => temperatureResponses.removeAt(0));

      var values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '-15.01');
      values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '-1.77');
      values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '7.77');
      values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '16.06');
      values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '24.07');
      values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '32.45');
      values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '42.00');
      values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '54.16');
      values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '73.05');
      values = temperature.values;
      expect(values.celsius.toStringAsFixed(2), '131.44');
    });
  });

  return 0;
}
