import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';

class ExpiredPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ExpiredPageState();
  }
}

class ExpiredPageState extends State<ExpiredPage> {
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: checkForBackgroundColor(context),
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Icon(Icons.close, size: 35, color: eventajaGreenTeal,),
        ),
        centerTitle: true,
        title: Text('TRANSACTION EXPIRED', style: TextStyle(color: eventajaGreenTeal)),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(child: SizedBox(),),
            Container(
              height: ScreenUtil.instance.setWidth(250),
              width: ScreenUtil.instance.setWidth(250),
              child: Image.asset('assets/failed-transaction.png'),
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(20),
            ),
            Text('TRANSACTION EXPIRED', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
            SizedBox(
              height: ScreenUtil.instance.setWidth(20),
            ),
            Expanded(child: SizedBox(),),
          ],
        ),
      ),
    );
  }
}
