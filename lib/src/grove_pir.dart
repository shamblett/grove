/**
 * Package : mraa
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 13/11/2019
 * Copyright :  S.Hamblett
 */

part of grove;

/// This sensor allows you to sense motion, usually human movement
/// in its range. It uses passive infra red sensing.
/// When anyone moves in its detecting range, the sensor will
/// output HIGH on its SIG pin.
class GrovePir {
  GrovePir(this._mraa, this._context);

  /// The initialised MRAA library
  final Mraa _mraa;

  /// The initialised device context
  final Pointer<MraaGpioContext> _context;

  int _lastValue = 0;

  /// Read the current value on the signal pin,
  /// either 0 or 1
  int value() => _mraa.gpio.read(_context);

  /// Check if the sensor has triggered, i.e has transitioned from a 0 to a 1
  bool hasTriggered() {
    final int now = value();
    if (now > _lastValue) {
      _lastValue = now;
      return true;
    }
    _lastValue = now;
    return false;
  }
}
