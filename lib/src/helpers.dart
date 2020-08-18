import 'package:flutter/material.dart';
import 'responsive_sizing_config.dart';
import 'sizing_information.dart';

/// Returns the [DeviceScreenType] that the application is currently running on
RDevice getDevice(BuildContext context, {CustomBreakpoints breakpoints}) =>
    getCustomDeviceType(MediaQuery.of(context).size, breakpoints: breakpoints);

RDevice getCustomDeviceType(Size size, {CustomBreakpoints breakpoints}) {
  double deviceWidth = size.shortestSide;

  // Replaces the defaults with the user defined definitions
  if (breakpoints != null) {
    for (var _t = 0; _t < breakpoints.data.length; _t++) {
      RDevice _currentDevice = breakpoints.data[_t];
      if (deviceWidth < _currentDevice.breakPointlimit) {
        return _currentDevice;
      }
    }
    return breakpoints.data.last;
  } else {
    for (var _t = 0;
        _t < ResponsiveSizingConfig.instance.breakpoints.data.length;
        _t++) {
      RDevice _currentDevice =
          ResponsiveSizingConfig.instance.breakpoints.data[_t];
      if (deviceWidth < _currentDevice.breakPointlimit) {
        return _currentDevice;
      }
    }
  }
  return ResponsiveSizingConfig.instance.breakpoints.data.last;
}

/// Will return one of the values passed in for the device it's running on
double rsize(BuildContext context, double value) {
  RDevice deviceScreenType = getDevice(context);
  if (deviceScreenType != null) {
    return value * deviceScreenType.multiplier;
  }
  return null;
}
