/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 23/10/2020
 * Copyright :  S.Hamblett
 */

part of grove;

/// Command status
enum CommandStatus { ok, failed }

/// Command, data and font definitions for the Grove NFC PN532 based reader.
class GroveNfcPn532Definitions {
  /// Command codes and response lengths
  static const wakeup = 0x55;
  static const diagnose = 0x00;
  static const getFirmwareVersion = 0x02;
  static const getFirmwareVersionRlength = 4;
  static const getGeneralStatus = 0x04;
  static const readRegister = 0x06;
  static const writeRegister = 0x08;
  static const readGpio = 0x0c;
  static const writeGpio = 0x0e;
  static const setSerialBaudrate = 0x10;
  static const setParameters = 0x12;
  static const samConfiguration = 0x14;
  static const powerdown = 0x16;
  static const rfConfiguration = 0x32;
  static const rfRegulationTest = 0x58;
  static const inJumpForDep = 0x56;
  static const inJumpForPsl = 0x46;
  static const inListPassiveTarget = 0x4a;
  static const inatr = 0x50;
  static const inpsl = 0x4e;
  static const inDataExchange = 0x40;
  static const inCommunicateThru = 0x42;
  static const inDeselect = 0x44;
  static const inRelease = 0x52;
  static const inSelect = 0x54;
  static const inAutoPoll = 0x60;
  static const tginitAsTarget = 0x8c;
  static const tgSetGeneralBytes = 0x92;
  static const tgGetData = 0x86;
  static const tgSetData = 0x8e;
  static const tgSetMetadata = 0x94;
  static const tgGetInitiatorCommand = 0x88;
  static const tgResponseToinItiator = 0x90;
  static const tgGetTargetStatus = 0x8a;

  /// Control codes
  static const preamble = 0x00;
  static const startcode1 = 0x00;
  static const startcode2 = 0xff;
  static const postamble = 0x00;
  static const hostToPn532 = 0xd4;
  static const pn532ToHost = 0xd5;
  static const ackWaitTime = 10; // ms, timeout of waiting for ACK
  static const invalidAck = -1;
  static const timeout = -2;
  static const invalidFrame = -3;
  static const noSpace = -4;
  static const readResponseLength = 2;
  static const commandByteLength = 2;
  static const postambleChecksumlength = 2;

  /// Command sequences
  static const wakeupSequence = <int>[wakeup, wakeup, 0x00, 0x00, 0x00];
  static const acknowledge = <int>[0x00, 0x00, 0xff, 0x00, 0xff, 0x00];
  static const preambleAndStartCodes = <int>[preamble, startcode1, startcode2];

  /// Uart
  static const uartDefaultDevice = '/dev/ttyS0';
  static const maxTimeToWait = 1000; // ms
  static const baudRate = 9600;//115200;

}
