/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 10/11/2019
 * Copyright :  S.Hamblett
 */

import 'dart:io';
import 'dart:math';
import 'package:mraa/mraa.dart';
import 'package:grove/grove.dart';

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print

// The GPIO pins for the Grove Led bar, set as needed.
const int clockGPIOPin = 59;
const int dataGPIOPin = 57;

/// Simple exercises for the Grove Led Bar
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

  /// The Led Bar sensor initialisation
  print('Initialising the Led bar');
  final dataContext = mraa.gpio.initialise(dataGPIOPin);
  final clockContext = mraa.gpio.initialise(clockGPIOPin);
  final ledbar = GroveLedBar(mraa, clockContext, dataContext)..initialise();

  print('All on/off');
  ledbar.clearAll();
  sleep(const Duration(milliseconds: 2000));
  ledbar.setAll();
  sleep(const Duration(milliseconds: 2000));
  ledbar.clearAll();
  sleep(const Duration(milliseconds: 2000));

  print('Exercising the Led Bar');
  ledbar.setLed(9, on: true);
  sleep(const Duration(milliseconds: 500));

  ledbar.setLed(8, on: true);
  sleep(const Duration(milliseconds: 500));

  ledbar.setLed(7, on: true);
  sleep(const Duration(milliseconds: 500));

  ledbar.setLed(1, on: true);
  sleep(const Duration(milliseconds: 500));

  ledbar.setLed(2, on: true);
  sleep(const Duration(milliseconds: 500));

  ledbar.setLed(3, on: true);
  sleep(const Duration(milliseconds: 500));

  ledbar.clearAll();
  sleep(const Duration(milliseconds: 2000));

  print('Random single bars');
  for (var i = 0; i < 19; i++) {
    final state = Random().nextInt(9);
    ledbar.setLed(state, on: true);
    sleep(const Duration(milliseconds: 2000));
    ledbar.setLed(state, on: false);
  }

  print('Random levels');
  for (var i = 0; i < 19; i++) {
    final state = Random().nextInt(10);
    ledbar.setLevel(state);
    sleep(const Duration(milliseconds: 2000));
  }

  ledbar.clearAll();

  return 0;
}
