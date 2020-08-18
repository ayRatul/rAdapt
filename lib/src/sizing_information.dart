import 'package:flutter/material.dart';

/// Contains sizing information to make responsive choices for the current screen
class SizingInformation {
  final String deviceScreenType;
  final Size screenSize;
  final Size localWidgetSize;

  SizingInformation({
    this.deviceScreenType,
    this.screenSize,
    this.localWidgetSize,
  });

  @override
  String toString() {
    return 'DeviceType:$deviceScreenType ScreenSize:$screenSize LocalWidgetSize:$localWidgetSize';
  }
}

/// Manually define screen resolution breakpoints
///
/// Overrides the defaults
class CustomBreakpoints {
  final Map<String, double> data;

  const CustomBreakpoints({
    @required this.data,
  });

  @override
  String toString() {
    return data.toString();
  }
}
