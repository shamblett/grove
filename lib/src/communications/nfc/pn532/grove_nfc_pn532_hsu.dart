/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 25/10/2020
 * Copyright :  S.Hamblett
 */

part of grove;

Function eq = const ListEquality().equals;

/// Communications interface to the PN532 High Speed Uart(HSU) interface.
abstract class GroveNfcPn532Hsu implements GroveNfcPn532Interface {
  /// Construction
  GroveNfcPn532Hsu(this._mraaUart,
      {String uartDevice = GroveNfcPn532Definitions.uartDefaultDevice}) {
    _uartDevice = uartDevice;
  }

  final _mraaUart;
  String _uartDevice;
  Pointer<MraaUartContext> _context;
  int _commandAwaitingResponse = 0;

  /// Initialise the interface
  @override
  bool initialise() {
    // Device
    _context = _mraaUart.initialiseRaw(_uartDevice);
    if (_context == null) {
      return false;
    }
    // Read timeout
    var ret = _mraaUart.timeout(
        _context, GroveNfcPn532Definitions.maxTimeToWait, 0, 0);
    if (ret != MraaReturnCode.success) {
      return false;
    }
    // Flow control
    ret = _mraaUart.flowControl(_context, true, false);
    if (ret != MraaReturnCode.success) {
      return false;
    }
    // Baud rate
    ret = _mraaUart.baudRate(_context, GroveNfcPn532Definitions.baudRate);
    if (ret != MraaReturnCode.success) {
      return false;
    }
    // Mode 8N1
    ret = _mraaUart.mode(_context, 8, MraaUartParity.none, 1);
    if (ret != MraaReturnCode.success) {
      return false;
    }

    return true;
  }

  /// Wake up the PN532 before communicating with it.
  @override
  void wakeup() {
    final buff = MraaUartBuffer();
    buff.byteData = Uint8List.fromList(GroveNfcPn532Definitions.wakeupSequence);
    final ret = _mraaUart.writeBytes(_context, buff, buff.byteLength);
    if (ret != buff.byteLength) {
      print(
          'GroveNfcPn532Hsu::wakeup - failed to write wakeup to UART, return value is $ret}');
    }
  }

  /// Write a command to the PN532 and check the acknowledgement.
  @override
  CommandStatus writeCommand(List<int> header, List<int> body) {
    _commandAwaitingResponse = header[0];
    final sequence = <int>[];

    // Preamble
    sequence.add(GroveNfcPn532Definitions.preamble);
    sequence.add(GroveNfcPn532Definitions.startcode1);
    sequence.add(GroveNfcPn532Definitions.startcode2);
    // Length of the data field: TFI + DATA
    final length = header.length + body.length + 1;
    sequence.add(length);
    // Checksum of the data field length
    sequence.add(~length + 1);
    sequence.add(GroveNfcPn532Definitions.hostToPn532);
    var sum = GroveNfcPn532Definitions.hostToPn532;
    sequence.addAll(header);
    header.forEach((int e) {
      sum += e;
    });
    sequence.addAll(body);
    body.forEach((int e) {
      sum += e;
    });
    // checksum of TFI + DATA
    final checksum = ~sum + 1;
    sequence.add(checksum);
    sequence.add(GroveNfcPn532Definitions.postamble);

    // Send to the device
    final buff = MraaUartBuffer();
    buff.byteData = Uint8List.fromList(sequence);
    final ret = _mraaUart.writeBytes(_context, buff, buff.byteLength);
    if (ret != buff.byteLength) {
      print(
          'GroveNfcPn532Hsu::writeCommand - failed to write command to UART, return value is $ret,'
          'command is $_commandAwaitingResponse');
      return CommandStatus.failed;
    }
    // Get the acknowledge
    return _readAcknowledgement() ? CommandStatus.ok : CommandStatus.failed;
  }

  ///  Read the response of a command, strip prefix and suffix.
  ///  Maximum time to wait is in milliseconds.
  ///  Always returns a result, a length of 0 indicates failure.
  @override
  List<int> readResponse(
      {int maxTimeToWait = GroveNfcPn532Definitions.maxTimeToWait}) {
    final buffer = Uint8List(0);

    return buffer;
  }

  /// Read an acknowledge from the device
  /// True indicates the acknowledge is OK.
  bool _readAcknowledgement() {
    final buff = MraaUartBuffer();
    final ret = _mraaUart.readBytes(
        _context, buff, GroveNfcPn532Definitions.acknowledge.length);
    if (ret != buff.byteLength) {
      print(
          'GroveNfcPn532Hsu::_readAcknowledgement - failed to read acknowledgement from device return value is $ret');
      return false;
    }
    // Check the acknowledgement
    var isEqual = eq(GroveNfcPn532Definitions.acknowledge, buff.byteData);
    if (!isEqual) {
      print(
          'GroveNfcPn532Hsu::_readAcknowledgement - invalid acknowledge sequence received from device, ${buff.byteData.toString()}');
    }
    return true;
  }
}
