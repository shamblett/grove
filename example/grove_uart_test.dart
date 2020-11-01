/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/10/2019
 * Copyright :  S.Hamblett
 */

import 'package:mraa/mraa.dart';
import 'example_config.dart';

/// A loopback test of the UART device, please ensure you have TX/RX looped back.
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

  // Initialise the UART device.
  print('Initialising UART $defaultUart');
  final context = mraa.uart.initialiseRaw(defaultUart);
  if (context == null) {
    print('Failed to initialise UART - no context');
    return -1;
  }

  // Send a string.
  print('Sending the test string to the UART');
  final buffer = MraaUartBuffer();
  buffer.utf8Data = 'Hello World!';
  var lret = mraa.uart.writeUtf8(context, buffer, buffer.utf8Length);
  if (lret != 12) {
    print('Failed to write string to UART, return is $lret');
    return -1;
  }

  // Read the response
  print('Reading the test string from the UART');
  buffer.utf8Data = '';
  lret = mraa.uart.readUtf8(context, buffer, 12);
  if (lret != 12) {
    print('Failed to read string from UART, return is $lret');
    return -1;
  }

  print('UART test completed successfully');
  return 0;
}
