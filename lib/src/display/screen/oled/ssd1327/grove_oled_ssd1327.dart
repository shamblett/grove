/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

part of grove;

/// Provides support for the Grove OLED 96*96 display module,
/// which is an OLED monochrome display based on a SSD1327 chip.
///
/// The SSD1327 is a 96x96 dot-matrix OLED/PLED segment driver with an
/// associated controller, accessed through the I2C bus.

class GroveOledSsd1327 {
  /// Default device address.
  static const int defaultDeviceAddress = 0x3c;

  /// Construction
  GroveOledSsd1327(this._mraa, this._context,
      [int deviceAddress = defaultDeviceAddress]) {
    // Set the device address
    _mraa.i2c.address(_context, deviceAddress);
  }

  /// The initialised MRAA library
  final Mraa _mraa;

  /// Initialise sleep time default.
  static const Duration initSleepDefault = Duration(microseconds: 3000);

  /// Command sleep time default.
  static const Duration cmdSleepDefault = Duration(microseconds: 1000);

  /// Initialisation inter command sleep time in microseconds
  Duration initSleep = initSleepDefault;

  /// Post command sleep time
  Duration cmdSleep = cmdSleepDefault;

  /// The initialised I2C context
  final Pointer<MraaI2cContext> _context;

  @protected
  bool _initialised = false;

  /// Initialised. Use the setter with caution, intended only for testing.
  bool get initialised => _initialised;
  set initialised(bool state) => _initialised = state;

  final _monitor = GroveSequenceMonitor<MraaReturnCode>(MraaReturnCode.success);

  /// Last monitored sequence status
  GroveSequenceMonitor<MraaReturnCode> get monitored => _monitor;

  int _grayHigh = 0;
  int _grayLow = 0;

  /// The gray level for the OLED panel.
  /// Values are constrained to range 0 - 15.
  set grayLevel(int level) {
    if (level < 0) {
      _grayHigh = 0;
      _grayLow = 0;
      return;
    }
    _grayHigh = (level << 4) & 0xF0;
    _grayLow = level & 0x0F;
  }

  int get grayLevel => _grayLow;

  bool _isVerticalMode = false;

  /// Initialise the display for use.
  ///
  /// Must succeed otherwise no commands are sent to the device.
  /// Returns true if initialisation succeeded and is a
  /// monitored sequence.
  bool initialise() {
    _monitor.reset();
    _initialise(_monitor);
    if (_monitor.isOk) {
      _initialised = true;
      // Initialize the screen
      grayLevel = GroveOledSsd1327Definitions.defaultGrayLevel;
      clear();
      return true;
    }
    return false;
  }

  /// Draws an image.
  ///
  /// Pixels are arranged in one byte for 8 vertical pixels and not
  /// addressed individually.
  MraaReturnCode draw(Uint8List data, int bytes) {
    var error = MraaReturnCode.success;
    _setHorizontalMode();
    for (var row = 0; row < bytes; row++) {
      for (var col = 0; col < 8; col += 2) {
        var value = 0x0;

        final bitOne = (data[row] << col) & 0x80;
        final bitTwo = (data[row] << (col + 1)) & 0x80;

        value |= (bitOne != 0) ? _grayHigh : 0x00;
        value |= (bitTwo != 0) ? _grayLow : 0x00;

        error = _writeReg(GroveOledSsd1327Definitions.oledData, <int>[value]);
        sleep(cmdSleep - const Duration(milliseconds: 2));
      }
    }
    return error;
  }

  /// Writes a string to the OLED.
  ///
  /// Note: only ASCII characters are supported.
  MraaReturnCode write(String msg) {
    var error = MraaReturnCode.success;
    error = _setVerticalMode();
    msg.codeUnits.forEach(_writeChar);
    return error;
  }

  /// Sets the cursor to the specified coordinates.
  /// The text display is a 12 * 12 display of characters.
  MraaReturnCode setCursor(int row, int column) {
    var error = MraaReturnCode.success;
    // Column Address
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.setColumnAddress]);
    sleep(cmdSleep);
    // Start Column
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.startColumnAddress + (column * 4)]);
    sleep(cmdSleep);
    // End column
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.endColumnAddress]);
    sleep(cmdSleep);
    // Row Address
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.setRowAddress]);
    sleep(cmdSleep);
    // Start row
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd, <int>[(row * 8)]);
    sleep(cmdSleep);
    // End Row
    error =
        _writeReg(GroveOledSsd1327Definitions.oledCmd, <int>[0x07 + (row * 8)]);
    sleep(cmdSleep);
    return error;
  }

  /// Clears the display of all characters.
  MraaReturnCode clear() {
    var error = MraaReturnCode.success;
    for (var rowIdx = GroveOledSsd1327Definitions.textRowStart;
        rowIdx < GroveOledSsd1327Definitions.textRowEnd;
        rowIdx++) {
      setCursor(rowIdx, 0);
      // Clear all columns
      for (var columnIdx = GroveOledSsd1327Definitions.textColumnStart;
          columnIdx < GroveOledSsd1327Definitions.textColumnEnd;
          columnIdx++) {
        error = _writeChar(' '.codeUnitAt(0));
      }
    }
    return error;
  }

  /// Returns to the original coordinates (0,0).
  MraaReturnCode home() => setCursor(0, 0);

  /// Draws a bitmap.
  MraaReturnCode drawBitMap(List<int> bitmap, int bytes) {
    var error = MraaReturnCode.success;
    // Set horizontal mode for drawing
    final wasVertical = _isVerticalMode;
    _setHorizontalMode();

    for (var i = 0; i < bytes; i++) {
      for (var j = 0; j < 8; j = j + 2) {
        var c = 0x00;
        final bit1 = bitmap[i] << j & 0x80;
        final bit2 = bitmap[i] << (j + 1) & 0x80;
        // Each bit is changed to a nibble
        c |= (bit1 == 0) ? _grayHigh : 0x00;
        c |= (bit2 == 0) ? _grayLow : 0x00;
        error = _writeReg(GroveOledSsd1327Definitions.oledData, <int>[c]);
      }
    }
    if (wasVertical) {
      error = _setVerticalMode();
    }
    return error;
  }

  MraaReturnCode _writeChar(int value) {
    var rv = MraaReturnCode.success;
    var calcValue = value;
    if (value < 0x20 || value > 0x7F) {
      calcValue = 0x20;
    }
    calcValue -= 0x20;
    for (var row = 0; row < 8; row = row + 2) {
      for (var col = 0; col < 8; col++) {
        var data = 0x0;
        final bitOne =
            ((GroveOledSsd1327Definitions.basicFont[calcValue][row]) >> col) &
                0x1;
        final bitTwo = ((GroveOledSsd1327Definitions.basicFont[calcValue]
                    [row + 1]) >>
                col) &
            0x1;
        data |= (bitOne != 0) ? _grayHigh : 0x00;
        data |= (bitTwo != 0) ? _grayLow : 0x00;
        rv = _writeReg(GroveOledSsd1327Definitions.oledData, <int>[data]);
        sleep(cmdSleep);
      }
    }
    return rv;
  }

  MraaReturnCode _setHorizontalMode() {
    var rv = MraaReturnCode.success;
    // Remap to horizontal mode
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.setRemap]);
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.horizontalMode]);
    sleep(cmdSleep);
    // Reset row Address
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.setRowAddress]);
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.startRowAddress]);
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.endRowAddress]);
    sleep(cmdSleep);
    // Column Address
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.setColumnAddress]);
    sleep(cmdSleep);
    // Start from 8th Column of driver IC. This is 0th Column for OLED
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.startColumnAddress]);
    sleep(cmdSleep);
    // End at  (8 + 47)th column. Each column has 2 pixels(or segments)
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.endColumnAddress]);
    sleep(cmdSleep);
    _isVerticalMode = false;
    return rv;
  }

  MraaReturnCode _setVerticalMode() {
    var rv = MraaReturnCode.success;
    // Remap to vertical mode
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.setRemap]);
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        <int>[GroveOledSsd1327Definitions.verticalMode]);
    sleep(cmdSleep);
    _isVerticalMode = true;
    return rv;
  }

  MraaReturnCode _writeReg(int reg, List<int> data,
      [bool initialising = false]) {
    if (!initialising) {
      if (!_initialised) {
        print(
            '_writeReg - Failed to write data to the command register, not initialised');
        return MraaReturnCode.errorPlatformNotInitialised;
      }
    }
    final ret = _mraa.i2c.writeByteData(_context, data[0], reg);
    if (ret != MraaReturnCode.success && !initialising) {
      print(
          '_writeReg - Failed to write data to the command register, status is '
          '${returnCode.asString(ret)}, register is ${reg.toRadixString(16)}');
    }
    return ret;
  }

  void _initialise(GroveSequenceMonitor<MraaReturnCode> monitor) {
    // Unlock the OLED driver IC MCU interface from entering command.
    // i.e. accept commands
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setCommandLock], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setCommandLockReset], true);
    sleep(initSleep);
    // Set display off
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setDisplayOff], true);
    sleep(initSleep);
    // Set multiplex ratio to 96
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setMuxRatio], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.muxRatio], true);
    sleep(initSleep);
    // Set the display start line
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setDisplayStartLine], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.displayStartLine], true);
    sleep(initSleep);
    // Set the display offset
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setDisplayOffset], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.displayOffset], true);
    sleep(initSleep);
    // Set remap
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setRemap], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.verticalMode], true);
    sleep(initSleep);
    _isVerticalMode = true;
    // Set vdd internal
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.functionSelectionA], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.vddInternal], true);
    sleep(initSleep);
    // Set the contrast
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setContrast], true);
    sleep(initSleep);
    // 100 nit
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.contrast], true);
    sleep(initSleep);
    // Set the phase Length
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setPhaseLength], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.phaseLength], true);
    sleep(initSleep);
    // Set the Display Clock Divide Ratio/Oscillator frequency
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setFrontClock], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.frontClockFrequency], true);
    sleep(initSleep);
    // Linear LUT
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setLinearLut], true);
    sleep(initSleep);
    // Set pre_charge voltage
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setPreChargeVoltage], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.preChargeVoltage], true);
    sleep(initSleep);
    // Set VCOMH
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setVcomh], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.vcomh], true);
    sleep(initSleep);
    // Set second pre-charge period
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setSecondPreChargePeriod], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.secondPreChargePeriod], true);
    sleep(initSleep);
    // Enable second precharge and internal vsl
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.functionSelectionB], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.secondPrechargeAndVSL], true);
    sleep(initSleep);
    // Set Normal Display Mode
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setNormalDisplay], true);
    sleep(initSleep);
    // Deactivate Scroll
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.deactivateScroll], true);
    sleep(initSleep);
    // Switch on display
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setDisplayOn], true);
    sleep(initSleep);
    // Set Row Address
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setRowAddress], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.startRowAddress], true);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.endRowAddress], true);
    sleep(initSleep);
    // Set Column Address
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.setColumnAddress], true);
    sleep(initSleep);
    // Start from 8th Column of driver IC. This is 0th Column for OLED
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.startColumnAddress], true);
    sleep(initSleep);
    // End at  (8 + 47)th column. Each Column has 2  // pixels(segments)
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            <int>[GroveOledSsd1327Definitions.endColumnAddress], true);
    sleep(initSleep);
  }
}
