/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/10/2019
 * Copyright :  S.Hamblett
 */

import 'package:mraa/mraa.dart';
import 'package:grove/grove.dart';
import 'example_config.dart';

/// An example of usage of the LORA RF95 device as a server application
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
    return -1;
  }

  print('Getting platform name');
  final platformName = mraa.common.platformName();
  print('The platform name is : $platformName');

  // Initialise the LORA RF95 device
  print('Initialising the LORA RF95 device on tty $defaultUart');
  final lora = GroveLoraRf95(mraa, tty: defaultUart);
  final ok = lora.initialise();
  if (!ok) {
    print('Failed to initialise the LORA RF95  device');
    return -1;
  }

  return 0;
}
