import 'package:flutter/material.dart';
import 'rSize.dart';

///We use this as a theme class. It just needs to override colors
abstract class RTheme {
  final Map<String, Color> colors = {};
}

BuildContext _context;

///[breakpoints] is a [RBreakpoints] object. [colorList] NEEDS to be initialized in a special way, it's optional
///[colorList] is an ENUM. Please refer to the documentation to know how to set up the themes.
///[themesList] is a list of RThemes, [onLoad] is just called after initState, you should use this to load saved
///options, like a different theme, by default, we use the first theme. You call RController.changeTheme() to
///change the default theme on onLoad
///[onErrorColor] is used when the color can't be found in the theme. This should not ocurr if you follow the docs,
///but... it's nice to know
class RWrapper extends StatefulWidget {
  RWrapper(
      {@required this.child,
      @required this.breakpoints,
      this.colorList,
      this.themesList,
      this.initialTheme,
      this.onLoad,
      this.onErrorColor = Colors.red});
  final Widget child;
  final RBreakpoints breakpoints;
  final List<dynamic> colorList;
  final String initialTheme;
  final Map<String, RTheme> themesList;
  final Function onLoad;
  final Color onErrorColor;
  @override
  __RWrapperState createState() => __RWrapperState();
}

class __RWrapperState extends State<RWrapper> {
  RBreakpoints breakpoints;
  RTheme currentTheme;

  @override
  void initState() {
    breakpoints = widget.breakpoints ?? RController._defaultBreakPoints;
    currentTheme = widget.themesList[widget.initialTheme];
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) => widget.onLoad ?? () {});
  }

  void changeTheme(String name) {
    currentTheme = widget.themesList[name];
    setState(() {});
  }

  void changeBreakpoints(RBreakpoints b) {
    setState(() {
      breakpoints = b;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _RWrapper(
      key: UniqueKey(),
      child: Builder(
        builder: (BuildContext context) {
          _context = context;
          return widget.child;
        },
      ),
      theme: currentTheme,
      state: this,
      breakpoints: widget.breakpoints,
    );
  }
}

class _RWrapper extends InheritedWidget {
  final RBreakpoints breakpoints;
  final __RWrapperState state;
  final RTheme theme;
  _RWrapper(
      {Key key,
      @required Widget child,
      @required this.state,
      @required this.breakpoints,
      this.theme})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_RWrapper oldWidget) {
    return false;
  }
}

class RController {
  static RBreakpoints get breakpoints => RController.of(_context).breakpoints;

  static _RWrapper of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RWrapper>();

  static RBreakpoints _defaultBreakPoints =
      RBreakpoints(data: [RDevice(480, 1)]);

  static void changeTheme(String name) {
    if (!RController.of(_context).state.widget.themesList.containsKey(name))
      return;
    RController.of(_context).state.changeTheme(name);
  }

  static void changeBreakpoints(RBreakpoints breakpoints) {
    if (breakpoints.data.length <= 0) {
      return;
    }
    RController.of(_context).state.changeBreakpoints(breakpoints);
  }

  static Color getColorForName(String p) {
    if (!RController.of(_context).theme.colors.containsKey(p)) {
      return RController.of(_context).state.widget.onErrorColor;
    }
    return RController.of(_context).theme.colors[p];
  }
}

extension RSmartSize on num {
  double get d => rsize(_context, this);
  int get i => rsize(_context, this).toInt();
}

//We could use a similar extension on enum, but that would require to declare the enum in the library... that would lead to
//a limited number of colors and names. So we let the user define the enum, and the extension themselfs.
//Then, we just use the logic to get the color.
//Pros of this : the compiler knows the colors, it's beautiful and simple code. No boilerplate
//Cons of this : The user needs to import both the library, and the Colors file.
//It's still better thatn calling MyThemeData.of(context).backgroundColor, instead just call R.backgroundColor.c

class AppBuilder extends StatefulWidget {
  final Function(BuildContext) builder;

  const AppBuilder({Key key, this.builder}) : super(key: key);

  @override
  AppBuilderState createState() => new AppBuilderState();

  static AppBuilderState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<AppBuilderState>());
  }
}

class AppBuilderState extends State<AppBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  void rebuild() {
    setState(() {});
  }
}
