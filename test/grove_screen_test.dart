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

class MockMraaI2c extends Mock implements MraaI2c {}

int main() {
  group('Oled', () {
    // Mock the Mraa interfaces
    final Mraa mraa = MockMraa();
    final MraaI2c mraaI2c = MockMraaI2c();
    when(mraa.i2c).thenReturn(mraaI2c);

    group('SSD1372', () {
      final context = Pointer<MraaI2cContext>.fromAddress(1);
      test('Initialise - success', () {
        final oled = GroveOledSsd1327(mraa, context);
        expect(oled.initialised, isFalse);
        expect(oled.monitored.isOk, isFalse);
        when(mraaI2c.writeByteData(context, any, any))
            .thenReturn(MraaReturnCode.success);
        final ret = oled.initialise();
        expect(ret, isTrue);
        expect(oled.initialised, isTrue);
        expect(oled.monitored.isOk, isTrue);
      });
      test('Initialise - fail', () {
        final oled = GroveOledSsd1327(mraa, context);
        expect(oled.initialised, isFalse);
        expect(oled.monitored.isOk, isFalse);
        when(mraaI2c.writeByteData(context, any, any))
            .thenReturn(MraaReturnCode.success);
        when(mraaI2c.writeByteData(context, 0xfd, 0x80))
            .thenReturn(MraaReturnCode.errorInvalidResource);
        when(mraaI2c.writeByteData(context, 0xab, 0x80))
            .thenReturn(MraaReturnCode.errorFeatureNotImplemented);
        final ret = oled.initialise();
        expect(ret, isFalse);
        expect(oled.initialised, isFalse);
        expect(oled.monitored.isOk, isFalse);
        expect(oled.monitored.failureValues.length, 2);
        expect(oled.monitored.failureValues[0],
            MraaReturnCode.errorInvalidResource);
        expect(oled.monitored.failureValues[1],
            MraaReturnCode.errorFeatureNotImplemented);
      });
    });
  });

  return 0;
}
