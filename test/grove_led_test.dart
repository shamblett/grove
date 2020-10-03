/*
 * Package : mraa
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

import 'dart:ffi';
import 'package:grove/grove.dart';
import 'package:mockito/mockito.dart';
import 'package:mraa/mraa.dart';
import 'package:test/test.dart';

@TestOn('VM')
class MockMraa extends Mock implements Mraa {}

class MockMraaGpio extends Mock implements MraaGpio {}

int main() {
  group('Led Bar', () {
    // Mock the Mraa GPIO interface
    final Mraa mraa = MockMraa();
    final MraaGpio mraaGpio = MockMraaGpio();
    when(mraa.gpio).thenReturn(mraaGpio);

    group('MY9221', () {
      final clockPin = Pointer<MraaGpioContext>.fromAddress(0);
      final dataPin = Pointer<MraaGpioContext>.fromAddress(0);
      test('Initialise - no auto refresh - success', () {
        when(mraaGpio.direction(any, MraaGpioDirection.out))
            .thenReturn(MraaReturnCode.success);
        final ledbar = GroveLedBarMy9221(mraa, clockPin, dataPin);
        expect(ledbar.deviceContext.initialized, isFalse);
        ledbar.autoRefresh = false;
        final ret = ledbar.initialise();
        expect(ret, MraaReturnCode.success);
        expect(ledbar.deviceContext.autoRefresh, isFalse);
        expect(ledbar.deviceContext.lowIntensity, 0);
        expect(ledbar.deviceContext.highIntensity, 0xff);
        expect(ledbar.deviceContext.commandWord, 0);
        expect(ledbar.deviceContext.instances, 1);
        expect(ledbar.deviceContext.bitStates.length, 12);
        expect(
            ledbar.deviceContext.bitStates
                .every((e) => e == ledbar.deviceContext.lowIntensity),
            isTrue);
        expect(ledbar.deviceContext.maxLed, 12);
        expect(ledbar.deviceContext.initialized, isTrue);
      });
    });
  });

  return 0;
}
