/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 23/10/2020
 * Copyright :  S.Hamblett
 */

part of grove;

/// Command, data and font definitions for the Grove NFC PN532 based reader.
class GroveNfcPn532Definitions {
  /// Command codes
  static const wakeup = 0x55;

  /// Control codes
  static const preamble = 0x00;
  static const startcode1 = 0x00;
  static const startcode2 = 0xff;
  static const postamble = 0x00;
  static const hostToPN532 = 0xd4;
  static const pn532ToHost = 0xd5;
  static const ackWaitTime = 10; // ms, timeout of waiting for ACK
  static const invalidAck = -1;
  static const timeout = -2;
  static const invalidFrame = -3;
  static const noSpace = -4;
}
