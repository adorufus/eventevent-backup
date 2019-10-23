import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class UseTicketSuccess extends StatefulWidget {
  final eventName;

  const UseTicketSuccess({Key key, this.eventName}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return UseTicketSuccessState();
  }
}

class UseTicketSuccessState extends State<UseTicketSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      
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
            Text('Congratulation', style: TextStyle(color: eventajaGreenTeal, fontSize: 18, fontWeight: FontWeight.bold),),
            SizedBox(
              height: 15,
            ),
            Text('YOU ARE CHECKED IN TO ${widget.eventName}', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
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
                  child: Text('OK', style: TextStyle(color: Colors.white, fontSize: 18),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
