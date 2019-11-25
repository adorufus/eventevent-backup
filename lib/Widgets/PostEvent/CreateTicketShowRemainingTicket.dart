import 'package:eventevent/Widgets/PostEvent/CreateTicketOnePurchase.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CreateTicketPrice.dart';

class CreateTicketShowRemainingTicket extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateTicketShowRemainingTicketState();
  }
}

class CreateTicketShowRemainingTicketState extends State<CreateTicketShowRemainingTicket> {
  var textController = new TextEditingController();
  var thisScaffold = new GlobalKey<ScaffoldState>();

  int __curValue = 0;

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
        key: thisScaffold,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // leading: GestureDetector(
          //   onTap: (){
          //     Navigator.popUntil(context, ModalRoute.withName('/Dashboard'));
          //   },
          //   child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
          // ),
          centerTitle: true,
          title: Text(
            'CREATE TICKET',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    navigateToNextStep();
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                ),
              ),
            )
          ],
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 15, top: 15),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Show Remaining Ticket',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(25),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(20),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Divider(
                  color: Colors.grey,
                  height: ScreenUtil.instance.setWidth(10),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(150),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 29, left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Radio(
                      groupValue: __curValue,
                      onChanged: (int i) => setState(() => __curValue = i),
                      value: 1,
                    ),
                    Text('Yes'),
                    SizedBox(width: ScreenUtil.instance.setWidth(25),),
                    Radio(
                      groupValue: __curValue,
                      onChanged: (int i) => setState((){
                        __curValue = i;
                        print(MaterialTapTargetSize.values);
                      }),
                      value: 0,
                    ),
                    Text('No')
                  ],
                )
              )
            ],
          ),
        ));
  }

  navigateToNextStep() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (__curValue == null) {
      thisScaffold.currentState.showSnackBar(SnackBar(
        content: Text('Choose at least one option', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
      ));
    } else {
      prefs.setString('SETUP_TICKET_SHOW_REMAINING_TICKET', __curValue.toString());
      print(prefs.getString('SETUP_TICKET_SHOW_REMAINING_TICKET'));
      Navigator.push(context,
          CupertinoPageRoute(builder: (BuildContext context) => CreateTicketOnePurchase()));
    }
  }
}