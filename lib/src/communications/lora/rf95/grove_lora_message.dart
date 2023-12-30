/*
* Package : grove
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 14/11/2020
* Copyright :  S.Hamblett
*/

part of '../../../../grove.dart';

/// A LORA receive message
class GroveLoraReceiveMessage extends GroveLoraMessage {
  /// The value of the last received RSSI value, in some transport specific units.
  int lastRssi = 0;

  /// True if the message is a valid received message.
  bool messageValid = false;
  bool get isValid => messageValid;

  @override
  String toString() {
    final sb = StringBuffer();
    if (isValid) {
      final sb = StringBuffer();
      sb.write(super.toString());
      sb.writeln('Last RSSI : $lastRssi');
    } else {
      sb.writeln('There is no valid received message');
    }
    return sb.toString();
  }
}

// A LORA transmit message
class GroveLoraTransmitMessage extends GroveLoraMessage {
  /// Construction
  GroveLoraTransmitMessage() {
    headerFrom = GroveLoraRf95Definitions.rhrBroadcastAddress;
    headerTo = GroveLoraRf95Definitions.rhrBroadcastAddress;
  }

  /// True if the message is valid to transmit.
  bool get isValid =>
      headerTo != 0 &&
      headerFrom != 0 &&
      message.isNotEmpty &&
      message.length > GroveLoraRf95Definitions.rhrF95MaxMessageLen;

  @override
  String toString() {
    final sb = StringBuffer();
    if (isValid) {
      final sb = StringBuffer();
      sb.write(super.toString());
    } else {
      sb.writeln('The transmit message is not valid');
    }
    return sb.toString();
  }
}

/// A LORA message
class GroveLoraMessage {
  // The message buffer
  final List<int> message = <int>[];

  /// TO header.
  int headerTo = 0;

  /// FROM header.
  int headerFrom = 0;

  /// ID header
  int headerId = 0;

  /// FLAGS header.
  int headerFlags = 0;

  /// Timestamp of the message
  String? get time => timestamp.toString().split('.')[0];
  late DateTime timestamp;

  /// Length of the message.
  int get length => message.length;

  @override
  String toString() {
    final sb = StringBuffer();
    sb.writeln('Header To : $headerTo');
    sb.writeln('Header From : $headerFrom');
    sb.writeln('Header Id : $headerId');
    sb.writeln('Header Flags : $headerFlags');
    sb.writeln('Valid at : $timestamp');
    sb.writeln('Message bytes : $message');
    sb.writeln('Message as string : ${String.fromCharCodes(message)}');
    return sb.toString();
  }
}
