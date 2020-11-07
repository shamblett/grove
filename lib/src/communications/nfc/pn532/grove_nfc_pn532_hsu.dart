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

    // Baud rate
    var ret = _mraaUart.baudRate(_context, GroveNfcPn532Definitions.baudRate);
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
    _mraaUart.flush(_context);
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
    _mraaUart.flush(_context);
    // Get the acknowledge
    return _readAcknowledgement() ? CommandStatus.ok : CommandStatus.failed;
  }

  ///  Read the response of a command, strip prefix and suffix.
  ///  Maximum time to wait is in milliseconds.
  ///  Always returns a result, a length of 0 indicates failure.
  @override
  int readResponse(List<int> rBuffer, int length,
      {int maxTimeToWait = GroveNfcPn532Definitions.maxTimeToWait}) {
    final result = 0;
    final bytes = <int>[];
    // Preamble and start codes
    var ret = _receive(
        bytes, GroveNfcPn532Definitions.preambleAndStartCodes.length,
        timeout: maxTimeToWait);
    if (!ret) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read preamble and start codes - timed out');
      return result;
    }
    if (!eq(
        GroveNfcPn532Definitions.preambleAndStartCodes.length, bytes.length)) {
      print(
          'GroveNfcPn532Hsu::readResponse - preamble and start codes not correct, ${bytes}');
      return result;
    }
    // Length
    bytes.clear();
    ret = _receive(bytes, GroveNfcPn532Definitions.readResponseLength,
        timeout: maxTimeToWait);
    if (!ret) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read length - timed out');
      return result;
    }
    if (0 != bytes[0] + bytes[1]) {
      print('GroveNfcPn532Hsu::readResponse - length check failed, ${bytes}');
      return result;
    }
    bytes[0] -= GroveNfcPn532Definitions.readResponseLength;
    if (bytes[0] > length) {
      print('GroveNfcPn532Hsu::readResponse - no space error, ${bytes}');
      return result;
    }
    final rxLength = bytes[0];
    // Receive the command byte
    bytes.clear();
    ret = _receive(bytes, GroveNfcPn532Definitions.commandByteLength,
        timeout: maxTimeToWait);
    if (!ret) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read command byte 1 - timed out');
      return result;
    }
    final command = _commandAwaitingResponse + 1;
    if (GroveNfcPn532Definitions.pn532ToHost != bytes[0] ||
        command != bytes[1]) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read command byte 1 - error ${bytes}');
    }
    bytes.clear();
    ret = _receive(bytes, rxLength, timeout: maxTimeToWait);
    if (!ret) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read command byte 2 - timed out');
      return result;
    }
    if (bytes.length != rxLength) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read command byte 2, ${bytes}');
      return result;
    }
    var sum = GroveNfcPn532Definitions.pn532ToHost + command;
    bytes.forEach((e) {
      sum += e;
    });
    // Checksum and postamble
    bytes.clear();
    ret = _receive(bytes, GroveNfcPn532Definitions.postambleChecksumlength,
        timeout: maxTimeToWait);
    if (!ret) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read checksum and postamble - timed out');
      return result;
    }
    if (bytes.length != GroveNfcPn532Definitions.postambleChecksumlength) {
      print(
          'GroveNfcPn532Hsu::readResponse - failed to read checksum and postamble, ${bytes}');
      return result;
    }
    if (0 != sum + bytes[0] || 0 != bytes[1]) {
      print('GroveNfcPn532Hsu::readResponse - checksum error, ${bytes}');
      return result;
    }
    if (maxTimeToWait != null) {
      _mraaUart.timeout(_context, GroveNfcPn532Definitions.maxTimeToWait, 0, 0);
    }
    rBuffer.addAll(bytes);
    return rxLength;
  }

  /// Read an acknowledge from the device
  /// True indicates the acknowledge is OK.
  bool _readAcknowledgement() {
    var readOk = false;
    var ackCheck = false;
    final bytes = <int>[];
    final ret = _receive(bytes, GroveNfcPn532Definitions.acknowledge.length,
        timeout: GroveNfcPn532Definitions.ackWaitTime);
    if (!ret) {
      print(
          'GroveNfcPn532Hsu::_readAcknowledgement - failed to read acknowledgement from device - timed out');
    }
    if (ret) {
      // Check the acknowledgement
      readOk = true;
      var isEqual = eq(GroveNfcPn532Definitions.acknowledge, bytes);
      if (!isEqual) {
        print(
            'GroveNfcPn532Hsu::_readAcknowledgement - invalid acknowledge sequence received from device, ${bytes}');
      } else {
        ackCheck = true;
      }
    }
    return readOk && ackCheck;
  }

  // Return of true indicates OK, false is timed out.
  bool _receive(List<int> bytes, int length,
      {int timeout = GroveNfcPn532Definitions.maxTimeToWait}) {
    var rxOk = false;
    if (_mraaUart.dataAvailable(_context, timeout)) {
      final buffer = MraaUartBuffer();
      while (true) {
        final ret = _mraaUart.readBytes(_context, buffer, length);
        if (ret == Mraa.generalError) {
          continue;
        } else if (ret < length) {
          bytes.addAll(buffer.byteData);
          buffer.byteData.clear();
          if (bytes.length == length) {
            rxOk = true;
            break;
          }
          if (_mraaUart.dataAvailable(_context, 1)) {
            continue;
          } else {
            break;
          }
        } else if (ret == length) {
          bytes.addAll(buffer.byteData);
          rxOk = true;
          break;
        } else {
          continue;
        }
      }
    } else {
      print('No data available for $timeout milliseconds - exiting');
    }
    return rxOk;
  }
}
