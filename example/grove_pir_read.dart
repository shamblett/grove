/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

import 'dart:io';
import 'package:mraa/mraa.dart';
import 'package:grove/grove.dart';
import 'example_config.dart';

/// Checks if the Grove PIR motion sensor has been triggered
int main() {
  final mraa =
      Mraa.fromLib(mraaLibraryPath)
        ..noJsonLoading = noJsonLoading
        ..useGrovePi = useGrovePi
        ..initialise();

  // Version
  final mraaVersion = mraa.common.version();
  print('Mraa version is : $mraaVersion');

  print('Initialising MRAA');
  final ret = mraa.common.initialise();
  if (ret != MraaReturnCode.success) {
    print('Failed to initialise MRAA, return code is $ret');
  }

  print('Getting platform name');
  final platformName = mraa.common.platformName();
  print('The platform name is : $platformName');

  /// The PIR sensor initialisation
  print('Initialising GPIO');
  final context = mraa.gpio.initialise(pirSensorGPIOPin);

  print('Checking for a PIR motion trigger');
  final pir = GrovePir(mraa, context);
  for (var i = 1; i <= 10000; i++) {
    print('Current value is ${pir.value}');
    if (pir.hasTriggered) {
      print('PIR has triggered');
    }
    sleep(const Duration(milliseconds: 300));
  }

  return 0;
}
