import 'package:flutter/material.dart';
import '../responsive.dart';

///We use this as a theme class. It just needs to override colors
abstract class RTheme {
  final Map<String, Color> colors = {};
}

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
      this.onLoad,
      this.onErrorColor = Colors.red});
  final Widget child;
  final RBreakpoints breakpoints;
  final List<dynamic> colorList;
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
    currentTheme = widget.themesList[0];
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) => widget.onLoad ?? () {});
  }

  void changeTheme(String name) {
    setState(() {
      currentTheme = widget.themesList[name];
    });
  }

  void changeBreakpoints(RBreakpoints b) {
    setState(() {
      breakpoints = b;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _RWrapper(
      child: Builder(builder: (context) {
        RController._rContext = RController._rContext ?? context;
        RController._instance =
            RController._instance ?? RController.of(context);
        return widget.child;
      }),
      context: context,
      theme: currentTheme,
      state: this,
      breakpoints: widget.breakpoints,
    );
  }
}

class _RWrapper extends InheritedWidget {
  final BuildContext context;
  final RBreakpoints breakpoints;
  final __RWrapperState state;
  final RTheme theme;
  _RWrapper(
      {Key key,
      @required Widget child,
      @required this.state,
      @required this.context,
      @required this.breakpoints,
      this.theme})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_RWrapper oldWidget) {
    return oldWidget.breakpoints != breakpoints || oldWidget.theme != theme;
  }
}

class RController {
  static _RWrapper _instance;
  static RBreakpoints get breakpoints => RController._instance.breakpoints;
  static BuildContext _rContext;

  static _RWrapper of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RWrapper>();

  static RBreakpoints _defaultBreakPoints =
      RBreakpoints(data: [RDevice(480, 1)]);

  static void changeTheme(String name) {
    if (!RController._instance.state.widget.themesList.containsKey(name))
      return;
    RController._instance.state.changeTheme(name);
  }

  static void changeBreakpoints(RBreakpoints breakpoints) {
    if (breakpoints.data.length <= 0) {
      return;
    }
    RController._instance.state.changeBreakpoints(breakpoints);
  }

  static Color getColorForName(String p) {
    if (!_instance.theme.colors.containsKey(p)) {
      return _instance.state.widget.onErrorColor;
    }
    return _instance.theme.colors[p];
  }
}

extension SizeExtension on num {
  double get d => rsize(RController._rContext, this);
  int get i => rsize(RController._rContext, this).toInt();
}

//We could use a similar extension on enum, but that would require to declare the enum in the library... that would lead to
//a limited number of colors and names. So we let the user define the enum, and the extension themselfs.
//Then, we just use the logic to get the color.
//Pros of this : the compiler knows the colors, it's beautiful and simple code. No boilerplate
//Cons of this : The user needs to import both the library, and the Colors file.
//It's still better thatn calling MyThemeData.of(context).backgroundColor, instead just call R.backgroundColor.c
