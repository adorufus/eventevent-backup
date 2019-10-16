import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: Colors.white.withOpacity(0.95),
      appBar: AppBar(
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
            Container(
              height: 250,
              width: 250,
              child: Image.asset('assets/drawable/success.png'),
            ),
            SizedBox(
              height: 20,
            ),
            Text('TRANSACTION EXPIRED', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
