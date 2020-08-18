import 'package:flutter/material.dart';
import 'responsive_sizing_config.dart';
import 'sizing_information.dart';

/// Returns the [DeviceScreenType] that the application is currently running on
String getDevice(BuildContext context, {CustomBreakpoints breakpoints}) =>
    getCustomDeviceType(MediaQuery.of(context).size, breakpoints: breakpoints);

String getCustomDeviceType(Size size, {CustomBreakpoints breakpoints}) {
  double deviceWidth = size.shortestSide;
  if (breakpoints != null) {
    List<String> _orderedList =
        ResponsiveSizingConfig.getOrderedList(breakpoints);
    for (var _t = 0; _t < _orderedList.length; _t++) {
      String _currentDevice = _orderedList[_t];
      if (deviceWidth < breakpoints.data[_currentDevice]) {
        return _currentDevice;
      }
    }
    return _orderedList.last;
  } else {
    for (var _t = 0;
        _t < ResponsiveSizingConfig.instance.sizeOrder.length;
        _t++) {
      String _currentDevice = ResponsiveSizingConfig.instance.sizeOrder[_t];
      if (deviceWidth <
          ResponsiveSizingConfig.instance.breakpoints.data[_currentDevice]) {
        return _currentDevice;
      }
    }
  }
  return ResponsiveSizingConfig.instance.sizeOrder.last;
}

/// Will return one of the values passed in for the device it's running on
T getValueForScreenType<T>(
    {BuildContext context, Map<String, dynamic> values}) {
  String deviceScreenType = getDevice(context);
  if (values.containsKey(deviceScreenType)) {
    return values[deviceScreenType];
  }
  return null;
}

T rsize<T>(BuildContext context, Map<String, dynamic> values) =>
    getValueForScreenType(context: context, values: values);

class ScreenTypeValueBuilder<T> {
  @Deprecated('Use better named function getValueForScreenType')
  T getValueForType({BuildContext context, Map<String, dynamic> values}) {
    return getValueForScreenType(context: context, values: values);
  }
}
