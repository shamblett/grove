/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

import 'package:grove/grove.dart';

/// Device states
enum State {
  commandExpected,
  dataExpected,
  startColumnExpected,
  endColumnExpected,
  startRowExpected,
  endRowExpected,
}

/// State machine
const Map<int, State> sm = {
  GroveOledSsd1327Definitions.setColumnAddress: State.startColumnExpected,
  GroveOledSsd1327Definitions.setRowAddress: State.startRowExpected,
};

/// Virtual OLED test support package.
class GroveVirtualOled {
  int? startColumn = -1;
  int? endColumn = -1;
  int? startRow = -1;
  int? endRow = -1;

  final commandStack = <int?>[];
  final commandDataStack = <int?>[];
  final dataDataStack = <int?>[];

  int _grayHigh = 0;
  int _grayLow = 0;

  /// The gray level for the OLED panel.
  /// Values are constrained to range 0 - 15.
  set grayLevel(int level) {
    if (level < 0) {
      _grayHigh = 0;
      _grayLow = 0;
      return;
    }
    _grayHigh = (level << 4) & 0xF0;
    _grayLow = level & 0x0F;
  }

  State? currentState = State.commandExpected;

  void writeCommandData(int? command, int? data) {
    if (currentState != State.commandExpected) {
      commandDataStack.add(data);
      switch (currentState) {
        case State.startColumnExpected:
          {
            startColumn = data;
            currentState = State.endColumnExpected;
            break;
          }
        case State.endColumnExpected:
          {
            endColumn = data;
            currentState = State.commandExpected;
            break;
          }
        case State.startRowExpected:
          {
            startRow = data;
            currentState = State.endRowExpected;
            break;
          }
        case State.endRowExpected:
          {
            endRow = data;
            currentState = State.commandExpected;
            break;
          }
        default:
          {
            break;
          }
      }
    } else {
      currentState = sm[data!];
      commandStack.add(data);
    }
  }

  void writeDataData(int? value) {
    dataDataStack.add(value);
  }

  String asciiArt() {
    final sb = StringBuffer();
    sb.writeln();
    sb.writeln('Data stack length is ${dataDataStack.length}');
    sb.writeln();
    var count = 0;
    for (var pixel in dataDataStack) {
      if (pixel == _grayHigh + _grayLow) {
        sb.write('#');
      } else {
        sb.write('.');
      }
      count++;
      if (count == 48) {
        count = 0;
        sb.writeln();
      }
    }
    return sb.toString();
  }
}
