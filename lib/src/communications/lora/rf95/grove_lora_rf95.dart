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
  ///< Bw = 125 kHz, Cr = 4/5, Sf = 128chips/symbol, CRC on. Default medium range
  bw125Cr45Sf128,

  ///< Bw = 500 kHz, Cr = 4/5, Sf = 128chips/symbol, CRC on. Fast+short range
  bw500Cr45Sf128,

  ///< Bw = 31.25 kHz, Cr = 4/8, Sf = 512chips/symbol, CRC on. Slow+long range
  bw3125Cr48Sf512,

  ///< Bw = 125 kHz, Cr = 4/8, Sf = 4096chips/symbol, CRC on. Slow+long range
  bw125Cr48Sf4096,
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
    return true;
  }

  void setModemRegisters() {}
  bool setModemConfig() {
    return false;
  }
}
