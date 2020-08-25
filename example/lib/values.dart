import 'package:rAdapt/rAdapt.dart';
import 'package:flutter/material.dart';
export 'package:rAdapt/rAdapt.dart';

enum R {
  background,
  button,
  foreground
  //etc,etc
}

class RDevices {
  static RDevice watch = RDevice(300, 0.8);
  static RDevice mobile = RDevice(800, 1);
  static RDevice tablet = RDevice(1200, 1.2);
  static RDevice desktop = RDevice(1500, 1.5);
  static List<RDevice> get toList => [watch, mobile, tablet, desktop];
}

class RThemes {
  static RThemeBuilder light = () => LightTheme();
  static RThemeBuilder dark = () => DarkTheme();
  static List<RThemeBuilder> get toList => [light, dark];
}

class MyConfiguration implements RConfiguration {
  @override
  final List<RDevice> devices = RDevices.toList;
  @override
  final List<RThemeBuilder> themes = RThemes.toList;
  @override
  final List<String> allowedColors = R.values.map((e) => e.toString()).toList();
  @override
  final RThemeBuilder defaultTheme = RThemes.light;
}

extension RNumber on int {
  double get d => RController.getValue(this);
  int get i => this.d.toInt();
}

extension RColor on R {
  String get f => this.toString();
  Color get c => RController.getColor(this.f);
}

class LightTheme implements RTheme {
  @override
  final Map<String, Color> colors = {
    R.background.f: Colors.white,
    R.button.f: Colors.blue,
    R.foreground.f: Color(0xFFFF00FF)
  };

  @override
  bool get inheritsColors => true;
}

class DarkTheme implements RTheme {
  @override
  final Map<String, Color> colors = {
    R.background.f: Colors.black,
    R.button.f: Colors.red,
    R.foreground.f: Color(0xFF0000FF),
  };

  @override
  bool get inheritsColors => true;
}
