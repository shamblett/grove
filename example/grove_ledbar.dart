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
import 'example_config.dart';

/// Simple exercises for the Grove Led Bar
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
    print('ERROR: Failed to initialise MRAA, return code is $ret');
    return -1;
  }

  print('Getting platform name');
  final platformName = mraa.common.platformName();
  print('The platform name is : $platformName');

  /// The Led Bar sensor initialisation
  print('Initialising the Led bar');
  final dataContext = mraa.gpio.initialise(dataGPIOPin);
  final clockContext = mraa.gpio.initialise(clockGPIOPin);
  final ledBar = GroveLedBarMy9221(mraa, clockContext, dataContext);

  /// Initialise is a monitored sequence, if it fails check the [monitored] status.
  final result = ledBar.initialise();
  if (!result) {
    print('ERROR - failed to initialise the led bar');
    print(ledBar.monitored.failureValues);
    return -1;
  }

  /// Set auto refresh
  ledBar.autoRefresh = true;

  print('All on/off');
  ledBar.clearAll();
  sleep(const Duration(milliseconds: 2000));
  ledBar.setAll();
  sleep(const Duration(milliseconds: 2000));
  ledBar.clearAll();
  sleep(const Duration(milliseconds: 2000));

  print('Exercising the Led Bar');
  ledBar.setLed(9, on: true);
  sleep(const Duration(milliseconds: 500));

  ledBar.setLed(8, on: true);
  sleep(const Duration(milliseconds: 500));

  ledBar.setLed(7, on: true);
  sleep(const Duration(milliseconds: 500));

  ledBar.setLed(1, on: true);
  sleep(const Duration(milliseconds: 500));

  ledBar.setLed(2, on: true);
  sleep(const Duration(milliseconds: 500));

  ledBar.setLed(3, on: true);
  sleep(const Duration(milliseconds: 500));

  ledBar.clearAll();
  sleep(const Duration(milliseconds: 2000));

  print('Random single bars');
  for (var i = 0; i < 19; i++) {
    final state = Random().nextInt(9);
    ledBar.setLed(state, on: true);
    sleep(const Duration(milliseconds: 2000));
    ledBar.setLed(state, on: false);
  }

  print('Random levels');
  for (var i = 0; i < 19; i++) {
    final state = Random().nextInt(10);
    ledBar.setLevel(state);
    sleep(const Duration(milliseconds: 2000));
  }

  ledBar.clearAll();

  return 0;
}
