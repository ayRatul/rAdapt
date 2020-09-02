library radapt;

import 'dart:ui';
import 'package:flutter/material.dart';

BuildContext _context;
typedef RTheme RThemeBuilder();

//These 2 are the classes that the user should use, they allow for a better workflow by overriding the values
abstract class RTheme {
  const RTheme({this.colors, this.inheritsColors});
  final Map<String, Color> colors;
  final bool inheritsColors;
}

abstract class RConfiguration {
  final List<RDevice> devices = null;
  final List<RThemeBuilder> themes = null;
  final List<String> allowedColors = null;
  final RThemeBuilder rootTheme = null;
}

class _CurrentTheme {
  const _CurrentTheme(this.type, this.colors);
  final Type type;
  final Map<String, Color> colors;
}

class RWrap extends StatefulWidget {
  RWrap(
      {Key key,
      @required this.child,
      @required this.configuration,
      this.initialTheme})
      : super(key: key);
  final Widget child;
  final RConfiguration configuration;
  final String initialTheme;
  static RDeviceAndThemeProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RDeviceAndThemeProvider>();

  @override
  __RWrapperState createState() => __RWrapperState();
}

class __RWrapperState extends State<RWrap> with WidgetsBindingObserver {
  List<_RDevice> breakpoints;
  Map<String, RThemeBuilder> themes = {};
  _RDevice currentDevice = _RDevice(0, 100, 1);
  _CurrentTheme currentTheme;
  @override
  void initState() {
    _loadThemes();
    loadBreakpoints(widget.configuration.devices, shouldUpdate: false);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  bool get hasThemes =>
      widget.configuration.rootTheme != null ||
      widget.configuration.allowedColors != null ||
      widget.configuration.themes != null;

  void _loadThemes() {
    RConfiguration conf = widget.configuration;
    //We only load the Themes if needed
    if (!hasThemes) return;
    assert(conf.rootTheme != null,
        'RConfiguration: RConfiguration.rootTheme should not be null');
    assert(conf.allowedColors != null,
        'RConfiguration: RConfiguration.allowedColors should not be null');
    assert(conf.themes != null,
        'RConfiguration: RConfiguration.themes should not be null');
    _CurrentTheme _defaultTheme = _buildTheme(widget.configuration.rootTheme);
    assert(_defaultTheme.colors != null,
        'RConfiguration.rootTheme: RTheme.colors should not be null');
    conf.allowedColors.forEach((element) {
      assert(_defaultTheme.colors.containsKey(element),
          "RConfiguration.rootTheme: The default RTheme ${_defaultTheme.runtimeType.toString()} doesn't containt the color :$element , the Default Theme sould have EVERY color specified in RConfiguration.allowedColors");
    });
    //We clear the previous themes (if any), to load conf.themes, convert it to a Map of <String,RThemeBuilder>, for easy access ;)
    themes.clear();
    conf.themes.forEach((_themeBuilder) {
      RTheme _theme = _themeBuilder();
      assert(_theme.colors != null,
          '${_theme.runtimeType.toString()}: RTheme.colors should not be null');
      if (!_theme.inheritsColors) {
        conf.allowedColors.forEach((element) {
          assert(_theme.colors.containsKey(element),
              "RConfiguration.themes: The RTheme ${_theme.runtimeType.toString()} doesn't containt the color :$element , since RTheme.inheritsColors is false on that Theme, it should have EVERY color specified in RConfiguration.allowedColors ");
        });
      }
      assert(!themes.containsKey(_theme.runtimeType.toString()),
          'RConfiguration.themes:The theme "${_theme.runtimeType.toString()}" is duplicated');
      themes[_theme.runtimeType.toString()] = _themeBuilder;
    });
    //We load the current Theme
    if (widget.initialTheme != null) {
      assert(themes.containsKey(widget.initialTheme),
          'RWrapper:The initialTheme ${widget.initialTheme} does not match any of the names specified in RConfiguration.themes');
      currentTheme = _buildTheme(themes[widget.initialTheme]);
    } else {
      currentTheme = _defaultTheme;
    }
  }

  _CurrentTheme _buildTheme(RThemeBuilder builder) {
    RTheme _theme = builder();
    if (_theme.inheritsColors)
      return _CurrentTheme(_theme.runtimeType,
          {...widget.configuration.rootTheme().colors, ..._theme.colors});
    return _CurrentTheme(_theme.runtimeType, _theme.colors);
  }

  void changeTheme(Type name) {
    assert(hasThemes,
        "RController.changeTheme was called, even tought you didn't specify the required parameters in RConfiguration || RWrapper");
    assert(themes.containsKey(name.toString()),
        'RController.changeTheme: The name ${name.toString()} does not match any of the names specified in RConfiguration.themes');
    currentTheme = _buildTheme(themes[name.toString()]);
    setState(() {});
  }

  void loadBreakpoints(List<RDevice> newBreakpoints, {shouldUpdate = true}) {
    if (newBreakpoints == null || newBreakpoints.length == 0) return;
    List<RDevice> _breakpoints = newBreakpoints.toList()
      ..sort((a, b) => a.maxSize.compareTo(b.maxSize));
    RDevice _prevBreakpoint = _breakpoints[0];
    List<_RDevice> _orderedBreakpoints = [];
    _breakpoints.forEach((element) {
      _orderedBreakpoints.add(_RDevice(
          _prevBreakpoint.maxSize != element.maxSize
              ? _prevBreakpoint.maxSize
              : 0,
          element.maxSize,
          element.multiplier));
      _prevBreakpoint = element;
    });
    breakpoints = _orderedBreakpoints;
    detectDevice(shouldUpdate: shouldUpdate);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void detectDevice({bool shouldUpdate = true}) {
    if (breakpoints == null) return;
    double size = window.physicalSize.shortestSide / window.devicePixelRatio;
    if (size > currentDevice.minSize && size <= currentDevice.maxSize) return;
    _RDevice _dev = breakpoints.last;
    for (var _t = 0; _t < breakpoints.length; _t++) {
      _RDevice _currentDevice = breakpoints[_t];
      if (size > _currentDevice.minSize && size <= _currentDevice.maxSize) {
        _dev = _currentDevice;
        break;
      }
    }
    currentDevice = _dev;
    if (shouldUpdate) setState(() {});
  }

  @override
  void didChangeMetrics() {
    detectDevice();
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return RDeviceAndThemeProvider(
        key: UniqueKey(),
        child: _Notifier(widget.child),
        theme: currentTheme,
        state: this,
        device: currentDevice);
  }
}

class _Notifier extends StatelessWidget {
  const _Notifier(this.child, {Key key}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return child;
  }
}

class RDeviceAndThemeProvider extends InheritedWidget {
  final _RDevice device;
  final __RWrapperState state;
  final _CurrentTheme theme;
  const RDeviceAndThemeProvider(
      {Key key,
      @required Widget child,
      @required this.state,
      @required this.device,
      this.theme})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(RDeviceAndThemeProvider oldWidget) =>
      oldWidget.theme != theme || oldWidget.device != device;
}

class RDevice {
  const RDevice(this.maxSize, this.multiplier);
  final double multiplier;
  final int maxSize;
}

class _RDevice {
  _RDevice(this.minSize, this.maxSize, this.multiplier);
  final double multiplier;
  final int maxSize;
  final int minSize;
}

class OrientationLayoutBuilder extends StatelessWidget {
  final WidgetBuilder landscape;
  final WidgetBuilder portrait;
  const OrientationLayoutBuilder({
    Key key,
    @required this.landscape,
    @required this.portrait,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.landscape &&
        landscape != null) return landscape(context);
    return portrait(context);
  }
}

class RAdapt {
  static Color getColorOfContext(BuildContext context, String color) {
    assert(
        RWrap.of(context)
            .state
            .widget
            .configuration
            .allowedColors
            .contains(color),
        'Color "$color" is not an allowed Color in RConfiguration.allowedColors');
    return RWrap.of(context).theme.colors[color];
  }

  static void attach(BuildContext context) => RWrap.of(context);

  static Color getColor(String color) => getColorOfContext(_context, color);

  static double getNumberOfContext(BuildContext context, num number) {
    return RWrap.of(context).device.multiplier * number;
  }

  static double getNumber(num number) => getNumberOfContext(_context, number);

  static void changeTheme(BuildContext context, Type theme) =>
      RWrap.of(context).state.changeTheme(theme);

  static void changeBreakpoints(
          BuildContext context, List<RDevice> breakpoints) =>
      RWrap.of(context).state.loadBreakpoints(breakpoints, shouldUpdate: true);

  static List<String> valuesToString(List<dynamic> values) {
    return values.map((e) => e.toString()).toList();
  }
}
