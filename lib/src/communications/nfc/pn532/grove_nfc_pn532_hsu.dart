/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 25/10/2020
 * Copyright :  S.Hamblett
 */

part of grove;

Function eq = const ListEquality().equals;

/// Communications interface to the PN532 High Speed Uart(HSU) interface.
class GroveNfcPn532Hsu implements GroveNfcPn532Interface {
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
  bool wakeup() {
    final buff = MraaUartBuffer();
    buff.byteData = Uint8List.fromList(GroveNfcPn532Definitions.wakeupSequence);
    final ret = _mraaUart.writeBytes(_context, buff, buff.byteLength);
    if (ret != buff.byteLength) {
      print(
          'GroveNfcPn532Hsu::wakeup - failed to write wakeup to UART, return value is $ret}');
      return false;
    }
    return true;
  }

  /// Write a command to the PN532 and check the acknowledgement.
  @override
  CommandStatus writeCommand(List<int> header, {List<int> body}) {
    _commandAwaitingResponse = header[0];
    final sequence = <int>[];

    // Preamble and start codes
    sequence.addAll(GroveNfcPn532Definitions.preambleAndStartCodes);
    // Length of the data field: TFI + DATA
    var length = header.length + 1;
    if (body != null) {
      length += body.length;
    }
    sequence.add(length);
    // Checksum of the data field length
    sequence.add(~length + 1);
    sequence.add(GroveNfcPn532Definitions.hostToPn532);
    var sum = GroveNfcPn532Definitions.hostToPn532;
    sequence.addAll(header);
    header.forEach((int e) {
      sum += e;
    });
    if (body != null) {
      sequence.addAll(body);
      body.forEach((int e) {
        sum += e;
      });
    }
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
  int readResponse(List<int> rBuffer, int length, {int maxTimeToWait}) {
    final result = 0;
    if (maxTimeToWait != null) {
      _mraaUart.timeout(_context, maxTimeToWait, 0, 0);
    }
    final buffer = MraaUartBuffer();
    // Preamble and start codes
    var ret = _mraaUart.readBytes(_context, buffer,
        GroveNfcPn532Definitions.preambleAndStartCodes.length);
    if (ret != GroveNfcPn532Definitions.preambleAndStartCodes.length) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read preamble and start codes, return is $ret');
      return result;
    }
    if (!eq(GroveNfcPn532Definitions.preambleAndStartCodes.length,
        buffer.byteData)) {
      print(
          'GroveNfcPn532Hsu::readResponse - preamble and start codes not correct, ${buffer.byteData}');
      return result;
    }
    // Length
    buffer.byteData.clear();
    ret = _mraaUart.readBytes(
        _context, buffer, GroveNfcPn532Definitions.readResponseLength);
    if (ret != GroveNfcPn532Definitions.readResponseLength) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read length, return is $ret');
      return result;
    }
    if (0 != buffer.byteData[0] + buffer.byteData[1]) {
      print(
          'GroveNfcPn532Hsu::readResponse - length check failed, ${buffer.byteData}');
      return result;
    }
    buffer.byteData[0] -= GroveNfcPn532Definitions.readResponseLength;
    if (buffer.byteData[0] > length) {
      print(
          'GroveNfcPn532Hsu::readResponse - no space error, ${buffer.byteData}');
      return result;
    }
    final rxLength = buffer.byteData[0];
    // Receive the command byte
    buffer.byteData.clear();
    ret = _mraaUart.readBytes(
        _context, buffer, GroveNfcPn532Definitions.commandByteLength);
    if (ret != GroveNfcPn532Definitions.readResponseLength) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read command byte 1, return is $ret');
      return result;
    }
    final command = _commandAwaitingResponse + 1;
    if (GroveNfcPn532Definitions.pn532ToHost != buffer.byteData[0] ||
        command != buffer.byteData[1]) {}
    buffer.byteData.clear();
    ret = _mraaUart.readBytes(_context, buffer, rxLength);
    if (ret != rxLength) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read command byte 2, return is $ret');
      return result;
    }
    var sum = GroveNfcPn532Definitions.pn532ToHost + command;
    buffer.byteData.forEach((e) {
      sum += e;
    });
    // Checksum and postamble
    buffer.byteData.clear();
    ret = _mraaUart.readBytes(
        _context, buffer, GroveNfcPn532Definitions.postambleChecksumlength);
    if (ret != GroveNfcPn532Definitions.postambleChecksumlength) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read checksum and postamble, return is $ret');
      return result;
    }
    if (0 != sum + buffer.byteData[0] || 0 != buffer.byteData[1]) {
      print(
          'GroveNfcPn532Hsu::readResponse - checksum error, ${buffer.byteData}');
      return result;
    }
    if (maxTimeToWait != null) {
      _mraaUart.timeout(_context, GroveNfcPn532Definitions.maxTimeToWait, 0, 0);
    }
    rBuffer.addAll(buffer.byteData);
    return rxLength;
  }

  /// Read an acknowledge from the device
  /// True indicates the acknowledge is OK.
  bool _readAcknowledgement() {
    var readOk = false;
    var ackCheck = false;
    _mraaUart.timeout(_context, GroveNfcPn532Definitions.ackWaitTime, 0, 0);
    final buff = MraaUartBuffer();
    final ret = _mraaUart.readBytes(
        _context, buff, GroveNfcPn532Definitions.acknowledge.length);
    if (ret != buff.byteLength) {
      print(
          'GroveNfcPn532Hsu::_readAcknowledgement - failed to read acknowledgement from device return value is $ret');
      readOk = true;
    }
    // Check the acknowledgement
    var isEqual = eq(GroveNfcPn532Definitions.acknowledge, buff.byteData);
    if (!isEqual) {
      print(
          'GroveNfcPn532Hsu::_readAcknowledgement - invalid acknowledge sequence received from device, ${buff.byteData.toString()}');
      ackCheck = true;
    }
    _mraaUart.timeout(_context, GroveNfcPn532Definitions.maxTimeToWait, 0, 0);
    return readOk && ackCheck;
  }
}
