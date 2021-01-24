/*
* Package : grove
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 23/10/2020
* Copyright :  S.Hamblett
*/

part of grove;

/// The Grove PN532 based NFC device.
///
/// Features a highly integrated transceiver module PN532 which handles contactless communication
/// at 13.56MHz. You can read and write a 13.56MHz tag with this module or implement
/// point to point data exchange with two NFCs.
class GroveNfcPn532 {
  /// Construction
  GroveNfcPn532(this._mraa,
      {String tty = GroveNfcPn532Definitions.uartDefaultDevice}) {
    _tty = tty;
    _interface = GroveNfcPn532Hsu(_mraa.uart, uartDevice: _tty);
  }

  final Mraa _mraa;

  String _tty;

  GroveNfcPn532Interface _interface;

  bool initialised = false;

  /// Initialise
  ///
  /// Must be called or no communication to the device will occur.
  /// Returns true if initialisation succeed.
  bool initialise() {
    var ok = _interface.initialise();
    if (!ok) {
      print(
          'GroveNfcPn532::initialise - failed to initialise the HSU interface');
      return false;
    }
    ok = _interface.wakeup();
    if (!ok) {
      print('GroveNfcPn532::initialise - failed to wakeup the HSU interface');
      return false;
    }
    initialised = true;
    return true;
  }

  /// Checks the firmware version of the PN532 chip
  /// Returns the chip's firmware version and ID.
  /// A response of zero indicates failure.
  int firmwareVersion() {
    if (!_prepareCommand()) {
      return 0;
    }
    final ret =
        _interface.writeCommand([GroveNfcPn532Definitions.getFirmwareVersion]);
    if (ret != CommandStatus.ok) {
      print('GroveNfcPn532::getFirmwareVersion - failed to execute command');
      return 0;
    }
    final responseBuffer = <int>[];
    final rLength = _interface.readResponse(
        responseBuffer, GroveNfcPn532Definitions.getFirmwareVersionRlength);
    if (rLength != GroveNfcPn532Definitions.getFirmwareVersionRlength) {
      print(
          'GroveNfcPn532::getFirmwareVersion - invalid response length, $rLength');
      return 0;
    }
    var response = 0;
    response = responseBuffer[0];
    response <<= 8;
    response |= responseBuffer[1];
    response <<= 8;
    response |= responseBuffer[2];
    response <<= 8;
    response |= responseBuffer[3];

    return response;
  }

  bool _prepareCommand() {
    if (!initialised) {
      print('GroveNfcPn532::_initialiseCheck - not initialised');
      return false;
    }
    return true;
  }
}
