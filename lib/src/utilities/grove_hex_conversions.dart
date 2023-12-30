/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 07/10/2020
 * Copyright :  S.Hamblett
 */

part of '../../grove.dart';

/// Hex conversion helpers.

/// Converts a list of integers to a byte string with leading 0x's.
/// Line length can be set as needed.
String groveList2Hex(List<int> values, {int lineLength = 8}) {
  final sb = StringBuffer();
  var count = 0;
  for (var e in values) {
    var temp = e.toRadixString(16);
    if (temp.length == 1) {
      temp = '0$temp';
    }
    temp = '0x$temp';
    sb.write('$temp,');
    if (count == lineLength - 1) {
      sb.writeln();
      count = 0;
    } else {
      count++;
    }
  }

  var temp = sb.toString();
  return temp.substring(0, temp.length - 2);
}

/// Single byte convert
String groveByte2Hex(int value) => groveList2Hex([value], lineLength: 1);
