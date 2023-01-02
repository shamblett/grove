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

class MockMraaGpio extends Mock implements MraaGpio {}

int main() {
  setUpAll(() {
    final mraaGpioContextAddr = MraaGpioContext.fromAddress(1);
    registerFallbackValue(mraaGpioContextAddr);
  });

  group('Infrared', () {
    // Mock the Mraa GPIO interface
    final Mraa mraa = MockMraa();
    final MraaGpio mraaGpio = MockMraaGpio();
    final contextAddr = calloc.allocate<MraaGpioContext>(1).address;
    final context = MraaGpioContext.fromAddress(contextAddr);
    when(() => mraa.gpio).thenReturn(mraaGpio);

    test('Values and triggers', () {
      final pir = GrovePir(mraa, context);
      final pirResponses = <int>[
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        0
      ];
      when(() => mraaGpio.read(context))
          .thenAnswer((_) => pirResponses.removeAt(0));

      var value = pir.value;
      expect(value, 0);
      expect(pir.hasTriggered, isFalse);
      value = pir.value;
      expect(value, 0);
      expect(pir.hasTriggered, isFalse);
      value = pir.value;
      expect(value, 0);
      expect(pir.hasTriggered, isFalse);
      value = pir.value;
      expect(value, 1);
      expect(pir.hasTriggered, isTrue);
      value = pir.value;
      expect(value, 1);
      expect(pir.hasTriggered, isTrue);
      value = pir.value;
      expect(value, 1);
      expect(pir.hasTriggered, isTrue);
      value = pir.value;
      expect(pir.hasTriggered, isFalse);
      expect(value, 0);
      value = pir.value;
      expect(pir.hasTriggered, isFalse);
      expect(value, 0);
    });
  });

  return 0;
}
