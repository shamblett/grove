// ignore_for_file: no-magic-number

/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 26/09/2020
 * Copyright :  S.Hamblett
 */

part of '../../../grove.dart';

/// The values class for the Grove temperature sensors
class GroveTemperatureValues {
  /// Raw value
  late int raw;

  /// Celsius
  late double celsius;

  /// Timestamp
  DateTime? validAt;

  /// Construction
  GroveTemperatureValues() {
    validAt = DateTime.now();
  }

  @override
  String toString() =>
      'Temperature values at $validAt :: Raw : $raw : Celsius '
      '${celsius.toStringAsFixed(2)}';
}
