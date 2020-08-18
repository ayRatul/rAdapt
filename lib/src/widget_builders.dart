import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:praktice/responsive.dart';
import 'helpers.dart';
import 'sizing_information.dart';

typedef SizeWidgetBuilder = Widget Function(
    BuildContext context, SizingInformation sizeInfo);

/// A widget with a builder that provides you with the sizingInformation
///
/// This widget is used by the ScreenTypeLayout to provide different widget builders
class ResponsiveBuilder extends StatelessWidget {
  final SizeWidgetBuilder builder;

  final CustomBreakpoints breakpoints;

  const ResponsiveBuilder({Key key, this.builder, this.breakpoints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(
        context,
        SizingInformation(
            deviceScreenType: getDevice(context, breakpoints: breakpoints)));
  }
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
    return Builder(
      builder: (context) {
        var orientation = MediaQuery.of(context).orientation;
        if (orientation == Orientation.landscape) {
          if (landscape != null) {
            return landscape(context);
          }
        }

        return portrait(context);
      },
    );
  }
}
