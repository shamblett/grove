/*
* Package : grove
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 14/11/2020
* Copyright :  S.Hamblett
*/

part of '../../../../grove.dart';

/// Choices for [GroveLoraRf95.setModemConfiguration] for a selected subset of common
/// data rates. If you need another configuration,
/// determine the necessary settings and call [GroveLoraRf95.setModemRegisters] with your
/// desired settings. It might be helpful to use the LoRa calculator mentioned in
/// http://www.semtech.com/images/datasheet/LoraDesignGuide_STD.pdf
/// These are indexes into MODEM_CONFIG_TABLE. We strongly recommend you use these symbolic
/// definitions and not their integer equivalents: its possible that new values will be
/// introduced in later versions (though we will try to avoid it).
enum GroveLoraModemConfigurationChoice {
  /// Bw = 125 kHz, Cr = 4/5, Sf = 128chips/symbol, CRC on. Default medium range
  bw125Cr45Sf128,

  /// Bw = 500 kHz, Cr = 4/5, Sf = 128chips/symbol, CRC on. Fast+short range
  bw500Cr45Sf128,

  /// Bw = 31.25 kHz, Cr = 4/8, Sf = 512chips/symbol, CRC on. Slow+long range
  bw3125Cr48Sf512,

  /// Bw = 125 kHz, Cr = 4/8, Sf = 4096chips/symbol, CRC on. Slow+long range
  bw125Cr48Sf4096,
}

/// Defines register values for a set of modem configuration registers
/// that can be passed to [GroveLoraRf95.setModemRegisters] if none of
/// the choices in [GroveLoraModemConfigurationChoice] suit your need
/// [GroveLoraRf95.setModemRegisters] writes the
/// register values from this structure to the appropriate registers
/// to set the desired spreading factor, coding rate and bandwidth
class GroveLoraModemConfiguration {
  /// Construction
  GroveLoraModemConfiguration(this._reg1d, this._reg1e, this._reg26);
  GroveLoraModemConfiguration.fromList(List<int> settings) {
    _reg1d = settings[0];
    _reg1e = settings[1];
    _reg26 = settings[2];
  }

  /// Value for [GroveLoraRf95Definitions.rhrF95ReG1DmodemconfiG1]
  int get reg1d => _reg1d;
  int _reg1d = 0;

  /// Value for [GroveLoraRf95Definitions.rhrF95ReG1EmodemconfiG2]
  int get reg1e => _reg1e;
  int _reg1e = 0;

  /// Value for [GroveLoraRf95Definitions.rhrF95ReG26ModemconfiG3]
  int get reg26 => _reg26;
  int _reg26 = 0;
}

/// These are indexed by the values of [GroveLoraModemConfigurationChoice]
const Map<GroveLoraModemConfigurationChoice, List<int>>
modemConfigurationTable = {
  GroveLoraModemConfigurationChoice.bw125Cr45Sf128: [0x72, 0x74, 0x00],
  GroveLoraModemConfigurationChoice.bw500Cr45Sf128: [0x92, 0x74, 0x00],
  GroveLoraModemConfigurationChoice.bw3125Cr48Sf512: [0x48, 0x94, 0x00],
  GroveLoraModemConfigurationChoice.bw125Cr48Sf4096: [0x78, 0xc4, 0x00],
};
