/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 14/11/2020
 * Copyright :  S.Hamblett
 */

part of grove;

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
  /// Initialise the driver transport hardware and software.
  /// Make sure the driver is properly configured before calling initialise
  /// or no commands will be sent to the device.
  /// Returns true if initialisation succeeded.
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

    ok = setModeIdle();
    if (!ok) {
      print('GroveLoraRf95::initialise - failed to set mode to idle');
      return false;
    }

    // Set up default configuration
    // No Sync Words in LORA mode.
    ok = setModemConfiguration(
        GroveLoraModemConfigurationChoice.bw125Cr45Sf128); // Radio default
    if (!ok) {
      print('GroveLoraRf95::initialise - failed to set modem configuration');
      return false;
    }

    // Set the default preamble length.
    ok = setPreambleLength(GroveLoraRf95Definitions.defaultPreambleLength);
    if (!ok) {
      print(
          'GroveLoraRf95::initialise - failed to set default preamble length');
      return false;
    }

    // Frequency
    ok = setFrequency(GroveLoraRf95Definitions.defaultFrequency);
    if (!ok) {
      print('GroveLoraRf95::initialise - failed to set default frequency');
      return false;
    }

    // Lowish power
    ok = setTxPower(GroveLoraRf95Definitions.defaultPower);
    if (!ok) {
      print('GroveLoraRf95::initialise - failed to set default power');
      return false;
    }

    initialised = true;
    return true;
  }

  /// setModemRegisters
  ///
  /// Sets all the registered required to configure the data modem in the RF95/96/97/98, including the bandwidth,
  /// spreading factor etc. You can use this to configure the modem with custom configurations if none of the
  /// canned configurations in ModemConfigChoice suit you.
  /// /// Returns true if the configuration is set.
  bool setModemRegisters(GroveLoraModemConfiguration configuration) {
    if (!_initialisedOk()) {
      print('GroveLoraRf95::setModemRegisters - not initialised');
      return false;
    }
    var ok = _interface.write(
        GroveLoraRf95Definitions.rhrF95ReG1DmodemconfiG1, configuration.reg1d);
    ok &= _interface.write(
        GroveLoraRf95Definitions.rhrF95ReG1EmodemconfiG2, configuration.reg1e);
    ok &= _interface.write(
        GroveLoraRf95Definitions.rhrF95ReG26ModemconfiG3, configuration.reg26);
    if (!ok) {
      print('GroveLoraRf95::setModemRegisters - failed to set modem registers');
      return false;
    }
    return true;
  }

  /// setModemConfiguration
  ///
  /// Select one of the predefined modem configurations. If you need a modem configuration not provided
  ///  here, use [setModemRegisters()] with your own modem configuration.
  /// Returns true if the choice is set.
  bool setModemConfiguration(GroveLoraModemConfigurationChoice choice) {
    if (!_initialisedOk()) {
      print('GroveLoraRf95::setModemConfiguration - not initialised');
      return false;
    }
    final configuration =
        GroveLoraModemConfiguration.fromList(modemConfigurationTable[choice]);
    setModemRegisters(configuration);
    return false;
  }

  /// setPreambleLength
  ///
  /// Sets the length of the preamble in bytes.
  /// Caution: this should be set to the same
  /// value on all nodes in your network. Default is 8.
  /// Sets the message preamble length in RH_RF95_REG_??_PREAMBLE_?SB
  /// Returns true if the preamable length is set.
  bool setPreambleLength(int bytes) {
    if (!_initialisedOk()) {
      print('GroveLoraRf95::setPreambleLength - not initialised');
      return false;
    }
    var ok = _interface.write(
        GroveLoraRf95Definitions.rhrF95ReG20Preamblemsb, bytes >> 8);
    ok &= _interface.write(
        GroveLoraRf95Definitions.rhrF95ReG21Preamblelsb, bytes & 0xff);
    if (!ok) {
      print('GroveLoraRf95::setPreambleLength - failed to set preamble length');
      return false;
    }
    return true;
  }

  /// setFrequency
  ///
  /// Sets the transmitter and receiver centre frequency
  /// in MHz. 137.0 to 1020.0. Caution: RFM95/96/97/98 comes in several
  /// different frequency ranges, and setting a frequency outside that range
  /// of your radio will probably not work.
  /// Returns true if the frequency is set.
  bool setFrequency(double centre) {
    if (!_initialisedOk()) {
      print('GroveLoraRf95::setFrequency - not initialised');
      return false;
    }
    // Frf = FRF / FSTEP
    var frf = (centre * 1000000.0) ~/ GroveLoraRf95Definitions.rhrF95Fstep;
    var ok = _interface.write(
        GroveLoraRf95Definitions.rhrF95ReG06Frfmsb, (frf >> 16) & 0xff);
    ok &= _interface.write(
        GroveLoraRf95Definitions.rhrF95ReG07Frfmid, (frf >> 8) & 0xff);
    ok &= _interface.write(
        GroveLoraRf95Definitions.rhrF95ReG08Frflsb, frf & 0xff);
    if (!ok) {
      print(
          'GroveLoraRf95::setFrequency - failed to set the frequency $centre');
      return false;
    }
    return true;
  }

  /// setTxPower
  ///
  /// Caution: legal power limits may apply in certain countries.
  /// After [initialise], the power will be set to 13dBm, with PA Boost enabled.
  /// Returns true if the Tx power is set.
  bool setTxPower(int txPower) {
    if (!_initialisedOk()) {
      print('GroveLoraRf95::setTxPower - not initialised');
      return false;
    }
    var power = txPower;
    if (power > 23) power = 23;
    if (power < 5) power = 5;
    var ok = false;

    // For RH_RF95_PA_DAC_ENABLE, manual says '+20dBm on PA_BOOST when OutputPower=0xf'
    // RH_RF95_PA_DAC_ENABLE actually adds about 3dBm to all power levels. We will us it
    // for 21 and 23dBm
    if (power > 20) {
      ok = _interface.write(GroveLoraRf95Definitions.rhrF95ReG4DPaDac,
          GroveLoraRf95Definitions.rhrF95PaDacEnable);
      power -= 3;
    } else {
      ok = _interface.write(GroveLoraRf95Definitions.rhrF95ReG4DPaDac,
          GroveLoraRf95Definitions.rhrF95PaDacDisable);
    }

    // RFM95/96/97/98 does not have RFO pins connected to anything. Only PA_BOOST
    // pin is connected, so must use PA_BOOST
    // Pout = 2 + OutputPower.
    // The documentation is pretty confusing on this topic: PaSelect says the max power is 20dBm,
    // but OutputPower claims it would be 17dBm.
    // My measurements show 20dBm is correct
    ok &= _interface.write(GroveLoraRf95Definitions.rhrF95ReG09Paconfig,
        GroveLoraRf95Definitions.rhrF95PaSelect | (power - 5));
    if (!ok) {
      print('GroveLoraRf95::setTxPower - failed to set the Tx power $power');
      return false;
    }
    return true;
  }

  /// setModeIdle
  ///
  /// If the current mode is Rx or Tx changes it to Idle. If the transmitter or
  /// receiver is running it disables them.
  /// Returns true if idle mode is set.
  bool setModeIdle() {
    if (!_initialisedOk()) {
      print('GroveLoraRf95::setModeIdle - not initialised');
      return false;
    }
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

  bool _initialisedOk() {
    if (!initialised) {
      print(
          'GroveLoraRf95:: not initialised, commands will not be sent to the device');
      return false;
    }
    return true;
  }

  /// Prints the value of all chip registers
  /// For debugging purposes only.
  void printRegisters() {
    final sb = StringBuffer();
    for (final register in GroveLoraRf95Definitions.registers) {
      sb.write('${groveByte2Hex(register)} : ');
      final registerValue = _interface.read(register);
      sb.write('${groveByte2Hex(registerValue)},');
    }
    sb.writeln('');
    print('GroveLoraRf95::printRegisters - register values are :-');
    print(sb.toString());
  }

  /// receiveMessage
  ///
  /// Turns the receiver on if it not already on.
  /// If there is a valid message available, copy it to [buffer] and return true
  /// else return false.
  /// Caution, 0 length messages are permitted.
  /// You should be sure to call this function frequently enough to not miss any messages
  /// It is recommended that you call it in your main loop.
  /// Returns true if a valid message was copied to [buffer]
  bool receiveMessage(List<int> buffer) {
    return false;
  }

  /// available
  ///
  /// Tests whether a new message is available from the driver.
  /// On most drivers, this will also put the driver into [modeRx] mode until
  /// a message is actually received by the transport, when it wil be returned to [modeIdle].
  /// This can be called multiple times in a timeout loop.
  /// Returns true if a new, complete, error-free uncollected message
  /// is available to be retrieved by [receiveMessage].
  bool available() {
    return false;
  }

}
