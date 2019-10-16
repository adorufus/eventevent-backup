import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CreateTicketStartDate.dart';

class CreateTicketPrice extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateTicketPriceState();
  }
}

class CreateTicketPriceState extends State<CreateTicketPrice> {
  var textController = new TextEditingController();
  var thisScaffold = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(color: eventajaGreenTeal, fontSize: 18),
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
                    'Ticket Price',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Divider(
                  color: Colors.grey,
                  height: 10,
                ),
              ),
              SizedBox(
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 50, left: 35),
                child: TextFormField(
                  onFieldSubmitted: (value) {
                    navigateToNextStep();
                  },
                  controller: textController,
                  autocorrect: false,
                  autofocus: false,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'enter your ticket price',
                  ),
                ),
              )
            ],
          ),
        ));
  }

  navigateToNextStep() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (textController.text == null || textController.text == '' || textController.text == ' ') {
      thisScaffold.currentState.showSnackBar(SnackBar(
        content: Text('Input ticket price!'),
        backgroundColor: Colors.red,
      ));
    } else {
      prefs.setString('SETUP_TICKET_PRICE', textController.text);
      print(prefs.getString('SETUP_TICKET_PRICE'));
      Navigator.push(context,
          CupertinoPageRoute(builder: (BuildContext context) => CreateTicketStartDate()));
    }
  }
}