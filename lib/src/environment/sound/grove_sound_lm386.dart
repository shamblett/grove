/*
* Package : grove
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 13/11/2019
* Copyright :  S.Hamblett
*/

part of '../../../grove.dart';

/// The Grove Sound Sensor can detect the sound intensity of the environment.
///
/// The main component of the module is a simple microphone, which is based
/// on the LM386 amplifier and an electret microphone. This module's output
/// is analogue.
class GroveSoundLM386 {
  /// Sample count can be anything in the range 5..500, values outside this range assume
  /// 5 or 500 as appropriate.
  GroveSoundLM386(this._mraa, this._context, [int sampleCount = 5]) {
    if (sampleCount < 5) {
      _sampleCount = 5;
    } else if (sampleCount > 500) {
      _sampleCount = 500;
    } else {
      _sampleCount = sampleCount;
    }
  }

  /// The initialised MRAA library
  final Mraa _mraa;

  /// The initialised device context
  final MraaAioContext _context;

  int _sampleCount = 0;

  /// The sample count
  int get sampleCount => _sampleCount;

  /// Get a raw value directly from the sound sensor
  int get value => _mraa.aio.read(_context);

  /// Get a smoothed value averaged over [sampleCount] samples
  int get smoothed {
    var retValue = 0;
    for (var i = 0; i < sampleCount; i++) {
      retValue += value;
    }
    return retValue ~/ sampleCount;
  }

  /// Gat a scaled raw value from 1..10, i.e for driving a led bar
  int get scaled => value ~/ 100;

  /// Gat a scaled smooth value from 1..10, i.e for driving a led bar
  int get smoothScaled => smoothed ~/ 100;
}
