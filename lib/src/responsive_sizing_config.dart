import 'sizing_information.dart';

/// Keeps the configuration that will determines the breakpoints for different device sizes
class ResponsiveSizingConfig {
  static ResponsiveSizingConfig _instance;
  CustomBreakpoints _customBreakPoints;

  static ResponsiveSizingConfig get instance {
    if (_instance == null) {
      _instance = ResponsiveSizingConfig();
    }

    return _instance;
  }

  void setCustomBreakpoints(CustomBreakpoints customBreakpoints) {
    _customBreakPoints = customBreakpoints;
  }

  static CustomBreakpoints _defaultBreakPoints =
      CustomBreakpoints(data: [RDevice(480, 1)]);

  CustomBreakpoints get breakpoints =>
      _customBreakPoints ?? _defaultBreakPoints;
}
