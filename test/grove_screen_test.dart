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
  group('Oled', () {
    // Mock the Mraa GPIO interface
    final Mraa mraa = MockMraa();
    final MraaGpio mraaGpio = MockMraaGpio();
    when(mraa.gpio).thenReturn(mraaGpio);

    group('SSD1372', () {
      test('Initialise - success', () {});
    });
  });

  return 0;
}
