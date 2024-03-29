/*
* Package : grove
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 03/10/2019
* Copyright :  S.Hamblett
*/

import 'package:grove/grove.dart';

/// Test class that allows member function override, e.g. initialisation
class GroveTestOledSsd1327 extends GroveOledSsd1327 {
  GroveTestOledSsd1327(super.mraa, super.context);

  @override
  bool initialise({bool clearDisplay = false}) {
    super.initialised = true;
    grayLevel = GroveOledSsd1327Definitions.defaultGrayLevel;
    return true;
  }
}
