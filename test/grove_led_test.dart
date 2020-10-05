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
      final dataPin = Pointer<MraaGpioContext>.fromAddress(1);

      test('Initialise - success', () {
        when(mraaGpio.direction(any, MraaGpioDirection.out))
            .thenReturn(MraaReturnCode.success);
        final ledbar = GroveLedBarMy9221(mraa, clockPin, dataPin);
        expect(ledbar.deviceContext.initialized, isFalse);
        final ret = ledbar.initialise();
        verify(mraaGpio.direction(any, MraaGpioDirection.out)).called(2);
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
      test('Initialise - clock pin fail', () {
        when(mraaGpio.direction(clockPin, MraaGpioDirection.out))
            .thenReturn(MraaReturnCode.errorUnspecified);
        final ledbar = GroveLedBarMy9221(mraa, clockPin, dataPin);
        expect(ledbar.deviceContext.initialized, isFalse);
        final ret = ledbar.initialise();
        verify(mraaGpio.direction(any, MraaGpioDirection.out)).called(1);
        expect(ret, MraaReturnCode.errorUnspecified);
        expect(ledbar.deviceContext.autoRefresh, isFalse);
        expect(ledbar.deviceContext.lowIntensity, isNull);
        expect(ledbar.deviceContext.highIntensity, isNull);
        expect(ledbar.deviceContext.commandWord, isNull);
        expect(ledbar.deviceContext.instances, isNull);
        expect(ledbar.deviceContext.bitStates, isNull);
        expect(ledbar.deviceContext.maxLed, isNull);
        expect(ledbar.deviceContext.initialized, isFalse);
      });
      test('Initialise - data pin fail', () {
        when(mraaGpio.direction(clockPin, MraaGpioDirection.out))
            .thenReturn(MraaReturnCode.success);
        when(mraaGpio.direction(dataPin, MraaGpioDirection.out))
            .thenReturn(MraaReturnCode.errorUnspecified);
        final ledbar = GroveLedBarMy9221(mraa, clockPin, dataPin);
        expect(ledbar.deviceContext.initialized, isFalse);
        final ret = ledbar.initialise();
        verify(mraaGpio.direction(any, MraaGpioDirection.out)).called(2);
        expect(ret, MraaReturnCode.errorUnspecified);
        expect(ledbar.deviceContext.autoRefresh, isFalse);
        expect(ledbar.deviceContext.lowIntensity, isNull);
        expect(ledbar.deviceContext.highIntensity, isNull);
        expect(ledbar.deviceContext.commandWord, isNull);
        expect(ledbar.deviceContext.instances, isNull);
        expect(ledbar.deviceContext.bitStates, isNull);
        expect(ledbar.deviceContext.maxLed, isNull);
        expect(ledbar.deviceContext.initialized, isFalse);
      });
      test('Close', () {
        when(mraaGpio.direction(any, MraaGpioDirection.out))
            .thenReturn(MraaReturnCode.success);
        final ledbar = GroveLedBarMy9221(mraa, clockPin, dataPin);
        expect(ledbar.deviceContext.initialized, isFalse);
        final ret = ledbar.initialise();
        expect(ret, MraaReturnCode.success);
        ledbar.setAll();
        expect(
            ledbar.deviceContext.bitStates
                .every((e) => e == ledbar.deviceContext.highIntensity),
            isTrue);
        when(mraaGpio.close(any)).thenReturn(MraaReturnCode.success);
        ledbar.close();
        expect(
            ledbar.deviceContext.bitStates
                .every((e) => e == ledbar.deviceContext.lowIntensity),
            isTrue);
        expect(ledbar.deviceContext.initialized, isFalse);
      });
      test('Set Level', () {
        when(mraaGpio.direction(any, MraaGpioDirection.out))
            .thenReturn(MraaReturnCode.success);
        final ledbar = GroveLedBarMy9221(mraa, clockPin, dataPin);
        expect(ledbar.deviceContext.initialized, isFalse);
        final ret = ledbar.initialise();
        expect(ret, MraaReturnCode.success);
        expect(
            ledbar.deviceContext.bitStates
                .every((e) => e == ledbar.deviceContext.lowIntensity),
            isTrue);
        ledbar.setLevel(-1);
        expect(
            ledbar.deviceContext.bitStates
                .every((e) => e == ledbar.deviceContext.lowIntensity),
            isTrue);
        ledbar.setLevel(5);
        expect(
            ledbar.deviceContext.bitStates
                .take(5)
                .every((e) => e == ledbar.deviceContext.highIntensity),
            isTrue);
        ledbar.setLevel(11);
        expect(
            ledbar.deviceContext.bitStates
                .every((e) => e == ledbar.deviceContext.highIntensity),
            isTrue);
      });
      test('Set Led', () {
        when(mraaGpio.direction(any, MraaGpioDirection.out))
            .thenReturn(MraaReturnCode.success);
        final ledbar = GroveLedBarMy9221(mraa, clockPin, dataPin);
        expect(ledbar.deviceContext.initialized, isFalse);
        final ret = ledbar.initialise();
        expect(ret, MraaReturnCode.success);
        expect(
            ledbar.deviceContext.bitStates
                .every((e) => e == ledbar.deviceContext.lowIntensity),
            isTrue);
        ledbar.setLed(-1, on: true);
        expect(ledbar.deviceContext.bitStates[0],
            ledbar.deviceContext.highIntensity);
        ledbar.setLed(5, on: true);
        expect(ledbar.deviceContext.bitStates[5],
            ledbar.deviceContext.highIntensity);
        ledbar.setLed(14, on: true);
        expect(ledbar.deviceContext.bitStates[0],
            ledbar.deviceContext.highIntensity);
        ledbar.setLed(5);
        expect(ledbar.deviceContext.bitStates[5],
            ledbar.deviceContext.lowIntensity);
      });
    });
  });

  return 0;
}
