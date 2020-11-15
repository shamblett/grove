/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 15/11/2020
 * Copyright :  S.Hamblett
 */

part of grove;

/// Extension methods for Uart communication in Grove.
extension GroveUartExtensions on MraaUart {
  /// Send bytes with optional UART buffer flushing, defaults to flush.
  /// Sends the length of the data list.
  /// Returns true if the send succeeded.
  bool send(Pointer<MraaUartContext> context, List<int> data,
      {bool flush = true}) {
    final buffer = MraaUartBuffer();
    buffer.byteData = Uint8List.fromList(data);
    var ret = writeBytes(context, buffer, data.length);
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
  bool receive(Pointer<MraaUartContext> context, List<int> bytes, int length,
      {int timeout = 0}) {
    var rxOk = false;
    if (dataAvailable(context, timeout)) {
      final buffer = MraaUartBuffer();
      while (true) {
        final ret = readBytes(context, buffer, length);
        if (ret == Mraa.generalError) {
          continue;
        } else if (ret < length) {
          bytes.addAll(buffer.byteData);
          buffer.byteData.clear();
          if (bytes.length == length) {
            rxOk = true;
            break;
          }
          if (dataAvailable(context, 1)) {
            continue;
          } else {
            break;
          }
        } else if (ret == length) {
          bytes.addAll(buffer.byteData);
          rxOk = true;
          break;
        } else {
          continue;
        }
      }
    }
    return rxOk;
  }
}
