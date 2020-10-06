/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

part of grove;

/// This implementation supports the Grove LED 96*96 display module,
/// which is an OLED monochrome display based on a SSD1327 chip.
/// The SSD1327 is a 96x96 dot-matrix OLED/PLED segment driver with an
/// associated controller, accessed through the I2C bus.

class GroveOledSsd1327 {
  /// Construction
  GroveOledSsd1327(this._mraa, this._context) {
    // Set the device address
    _mraa.i2c.address(_context, lcdDeviceAddress);
  }

  /// The initialised MRAA library
  final Mraa _mraa;

  /// Initialisation inter command sleep time in microseconds
  Duration initSleep = initSleepDefault;

  /// Post command sleep time
  Duration cmdSleep = cmdSleepDefault;

  /// The initialised I2C context
  final Pointer<MraaI2cContext> _context;

  static const int lcdDeviceAddress = 0x3C;
  static const Duration initSleepDefault = Duration(microseconds: 3000);
  static const Duration cmdSleepDefault = Duration(microseconds: 1000);

  MraaReturnCode error = MraaReturnCode.success;

  int _grayHigh = 0;
  int _grayLow = 0;

  bool _isVerticalMode = false;

  /// Initialise the display for use
  void initialise() {
    sleep(initSleep);
    // Unlock OLED driver IC MCU interface from entering command.
    // i.e: accept commands
    _writeReg(GroveOledSsd1327Definitions.lcdCmd,
        <int>[GroveOledSsd1327Definitions.setCommandLock1]);
    sleep(initSleep);
    _writeReg(GroveOledSsd1327Definitions.lcdCmd,
        <int>[GroveOledSsd1327Definitions.setCommandLock2]);
    sleep(initSleep);
    // Set display off
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xAE]);
    sleep(initSleep);
    // Set multiplex ratio to 96
    _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xA8]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x5F]);
    sleep(initSleep);
    // Set the display start line
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xA1]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x00]);
    sleep(initSleep);
    // Set the display offset
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xA2]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x60]);
    sleep(initSleep);
    // Set remap
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xA0]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x46]);
    sleep(initSleep);
    // Set vdd internal
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xAB]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x01]);
    sleep(initSleep);
    // Set the contrast
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x81]);
    sleep(initSleep);
    // 100 nit
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x53]);
    sleep(initSleep);
    // Set the phase Length
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xB1]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0X51]);
    sleep(initSleep);
    // Set the Display Clock Divide Ratio/Oscillator
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xB3]);
    // Frequency
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x01]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xB9]);
    sleep(initSleep);
    // Set pre_charge
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xBC]);
    // Set voltage/VCOMH
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x08]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xBE]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0X07]);
    sleep(initSleep);
    // Set second pre-charge
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xB6]);
    // Period
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x01]);
    sleep(initSleep);
    // Enable second precharge and enternal vsl
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xD5]);
    sleep(initSleep);
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0X62]);
    sleep(initSleep);
    // Set Normal Display Mode
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xA4]);
    sleep(initSleep);
    // Deactivate Scroll
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x2E]);
    sleep(initSleep);
    // Switch on display
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xAF]);
    sleep(initSleep);
    // Set Row Address
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x75]);
    sleep(initSleep);
    error =
        _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x00]); // Start 0
    sleep(initSleep);
    error =
        _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x5f]); // End 95
    sleep(initSleep);

    // Set Column Address
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x15]);
    sleep(initSleep);
    // Start from 8th Column of driver IC. This is 0th Column for OLED
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x08]);
    sleep(initSleep);
    // End at  (8 + 47)th column. Each Column has 2  // pixels(segments)
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x37]);
    sleep(initSleep);

    // Initialize the screen
    clear();
    setGrayLevel(12);
    _setNormalDisplay();
    _setVerticalMode();
  }

  /// Draws an image.
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

        error = _writeReg(GroveOledSsd1327Definitions.lcdData, <int>[value]);
        sleep(cmdSleep - const Duration(milliseconds: 2));
      }
    }
    return error;
  }

  /// Sets the gray level for the LCD panel
  void setGrayLevel(int level) {
    _grayHigh = (level << 4) & 0xF0;
    _grayLow = level & 0x0F;
  }

  /// Writes a string to the LCD
  /// Note: only ASCII characters are supported.
  MraaReturnCode write(String msg) {
    var error = MraaReturnCode.success;
    error = _setVerticalMode();
    msg.codeUnits.forEach(_writeChar);
    return error;
  }

  /// Sets the cursor to specified coordinates
  MraaReturnCode setCursor(int row, int column) {
    var error = MraaReturnCode.success;
    // Column Address
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd,
        <int>[GroveOledSsd1327Definitions.setColumnAddress]);
    sleep(cmdSleep);
    // Start Column, start from 8
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd,
        <int>[GroveOledSsd1327Definitions.startColumn + (column * 4)]);
    sleep(cmdSleep);
    // End column
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x37]);
    sleep(cmdSleep);
    // Row Address
    error = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x75]);
    sleep(cmdSleep);
    // Start row
    error =
        _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x00 + (row * 8)]);
    sleep(cmdSleep);
    // End Row
    error =
        _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x07 + (row * 8)]);
    sleep(cmdSleep);
    return error;
  }

  /// Clears the display of all characters
  MraaReturnCode clear() {
    var error = MraaReturnCode.success;
    int columnIdx, rowIdx;
    for (rowIdx = 0; rowIdx < 12; rowIdx++) {
      setCursor(rowIdx, 0);
      // Clear all columns
      for (columnIdx = 0; columnIdx < 12; columnIdx++) {
        error = _writeChar(' '.codeUnitAt(0));
      }
    }
    return error;
  }

  /// Returns to the original coordinates (0,0)
  MraaReturnCode home() => setCursor(0, 0);

  /// Draws a bitmap
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
        error = _writeReg(GroveOledSsd1327Definitions.lcdData, <int>[c]);
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
    for (var row = 0; row < 8; row = row + 2) {
      for (var col = 0; col < 8; col++) {
        var data = 0x0;
        final bitOne = ((GroveOledSsd1327Definitions.basicFont[calcValue - 32]
                    [row]) >>
                col) &
            0x1;
        final bitTwo = ((GroveOledSsd1327Definitions.basicFont[calcValue - 32]
                    [row + 1]) >>
                col) &
            0x1;
        data |= (bitOne != 0) ? _grayHigh : 0x00;
        data |= (bitTwo != 0) ? _grayLow : 0x00;
        rv = _writeReg(GroveOledSsd1327Definitions.lcdData, <int>[data]);
        sleep(cmdSleep);
      }
    }
    return rv;
  }

  MraaReturnCode _setNormalDisplay() => _writeReg(
      GroveOledSsd1327Definitions.lcdCmd,
      <int>[GroveOledSsd1327Definitions.displayCmdSetNormal]);

  MraaReturnCode _setHorizontalMode() {
    var rv = MraaReturnCode.success;
    rv = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xA0]); // remap to
    sleep(cmdSleep);
    rv = _writeReg(
        GroveOledSsd1327Definitions.lcdCmd, <int>[0x42]); // horizontal mode
    sleep(cmdSleep);
    // Row Address
    rv = _writeReg(
        GroveOledSsd1327Definitions.lcdCmd, <int>[0x75]); // Set Row Address
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x00]); // Start 0
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x5f]); // End 95
    sleep(cmdSleep);
    // Column Address
    rv = _writeReg(
        GroveOledSsd1327Definitions.lcdCmd, <int>[0x15]); // Set Column Address
    sleep(cmdSleep);
    // Start from 8th Column of driver IC. This is 0th Column for OLED
    rv = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x08]);
    sleep(cmdSleep);
    // End at  (8 + 47)th column. Each column has 2 pixels(or segments)
    rv = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x37]);
    sleep(cmdSleep);
    _isVerticalMode = false;
    return rv;
  }

  MraaReturnCode _setVerticalMode() {
    var rv = MraaReturnCode.success;
    // Remap to vertical mode
    rv = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0xA0]);
    sleep(cmdSleep);
    rv = _writeReg(GroveOledSsd1327Definitions.lcdCmd, <int>[0x46]);
    sleep(cmdSleep);
    _isVerticalMode = true;
    return rv;
  }

  MraaReturnCode _writeReg(int reg, List<int> data) =>
      _mraa.i2c.writeByteData(_context, data[0], reg);
}
