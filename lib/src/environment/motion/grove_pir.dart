/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 13/11/2019
 * Copyright :  S.Hamblett
 */

part of '../../../grove.dart';

/// The Grove PIR Motion Sensor.
///
/// This sensor allows you to sense motion, usually human movement
/// in its range. It uses passive infra red sensing.
///
/// When anyone moves in its detecting range, the sensor will
/// output HIGH on its SIG pin.
class GrovePir {
  /// Construction
  GrovePir(this._mraa, this._context);

  /// The initialised MRAA library
  final Mraa _mraa;

  /// The initialised device context
  final MraaGpioContext _context;

  int _lastValue = -1;

  /// Read the current value on the signal pin,
  /// either 0 or 1.
  int get value => _mraa.gpio.read(_context);

  /// Check if the sensor has triggered, i.e has transitioned from a 0 to a 1.
  /// This is a latch, if the sensor stays at 1 this will continue to return true
  /// until the sensor transitions back to a 0 when false will be returned.
  bool get hasTriggered {
    final now = value;
    if (now != _lastValue) {
      _lastValue = now;
      if (now == 1) {
        return true;
      }
    }
    return now == 1 ? true : false;
  }
}
