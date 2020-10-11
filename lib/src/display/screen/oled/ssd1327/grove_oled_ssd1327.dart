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

  var _initialisationState = GroveDeveiceInitialisationState.notInitialised;

  /// Initialised. Use the setter with caution, intended only for testing.
  bool get initialised =>
      _initialisationState == GroveDeveiceInitialisationState.initialised;

  set initialised(bool state) => state
      ? _initialisationState = GroveDeveiceInitialisationState.initialised
      : GroveDeveiceInitialisationState.notInitialised;

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
  ///
  /// Performs the following actions :-
  ///
  /// Unlocks the OLED driver IC MCU interface.
  /// Sets the display off.
  /// Sets multiplex ratio to 96.
  /// Sets the display start line.
  /// Sets the display offset.
  /// Sets remap.
  /// Sets VDD internal
  /// Sets the contrast.
  /// Sets the phase length.
  /// Sets the display clock divide ratio/oscillator frequency
  /// Sets linear LUT.
  /// Sets the pre_charge voltage.
  /// Sets VCOMH.
  /// Sets the second pre-charge period.
  /// Enables the second precharge and internal vsl.
  /// Sets normal mode.
  /// Deactivates scroll.
  /// Switches on display.
  /// Sets the row address.
  /// Sets the column address.
  /// Sets the default gray level
  /// Optionally clears the display
  bool initialise({bool clearDisplay = false}) {
    _monitor.reset();
    _initialisationState = GroveDeveiceInitialisationState.initialising;
    _initialise(_monitor);
    if (_monitor.isOk) {
      _initialisationState = GroveDeveiceInitialisationState.initialised;
      // Initialize the screen
      grayLevel = GroveOledSsd1327Definitions.defaultGrayLevel;
      if ( clearDisplay ) {
        clear();
      }
        return true;
    }
    _initialisationState = GroveDeveiceInitialisationState.notInitialised;
    return false;
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
  ///
  /// The text display is a 12 * 12 display of characters giving
  /// cursor parameters of 0..11 to which they are constrained.
  MraaReturnCode setCursor(int pRow, int pColumn) {
    var error = MraaReturnCode.success;
    final row = pRow.isNegative
        ? 0
        : pRow >= GroveOledSsd1327Definitions.textRowEnd - 1
            ? GroveOledSsd1327Definitions.textRowEnd - 1
            : pRow;
    final column = pColumn.isNegative
        ? 0
        : pColumn >= GroveOledSsd1327Definitions.textColumnEnd - 1
            ? GroveOledSsd1327Definitions.textColumnEnd - 1
            : pColumn;
    // Column Address
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.setColumnAddress);
    sleep(cmdSleep);
    // Start Column
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.startColumnAddress + (column * 4));
    sleep(cmdSleep);
    // End column
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.endColumnAddress);
    sleep(cmdSleep);
    // Row Address
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.setRowAddress);
    sleep(cmdSleep);
    // Start row
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd, (row * 8));
    sleep(cmdSleep);
    // End Row
    error = _writeReg(GroveOledSsd1327Definitions.oledCmd, 0x07 + (row * 8));
    sleep(cmdSleep);
    return error;
  }

  /// Clears the display of all characters.
  MraaReturnCode clear() {
    var error = MraaReturnCode.success;
    final wasVertical = _isVerticalMode;
    final gray = grayLevel;
    grayLevel = 0;
    final byteData = Uint8List(GroveOledSsd1327Definitions.maxPixels)
      ..fillRange(0, GroveOledSsd1327Definitions.maxPixels - 1, 1);
    error = _draw(byteData);
    if (wasVertical) {
      error = _setVerticalMode();
    }
    grayLevel = gray;
    return error;
  }

  /// Returns to the original coordinates (0,0).
  MraaReturnCode home() => setCursor(0, 0);

  /// Draws an image.
  ///
  /// Pixels are arranged in one byte for 8 vertical pixels and not
  /// addressed individually.
  /// If bytes to draw is not supplied then all the bytes are drawn.
  /// Vertical mode is preserved.
  MraaReturnCode drawImage(List<int> bitmap, [int bytesToDraw]) {
    var error = MraaReturnCode.success;
    final wasVertical = _isVerticalMode;
    final data = Uint8List.fromList(bitmap);
    _draw(data, bytesToDraw);
    if (wasVertical) {
      error = _setVerticalMode();
    }
    return error;
  }

  /// Display mode on.
  ///
  /// Force the entire display to be at the highest gray scale level,
  /// regardless of the contents of the display data.
  void displayOn() => _writeReg(GroveOledSsd1327Definitions.oledCmd,
      GroveOledSsd1327Definitions.displayModeOn);

  /// Display mode off.
  ///
  /// Force the entire display to be at the lowest gray scale level,
  /// regardless of the contents of the display data.
  void displayOff() => _writeReg(GroveOledSsd1327Definitions.oledCmd,
      GroveOledSsd1327Definitions.displayModeOff);

  /// Inverse display mode.
  ///
  /// The gray scale level of display data are swapped such that gray low
  /// become gray high.
  void invertDisplay() => _writeReg(GroveOledSsd1327Definitions.oledCmd,
      GroveOledSsd1327Definitions.displayModeInvert);

  /// Normal display.
  ///
  /// Reset the [displayOn], [displayOff] or [invertDisplay] effects and
  /// turn the data to on at the set gray level.
  void displayNormal() => _writeReg(GroveOledSsd1327Definitions.oledCmd,
      GroveOledSsd1327Definitions.displayModeNormal);

  /// Turn the display on in normal mode.
  void turnOn() => _writeReg(GroveOledSsd1327Definitions.oledCmd,
      GroveOledSsd1327Definitions.setDisplayOn);

  /// Turn the display off(sleep) mode.
  void turnOff() => _writeReg(GroveOledSsd1327Definitions.oledCmd,
      GroveOledSsd1327Definitions.setDisplayOff);

  MraaReturnCode _draw(Uint8List data, [int bytesToDraw]) {
    var error = MraaReturnCode.success;
    // Set horizontal mode for drawing
    _setHorizontalMode();
    final bytes = bytesToDraw ?? data.length;
    for (var row = 0; row < bytes; row++) {
      for (var col = 0; col < 8; col += 2) {
        var value = 0x0;

        final bitOne = (data[row] << col) & 0x80;
        final bitTwo = (data[row] << (col + 1)) & 0x80;

        value |= (bitOne == 0) ? _grayHigh : 0x00;
        value |= (bitTwo == 0) ? _grayLow : 0x00;

        error = _writeReg(GroveOledSsd1327Definitions.oledData, value);
        sleep(cmdSleep);
      }
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
        rv = _writeReg(GroveOledSsd1327Definitions.oledData, data);
        sleep(cmdSleep);
      }
    }
    return rv;
  }

  MraaReturnCode _setHorizontalMode() {
    var rv = MraaReturnCode.success;
    // Remap to horizontal mode
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.setRemap);
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.horizontalMode);
    sleep(cmdSleep);
    // Reset row Address
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.setRowAddress);
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.startRowAddress);
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.endRowAddress);
    sleep(cmdSleep);
    // Column Address
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.setColumnAddress);
    sleep(cmdSleep);
    // Start from 8th Column of driver IC. This is 0th Column for OLED
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.startColumnAddress);
    sleep(cmdSleep);
    // End at  (8 + 47)th column. Each column has 2 pixels(or segments)
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.endColumnAddress);
    sleep(cmdSleep);
    _isVerticalMode = false;
    return rv;
  }

  MraaReturnCode _setVerticalMode() {
    var rv = MraaReturnCode.success;
    // Remap to vertical mode
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.setRemap);
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.oledCmd,
        GroveOledSsd1327Definitions.verticalMode);
    sleep(cmdSleep);
    _isVerticalMode = true;
    return rv;
  }

  MraaReturnCode _writeReg(int reg, int data) {
    if (!initialised) {
      if (_initialisationState !=
          GroveDeveiceInitialisationState.initialising) {
        print(
            '_writeReg - Failed to write data to the command register, not initialised');
        return MraaReturnCode.errorPlatformNotInitialised;
      }
    }
    final ret = _mraa.i2c.writeByteData(_context, data, reg);
    if (ret != MraaReturnCode.success) {
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
            GroveOledSsd1327Definitions.setCommandLock);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setCommandLockReset);
    sleep(initSleep);
    // Set display off
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setDisplayOff);
    sleep(initSleep);
    // Set multiplex ratio to 96
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setMuxRatio);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.muxRatio);
    sleep(initSleep);
    // Set the display start line
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setDisplayStartLine);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.displayStartLine);
    sleep(initSleep);
    // Set the display offset
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setDisplayOffset);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.displayOffset);
    sleep(initSleep);
    // Set remap
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setRemap);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.verticalMode);
    sleep(initSleep);
    _isVerticalMode = true;
    // Set vdd internal
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.functionSelectionA);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.vddInternal);
    sleep(initSleep);
    // Set the contrast
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setContrast);
    sleep(initSleep);
    // 100 nit
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.contrast);
    sleep(initSleep);
    // Set the phase Length
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setPhaseLength);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.phaseLength);
    sleep(initSleep);
    // Set the Display Clock Divide Ratio/Oscillator frequency
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setFrontClock);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.frontClockFrequency);
    sleep(initSleep);
    // Linear LUT
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setLinearLut);
    sleep(initSleep);
    // Set pre_charge voltage
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setPreChargeVoltage);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.preChargeVoltage);
    sleep(initSleep);
    // Set VCOMH
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setVcomh);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.vcomh);
    sleep(initSleep);
    // Set second pre-charge period
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setSecondPreChargePeriod);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.secondPreChargePeriod);
    sleep(initSleep);
    // Enable second precharge and internal vsl
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.functionSelectionB);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.secondPrechargeAndVSL);
    sleep(initSleep);
    // Set Normal Display Mode
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setNormalDisplay);
    sleep(initSleep);
    // Deactivate Scroll
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.deactivateScroll);
    sleep(initSleep);
    // Switch on display
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setDisplayOn);
    sleep(initSleep);
    // Set Row Address
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setRowAddress);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.startRowAddress);
    sleep(initSleep);
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.endRowAddress);
    sleep(initSleep);
    // Set Column Address
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.setColumnAddress);
    sleep(initSleep);
    // Start from 8th Column of driver IC. This is 0th Column for OLED
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.startColumnAddress);
    sleep(initSleep);
    // End at  (8 + 47)th column. Each Column has 2  // pixels(segments)
    monitor +
        _writeReg(GroveOledSsd1327Definitions.oledCmd,
            GroveOledSsd1327Definitions.endColumnAddress);
    sleep(initSleep);
  }
}
