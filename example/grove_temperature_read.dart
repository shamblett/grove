/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

import 'dart:io';
import 'package:mraa/mraa.dart';
import 'package:grove/grove.dart';

// The AIO pin for the temperature sensor, set as needed.
const int temperatureSensorAIOPin = 2;

/// Read the current temperature value using AIO from the Grove
/// temperature sensor
int main() {
  // Initialise from our Beaglebone Mraa lib version 2.0.0 with no JSON loading.
  // Please change this for your platform.
  final mraa = Mraa.fromLib('lib/libmraa.so.2.0.0')
    ..noJsonLoading = true
    ..initialise();

  // Version
  final mraaVersion = mraa.common.version();
  print('Mraa version is : $mraaVersion');

  print('Initialising MRAA');
  final ret = mraa.common.initialise();
  if (ret != MraaReturnCode.success) {
    print('Failed to initialise MRAA, return code is '
        '${returnCode.asString(ret)}');
  }

  print('Getting platform name');
  final platformName = mraa.common.platformName();
  print('The platform name is : $platformName');

  /// Initialise the temperature sensor
  print('Initialising AIO');
  final context = mraa.aio.initialise(temperatureSensorAIOPin);

  print('Reading the temperature sensor values');
  final temperature = GroveTemperature(mraa, context);
  for (var i = 1; i <= 100; i++) {
    final values = temperature.getValues();
    print(values);
    sleep(const Duration(milliseconds: 2000));
  }

  return 0;
}
