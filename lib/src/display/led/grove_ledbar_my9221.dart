/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 10/11/2019
 * Copyright :  S.Hamblett
 */

part of '../../../grove.dart';

/// Local context for the MY9221 chip
class My9221Context {
  /// GPIO clock pin context
  late MraaGpioContext gpioClk;

  /// GPIO data pin context
  late MraaGpioContext gpioData;

  /// Auto refresh state
  bool autoRefresh = false;

  /// Low intensity level
  int? lowIntensity;

  /// High intensity level
  int? highIntensity;

  /// Maximum led bars
  int? maxLed;

  /// Maximum led bar instances
  int? instances;

  /// An array of Uint16's representing our bit states (on/off)
  /// intensities.  Only the low 8 bits are used.
  late Uint16List bitStates;

  /// The command word
  int? commandWord;

  /// Initialise status
  bool initialized = false;
}

/// The Grove LED Bar MY9221 is comprised of a 10 segment LED gauge bar and an MY9221
/// LED controlling chip.
///
/// It can be used as an indicator for remaining battery life, voltage,
/// water level, music volume or other values that require a gradient display.
///
/// There are 10 LED bars in the LED bar graph: one red, one yellow,
/// one light green, and seven green bars.
///
/// An individual led is on or off dependent on its intensity value, initially
/// values of 0 and 0xff are used for low and high intensity values. These can
/// be set as you wish, with a high intensity value 0x7f being half the intensity of
/// a 0xff value.
class GroveLedBarMy9221 {
  /// Construction
  GroveLedBarMy9221(
      Mraa mraa, MraaGpioContext clockPin, MraaGpioContext dataPin) {
    _dev = My9221Context();
    _dev!.gpioClk = clockPin;
    _dev!.gpioData = dataPin;
    _mraa = mraa;
  }

  /// Led bars per instance
  static const int ledPerInstance = 10;

  My9221Context? _dev;

  /// The My9221 context
  My9221Context? get deviceContext => _dev;

  /// The initialised MRAA library
  late Mraa _mraa;

  final _monitor = GroveSequenceMonitor<MraaReturnCode>(MraaReturnCode.success);

  /// Last monitored sequence status
  GroveSequenceMonitor<MraaReturnCode> get monitored => _monitor;

  /// Initialise - must be called before use otherwise
  /// no commands will be sent to the device.
  /// Returns true if initialisation succeeded and is a
  /// monitored sequence.
  bool initialise() {
    _monitor.reset();
    _initialise(_monitor);
    if (_monitor.isOk) {
      _dev!.initialized = true;
      return true;
    }
    return false;
  }

  /// Close the GPIO pin contexts and
  /// the MY9221 context.
  void close() {
    if (_dev!.initialized) {
      clearAll();
      if (_dev!.autoRefresh) {
        refresh();
      }
    }
    _mraa.gpio.close(_dev!.gpioClk);
    _mraa.gpio.close(_dev!.gpioData);
    _dev!.initialized = false;
  }

  /// Set level (0-10)
  /// Level 0 means all leds off
  /// Level 10 means all leds on
  void setLevel(int level) {
    clearAll();
    if (level <= 0) {
      return;
    }
    if (level >= ledPerInstance - 2) {
      setAll();
      return;
    }
    for (var i = 0; i < level; i++) {
      _dev!.bitStates[i] = _dev!.highIntensity!;
    }
    if (_dev!.autoRefresh) {
      refresh();
    }
  }

  /// Set and individual led on or off, note this will
  /// auto scale to the led range.
  void setLed(int led, {bool on = false}) {
    final maxLed = _dev!.maxLed! - 1;
    var localLed = led;

    if (localLed > maxLed) {
      localLed = maxLed;
    }
    if (localLed < 0) {
      localLed = 0;
    }
    _dev!.bitStates[localLed] = on ? _dev!.highIntensity! : _dev!.lowIntensity!;
    if (_dev!.autoRefresh) {
      refresh();
    }
  }

  /// Set low intensity
  set lowIntensity(int intensity) => _dev!.lowIntensity = intensity & 0xff;

  /// Set high intensity
  set highIntensity(int intensity) => _dev!.highIntensity = intensity & 0xff;

  /// Set all Led's on
  void setAll() {
    for (var i = 0; i < maxLed!; i++) {
      _dev!.bitStates[i] = _dev!.highIntensity!;
    }
    if (_dev!.autoRefresh) {
      refresh();
    }
  }

  /// Clear all Led's
  void clearAll() {
    for (var i = 0; i < maxLed!; i++) {
      _dev!.bitStates[i] = _dev!.lowIntensity!;
    }
    if (_dev!.autoRefresh) {
      refresh();
    }
  }

  /// Auto refresh
  ///
  /// If true then any updates to the state of the led bar will be
  /// automatically sent to the device. If false the user must do this
  /// themselves.
  /// Defaults to false.
  set autoRefresh(bool enable) => _dev!.autoRefresh = enable;

  /// Max led bars
  int? get maxLed => _dev!.maxLed;

  /// Refresh the display.
  /// This can be done automatically see [autoRefresh].
  /// The device must be initialised.
  void refresh() {
    if (!_dev!.initialized) {
      return;
    }
    _send16BitBlock(_dev!.commandWord);
    for (var i = 0; i < maxLed!; i++) {
      _send16BitBlock(_dev!.bitStates[i]);
    }
    // Send two extra empty bits for padding the command to the correct length.
    _send16BitBlock(0x00);
    _send16BitBlock(0x00);
    _lockData();
  }

  void _lockData() {
    // Writes command data to the MY9221 chip latch
    _mraa.gpio.write(_dev!.gpioData, 0);
    _mraa.gpio.write(_dev!.gpioClk, 1);
    _mraa.gpio.write(_dev!.gpioClk, 0);
    _mraa.gpio.write(_dev!.gpioClk, 1);
    _mraa.gpio.write(_dev!.gpioClk, 0);
    io.sleep(const Duration(microseconds: 240));

    for (var idx = 0; idx < 4; idx++) {
      _mraa.gpio.write(_dev!.gpioData, 1);
      _mraa.gpio.write(_dev!.gpioData, 0);
    }
    io.sleep(const Duration(microseconds: 1));
    _mraa.gpio.write(_dev!.gpioClk, 1);
    _mraa.gpio.write(_dev!.gpioClk, 0);
  }

  void _send16BitBlock(int? data) {
    MraaReturnCode ret;
    var localData = data;
    for (var bitIdx = 0; bitIdx < 16; bitIdx++) {
      var state = (localData! & 0x8000) != 0 ? 1 : 0;
      ret = _mraa.gpio.write(_dev!.gpioData, state);
      if (ret != MraaReturnCode.success) {
        print(
            'send16BitBlock - Failed to write state to data pin, status is $ret, state is $state');
      }
      state = _mraa.gpio.read(_dev!.gpioClk);
      if (state == Mraa.generalError) {
        print(
            'send16BitBlock - Failed to read state of clock pin, status is $ret');
      }
      if (state != 0) {
        state = 0;
      } else {
        state = 1;
      }
      ret = _mraa.gpio.write(_dev!.gpioClk, state);
      if (ret != MraaReturnCode.success) {
        print(
            'send16BitBlock - Failed to write state to clock pin, status is $ret, state is $state');
      }
      localData <<= 1;
    }
  }

  void _initialise(GroveSequenceMonitor<MraaReturnCode> monitor) {
    // Set the clock and data pin directions
    monitor + _mraa.gpio.direction(_dev!.gpioClk, MraaGpioDirection.out);
    monitor + _mraa.gpio.direction(_dev!.gpioData, MraaGpioDirection.out);
    lowIntensity = 0x00;
    highIntensity = 0xff;
    _dev!.commandWord = 0x0000;
    _dev!.instances = 1;
    _dev!.bitStates = Uint16List(ledPerInstance);
    _dev!.maxLed = ledPerInstance;
    clearAll();
  }
}
