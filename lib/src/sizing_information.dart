import 'package:flutter/material.dart';

/// Contains sizing information to make responsive choices for the current screen
class SizingInformation {
  final RDevice deviceScreenType;
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
  final List<RDevice> data;

  CustomBreakpoints({
    @required this.data,
  }) {
    data.sort((a, b) => a.breakPointlimit.compareTo(b.breakPointlimit));
  }

  @override
  String toString() {
    return data.toString();
  }
}

class RDevice {
  const RDevice(this.breakPointlimit, this.multiplier);
  final double multiplier;
  final int breakPointlimit;
}
