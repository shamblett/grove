/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 14/11/2020
 * Copyright :  S.Hamblett
 */

part of grove;

/// Choices for [GroveLoraRf95.setModemConfig] for a selected subset of common
/// data rates. If you need another configuration,
/// determine the necessary settings and call [GroveLoraRf95.setModemRegisters] with your
/// desired settings. It might be helpful to use the LoRa calculator mentioned in
/// http://www.semtech.com/images/datasheet/LoraDesignGuide_STD.pdf
/// These are indexes into MODEM_CONFIG_TABLE. We strongly recommend you use these symbolic
/// definitions and not their integer equivalents: its possible that new values will be
/// introduced in later versions (though we will try to avoid it).
enum GroveLoraModemConfigChoice {
  /// Bw = 125 kHz, Cr = 4/5, Sf = 128chips/symbol, CRC on. Default medium range
  bw125Cr45Sf128,

  /// Bw = 500 kHz, Cr = 4/5, Sf = 128chips/symbol, CRC on. Fast+short range
  bw500Cr45Sf128,

  /// Bw = 31.25 kHz, Cr = 4/8, Sf = 512chips/symbol, CRC on. Slow+long range
  bw3125Cr48Sf512,

  /// Bw = 125 kHz, Cr = 4/8, Sf = 4096chips/symbol, CRC on. Slow+long range
  bw125Cr48Sf4096,
}

/// Defines different operating modes for the transport hardware
///
/// These are the different values that can be adopted by the [_mode] variable and
/// returned by the mode() member function,
enum GroveLoraMode {
  /// Transport is initialising. Initial default value.
  modeInitialising,

  /// Transport hardware is in low power sleep mode (if supported)
  modeSleep,

  /// Transport is idle.
  modeIdle,

  /// Transport is in the process of transmitting a message.
  modeTx,

  /// Transport is in the process of receiving a message.
  modeRx
}

/// Defines register values for a set of modem configuration registers
/// that can be passed to [GroveLoraRf95.setModemRegisters] if none of
/// the choices in [GroveLoraModemConfigChoice] suit your need
/// [GroveLoraRf95.setModemRegisters] writes the
/// register values from this structure to the appropriate registers
/// to set the desired spreading factor, coding rate and bandwidth
class GroveLoraModemConfig {
  /// Value for [GroveLoraRf95Definitions.rhrF95ReG1DmodemconfiG1]
  int reg1d = 0;

  /// Value for [GroveLoraRf95Definitions.rhrF95ReG1EmodemconfiG2]
  int reg1e = 0;

  /// Value for [GroveLoraRf95Definitions.rhrF95ReG26ModemconfiG3]
  int reg126 = 0;
}

///Lora RF95 class
class GroveLoraRf95 {
  /// Construction
  GroveLoraRf95(this._mraa,
      {String tty = GroveLoraRf95Definitions.uartDefaultDevice}) {
    _tty = tty;
    _interface = GroveLoraRf95Hsu(_mraa.uart, uartDevice: _tty);
  }

  final Mraa _mraa;

  String _tty;

  bool initialised = false;

  GroveLoraRf95Hsu _interface;

  GroveLoraMode _mode = GroveLoraMode.modeInitialising;

  /// Initialise
  ///
  /// Initialise the Driver transport hardware and software.
  /// Make sure the Driver is properly configured before calling initialise
  /// Return true if initialisation succeeded.
  bool initialise() {
    var ok = _interface.initialise();
    if (!ok) {
      print('GroveLoraRf95::initialise - failed to initialise HSU interface');
      return false;
    }

    // Set sleep mode, so we can also set LORA mode:
    ok = _interface.write(
        GroveLoraRf95Definitions.rhrF95ReG01Opmode,
        GroveLoraRf95Definitions.rhrF95Modesleep |
            GroveLoraRf95Definitions.rhrF95Longrangemode);

    if (!ok) {
      print('GroveLoraRf95::initialise - failed to set sleep mode');
      return false;
    }

    // Wait for sleep mode to take over from say, CAD
    sleep(Duration(milliseconds: 10));

    // Check we are in sleep mode, with LORA set
    if (_interface.read(GroveLoraRf95Definitions.rhrF95ReG01Opmode) !=
        GroveLoraRf95Definitions.rhrF95Modesleep |
            GroveLoraRf95Definitions.rhrF95Longrangemode) {
      print('GroveLoraRf95::initialise - failed to check sleep mode');
      return false;
    }

    // Set up FIFO.
    // We configure so that we can use the entire 256 byte FIFO for either receive
    // or transmit, but not both at the same time.
    ok =
        _interface.write(GroveLoraRf95Definitions.rhrF95ReG0Efifotxbaseaddr, 0);
    ok &=
        _interface.write(GroveLoraRf95Definitions.rhrF95ReG0Ffiforxbaseaddr, 0);
    if (!ok) {
      print('GroveLoraRf95::initialise - failed to set up FIFO');
      return false;
    }

    // Packet format is preamble + explicit-header + payload + crc
    // Explicit Header Mode
    // Payload is TO + FROM + ID + FLAGS + message data
    // RX mode is implmented with RXCONTINUOUS
    // Max message data length is 255 - 4 = 251 octets.

    ok = _setModeIdle();
    if (!ok) {
      print('GroveLoraRf95::initialise - failed to set mode to idle');
      return false;
    }

    return true;
  }

  void setModemRegisters() {}
  bool setModemConfig() {
    return false;
  }

  bool _setModeIdle() {
    if (_mode != GroveLoraMode.modeIdle) {
      final ok = _interface.write(GroveLoraRf95Definitions.rhrF95ReG01Opmode,
          GroveLoraRf95Definitions.rhrF95Modestdby);
      if (!ok) {
        print('GroveLoraRf95::_setModeIdle - failed to set mode to standby');
        return false;
      }
      _mode = GroveLoraMode.modeIdle;
    }
    return true;
  }
}
