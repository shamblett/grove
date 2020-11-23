/*
* Package : grove
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 14/11/2020
* Copyright :  S.Hamblett
*/

part of grove;

/// Defines different operating modes for the transport hardware
///
/// These are the different values that can be adopted by the [_mode] variable and
/// returned by the mode() member function,
enum GroveLoraMode {
  /// Transport is initialising. Initial default value.
  modeInitialising,

  /// Transport hardware is in low power sleep mode (if supported)
  modeSleep,

  /// Transport is idle.
  modeIdle,

  /// Transport is in the process of transmitting a message.
  modeTx,

  /// Transport is in the process of receiving a message.
  modeRx
}
