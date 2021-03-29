# grove
[![Build Status](https://travis-ci.com/shamblett/grove.svg?branch=master)](https://travis-ci.com/shamblett/grove)

This package provides interface classes to the [Grove](https://wiki.seeedstudio.com/Grove_System/) series of
devices comprising of sensors, actuators, display devices, communications and others. The package provides initialisation
functionality and the ability to read sensor values both raw and conditioned, e.g. the light sensor supplies both
raw values read from the device and a corresponding Lux value.

Grove builds on the [mraa](https://pub.dev/packages/mraa) package to perform low level device communication and
presents a logical device function oriented interface to the user.

Examples of usage for each of the supported devices can be found in the examples directory.

This package is intended to grow over time as devices are added, if any specific devices need to be supported 
please raise an issue and these will be considered in priority.
