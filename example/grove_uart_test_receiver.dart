/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/10/2019
 * Copyright :  S.Hamblett
 */

import 'package:grove/grove.dart';
import 'package:mraa/mraa.dart';
import 'example_config.dart';

/// The reeiver part of loopback test of the UART device, please ensure you have TX/RX looped back.
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
  var ret = mraa.common.initialise();
  if (ret != MraaReturnCode.success) {
    print('Failed to initialise MRAA, return code is $ret');
    return -1;
  }

  print('Getting platform name');
  final platformName = mraa.common.platformName();
  print('The platform name is : $platformName');

  // Initialise the UART device.
  print('Initialising UART $defaultUart');
  final context = mraa.uart.initialiseRaw(defaultUart);

  // Baud rate
  ret = mraa.uart.baudRate(context, 115200);
  if (ret != MraaReturnCode.success) {
    print('Unable to set baud rate on UART');
    return -1;
  }
  // Mode 8N1
  ret = mraa.uart.mode(context, 8, MraaUartParity.none, 1);
  if (ret != MraaReturnCode.success) {
    print('Unable to set mode on UART');
    return -1;
  }

  print(
    'Reading the test string from the UART, you have 10 seconds to send....',
  );
  var message = <int>[];
  print('Starting receive.....');
  final ok = mraa.uart.receive(
    context,
    message,
    uartTestMessage.length,
    timeout: 10000,
  );
  if (ok) {
    final str = String.fromCharCodes(message);
    print('The message has been successfully received');
    print('The received message is : $str, as bytes $message');
    print('UART receiver test completed successfully');
  } else {
    print('No data available for 10 seconds or receive failure.');
    print('The message has NOT been successfully received - exiting');
    return -1;
  }

  return 0;
}
