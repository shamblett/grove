/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 14/11/2020
 * Copyright :  S.Hamblett
 */

part of grove;


class GroveLoraRf95Definitions {

  /// Uart
  static const uartDefaultDevice = '/dev/ttyS0';
  static const maxTimeToWait = 1000; // ms
  static const baudRate = 57600;

  /// Commands
  static const uartWrite = 0x57; // W
  static const uartRead = 0x52; // R
  static const uartTimeout = 3; // ms
  static const writeMask = 0x80;
  static const readError = -1;

}
