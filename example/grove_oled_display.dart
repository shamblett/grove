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
import 'images/grove_seeed_logo.dart';

/// Output to the Grove OLED display.
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

  /// The OLED initialisation
  print('Initialising OLED');
  final context = mraa.i2c.initialise(i2cBusId);

  /// You can pass an optional device address if you wish to override
  /// the default one.
  final oled = GroveOledSsd1327(mraa, context);

  final result = oled.initialise();
  if (!result) {
    print('ERROR - failed to initialise the OLED display');
    print(oled.monitored.failureValues);
    return -1;
  }

  print('Printing to the OLED');
  oled.setCursor(4, 0);
  oled.write('Hello from');
  oled.setCursor(5, 0);
  oled.write('the Dart VM');
  oled.setCursor(6, 0);
  oled.write('Brought to');
  oled.setCursor(7, 0);
  oled.write('you by FFI');
  oled.setCursor(8, 0);
  oled.write('and Intel\'s');
  oled.setCursor(9, 0);
  oled.write('MRAA library');

  print('Press a key to clear the display and continue.....');
  stdin.readByteSync();
  oled.home();
  oled.clear();
  print('Now lets draw a logo.....');
  oled.drawImage(seeedLogo96x96);
  print('Press a key to clear the display and exit .....');
  stdin.readByteSync();
  oled.home();
  oled.clear();

  return 0;
}
