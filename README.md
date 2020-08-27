
# rAdapt: An Aproach to colors.xml and values.xml for flutter

rAdapt comes from the necessity of having more than 2 color themes in a Flutter app, of the desire to stop using "ThemeData.of(context)", and the desire of having a consistent scaling, and per device layouts.

The 2 main factors are color and size, rAdapt deals with them in a different way. We can call colors like **R.backgroundColor.c** , and sizes like **56.d** and they change depending on the device, and the current RTheme

The main project from what this is forked is https://github.com/FilledStacks/responsive_builder , which is awesome. But i have modified the code so much that it has evolved to a different library.

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
Now we need to define the  **RDevice** objects , it's an object that holds a maxSize value and a multiplier. Kinda like braekpoints.

> RDevice(maxSize,multiplier)

Since it doesn't provide any way of identifying itself, we need to use a class to hold all the RDevice objects, this is a recommended way of doing it

    class  RDevices {
    
    static  RDevice watch = RDevice(300, 0.8); //from 0 to 300 it's a watch and the value gets multiplied by 0.8
    
    static  RDevice mobile = RDevice(800, 1); //from 300 to 800 it's mobile, it's multiplied by 1, so it's the same value
    
    static  RDevice tablet = RDevice(1200, 1.2);
    
    static  RDevice desktop = RDevice(1500, 1.5);
    
    static  List<RDevice> get  dataList => [watch, mobile, tablet, desktop]; //We wrap all the values in a list, will come in handy later.
    
    }

Now... we need to make a class that **Implements RConfiguration**, the library uses this to determine multiple things at once and avoid boilerplate in the builder method of .

    class  MyConfiguration  implements  RConfiguration {
    
    @override
    
    get  devices => RDevices.dataList;
    
    @override
    
    get  themes => null; //We are not using themes for now, this is null
    
    @override
    
    get  allowedColors => null; //We are not using themes for now, this is null
    
    @override
    
    get  rootTheme => null; //We are not using themes for now, this is null
    
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
  
rAdapt stores the context of RWrap and uses it in the function "getNumber", flutter doesn't recommend to store context because the widget can be disposed... HOWEVER... since we call RWrap in the builder method of materialApp, that's unlikely to happen ;)

And after all that, enjoy rAdapt

    class  ExampleContainer  extends  StatelessWidget {
    
    @override
    
    Widget build(BuildContext context) {
	    return Center(
	    child:Container(
		    color: Colors.red,
			width: 50.d, //This 7u7
		    height: 50.d, //And this 0.0
	    ));
    }}

# Theme Setup

For themes, it gets somewhat complicated. but once you set it up, using it is a breeze.

First let's look at the current configuration

    class  MyConfiguration  implements  RConfiguration {
    
    @override
    
    get  devices => RDevices.dataList;
    
    @override
    
    get  themes => null;
    
    @override
    
    get  allowedColors => null; 
    
    @override
    
    get  rootTheme => null; 
    
    }
Let's start with "allowedColors", this is a List of Strings that represents all the colors that the theme will have. Why do we do this?.  To have consistency.
How do we set it up ? With an enum... an enum???? . Yes, an enum. You will see why later. (Also, i would suggest using only one letter as the enum name) 

    enum R{
    background,
    button,
    foreground
    }
 We can see that we have 3 available colors. Now let's set up some themes.
 rAdapt has the abstract class RTheme, each theme that you create should "implement RTheme"

    class LightTheme implements RTheme{}
    class DarkTheme implements RTheme{}
If you copy/paste this in your values.dart file the IDE might tell you that you need to implement the values "colors", and "inheritsColors" , colors is a Map<String,Color> ,and inheritColors is something we will discuse later.

So the classes should look like this 

    class  LightTheme  implements  RTheme {
    @override
    Map<String, Color> get  colors => {};
    
    @override
    bool  get  inheritsColors => true;
    }
    class  DarkTheme implements  RTheme {
    @override
    Map<String, Color> get  colors => {};
    
    @override
    bool  get  inheritsColors => true;
    }
Now... let's do something with that enum of colors... let's use an extension again. Copy and paste this

    extension  RColor  on  R {
    
    String  get  s => this.toString();
    
    Color  get  c => RAdapt.getColor(this.s);
    
    }

Now we can fill up the Themes color property like this :

    class  LightTheme  implements  RTheme {
    
    @override
    
    Map<String, Color> get  colors => {
    
    R.background.s:Color(0xFFFFFFFF), //We call R.background.s to convert the enum value to a string.
    
    R.button.s:Color(0xFFAAFFAA),
    
    R.foreground.s:Color(0xFF000000)
    
    };
    
      
    
    @override
    
    bool  get  inheritsColors => true; //We set this to true
    
    }
    
      
    
    class  DarkTheme  implements  RTheme {
    
    @override
    
    Map<String, Color> get  colors => {
    
    R.background.s:Color(0xFF000000),
    
    R.button.s:Color(0xFFFFFFAA),
	
	//Where is foreground color?? 7u7
    
    };
    
      
    
    @override
    
    bool  get  inheritsColors => true; //We set this to true
    
    }

As you can see we don't implement foreground in DarkTheme... Why? . Because DarkTheme has inheritsColors set to TRUE, it will INHERIT all the colors of the rootTheme... which will be LightTheme

Now we need to organize our Themes, we will use a class for that , and introduce a new object **RThemeBuilder** . Why do we use a builder? to avoid having resources wasted in themes that we are not using ;)

	class MyThemes {
	static RThemeBuilder light = ()=>LightTheme();
	static RThemeBuilder dark =()=>DarkTheme();
	static  List<RThemeBuilder> get  dataList => [light, dark];
	}

And we have come full circle, in MyConfiguration we just set the values
   

     class  MyConfiguration  implements  RConfiguration {
    
    @override
    
    get  devices => RDevices.dataList;
    
    @override
    
    get  themes => MyThemes.dataList;
    
    @override
    
    get  allowedColors => RAdapt.valuesToString(R.values); //This is important to convert the enum to a list of string ;) 
    
    @override
    
    get  rootTheme => RThemes.light; 
    
    }

Now... we can enjoy using the themes!

    class  ExampleContainer  extends  StatelessWidget {
        
    @override
    
    Widget build(BuildContext context) {
	    return Center(
	    child:Container(
		    color: R.button.c, //THISS!!
			width: 50.d, 
		    height: 50.d, 
	    ));
    }}

to change Themes we can just call **RAdapt.changeTheme(context, type); ** , where context is a normal buildcontext , and type, is the type of the theme, so it can be "LightTheme" and "DarkTheme", notice we don't use the parentheses, we use only the type

class  ExampleContainer  extends  StatelessWidget {
        
    @override
    
    Widget build(BuildContext context) {
	    return Center(
	    InkWell(
		    child: Container(width:20.d,height:20.d,color:R.background.c), //THISS!!
			onTap:(){RAdapt.changeTheme(context,DarkTheme);}
	    ));
    }}
And we are done !!

## TODO
- Better documentation
- Optimize the code
- Maybe upload it to pub.dev
