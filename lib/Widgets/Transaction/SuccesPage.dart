import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SuccessPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SuccessPageState();
  }
}

class SuccessPageState extends State<SuccessPage> {
  @override
  Widget build(BuildContext context) {
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
        title: Text('PAYMENT SUCCESS', style: TextStyle(color: eventajaGreenTeal)),
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
            Text('INV/XXXX/XXX/XXXX/XXX', style: TextStyle(color: eventajaGreenTeal, fontSize: 18, fontWeight: FontWeight.bold),),
            SizedBox(
              height: 15,
            ),
            Text('PAYMENT SUCCESS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: (){
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                  builder: ( BuildContext context) => ProfileWidget(initialIndex: 1,)
                ), ModalRoute.withName('/Dashboard'));
              },
              child: Container(
                height: 50,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: eventajaGreenTeal,
                ),
                child: Center(
                  child: Text('VIEW MY TICKETS', style: TextStyle(color: Colors.white, fontSize: 18),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
