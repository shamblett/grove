/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 21/09/2020
 * Copyright :  S.Hamblett
 */

part of grove;

///
/// AIO device interface using MRAA
///
class GroveMraaAioInterface implements GroveIAioInterface {
  Mraa mraa;

  ///
  /// Get bit
  ///
  @override
  int getBit(Pointer<MraaAioContext> context) => mraa.aio.getBit(context);

  ///
  /// Read
  ///
  @override
  int read(Pointer<MraaAioContext> context) => mraa.aio.read(context);
}
