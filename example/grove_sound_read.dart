/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/11/2019
 * Copyright :  S.Hamblett
 */

import 'dart:io';
import 'package:mraa/mraa.dart';
import 'package:grove/grove.dart';
import 'example_config.dart';

/// Read the sound level from the sound sensor
int main() {
  final mraa = Mraa.fromLib(mraaLibraryPath)
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

  /// Initialise the sound sensor
  print('Initialising AIO');
  final context = mraa.aio.initialise(soundSensorAIOPin);

  print('Reading the sound sensor values');
  final sound = GroveSoundLM386(mraa, context);
  for (var i = 1; i <= 100; i++) {
    print('Current raw sound value is : ${sound.value}');
    print('Current smoothed sound value is : ${sound.smoothed}');
    print('Current scaled value is ${sound.scaled}');
    print('Current smooth scaled value is ${sound.smoothScaled}');
    sleep(const Duration(milliseconds: 200));
  }

  return 0;
}
