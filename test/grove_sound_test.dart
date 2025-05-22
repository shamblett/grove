/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 27/09/2020
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

  group('LM386', () {
    // Mock the Mraa AIO interface
    final Mraa mraa = MockMraa();
    final MraaAio mraaAio = MockMraaAio();
    final contextAddr = calloc.allocate<MraaAioContext>(1).address;
    final context = MraaAioContext.fromAddress(contextAddr);
    when(() => mraa.aio).thenReturn(mraaAio);

    test('Construction', () {
      var sound = GroveSoundLM386(mraa, context, 10);
      expect(sound.sampleCount, 10);
      sound = GroveSoundLM386(mraa, context, 1000);
      expect(sound.sampleCount, 500);
      sound = GroveSoundLM386(mraa, context, 3);
      expect(sound.sampleCount, 5);
    });

    test('Values  - smoothed', () {
      final sound = GroveSoundLM386(mraa, context, 10);
      final soundResponses = <int>[
        100,
        200,
        300,
        200, // Smoothed start
        300,
        300,
        400,
        400,
        500,
        500,
        600,
        600,
        700, // Smoothed end
        700,
        800,
        900,
        1000,
      ];
      when(
        () => mraaAio.read(context),
      ).thenAnswer((_) => soundResponses.removeAt(0));

      var value = sound.value;
      expect(value, 100);
      value = sound.value;
      expect(value, 200);
      value = sound.value;
      expect(value, 300);
      var smoothed = sound.smoothed;
      expect(smoothed, 450);
      value = sound.value;
      expect(value, 700);
      value = sound.value;
      expect(value, 800);
      value = sound.value;
      expect(value, 900);
      value = sound.value;
      expect(value, 1000);
    });

    test('Values  - scaled', () {
      final sound = GroveSoundLM386(mraa, context, 10);
      final soundResponses = <int>[
        100,
        200,
        300,
        200, // Smoothed start
        300,
        300,
        400,
        400,
        500,
        500,
        600,
        600,
        700, // Smoothed end
        700,
        800,
        900,
        1000,
      ];
      when(
        () => mraaAio.read(context),
      ).thenAnswer((_) => soundResponses.removeAt(0));

      var value = sound.scaled;
      expect(value, 1);
      value = sound.scaled;
      expect(value, 2);
      value = sound.scaled;
      expect(value, 3);
      var smoothScaled = sound.smoothScaled;
      expect(smoothScaled, 4);
      value = sound.scaled;
      expect(value, 7);
      value = sound.scaled;
      expect(value, 8);
      value = sound.scaled;
      expect(value, 9);
      value = sound.scaled;
      expect(value, 10);
    });
  });

  return 0;
}
