import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsTester extends StatefulWidget {
  @override
  _CrashlyticsTesterState createState() => _CrashlyticsTesterState();
}

class _CrashlyticsTesterState extends State<CrashlyticsTester> {

  bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Text("test ${isSelected ? "true" : "false"}"),
        new RaisedButton(
          onPressed: () {
            if (isSelected) {
              setState(() {
                isSelected = false;
              });
            } else {
              setState(() {
                isSelected = true;
              });
            }
          },
          child: new Text("Select"),
        )
      ],
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Crashlytics tester'),
  //     ),
  //     body: ListView(
  //       children: <Widget>[
  //         RaisedButton(
  //           onPressed: (){
  //             Crashlytics.instance.setString('test error', 'tested by key test');
  //           },
  //           child: Text('key'),
  //         ),
  //         RaisedButton(
  //           onPressed: (){
  //             Crashlytics.instance.log('tested by log test');
  //           },
  //           child: Text('log'),
  //         ),
  //         RaisedButton(
  //           onPressed: (){
  //             Crashlytics.instance.crash();
  //           },
  //           child: Text('crash'),
  //         ),
  //         RaisedButton(
  //           onPressed: (){
  //             throw StateError('Uncaught Error thrown by app');
  //           },
  //           child: Text('throw error'),
  //         ),
  //         RaisedButton(
  //           onPressed: (){
  //             Future<void>.delayed(Duration(seconds: 2), (){
  //               final List<int> list = <int> [];
  //               print(list[100]);
  //             });
  //           },
  //           child: Text('Async out of bounds'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}