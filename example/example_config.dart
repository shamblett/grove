/*
 * Package : grove
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 23/09/2020
 * Copyright :  S.Hamblett
 */

/// Example configuration options. Update these as needed.

// Mraa library path.
const mraaLibraryPath = 'lib/libmraa.so.2.0.0';

// Mraa configuration.
const noJsonLoading = true;
const useGrovePi = true;

// Display logo path.
const logoPath = 'images/seedLogo96x96.txt';

// Display converted logo path.
const convertedLogoPath = 'images/dartlogo.txt';

/// Dump bitmap data
bool dumpBitMap = false;

// Device configuration

// The I2C bus id for the OLED display.
const int i2cBusId = 0;

// The GPIO pins for the Grove Led bar, set as needed.
const int clockGPIOPin = 59;
const int dataGPIOPin = 57;

// The AIO pin for the light sensor, set as needed.
const int lightSensorAIOPin = 0;

// The GPIO pin for the Grove PIR motion sensor, set as needed.
const int pirSensorGPIOPin = 73;

// The AIO pin for the sound sensor, set as needed.
const int soundSensorAIOPin = 4;

// The AIO pin for the temperature sensor, set as needed.
const int temperatureSensorAIOPin = 2;

// Default UART tty device
const String defaultUart = '/dev/ttyS0';

// UART test message
const String uartTestMessage = 'Hello World!';
