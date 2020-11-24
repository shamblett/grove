/*
* Package : grove
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 14/11/2020
* Copyright :  S.Hamblett
*/

part of grove;

/// A LORA message
class GroveLoraMessage {
  // The message buffer
  final List<int> message = <int>[];

  /// The value of the last received RSSI value, in some transport specific units.
  int rxLastRssi = 0;

  // True when there is a valid received message in the buffer
  bool rxMessageValid = false;

  // TO header in the last received message
  int rxHeaderTo = 0;

  /// FROM header in the last received message.
  int rxHeaderFrom = 0;

  /// ID header in the last received message.
  int rxHeaderId = 0;

  /// FLAGS header in the last received message.
  int rxHeaderFlags = 0;

  /// Timestamp of the last received message.
  String get lastRxTimeString => lastRxTime.toString().split('.')[0];
  DateTime lastRxTime;

  @override
  String toString() {
    final sb = StringBuffer();
    if (rxMessageValid) {
      sb.writeln('Rx Header To : $rxHeaderTo');
      sb.writeln('Rx Header From : $rxHeaderFrom');
      sb.writeln('Rx Header Id : $rxHeaderId');
      sb.writeln('Rx Header Flags : $rxHeaderTo');
      sb.writeln('Rx Last RSSI : $rxLastRssi');
      sb.writeln('Rx Valid at : $lastRxTimeString');
      sb.writeln('Rx Message bytes : $message');
      sb.writeln('Rx Message as string : ${String.fromCharCodes(message)}');
    } else {
      sb.writeln('There is no valid received message');
    }
    return sb.toString();
  }
}
