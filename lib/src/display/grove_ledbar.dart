/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 10/11/2019
 * Copyright :  S.Hamblett
 */

part of grove;

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print

/// Local context for the MY9221 chip
class My9221Context {
  /// GPIO clock pin context
  Pointer<MraaGpioContext> gpioClk;

  /// GPIO data pin context
  Pointer<MraaGpioContext> gpioData;

  /// Auto refresh state
  bool autoRefresh = true;

  /// Low intensity level
  int lowIntensity;

  /// High intensity level
  int highIntensity;

  /// Maximum led bars
  int maxLed;

  /// Maximum led bar instances
  int instances;

  /// An array of Uint16's representing our bit states (on/off)
  /// intensities.  Only the low 8 bits are used.
  Uint16List bitStates;

  /// The command word
  int commandWord;

  /// Initialise status
  bool initialized;
}

/// The Grove LED Bar is comprised of a 10 segment LED gauge bar and an MY9221
/// LED controlling chip.
///
/// It can be used as an indicator for remaining battery life, voltage,
/// water level, music volume or other values that require a gradient display.
/// There are 10 LED bars in the LED bar graph: one red, one yellow,
/// one light green, and seven green bars.
class GroveLedBar {
  /// Construction
  GroveLedBar(Mraa mraa, Pointer<MraaGpioContext> clockPin,
      Pointer<MraaGpioContext> dataPin) {
    _dev = My9221Context();
    _dev.gpioClk = clockPin;
    _dev.gpioData = dataPin;
    _mraa = mraa;
  }

  /// Led bars per instance + 2 for intensity settings
  static const int ledPerInstance = 12;

  /// The My9221 context
  My9221Context _dev;

  /// The initialised MRAA library
  Mraa _mraa;

  /// Initialise - must be called before use
  MraaReturnCode initialise() {
    MraaReturnCode ret = MraaReturnCode.success;
    // Set the clock and data pin directions
    ret = _mraa.gpio.direction(_dev.gpioClk, MraaGpioDirection.out);
    if (ret != MraaReturnCode.success) {
      print('initialise - Failed to set direction for clock pin, state is '
          '${returnCode.asString(ret)}');
      return ret;
    }
    ret = _mraa.gpio.direction(_dev.gpioData, MraaGpioDirection.out);
    if (ret != MraaReturnCode.success) {
      print('initialise - Failed to set direction for data pin, state is '
          '${returnCode.asString(ret)}');
      return ret;
    }
    setLowIntensityValue(0x00);
    setHighIntensityValue(0xFF);
    _dev.commandWord = 0x0000; // all defaults
    _dev.instances = 1;
    _dev.bitStates = Uint16List(ledPerInstance);
    autoRefresh = true;
    _dev.maxLed = ledPerInstance;
    clearAll();
    _dev.initialized = true;
    return ret;
  }

  /// Close the GPIO pin contexts and
  /// the MY9221 context.
  void close() {
    if (_dev.initialized) {
      clearAll();
      if (_dev.autoRefresh) {
        refresh();
      }
    }
    _mraa.gpio.close(_dev.gpioClk);
    _mraa.gpio.close(_dev.gpioData);
    _dev.initialized = false;
  }

  /// Set level (0-10)
  /// Level 0 means all leds off
  /// Level 10 means all leds on
  void setLevel(int level) {
    clearAll();
    if (level <= 0) {
      return;
    }
    if (level >= 10) {
      setAll();
      return;
    }
    for (int i = 0; i < level; i++) {
      _dev.bitStates[i] = 1;
    }
    if (_dev.autoRefresh) {
      refresh();
    }
  }

  /// Set and individual led on or off, note this will
  /// auto scale to the led range.
  void setLed(int led, {bool on}) {
    final int maxLed = _dev.maxLed - 1;
    int localLed = led;

    if (localLed > maxLed) {
      localLed = maxLed;
    }
    if (localLed < 0) {
      localLed = 0;
    }
    _dev.bitStates[localLed] = on ? _dev.highIntensity : _dev.lowIntensity;
    if (_dev.autoRefresh) {
      refresh();
    }
  }

  /// Set low intensity
  void setLowIntensityValue(int intensity) =>
      _dev.lowIntensity = intensity & 0xff;

  /// Set high intensity
  void setHighIntensityValue(int intensity) =>
      _dev.highIntensity = intensity & 0xff;

  /// Set all Led's on
  void setAll() {
    for (int i = 0; i < _dev.maxLed; i++) {
      _dev.bitStates[i] = _dev.highIntensity;
    }
    if (_dev.autoRefresh) {
      refresh();
    }
  }

  /// Clear all Led's
  void clearAll() {
    for (int i = 0; i < _dev.maxLed; i++) {
      _dev.bitStates[i] = _dev.lowIntensity;
    }
    if (_dev.autoRefresh) {
      refresh();
    }
  }

  /// Auto refresh state
  // ignore: avoid_setters_without_getters
  set autoRefresh(bool enable) => _dev.autoRefresh = enable;

  /// Max led bars
  int get maxLed => _dev.maxLed;

  /// Refresh the display
  void refresh() {
    _send16BitBlock(_dev.commandWord);
    for (int i = 0; i < 10; i++) {
      _send16BitBlock(_dev.bitStates[i]);
    }
    // Send two extra empty bits for padding the command to the correct length.
    _send16BitBlock(0x00);
    _send16BitBlock(0x00);
    _lockData();
  }

  void _lockData() {
    // Writes command data to the MY9221 chip latch
    _mraa.gpio.write(_dev.gpioData, 0);
    _mraa.gpio.write(_dev.gpioClk, 1);
    _mraa.gpio.write(_dev.gpioClk, 0);
    _mraa.gpio.write(_dev.gpioClk, 1);
    _mraa.gpio.write(_dev.gpioClk, 0);
    sleep(const Duration(microseconds: 240));

    for (int idx = 0; idx < 4; idx++) {
      _mraa.gpio.write(_dev.gpioData, 1);
      _mraa.gpio.write(_dev.gpioData, 0);
    }
    sleep(const Duration(microseconds: 1));
    _mraa.gpio.write(_dev.gpioClk, 1);
    _mraa.gpio.write(_dev.gpioClk, 0);
  }

  void _send16BitBlock(int data) {
    MraaReturnCode ret;
    int localData = data;
    for (int bitIdx = 0; bitIdx < 16; bitIdx++) {
      int state = (localData & 0x8000) != 0 ? 1 : 0;
      ret = _mraa.gpio.write(_dev.gpioData, state);
      if (ret != MraaReturnCode.success) {
        print('send16BitBlock - Failed to write state to data pin, status is '
            '${returnCode.asString(ret)}, state is $state');
      }
      state = _mraa.gpio.read(_dev.gpioClk);
      if (state == Mraa.generalError) {
        print('send16BitBlock - Failed to read state of clock pin, status is '
            '${returnCode.asString(ret)}');
      }
      if (state != 0) {
        state = 0;
      } else {
        state = 1;
      }
      ret = _mraa.gpio.write(_dev.gpioClk, state);
      if (ret != MraaReturnCode.success) {
        print('send16BitBlock - Failed to write state to clock pin, status is '
            '${returnCode.asString(ret)}, state is $state');
      }
      localData <<= 1;
    }
  }
}
