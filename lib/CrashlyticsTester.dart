
import 'package:eventevent/Providers/EventListProviders.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';

// class CrashlyticsTester extends StatefulWidget {
//   CrashlyticsTester({
//     Key key,   
//   }) : super(key: key);

//   @override
//   _CrashlyticsTesterState createState() => _CrashlyticsTesterState();
// }

// class _CrashlyticsTesterState extends State<CrashlyticsTester> {
//   int _selectedItem = 0;
//   bool isSelected = false;

//   selectItem(index) {

//     setState(() {
//       _selectedItem = index;
//       isSelected = !isSelected;
//       print(selectItem.toString());
//     });
//   }

//   @override
//   Widget build(BuildContext context) { 
//     //...YOUR WIDGET TREE HERE

//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: 5,
//       itemBuilder: (context, index) {
//         return CustomItem(
//           selectItem, // callback function, setstate for parent
//           index: index,
//           isSelected: _selectedItem == index ? true : false,
//           title: index.toString(),
//         );
//       },
//     );
//   }
// }

// class CustomItem extends StatefulWidget {
//   final String title;
//   final int index;
//   final bool isSelected;
//   Function(int) selectItem;

//   CustomItem(
//     this.selectItem, {
//     Key key,
//     this.title,
//     this.index,
//     this.isSelected,
//   }) : super(key: key);

//   _CustomItemState createState() => _CustomItemState();
// }

// class _CustomItemState extends State<CustomItem> {
//   @override
//   Widget build(BuildContext context) { 
//     return Row(
//       children: <Widget>[
//         Text("${widget.isSelected ? "true" : "false"}"),
//         RaisedButton(
//           onPressed: () {
//             widget.selectItem(widget.index);
//           },
//           child: Text("${widget.title}"),
//         )
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  // @override
  // Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
  //   double defaultScreenHeight = 810.0;

  //   ScreenUtil.instance = ScreenUtil(
  //     width: defaultScreenWidth,
  //     height: defaultScreenHeight,
  //     allowFontScaling: true,
  //   )..init(context);
  //   return new Row(
  //     children: <Widget>[
  //       new Text("test ${isSelected ? "true" : "false"}"),
  //       new RaisedButton(
  //         onPressed: () {
  //           if (isSelected) {
  //             setState(() {
  //               isSelected = false;
  //             });
  //           } else {
  //             setState(() {
  //               isSelected = true;
  //             });
  //           }
  //         },
  //         child: new Text("Select"),
  //       )
  //     ],
  //   );
  // }
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Text('Crashlytics tester'),
      ),
      body: ListView(
        children: <Widget>[
          RaisedButton(
            onPressed: (){
              Crashlytics.instance.setString('test error', 'tested by key test');
            },
            child: Text('key'),
          ),
          RaisedButton(
            onPressed: (){
              Crashlytics.instance.log('tested by log test');
            },
            child: Text('log'),
          ),
          RaisedButton(
            onPressed: (){
              Crashlytics.instance.crash();
            },
            child: Text('crash'),
          ),
          RaisedButton(
            onPressed: (){
              throw StateError('Uncaught Error thrown by app');
            },
            child: Text('throw error'),
          ),
          RaisedButton(
            onPressed: (){
              Future<void>.delayed(Duration(seconds: 2), (){
                final List<int> list = <int> [];
                print(list[100]);
              });
            },
            child: Text('Async out of bounds'),
          ),
        ],
      ),
    );
  }
}