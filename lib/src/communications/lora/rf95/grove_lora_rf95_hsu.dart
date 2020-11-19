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
  /// A return of true indicates initialisation OK.
  bool init() {
    return false;
  }

  /// UART transmit.
  /// Transmits the length of [bytes].
  /// A return of true indicates the Uart transmit was OK
  bool uartTx(int register, List<int> bytes) {
    return false;
  }

  /// UART receive.
  /// Receives the length specified in [length]
  /// A return of true indicates the read was OK.
  bool uartRx(int register, List<int> bytes, int length) {
    return false;
  }

  /// Read a register value.
  int read(int register) {
    return 0;
  }

  /// Write a register value.
  void write(int register, int value) {}

  /// Burst read
  void burstRead(int register, List<int> bytes, int length) {}

  /// Burst write
  void burstWrite(int register, List<int> bytes) {}
}
