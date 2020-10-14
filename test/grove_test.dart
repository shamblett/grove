/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

import 'package:grove/grove.dart';
import 'package:mraa/mraa.dart';
import 'package:test/test.dart';

@TestOn('VM')
int main() {
  group('Sequence Monitor', () {
    test('Operation', () {
      final monitor =
          GroveSequenceMonitor<MraaReturnCode>(MraaReturnCode.success);
      expect(monitor.isOk, isFalse);
      expect(monitor.failureValues.isEmpty, isTrue);
      monitor + MraaReturnCode.success;
      monitor + MraaReturnCode.success;
      expect(monitor.isOk, isTrue);
      expect(monitor.failureValues.isEmpty, isTrue);
      monitor + MraaReturnCode.errorFeatureNotImplemented;
      monitor + MraaReturnCode.errorFeatureNotSupported;
      monitor + MraaReturnCode.success;
      expect(monitor.isOk, isFalse);
      expect(monitor.failureValues.isEmpty, isFalse);
      expect(
          monitor.failureValues[0], MraaReturnCode.errorFeatureNotImplemented);
      expect(monitor.failureValues[1], MraaReturnCode.errorFeatureNotSupported);
      monitor.reset();
      expect(monitor.isOk, isFalse);
      expect(monitor.failureValues.isEmpty, isTrue);
    });
  });

  return 0;
}
