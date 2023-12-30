/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

part of '../../../grove.dart';

/// The Grove light sensor.
///
/// The Grove LM358 light sensor integrates a photo-resistor(light dependent
/// resistor) to detect the intensity of light. The resistance of
/// photo-resistor decreases when the intensity of light increases.
///
/// The dual OpAmp chip LM358 on board produces voltage corresponding to
/// intensity of light(i.e. based on resistance value).
///
/// The output signal is analog value, the brighter the light is,
/// the larger the value.
class GroveLightLM358 {
  /// Construction
  GroveLightLM358(this._mraa, this._context);

  /// The initialised MRAA library
  final Mraa _mraa;

  /// The initialised device context
  final MraaAioContext _context;

  /// Get the raw and Lux light values and timestamp them.
  ///
  /// Get the Lux value from a raw value, using the ADC resolution , this
  /// value 1024,2048 or 4096 and can be taken from the board implementation.
  /// If the [maxAdc] value is too small a Nan may be returned.
  GroveLightValues get values {
    // Get the ADC value range for Lux conversion
    final maxAdc = (1 << _mraa.aio.getBit(_context)) - 1;
    final raw = _mraa.aio.read(_context);
    final values = GroveLightValues();
    values.raw = raw;
    values.lux = 10000.0 /
        pow(((maxAdc - values.raw) * 10.0 / values.raw) * 15.0, 4.0 / 3.0);
    values.validAt = DateTime.now();
    return values;
  }
}
