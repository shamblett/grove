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
  int startColumn = -1;
  int endColumn = -1;
  int startRow = -1;
  int endRow = -1;

  final commandStack = <int>[];
  final commandDataStack = <int>[];
  final dataDataStack = <int>[];

  state currentState = state.commandExpected;

  void writeCommandData(int command, int data) {
    if (currentState != state.commandExpected) {
      commandDataStack.add(data);
      switch (currentState) {
        case state.startColumnExpected:
          {
            startColumn = data;
            currentState = state.endColumnExpected;
            break;
          }
        case state.endColumnExpected:
          {
            endColumn = data;
            currentState = state.commandExpected;
            break;
          }
        case state.startRowExpected:
          {
            startRow = data;
            currentState = state.endRowExpected;
            break;
          }
        case state.endRowExpected:
          {
            endRow = data;
            currentState = state.commandExpected;
            break;
          }
        default:
          {
            break;
          }
      }
    } else {
      currentState = sm[data];
      commandStack.add(data);
    }
  }

  void writeDataData(int value) {
    dataDataStack.add(value);
  }
}
