/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/10/2019
 * Copyright :  S.Hamblett
 */

import 'dart:io';
import 'package:mraa/mraa.dart';
import 'example_config.dart';

/// The reeiver part of loopback test of the UART device, please ensure you have TX/RX looped back.
int main() {
  final mraa = Mraa.fromLib(mraaLibraryPath)
    ..noJsonLoading = noJsonLoading
    ..useGrovePi = useGrovePi
    ..initialise();

  // Version
  final mraaVersion = mraa.common.version();
  print('Mraa version is : $mraaVersion');

  print('Initialising MRAA');
  var ret = mraa.common.initialise();
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

  // Flow control
  ret = mraa.uart.flowControl(context, true, false);
  if (ret != MraaReturnCode.success) {
    print('Unable to set flow control on UART');
    return -1;
  }

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
      'Reading the test string from the UART, you have 10 seconds to send....');
  final buffer = MraaUartBuffer();
  mraa.uart.readBytes(context, buffer, 1);
  if (mraa.uart.dataAvailable(context, 10000)) {
    final lret = mraa.uart.readUtf8(context, buffer, 12);
    if (lret != 12) {
      print('Failed to read string from UART, return is $lret');
      return -1;
    }
    print('We have received ${buffer.utf8Data}');
  } else {
    print('Failed to read UART data, no data available');
    return -1;
  }

  print('UART receiver test completed successfully');
  return 0;
}
