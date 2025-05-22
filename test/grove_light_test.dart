/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

@TestOn('vm')
library;

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
  group('LM358', () {
    // Mock the Mraa AIO interface
    final Mraa mraa = MockMraa();
    final MraaAio mraaAio = MockMraaAio();
    final contextAddr = calloc.allocate<MraaAioContext>(1).address;
    final context = MraaAioContext.fromAddress(contextAddr);
    when(() => mraa.aio).thenReturn(mraaAio);

    test('Values 1024 bit ADC', () {
      final light = GroveLightLM358(mraa, context);
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
        1000,
      ];
      when(() => mraaAio.getBit(context)).thenReturn(10);
      when(
        () => mraaAio.read(context),
      ).thenAnswer((_) => lightResponses.removeAt(0));
      var values = light.values;
      expect(values.lux.toStringAsFixed(2), '0.65');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '1.90');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '3.88');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '6.95');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '11.82');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '20.00');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '35.19');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '68.91');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '178.24');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '1918.26');
    });
    test('Values 4096 bit ADC', () {
      final light = GroveLightLM358(mraa, context);
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
        4000,
      ];
      when(() => mraaAio.getBit(context)).thenReturn(12);
      when(
        () => mraaAio.read(context),
      ).thenAnswer((_) => lightResponses.removeAt(0));
      var values = light.values;
      expect(values.lux.toStringAsFixed(2), '0.09');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '0.65');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '3.88');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '6.94');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '11.79');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '19.95');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '35.08');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '68.60');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '176.80');
      values = light.values;
      expect(values.lux.toStringAsFixed(2), '1837.92');
    });
  });
  return 0;
}
