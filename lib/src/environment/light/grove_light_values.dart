/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 23/09/2020
 * Copyright :  S.Hamblett
 */

part of grove;

/// The values class for the Grove light sensors.
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
