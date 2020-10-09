/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/10/2019
 * Copyright :  S.Hamblett
 */

import 'package:grove/grove.dart';
import 'package:mraa/mraa.dart';

/// Device states
enum state {
  commandExpected,
  dataExpected,
  startColumnExpected,
  endColumnExpected,
  startRowExpected,
  endRowExpected
}

/// State machine
const Map<int, state> sm = {
  GroveOledSsd1327Definitions.setColumnAddress: state.startColumnExpected,
  GroveOledSsd1327Definitions.setRowAddress: state.startRowExpected
};

/// Virtual OLED test support package.
class GroveVirtualOled {
  int startColumn = 0;
  int endColumn = 0;
  int startRow = 0;
  int endRow = 0;

  final commandStack = <int>[];
  final dataStack = [<int>[]];

  state currentState = state.commandExpected;

  void writeByteData(int command, List<int> data) {
    if (currentState != state.commandExpected) {
      dataStack.add(data);
      switch (currentState) {
        case state.startColumnExpected:
          {
            startColumn = data[0];
            currentState = state.endColumnExpected;
            break;
          }
        case state.endColumnExpected:
          {
            endColumn = data[0];
            currentState = state.commandExpected;
            break;
          }
        case state.startRowExpected:
          {
            startRow = data[0];
            currentState = state.endRowExpected;
            break;
          }
        case state.endRowExpected:
          {
            endRow = data[0];
            currentState = state.commandExpected;
            break;
          }
        default:
          {
            break;
          }
      }
    } else {
      currentState = sm[command];
      commandStack.add(command);
    }
  }
}
