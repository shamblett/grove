/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 14/11/2020
 * Copyright :  S.Hamblett
 */

part of '../../../../grove.dart';

class GroveLoraRf95Definitions {
  /// Uart
  static const uartDefaultDevice = '/dev/ttyS0';
  static const maxTimeToWait = 1000; // ms
  static const baudRate = 57600;

  /// Commands
  static const uartWrite = 0x57; // W
  static const uartRead = 0x52; // R
  static const uartAvailable = 0x49; // I
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
  static const rhrF95ReG22PayloadLength = 0x22;
  static const rhrF95ReG23MaxpayloadLength = 0x23;
  static const rhrF95ReG24Hopperiod = 0x24;
  static const rhrF95ReG25Fiforxbyteaddr = 0x25;
  static const rhrF95ReG26ModemconfiG3 = 0x26;
  static const rhrF95ReG4DPaDac = 0x4d;
  static const rhrF95Reg40DioMapping1 = 0x40;

  static const registers = <int>[
    rhrF95ReG01Opmode,
    rhrF95ReG06Frfmsb,
    rhrF95ReG07Frfmid,
    rhrF95ReG08Frflsb,
    rhrF95ReG09Paconfig,
    rhrF95ReG0Aparamp,
    rhrF95ReG0Bocp,
    rhrF95ReG0Clna,
    rhrF95ReG0Dfifoaddrptr,
    rhrF95ReG0Efifotxbaseaddr,
    rhrF95ReG0Ffiforxbaseaddr,
    rhrF95ReG10Fiforxcurrentaddr,
    rhrF95ReG11Irqflagsmask,
    rhrF95ReG12Irqflags,
    rhrF95ReG13Rxnbbytes,
    rhrF95ReG14Rxheadercntvaluemsb,
    rhrF95ReG15Rxheadercntvaluelsb,
    rhrF95ReG16Rxpacketcntvaluemsb,
    rhrF95ReG17Rxpacketcntvaluelsb,
    rhrF95ReG18Modemstat,
    rhrF95ReG19Pktsnrvalue,
    rhrF95ReG1Apktrssivalue,
    rhrF95ReG1Brssivalue,
    rhrF95ReG1Chopchannel,
    rhrF95ReG1DmodemconfiG1,
    rhrF95ReG1EmodemconfiG2,
    rhrF95ReG1Fsymbtimeoutlsb,
    rhrF95ReG20Preamblemsb,
    rhrF95ReG21Preamblelsb,
    rhrF95ReG22PayloadLength,
    rhrF95ReG23MaxpayloadLength,
    rhrF95ReG24Hopperiod,
    rhrF95ReG25Fiforxbyteaddr,
    rhrF95ReG26ModemconfiG3,
    rhrF95ReG4DPaDac,
    rhrF95Reg40DioMapping1
  ];

  /// PA
  static const rhrF95PaDacDisable = 0x04;
  static const rhrF95PaDacEnable = 0x07;
  static const rhrF95PaSelect = 0x80;

  /// IRQ
  static const rhrF95RxTimeoutMask = 0x80;
  static const rhrF95RxDoneMask = 0x40;
  static const rhrF95PayloadCrcErrorMask = 0x20;
  static const rhrF95RxTimeout = 0x80;
  static const rhrF95RxDone = 0x40;
  static const rhrF95PayloadCrcError = 0x20;
  static const rhrF95TxDone = 0x08;
  static const rhrF95TxDoneMask = 0x08;
  static const clearIrqFlags = 0xff;

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

  /// Radio/LORA defaults
  static const defaultPreambleLength = 8;
  static const defaultFrequency = 868.0;
  static const defaultPower = 13;
  static const rhrBroadcastAddress = 0xff;
  static const rhrF95Rrg40DioMapping1 = 0x40;
  // Max number of octets the LORA Rx/Tx FIFO can hold
  static const rhrF95FifoSize = 0xff;
  // This is the maximum number of bytes that can be carried by the LORA.
  // We use some for headers.
  static const rhrF95MaxPayloadLen = rhrF95FifoSize;
  // The length of the headers we add.
  // The headers are inside the LORA's payload
  static const rhrF95HeaderLen = 4;
  // This is the maximum message length that can be supported by this driver.
  // Can be pre-defined to a smaller size (to save SRAM) prior to including this header.
  // Here we allow for 1 byte message length, 4 bytes headers, user data and 2 bytes of FCS.
  static const rhrF95MaxMessageLen = (rhrF95MaxPayloadLen - rhrF95HeaderLen);
  // The crystal oscillator frequency of the module
  static const rhrF95Fxosc = 32000000.0;
  // The Frequency Synthesizer step = RH_RF95_FXOSC / 2^^19
  static const rhrF95Fstep = (rhrF95Fxosc / 524288);
  // Transmit available wait time
  static const transmitAvailableWait = 500;
}
