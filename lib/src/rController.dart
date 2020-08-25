import 'package:flutter/material.dart';
import 'rWidgets.dart';

//The main controller, this interacts with the UI and the RProvider
class RController {
  static BuildContext _context;
  static RDevice defaultDevice = RDevice(480, 1);
  static List<RDevice> get devices => _inst.breakpoints;
  static void initialize(BuildContext cont) => _context = _context ?? cont;

  static RProvider get _inst {
    assert(
        _context != null,
        "RController has not been initialized. Or it has been initialized too late." +
            "You must initialize RController in the first 'initState' for a stateful widget, and the first Build method of a stateless widget.");
    RProvider _w = _context.dependOnInheritedWidgetOfExactType<RProvider>();
    assert(
        _w != null,
        "RController has been initialized, but no RWrapper has been found." +
            "The wrapper provides a way of changing breakpoints and themes and automatically rebuilds all the children" +
            "You should wrap your app in RWrapper ");
    return _w;
  }

  static void changeTheme(String name) => _inst.state.changeTheme(name);

  static void changeBreakpoints(List<RDevice> breakpoints) =>
      _inst.state.changeBreakpoints(breakpoints);

  static Color getColor(String p) {
    assert(_inst.state.widget.configuration.allowedColors.contains(p),
        'Color "$p" is not an allowed Color in RConfiguration.allowedColors');
    return _inst.theme.colors[p];
  }

  static double getValue(num number) => number * device.multiplier;

  static RDevice get device {
    double deviceWidth = MediaQuery.of(_context).size.shortestSide;
    for (var _t = 0; _t < RController.devices.length; _t++) {
      RDevice _currentDevice = RController.devices[_t];
      if (deviceWidth < _currentDevice.maxSize) {
        return _currentDevice;
      }
    }
    return RController.devices.last;
  }
}

