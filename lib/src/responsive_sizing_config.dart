import 'sizing_information.dart';

/// Keeps the configuration that will determines the breakpoints for different device sizes
class ResponsiveSizingConfig {
  static ResponsiveSizingConfig _instance;
  CustomBreakpoints _customBreakPoints;
  List<String> _customList;
  static ResponsiveSizingConfig get instance {
    if (_instance == null) {
      _instance = ResponsiveSizingConfig();
    }

    return _instance;
  }

  void setCustomBreakpoints(CustomBreakpoints customBreakpoints) {
    _customBreakPoints = customBreakpoints;
    _customList = getOrderedList(customBreakpoints);
  }

  static const CustomBreakpoints _defaultBreakPoints =
      const CustomBreakpoints(data: {'mobile': 480});

  static const List<String> _defaultList = null;

  static List<String> getOrderedList(CustomBreakpoints _breakpoints) {
    return _breakpoints.data.keys.toList(growable: false)
      ..sort(
          (k1, k2) => _breakpoints.data[k1].compareTo(_breakpoints.data[k2]));
  }

  CustomBreakpoints get breakpoints =>
      _customBreakPoints ?? _defaultBreakPoints;
  List<String> get sizeOrder => _customList ?? _defaultList;
  String getSmallerSize(String deviceType) {
    int index = sizeOrder.indexOf(deviceType);
    if (index == 0) return null;
    print('Backlogging to ${sizeOrder[index - 1]}');
    return sizeOrder[index - 1];
  }
}
