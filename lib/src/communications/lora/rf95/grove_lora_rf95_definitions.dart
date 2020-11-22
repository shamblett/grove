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

  /// Register names (LoRa Mode)
  static const rhrF95ReG00Fifo = 0x00;
  static const rhrF95ReG01Opmode = 0x01;
  static const rhrF95ReG02Reserved = 0x02;
  static const rhrF95ReG03Reserved = 0x03;
  static const rhrF95ReG04Reserved = 0x04;
  static const rhrF95ReG05Reserved = 0x05;
  static const rhrF95ReG06Frfmsb = 0x06;
  static const rhrF95ReG07Frfmid = 0x07;
  static const rhrF95ReG08Frflsb = 0x08;
  static const rhrF95ReG09Paconfig = 0x09;
  static const rhrF95ReG0Aparamp = 0x0a;
  static const rhrF95ReG0Bocp = 0x0b;
  static const rhrF95ReG0Clna = 0x0c;
  static const rhrF95ReG0Dfifoaddrptr = 0x0d;
  static const rhrF95ReG0Efifotxbaseaddr = 0x0e;
  static const rhrF95ReG0Ffiforxbaseaddr = 0x0f;
  static const rhrF95ReG10Fiforxcurrentaddr = 0x10;
  static const rhrF95ReG11Irqflagsmask = 0x11;
  static const rhrF95ReG12Irqflags = 0x12;
  static const rhrF95ReG13Rxnbbytes = 0x13;
  static const rhrF95ReG14Rxheadercntvaluemsb = 0x14;
  static const rhrF95ReG15Rxheadercntvaluelsb = 0x15;
  static const rhrF95ReG16Rxpacketcntvaluemsb = 0x16;
  static const rhrF95ReG17Rxpacketcntvaluelsb = 0x17;
  static const rhrF95ReG18Modemstat = 0x18;
  static const rhrF95ReG19Pktsnrvalue = 0x19;
  static const rhrF95ReG1Apktrssivalue = 0x1a;
  static const rhrF95ReG1Brssivalue = 0x1b;
  static const rhrF95ReG1Chopchannel = 0x1c;
  static const rhrF95ReG1DmodemconfiG1 = 0x1d;
  static const rhrF95ReG1EmodemconfiG2 = 0x1e;
  static const rhrF95ReG1Fsymbtimeoutlsb = 0x1f;
  static const rhrF95ReG20Preamblemsb = 0x20;
  static const rhrF95ReG21Preamblelsb = 0x21;
  static const rhrF95ReG22Payloadlength = 0x22;
  static const rhrF95ReG23Maxpayloadlength = 0x23;
  static const rhrF95ReG24Hopperiod = 0x24;
  static const rhrF95ReG25Fiforxbyteaddr = 0x25;
  static const rhrF95ReG26ModemconfiG3 = 0x26;

  /// Modes
  static const rhrF95Longrangemode = 0x80;
  static const rhrF95Accesssharedreg = 0x40;
  static const rhrF95Mode = 0x07;
  static const rhrF95Modesleep = 0x00;
  static const rhrF95Modestdby = 0x01;
  static const rhrF95Modefstx = 0x02;
  static const rhrF95Modetx = 0x03;
  static const rhrF95Modefsrx = 0x04;
  static const rhrF95Moderxcontinuous = 0x05;
  static const rhrF95Moderxsingle = 0x06;
  static const rhrF95Modecad = 0x07;

  /// Radio defaults
  static const defaultPreambleLength = 8;
}
