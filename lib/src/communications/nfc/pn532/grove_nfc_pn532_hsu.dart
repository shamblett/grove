/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 25/10/2020
 * Copyright :  S.Hamblett
 */

part of grove;

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
          'GroveNfcPn532Hsu::wakeup - failed to write wakeup to UART, return code is ${returnCode.asString(ret)}');
    }
  }

  /// Write a command to the PN532 and check the acknowledgement.
  @override
  CommandStatus writeCommand(Uint8List header, Uint8List body) {
    return CommandStatus.ok;
  }

  ///  Read the response of a command, strip prefix and suffix.
  ///  Maximum time to wait is in milliseconds.
  ///  Always returns a result, a length of 0 indicates failure.
  @override
  Uint8List readResponse(
      {int maxTimeToWait = GroveNfcPn532Definitions.maxTimeToWait}) {
    final buffer = Uint8List(0);

    return buffer;
  }
}
