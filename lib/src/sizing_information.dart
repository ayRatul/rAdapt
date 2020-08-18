import 'package:flutter/material.dart';

/// Contains sizing information to make responsive choices for the current screen
class SizingInformation {
  final RDevice deviceScreenType;

  SizingInformation({
    this.deviceScreenType,
  });

  @override
  String toString() {
    return 'DeviceType:$deviceScreenType';
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
