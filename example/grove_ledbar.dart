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
  final ledbar = GroveLedBarMy9221(mraa, clockContext, dataContext)
    ..initialise();

  /// Set auto refresh
  ledbar.autoRefresh = true;

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
