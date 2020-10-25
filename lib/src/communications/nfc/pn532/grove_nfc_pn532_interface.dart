/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 25/10/2020
 * Copyright :  S.Hamblett
 */

part of grove;

/// Communications interface to the PN532.
abstract class GroveNfcPn532Interface {
  /// Initialise the interface.
  /// Returns true if successful.
  bool initialise();

  /// Wake up the PN532 before communicating with it.
  void wakeup();

  /// Write a command to the PN532 and check the acknowledgement.
  CommandStatus writeCommand(Uint8List header, Uint8List body);

  ///  Read the response of a command, strip prefix and suffix.
  ///  Maximun time to wait is in milliseconds.
  ///  Always returns a result, a length of 0 indicates failure.
  Uint8List readResponse({int maxTimeToWait = 1000});
}
