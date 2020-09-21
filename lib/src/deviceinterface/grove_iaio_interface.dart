/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 21/09/2020
 * Copyright :  S.Hamblett
 */

part of grove;
///
/// Interface for the AIO device
///
abstract class GroveIAioInterface {
  ///
  /// Get bit
  ///
  int getBit(Pointer<MraaAioContext> context);

  ///
  /// Read
  ///
  int read(Pointer<MraaAioContext> context);
}
