# RSize 💻➡️🖥➡️📱➡️⌚️

This is RSize. I growed up tired of context calls, conditional layouts everywhere, and hardcoded numbers. I wanted something that i had to initialize just once, then forget about it. So i discovered  https://pub.dev/packages/responsive_framework , but it just wasn't good enough, the dropdown and overlays were REALLY bugged.

I then discovered https://github.com/FilledStacks/responsive_builder , wich is the base for this library, i just changed the concept of limited breakpoints and hardcoded values, to Infinite Breakpoints, and one value... multiplied


Of course i still need to define the layout based on the Device in some parts of the application. But that logic is now fully delegated to the developer, not to the library

This library provides the "I" and the "D", as well as a ResponsiveSizingConfig Widget to build the layouts per device



## Installation

Add this repository as a dependency

```
rsize: 
    git: 
      url: git://github.com/ayRatul/RSize.git
```

## Usage

This package requires you to implement the device breakpoints. I suggest using a class with static variables and a getter to do the initial setup.

```
//Somewhere in your main.dart file
class RD {
  static RDevice watch = RDevice(300, 0.8); //it's a watch if the size goes from 0 to 300. We multiply the value by 0.8
  static RDevice mobile = RDevice(600, 1); //it's mobile if the size goes from 300 to 600 We multiply the value by 1
  static RDevice tablet = RDevice(1000, 1.2); //you get the point We multiply the value by 1.2
  static RDevice web = RDevice(1300, 2);
  static CustomBreakpoints get devices =>
      CustomBreakpoints(data: [watch, mobile, tablet, web]); //after all your breakpoints are defined, this method converts it to a CustomBreakpoints class. Will come in handy later
}
```

### Initialization

This needs to be done ONCE in the app, you can do it multiple times if you want but the effects are the same. It is HIGHLY advised to do it in the MaterialApp, or WidgetsApp `builder` function

```
return MaterialApp(
      ...
      builder: (context, child) {
        ResponsiveSizingConfig.instance.initialize(context, RD.devices); //we initialize with RD.devices ;)
        return child; //we return the child. Nothing more to do
      },
      ...
    )

```

### Usage

The advised usage is for widgets that are on the build section... You know.. those that you can see changing.

There are three ways of using this.
The "d", which returns a double value multiplied by the "multiplier"

```
            child: Container(
                  width: 48.d, // If the multiplier is 0.5 , this would be 24.0
                  height: 48.d,// If the multiplier is 0.5 , this would be 24.0
                  color: Colors.blue,
                ),
```

The "i", which returns an integer, the result of (value*multiplier).toInt()

```
            child: Container(
                  width: 46.i, // If the multiplier is 0.6 , this would be 28
                  height: 46.i,// If the multiplier is 0.6 , this would be 28
                  color: Colors.blue,
                ),
```

and finally, `rsize`, both ".i" and ".d" use resize under the hood. So it's kinda useless to call rsize directly. However, i have nice plans for this function


### Responsive Builder

The `ResponsiveBuilder` is used as any other builder widget.

```dart
// import the package
import 'package:rsize/rsize.dart';

// Use the widget
ResponsiveBuilder(
    builder: (context, device) {
      // Check the device information here and return your UI
          if (device == RD.watch) { //We can compare to the class with static variables
          return Container(color:Colors.blue);
        }

        if (device == RD.mobile) {
          return Container(color:Colors.red);
        }

        if (device == RD.tablet) {
          return Container(color:Colors.yellow);
        }

        return Container(color:Colors.purple);
      },
    },
  );
}
```

This will return different colour containers depending on which device it's being shown on. A simple way to test this is to either run your code on Flutter web and resize the window or add the [device_preview](https://pub.dev/packages/device_preview) package and view on different devices.

## Orientation Layout Builder

This widget can be seen as a duplicate of the `OrientationBuilder` that comes with Flutter, but the point of this library is to help you produce a readable responsive UI code base. As mentioned in the [follow along tutorial](https://youtu.be/udsysUj-X4w) I didn't want responsive code riddled with conditionals around orientation, `MediaQuery` or Renderbox sizes. That's why I created this builder.

The usage is easy. Provide a builder function that returns a UI for each of the orientations.

```dart
// import the package
import 'package:rsize/rsize.dart';

// Return a widget function per orientation
OrientationLayoutBuilder(
  portrait: (context) => Container(color: Colors.green),
  landscape: (context) => Container(color: Colors.pink),
),
```

This will return a different coloured container when you swap orientations for your device. In a more readable manner than checking the orientation with a conditional.

## Screen Type Layout

This is not available anymore, since the infinite breakpoints make imposible this implementation, however,ResponsiveBuilder does the trick ;)

### TODO:
- [ ] add more documentation
- [ ] add documentation about the behaviour of the breakpoints
- [ ] find bugs
- [ ] fix bugs
- [ ] maybe publish to pub.dev?

## Contribution

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request.
