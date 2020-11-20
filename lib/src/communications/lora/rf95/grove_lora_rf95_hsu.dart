/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 14/11/2020
 * Copyright :  S.Hamblett
 */

part of grove;

/// Communications interface to the RF95 High Speed Uart(HSU) interface.
class GroveLoraRf95Hsu {
  /// Construction
  GroveLoraRf95Hsu(this._mraaUart,
      {String uartDevice = GroveLoraRf95Definitions.uartDefaultDevice}) {
    _uartDevice = uartDevice;
  }
  final MraaUart _mraaUart;
  String _uartDevice;
  Pointer<MraaUartContext> _context;

  /// Initialise
  ///
  /// A return of true indicates initialisation OK.
  bool init() {
    // Device
    _context = _mraaUart.initialiseRaw(_uartDevice);
    if (_context == null) {
      return false;
    }

    // Baud rate
    var ret = _mraaUart.baudRate(_context, GroveLoraRf95Definitions.baudRate);
    if (ret != MraaReturnCode.success) {
      return false;
    }

    return true;
  }

  /// UART transmit
  ///
  /// Transmits the length of [bytes].
  /// A return of true indicates the Uart transmit was OK.
  bool uartTx(int register, List<int> bytes) {
    final buffer = <int>[];
    buffer.add(GroveLoraRf95Definitions.uartWrite);
    buffer.add(register);
    buffer.add(bytes.length);
    buffer.addAll(bytes);
    final ok = _mraaUart.send(_context, buffer);
    if (!ok) {
      print(
          'uartTx - Failed to send UART write, register is $register, length is ${bytes.length}');
      return false;
    }
    return true;
  }

  /// UART receive
  ///
  /// Receives the length specified in [length]
  /// A return of true indicates the read was OK.
  bool uartRx(int register, List<int> bytes, int length) {
    final buffer = <int>[];
    buffer.add(GroveLoraRf95Definitions.uartRead);
    buffer.add(register);
    buffer.add(bytes.length);
    var ok = _mraaUart.send(_context, buffer);
    if (!ok) {
      print(
          'uartRx - Failed to send UART read, register is $register, length is $length');
      return false;
    }
    ok = _mraaUart.receive(_context, bytes, length,
        timeout: GroveLoraRf95Definitions.uartTimeout);
    if (!ok) {
      print(
          'uartRx - Failed to receive data from UART, register is $register, length is $length');
      return false;
    }
    return true;
  }

  /// Read a register value
  ///
  /// Returns [GroveLoraRf95Definitions.readError] on fail.
  int read(int register) {
    final buffer = <int>[];
    final ok =
        uartRx(register & ~GroveLoraRf95Definitions.writeMask, buffer, 1);
    if (!ok) {
      print('read - Failed to read data from UART, register is $register');
      return GroveLoraRf95Definitions.readError;
    }
    if (buffer.length != 1) {
      print('read - Invalid length from read operation, register is $register');
      return GroveLoraRf95Definitions.readError;
    }
    return buffer[0];
  }

  /// Write a register value.
  void write(int register, int value) {}

  /// Burst read
  void burstRead(int register, List<int> bytes, int length) {}

  /// Burst write
  void burstWrite(int register, List<int> bytes) {}
}
