import 'package:flutter/cupertino.dart';
import 'helpers.dart';
import 'sizing_information.dart';

/// Keeps the configuration that will determines the breakpoints for different device sizes
class ResponsiveSizingConfig {
  BuildContext globalContext;
  static ResponsiveSizingConfig _instance;
  CustomBreakpoints _customBreakPoints;

  static ResponsiveSizingConfig get instance {
    if (_instance == null) {
      _instance = ResponsiveSizingConfig();
    }

    return _instance;
  }

  void initialize(BuildContext context, CustomBreakpoints customBreakpoints) {
    globalContext = context;
    _customBreakPoints = customBreakpoints;
  }

  static CustomBreakpoints _defaultBreakPoints =
      CustomBreakpoints(data: [RDevice(480, 1)]);

  CustomBreakpoints get breakpoints =>
      _customBreakPoints ?? _defaultBreakPoints;
}

extension SizeExtension on num {
  double get d => rsize(ResponsiveSizingConfig.instance.globalContext, this);
  int get i =>
      rsize(ResponsiveSizingConfig.instance.globalContext, this).toInt();
}
