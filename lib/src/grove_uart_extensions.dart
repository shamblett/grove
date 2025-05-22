// ignore_for_file: no-empty-block

/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 15/11/2020
 * Copyright :  S.Hamblett
 */

part of '../grove.dart';

/// Equality function for modem command/response processing
final Function eq = const ListEquality().equals;

/// Extension methods for Uart communication in Grove.
extension GroveUartExtensions on MraaUart {
  /// Send bytes with optional UART buffer flushing, defaults to flush.
  /// Sends the length of the data list.
  /// Returns true if the send succeeded.
  bool send(MraaUartContext context, List<int> data, {bool flush = true}) {
    final buffer = MraaUartBuffer();
    buffer.byteData = Uint8List.fromList(data);
    var ret = writeBytes(context, buffer, buffer.byteLength);
    if (flush) {
      this.flush(context);
    }
    if (ret != data.length) {
      return false;
    }
    return true;
  }

  /// Receive a specified number of bytes in a specified timeout period.
  /// If [timeout] is 0 the method returns immediately, in practice a timeout should always be supplied.
  /// Return of true indicates OK, false is timed out or the receive operation failed.
  bool receive(
    MraaUartContext context,
    List<int> bytes,
    int length, {
    int timeout = 0,
  }) {
    var rxOk = false;
    var rxLength = length;
    if (dataAvailable(context, timeout)) {
      while (true) {
        final buffer = MraaUartBuffer();
        final ret = readBytes(context, buffer, rxLength);
        if (ret == Mraa.generalError) {
          continue;
        } else if (ret < length) {
          bytes.addAll(buffer.byteData);
          if (bytes.length == length) {
            rxOk = true;
            break;
          } else {
            rxLength = length - ret;
            if (rxLength == 0) {
              break;
            }
          }
        } else if (ret == length) {
          bytes.addAll(buffer.byteData);
          rxOk = true;
          break;
        } else {
          continue;
        }
        while (!dataAvailable(context, 1)) {}
      }
    }
    return rxOk;
  }
}
