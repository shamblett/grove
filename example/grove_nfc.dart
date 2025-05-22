/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/10/2019
 * Copyright :  S.Hamblett
 */

import 'package:mraa/mraa.dart';
import 'package:grove/grove.dart';
import 'example_config.dart';

/// An example of usage of the PN235 NFC device.
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
    return -1;
  }

  print('Getting platform name');
  final platformName = mraa.common.platformName();
  print('The platform name is : $platformName');

  // Initialise the NFC device
  print('Initialising the NFC device on tty $defaultUart');
  final nfc = GroveNfcPn532(mraa, tty: defaultUart);
  final ok = nfc.initialise();
  if (!ok) {
    print('Failed to initialise the NFC device');
    return -1;
  }

  // Get the firmware version
  print('Getting the NFC firmware version');
  final firmware = nfc.firmwareVersion();
  if (firmware == 0) {
    print('Failed to get the firmware version');
    return -1;
  } else {
    print('NFC firmware version is $firmware');
  }

  return 0;
}
