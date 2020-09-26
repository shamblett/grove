/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

part of grove;

/// The Grove temperature sensor.
///
/// The Grove Temperature Sensor(V1.2) uses a Thermistor to detect the ambient
/// temperature.
///
/// The resistance of a thermistor will increase when the ambient
/// temperature decreases. It's this characteristic that we use to calculate
/// the ambient temperature.
///
/// The detectable range of this sensor is -40 - 125ºC, and the
/// accuracy is ±1.5ºC
class GroveTemperatureV12 {
  /// Construction
  GroveTemperatureV12(this._mraa, this._context);

  /// Scaling factor for raw analog value from the ADC, useful for mixed
  /// 3.3V/5V boards, default 1.0
  static const double scale = 1;

  /// Zero power resistance, this is 100K (default) for v1.1-v1.2
  /// and 10K for v1.0 of the sensor
  static const int r0 = 100000;

  /// Thermistor nominal B constant, this is 4275 (default)
  /// for v1.1-v1.2 and 3975 for v1.0 of the sensor
  static const int b = 4275;

  /// The initialised MRAA library
  final Mraa _mraa;

  /// The initialised device context
  final Pointer<MraaAioContext> _context;

  /// Get the raw and Celsius temperature values and timestamp them.
  GroveTemperatureValues get values {
    final raw = _mraa.aio.read(_context);
    final values = GroveTemperatureValues();
    if (raw == Mraa.generalError) {
      values.celsius = -1.0;
      values.raw = -1;
      return values;
    }
    values.raw = raw;
    final r = (1023.0 - values.raw) * (r0 / values.raw);
    values.celsius = 1.0 / (log(r / r0) / b + 1.0 / 298.15) - 273.15;
    return values;
  }
}
