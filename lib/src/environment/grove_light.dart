/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

part of grove;

/// The values class for the Grove light class
class GroveLightValues {
  /// Raw value
  int raw;

  /// Lux
  double lux;

  /// Timestamp
  DateTime validAt;

  @override
  String toString() =>
      'Light values at $validAt :: Raw : $raw : Lux ${lux.toStringAsFixed(2)}';
}

/// The Grove light sensor.
///
/// The Grove light sensor integrates a photo-resistor(light dependent
/// resistor) to detect the intensity of light. The resistance of
/// photo-resistor decreases when the intensity of light increases.
/// A dual OpAmp chip LM358 on board produces voltage corresponding to
/// intensity of light(i.e. based on resistance value).
/// The output signal is analog value, the brighter the light is,
/// the larger the value.
class GroveLight {
  /// Construction
  GroveLight(this._mraa, this._context);

  /// The initialised MRAA library
  final Mraa _mraa;

  /// The initialised device context
  final Pointer<MraaAioContext> _context;

  /// Get the raw and Lux light values and timestamp them.
  GroveLightValues getValues() {
    // Get the ADC value range for Lux conversion
    final int maxAdc = (1 << _mraa.aio.getBit(_context)) - 1;
    final int raw = _mraa.aio.read(_context);
    return calculateLux(raw, maxAdc);
  }

  /// Get the Lux value from a raw value, using the ADC resolution , this
  /// value 1024,2048 or 4096 and can be taken from the board implementation.
  /// If the [maxAdc] value is to small a Nan may be returned.
  GroveLightValues calculateLux(int rawValue, int maxAdc) {
    final GroveLightValues values = GroveLightValues();
    values.raw = rawValue;
    values.lux = 10000.0 /
        pow(((maxAdc - values.raw) * 10.0 / values.raw) * 15.0, 4.0 / 3.0);
    return values;
  }
}
