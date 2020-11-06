/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/10/2019
 * Copyright :  S.Hamblett
 */

import 'dart:async';
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
  // Non blocking
  ret = mraa.uart.nonBlocking(context, true);
  if (ret != MraaReturnCode.success) {
    print('Unable to set mode on UART');
    return -1;
  }

  print(
      'Reading the test string from the UART, you have 10 seconds to send....');
  var stop = false;
  var message = <int>[];

  final timer = Timer(Duration(seconds: 10), () {
    print('Read loop timer invoked - stopping');
    stop = true;
  });

  print('Starting receive loop');
  while (!stop) {
    if (mraa.uart.dataAvailable(context, 10)) {
      print('Data is available');
      final buffer = MraaUartBuffer();
      final ret = mraa.uart.readBytes(context, buffer, uartTestMessage.length);
      if (ret == Mraa.generalError) {
        print('Received general error - continuing');
        continue;
      } else if (ret < uartTestMessage.length) {
        message.addAll(buffer.byteData);
        if (message.length == uartTestMessage.length) {
          print('Test message received - stopping');
          timer.cancel();
          stop = true;
        }
      } else if (ret == uartTestMessage.length) {
        message.addAll(buffer.byteData);
        print('Test message received in one read - stopping');
        stop = true;
        timer.cancel();
      } else {
        print('Unrecognised return value - $ret');
      }
    } else {
      sleep(Duration(milliseconds: 1));
    }
  }

  var str;
  if (message.length == uartTestMessage.length) {
    str = String.fromCharCodes(message);
    if (str == uartTestMessage) {
      print('The message has been successfully received');
      print('The received message is $str');
    }
  } else {
    print('The message has NOT been successfully received');
    print('The partially received message at timeout is $str');
  }

  print('UART receiver test completed successfully');
  return 0;
}
