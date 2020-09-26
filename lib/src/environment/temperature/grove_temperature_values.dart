/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 26/09/2020
 * Copyright :  S.Hamblett
 */

part of grove;

/// The values class for the Grove temperature sensors
class GroveTemperatureValues {
  /// Construction
  GroveTemperatureValues() {
    validAt = DateTime.now();
  }

  /// Raw value
  int raw;

  /// Celsius
  double celsius;

  /// Timestamp
  DateTime validAt;

  @override
  String toString() => 'Temperature values at $validAt :: Raw : $raw : Celsius '
      '${celsius.toStringAsFixed(2)}';
}