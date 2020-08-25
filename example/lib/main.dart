import 'package:flutter/material.dart';
import 'package:example/values.dart'; //This is a relative import, change "example" with the name of your project

void main() {
  runApp(RWrapper(child: MyApp(), configuration: MyConfiguration()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RController.initialize(
        context); //initialize the RController context in the first page of materialapp
    //We could also initialize in materialApp's builder, however if we do that, to change theme we should call RWrapper.of(context).changeTheme();
    return Scaffold(
        backgroundColor: R.background.c,
        appBar: AppBar(
          title: Text('Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'The multiplier is',
              ),
              Text(
                '${RController.device.multiplier}',
                style: Theme.of(context).textTheme.headline4,
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    BuildChecker(0, Colors.blue),
                    BuildChecker(1, R.button.c),
                    BuildChecker(2, Colors.blue),
                    BuildChecker(3, R.button.c),
                    BuildChecker(4, Colors.blue),
                    BuildChecker(5, R.button.c),
                    BuildChecker(6, Colors.blue),
                    BuildChecker(7, R.button.c),
                  ],
                ),
              ))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: R.button.c,
          onPressed: () {
            RController.changeTheme(DarkTheme);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ));
  }
}

class BuildChecker extends StatelessWidget {
  const BuildChecker(this.index, this.color);
  final Color color;
  final int index;
  @override
  Widget build(BuildContext context) {
    print('Building box $index');
    return Container(
      color: color,
      width: 56.d,
      height: 56.d,
    );
  }
}
