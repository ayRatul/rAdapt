# rAdapt 💻➡️🖥➡️📱➡️⌚️

# rAdapt: Easy scaling, and color Theming

rAdapt comes from the necessity of having more than 2 color themes in a Flutter app, of the desire to stop using "ThemeData.of(context)", and the desire of having a consistent scaling, and per device layouts.

The main project from what this is forked is https://github.com/FilledStacks/responsive_builder , wich is awesome. But i have modified the code so much that it has evolved to a different library.

## So... how does it work?

Simple, you initialize some breakpoints, and themes and enums. Then you can just do things like

    Material(
    
	    child: Container(
    
		    width: 56.d,
    
		    height: 56.d,
    
		    color: R.button.c,
  
	    ),
    
    color: R.background.c)
What's the deal? That width/height 56 will be multiplied by a value depending of the breakpoints you set... automatically... of and did i forget to mention that R.button.c and R.background.c will also change color depending on the current Theme that we have? Neat :)

## How do i set this up?
Since the library is not on pub.dev you should download it from here. Add this to your dependencies.

    dependencies:
    ...
    
	    flutter:
    
		    sdk: flutter
	...
    
	    rAdapt:
    
		    git:
    
			    url: git://github.com/ayRatul/rAdapt.git

A good place to start is check the example project of this repository since this explanation is based on that...
First create a values.dart file in the /lib folder of your flutter project. We are gonna use this file in the whole app, the rAdapt library is just used for initialization and other small things.
**Import it... *and export it as well***

    import  'package:flutter/material.dart';
    
    import  'package:rAdapt/rAdapt.dart';
    
    export  'package:rAdapt/rAdapt.dart';
Now we need to define the  **RDevice** objects , it's an object that holds a maxSize value and a multiplier.

> RDevice(maxSize,multiplier)

Since it doesn't provide any way of identifying itself, we need to use a class to hold all the RDevice objects, this is a recommended way of doing it

    class  RDevices {
    
    static  RDevice watch = RDevice(300, 0.8); //from 0 to 300 it's a watch and the value gets multiplied by 0.8
    
    static  RDevice mobile = RDevice(800, 1); //from 300 to 800 it's mobile, it's multiplied by 1, so it's the same value
    
    static  RDevice tablet = RDevice(1200, 1.2);
    
    static  RDevice desktop = RDevice(1500, 1.5);
    
    static  List<RDevice> get  dataList => [watch, mobile, tablet, desktop]; //We wrap all the values in a list, will come in handy later.
    
    }

Now... we need to make a class that **Implements RConfiguration**, the library uses this to determine multiple things at once and avoid boilerplate in the build method.

    class  MyConfiguration  implements  RConfiguration {
    
    @override
    
    get  devices => RDevices.dataList;
    
    @override
    
    get  themes => null; //We are not using themes for now, all this is null
    
    @override
    
    get  allowedColors => null;
    
    @override
    
    get  rootTheme => null;
    
    }

## It's done!!!, time to link it to the app!!

In your MaterialApp's or WidgetsApp's builder method, we wrap his child in **RWrap**, yeah, i'm creative

    return MaterialApp(
    
	    title: 'Flutter Demo',
    
	    builder: (context, child) {
    
		    return RWrap(
    
			    child: child,
    
			    configuration: MyConfiguration(),
    
		    );
    
	    },
    
	    home: MyHomePage(),
    
    );

  
Now we can call **RWrap.of(context).device.multiplier** to get the multiplier... however there is a better way of doing this.

Using extensions... the library would implement extensions but importing from a library seems to be a problem with some dart versions, so you must implement it as well. Just copy and paste this

    extension  RNumber  on  num {
    
    double  get  d => RAdapt.getNumber(this); //this returns double numbers
    
    int  get  i => this.d.toInt(); //this returns int numbers
    
    }
  
after all that there is only 1 step, you must initialize rAdapt, this is easy as well

## Initialize
We need to initialize with access to the context, that means inside Build or initstate. 

    @override

    Widget  build(BuildContext context) {
    
	    RAdapt.initialize(context); //Call it once, it just updates the dependecies to listen for a size change ;)
    ...
    }

And after all that, enjoy rAdapt

    class  ExampleContainer  extends  StatelessWidget {
    
    @override
    
    Widget build(BuildContext context) {
	    RAdapt.initialize(context);
	    return Center(
	    child:Container(
		    color: Colors.red,
			width: 50.d, //This 7u7
		    height: 50.d, //And this 0.0
	    ));
    }}

