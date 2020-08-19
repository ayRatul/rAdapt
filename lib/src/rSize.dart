import 'package:flutter/material.dart';
import 'rWrapper.dart';

/// Returns the [DeviceScreenType] that the application is currently running on
RDevice getDevice(BuildContext context, {RBreakpoints breakpoints}) =>
    getCustomDeviceType(MediaQuery.of(context).size, breakpoints: breakpoints);

RDevice getCustomDeviceType(Size size, {RBreakpoints breakpoints}) {
  double deviceWidth = size.shortestSide;

  //We use the default breakpoints if `breakpoints` is null
  if (breakpoints != null) {
    for (var _t = 0; _t < breakpoints.data.length; _t++) {
      RDevice _currentDevice = breakpoints.data[_t];
      if (deviceWidth < _currentDevice.maxSize) {
        return _currentDevice;
      }
    }
    return breakpoints.data.last;
  }

  for (var _t = 0; _t < RController.breakpoints.data.length; _t++) {
    RDevice _currentDevice = RController.breakpoints.data[_t];
    if (deviceWidth < _currentDevice.maxSize) {
      return _currentDevice;
    }
  }

  return RController.breakpoints.data.last;
}

double rsize(BuildContext context, num value) {
  RDevice deviceScreenType = getDevice(context);
  if (deviceScreenType != null) {
    return value * deviceScreenType.multiplier;
  }
  return null;
}

//Why do we need this ? To order the breakpoints from smaller to bigger
class RBreakpoints {
  final List<RDevice> data;

  RBreakpoints({
    @required this.data,
  }) {
    data.sort((a, b) => a.maxSize.compareTo(b.maxSize));
  }

  @override
  String toString() {
    return data.toString();
  }
}

//The maxSize is the.. max size. The min size, depends if there is smaller breakpoints, if not, it's 0
class RDevice {
  const RDevice(this.maxSize, this.multiplier);
  final double multiplier;
  final int maxSize;
}

typedef SizeWidgetBuilder = Widget Function(
    BuildContext context, RDevice sizeInfo);

/// A widget with a builder that provides you with RDevice, useful if you want a different layout
/// for watches, TV, or 4k screens
class ResponsiveBuilder extends StatelessWidget {
  final SizeWidgetBuilder builder;
  final RBreakpoints breakpoints;
  const ResponsiveBuilder({Key key, this.builder, this.breakpoints})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      builder(context, getDevice(context, breakpoints: breakpoints));
}

/// Provides a builder function for a landscape and portrait widget
class OrientationLayoutBuilder extends StatelessWidget {
  final WidgetBuilder landscape;
  final WidgetBuilder portrait;
  const OrientationLayoutBuilder({
    Key key,
    this.landscape,
    this.portrait,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape && landscape != null) {
      return landscape(context);
    }
    return portrait(context);
  }
}
