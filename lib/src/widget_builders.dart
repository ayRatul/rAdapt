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
    return LayoutBuilder(builder: (context, boxConstraints) {
      var mediaQuery = MediaQuery.of(context);
      var sizingInformation = SizingInformation(
        deviceScreenType:
            getCustomDeviceType(mediaQuery.size, breakpoints: breakpoints),
        screenSize: mediaQuery.size,
        localWidgetSize:
            Size(boxConstraints.maxWidth, boxConstraints.maxHeight),
      );
      return builder(context, sizingInformation);
    });
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
