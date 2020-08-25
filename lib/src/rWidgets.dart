import 'package:flutter/material.dart';
import 'rController.dart';

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
  final RThemeBuilder defaultTheme = null;
  final List<String> allowedColors = null;
}

class RWrapper extends StatefulWidget {
  RWrapper(
      {Key key,
      @required this.child,
      @required this.configuration,
      this.overrideDefaultTheme,
      this.initialThemeType})
      : super(key: key);
  final Widget child;
  final RConfiguration configuration;
  final Type initialThemeType;
  final RThemeBuilder overrideDefaultTheme;
  static RProvider of(BuildContext context) {
    assert(
        context != null, "The context of RWrapper.of(context) can't be null");
    return context.dependOnInheritedWidgetOfExactType<RProvider>();
  }

  @override
  __RWrapperState createState() => __RWrapperState();
}

class __RWrapperState extends State<RWrapper> {
  List<RDevice> breakpoints;
  RTheme currentTheme;
  RTheme _defaultTheme;
  bool themesEnabled;
  Map<String, RThemeBuilder> themes = {};
  @override
  void initState() {
    loadConfiguration();
    super.initState();
  }

  void loadConfiguration() {
    RConfiguration conf = widget.configuration;
    //We load the breakpoints
    List<RDevice> _breakpoints = conf.devices != null
        ? conf.devices.toList()
        : [RController.defaultDevice];
    _breakpoints.sort((a, b) => a.maxSize.compareTo(b.maxSize));
    breakpoints = _breakpoints;
    //We check the default RTheme
    themesEnabled = widget.overrideDefaultTheme != null ||
        conf.defaultTheme != null ||
        conf.allowedColors != null ||
        conf.themes != null;
    if (!themesEnabled) return;
    _defaultTheme = widget.overrideDefaultTheme != null
        ? widget.overrideDefaultTheme()
        : conf.defaultTheme();
    assert(_defaultTheme != null,
        'RConfiguration.defaultTheme or RWrapper.overrideDefaultTheme should not be null');
    assert(_defaultTheme.colors != null,
        'RConfiguration.defaultTheme||RWrapper.overrideDefaultTheme: RTheme.colors and RTheme.name are obligatory');
    assert(conf.allowedColors != null,
        'RConfiguration.allowedColors should not be null');
    conf.allowedColors.forEach((element) {
      assert(_defaultTheme.colors.containsKey(element),
          "RConfiguration.defaultTheme||RWrapper.overrideDefaultTheme: The default RTheme ${_defaultTheme.runtimeType.toString()} doesn't containt the color :$element , the Default Theme sould have EVERY color specified in RConfiguration.allowedColors");
    });

    //We clear the previous themes (if any), to load conf.themes, convert it to a Map of <String,RThemeBuilder>, for easy access ;)
    themes.clear();
    assert(conf.themes != null, 'RConfiguration.themes should not be null');
    conf.themes.forEach((_themeBuilder) {
      RTheme _theme = _themeBuilder();
      assert(_theme.colors != null,
          'RTheme in RConfiguration.themes: RTheme.colors and RTheme.name are obligatory, please verify that each theme has those values');
      if (!_theme.inheritsColors) {
        conf.allowedColors.forEach((element) {
          assert(_theme.colors.containsKey(element),
              "RConfiguration.themes: The RTheme ${_theme.runtimeType.toString()} doesn't containt the color :$element , since RTheme.inheritsColors is false on that Theme, it should have EVERY color specified in RConfiguration.allowedColors ");
        });
      }
      assert(!themes.containsKey(_theme.runtimeType.toString()),
          'RConfiguration.themes:The name "${_theme.runtimeType.toString()}" is duplicated');
      themes[_theme.runtimeType.toString()] = _themeBuilder;
      print(_theme.runtimeType.toString());
    });
    //We load the current Theme
    if (widget.initialThemeType != null) {
      assert(themes.containsKey(widget.initialThemeType),
          'RWrapper:The initialThemeType ${widget.initialThemeType} does not match any of the names specified in RConfiguration.themes');
      currentTheme = _buildTheme(themes[widget.initialThemeType]);
    } else {
      currentTheme = _defaultTheme;
    }
  }

  RTheme _buildTheme(RThemeBuilder builder) {
    RTheme _theme = builder();
    if (_theme.inheritsColors) {
      RTheme _defaultTheme = widget.overrideDefaultTheme != null
          ? widget.overrideDefaultTheme()
          : widget.configuration.defaultTheme();
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

  void changeBreakpoints(List<RDevice> b) {
    assert(b != null || b.length < 0,
        'RController.changeBreakpoints: The breakpoints must not be null, and the length should be bigger than 0');
    setState(() {
      breakpoints = b;
    });
  }

  @override
  Widget build(BuildContext context) => RProvider(
        child: widget.child,
        theme: currentTheme,
        state: this,
        breakpoints: breakpoints,
      );
}

class RProvider extends InheritedWidget {
  final List<RDevice> breakpoints;
  final __RWrapperState state;
  final RTheme theme;
  RProvider(
      {Key key,
      @required Widget child,
      @required this.state,
      @required this.breakpoints,
      this.theme})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(RProvider oldWidget) =>
      oldWidget.theme != theme || oldWidget.breakpoints != breakpoints;
}

//The maxSize is the.. max size. The min size, depends if there is smaller breakpoints, if not, it's 0

class RDevice {
  const RDevice(this.maxSize, this.multiplier);
  final double multiplier;
  final int maxSize;
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
