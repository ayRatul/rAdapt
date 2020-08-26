library radapt;
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
  static RDeviceAndThemeProvider of(BuildContext context) {
    assert(
        context != null, "The context of RWrapper.of(context) can't be null");
    return context
        .dependOnInheritedWidgetOfExactType<RDeviceAndThemeProvider>();
  }

  @override
  __RWrapperState createState() => __RWrapperState();
}

class __RWrapperState extends State<RWrap> {
  List<RDeviceWithLimits> breakpoints;
  RDeviceWithLimits currentDevice = RDeviceWithLimits(0, 100, 1);
  RTheme currentTheme;
  double multiplier;
  bool themesEnabled;
  Map<String, RThemeBuilder> themes = {};
  @override
  void initState() {
    _loadThemes();
    _loadBreakpoints(widget.configuration.devices);
    super.initState();
  }

  void _loadThemes() {
    RConfiguration conf = widget.configuration;
    //We load the Themes if needed
    themesEnabled = conf.rootTheme != null ||
        conf.allowedColors != null ||
        conf.themes != null;

    if (!themesEnabled) return;
    assert(conf.rootTheme != null,
        'RConfiguration: RConfiguration.rootTheme should not be null');
    assert(conf.allowedColors != null,
        'RConfiguration: RConfiguration.allowedColors should not be null');
    assert(conf.themes != null,
        'RConfiguration: RConfiguration.themes should not be null');
    RTheme _defaultTheme = widget.configuration.rootTheme();
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

  RTheme _buildTheme(RThemeBuilder builder) {
    RTheme _theme = builder();
    if (_theme.inheritsColors) {
      RTheme _defaultTheme = widget.configuration.rootTheme();
      Map<String, Color> _t = {..._defaultTheme.colors, ..._theme.colors};
      _theme.colors.addAll(_t);
    }
    return _theme;
  }

  void changeTheme(Type name) {
    assert(themesEnabled,
        "RController.changeTheme was called, even tought you didn't specify the required parameters in RConfiguration || RWrapper");
    assert(themes.containsKey(name.toString()),
        'RController.changeTheme: The name ${name.toString()} does not match any of the names specified in RConfiguration.themes');
    RTheme _theme = _buildTheme(themes[name.toString()]);
    setState(() {
      currentTheme = _theme;
    });
  }

  void _loadBreakpoints(List<RDevice> newBreakpoints) {
    List<RDevice> _breakpoints = newBreakpoints?.toList();
    _breakpoints?.sort((a, b) => a.maxSize.compareTo(b.maxSize));
    RDevice previousBreakpoint = _breakpoints[0];
    List<RDeviceWithLimits> _orderedBreakpoints = [];
    _breakpoints.forEach((element) {
      _orderedBreakpoints.add(RDeviceWithLimits(
          previousBreakpoint.maxSize != element.maxSize
              ? previousBreakpoint.maxSize
              : 0,
          element.maxSize,
          element.multiplier));

      previousBreakpoint = element;
    });
    breakpoints = _orderedBreakpoints;
  }

  void changeBreakpoints(BuildContext context, List<RDevice> breakpoints) {
    _loadBreakpoints(breakpoints);
    detectDevice(context);
  }

  void detectDevice(BuildContext context) {
    if (breakpoints == null) return;
    double size = MediaQuery.of(context).size.shortestSide;
    if (size > currentDevice.minSize && size < currentDevice.maxSize) return;
    RDevice _dev = breakpoints.last;
    for (var _t = 0; _t < breakpoints.length; _t++) {
      RDevice _currentDevice = breakpoints[_t];
      if (size < _currentDevice.maxSize) {
        _dev = _currentDevice;

        break;
      }
    }
    setState(() {
      currentDevice = _dev;
    });
  }

  @override
  Widget build(BuildContext context) {
    changeBreakpoints(context, breakpoints);
    detectDevice(context);
    return RDeviceAndThemeProvider(
        child: Builder(
          builder: (pcontext) {
            _context = pcontext;
            return widget.child;
          },
        ),
        theme: currentTheme,
        state: this,
        device: currentDevice);
  }
}

class RDeviceAndThemeProvider extends InheritedWidget {
  final RDevice device;
  final __RWrapperState state;
  final RTheme theme;
  RDeviceAndThemeProvider(
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

//The maxSize is the.. max size. The min size, depends if there is smaller breakpoints, if not, it's 0

class RDevice {
  const RDevice(this.maxSize, this.multiplier);
  final double multiplier;
  final int maxSize;
}

class RDeviceWithLimits implements RDevice {
  RDeviceWithLimits(this.minSize, this.maxSize, this.multiplier);
  final double multiplier;
  final int maxSize;
  final int minSize;
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

  static void initialize(BuildContext context) {
    RWrap.of(context); //This is just to make the flutter widgets dependant 
  }

  static Color getColor(String color) => getColorOfContext(_context, color);

  static double getNumberOfContext(BuildContext context, num number) {
    return RWrap.of(context).device.multiplier * number;
  }

  static double getNumber(num number) => getNumberOfContext(_context, number);

  static void changeTheme(BuildContext context, Type theme) =>
      RWrap.of(context).state.changeTheme(theme);

  static void changeBreakpoints(
          BuildContext context, List<RDevice> breakpoints) =>
      RWrap.of(context).state.changeBreakpoints(context, breakpoints);

  static List<String> valuesToString(List<dynamic> values) {
    return values.map((e) => e.toString()).toList();
  }
}
