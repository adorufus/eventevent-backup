import 'package:eventevent/Widgets/PostEvent/CreateTicketPicture.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CreateTicketQty.dart';

class CreateTicketDescription extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateTicketDescriptionState();
  }
}

class CreateTicketDescriptionState extends State<CreateTicketDescription> {
  var textController = new TextEditingController();
  var thisScaffold = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Ticket Description',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 40,
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
                  height: ScreenUtil.instance.setWidth(50),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '*Required',
                            style: TextStyle(color: Colors.red),
                          )),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(20),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Description',
                              style: TextStyle(
                                  color: eventajaGreenTeal,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(20),
                      ),
                      TextFormField(
                        maxLines: 10,
                        onFieldSubmitted: (value) {
                          navigateToNextStep();
                        },
                        controller: textController,
                        autocorrect: false,
                        autofocus: false,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            fillColor: Colors.grey[200],
                            filled: true,
                            hintText: 'enter your ticket description',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8))),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (textController.text == null ||
        textController.text == '' ||
        textController.text == ' ') {
      thisScaffold.currentState.showSnackBar(SnackBar(
        content: Text('Input ticket description!'),
        backgroundColor: Colors.red,
      ));
    } else {
      prefs.setString('SETUP_TICKET_DESCRIPTION', textController.text);
      print(prefs.getString('SETUP_TICKET_DESCRIPTION'));
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) => CreateTicketPicture()));
    }
  }
}
