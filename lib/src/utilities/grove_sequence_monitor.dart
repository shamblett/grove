/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 07/10/2020
 * Copyright :  S.Hamblett
 */

part of grove;

/// The sequence monitor is used to monitor and check for errors
/// in a command sequence that must work, e.g. an initialisation
/// sequence.
class GroveSequenceMonitor<T> {
  /// A success value must be supplied for the monitored type
  GroveSequenceMonitor(this._successValue);

  final MraaReturnCode _successValue;

  final _results = <T>[];

  /// Is the sequence OK or not
  bool get isOk =>
      _results.isNotEmpty && _results.every((e) => e == _successValue);

  /// List of failure codes.
  List<T> get failureValues =>
      _results.where((e) => e != _successValue).toList();

  /// Add to the result list.
  GroveSequenceMonitor<T> operator +(T result) {
    _results.add(result);
    return this;
  }

  /// Reset the monitor
  void reset() => _results.clear();
}
