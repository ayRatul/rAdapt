import 'package:rAdapt/rAdapt.dart';
import 'package:flutter/material.dart';
export 'package:rAdapt/rAdapt.dart';

class MyConfiguration implements RConfiguration {
  @override
  get devices => RDevices.dataList;
  @override
  get themes => RThemes.dataList;
  @override
  get allowedColors => RAdapt.valuesToString(R.values);
  @override
  get rootTheme => RThemes.light;
}

enum R {
  background,
  button,
  foreground
  //etc,etc
}

extension RColor on R {
  String get s => this.toString();
  Color get c => RAdapt.getColor(this.s);
}

class RDevices {
  static RDevice watch = RDevice(300, 0.8);
  static RDevice mobile = RDevice(800, 1);
  static RDevice tablet = RDevice(1200, 1.2);
  static RDevice desktop = RDevice(1500, 1.5);
  static List<RDevice> get dataList => [watch, mobile, tablet, desktop];
}

extension RNumber on int {
  double get d => RAdapt.getNumber(this);
  int get i => this.d.toInt();
}

class RThemes {
  static RThemeBuilder light = () => LightTheme();
  static RThemeBuilder dark = () => DarkTheme();
  static List<RThemeBuilder> get dataList => [light, dark];
}

class LightTheme implements RTheme {
  @override
  Map<String, Color> get colors => {
        R.background.s: Colors.white,
        R.button.s: Colors.blue,
        R.foreground.s: Color(0xFFFF00FF)
      };

  @override
  bool get inheritsColors => true;
}

class DarkTheme implements RTheme {
  @override
  Map<String, Color> get colors => {
        R.background.s: Colors.black,
        R.button.s: Colors.red,
        R.foreground.s: Color(0xFF0000FF),
      };

  @override
  bool get inheritsColors => true;
}
