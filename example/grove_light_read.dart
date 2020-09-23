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

/// Read the current light values using AIO from the Grove light sensor
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

  /// The light sensor initialisation
  print('Initialising AIO');
  final context = mraa.aio.initialise(lightSensorAIOPin);

  print('Reading the light sensor values');
  final light = GroveLightLM358(mraa, context);
  for (var i = 1; i <= 100; i++) {
    final values = light.getValues();
    print(values);
    sleep(const Duration(milliseconds: 2000));
  }

  return 0;
}
