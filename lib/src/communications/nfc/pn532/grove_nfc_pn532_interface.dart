/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 25/10/2020
 * Copyright :  S.Hamblett
 */

part of '../../../../grove.dart';

/// Communications interface to the PN532.
abstract class GroveNfcPn532Interface {
  /// Initialise the interface.
  /// Returns true if successful.
  bool initialise();

  /// Wake up the PN532 before communicating with it.
  /// Returns true if the wkeup succeeded.
  bool wakeup();

  /// Write a command to the PN532 and check the acknowledgement.
  CommandStatus writeCommand(List<int> header, {List<int>? body});

  ///  Read the response of a command, strip prefix and suffix.
  ///  Maximum time to wait is in milliseconds, defaults to [GroveNfcPn532Definitions.maxTimeToWait]
  ///  Always returns a result, 0 indicates failure.
  int readResponse(List<int> rBuffer, int length, {int? maxTimeToWait});
}
