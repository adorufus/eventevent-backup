import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
        backgroundColor: checkForBackgroundColor(context),
        key: thisScaffold,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: appBarColor,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
            ),
          ),
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
                    style: TextStyle(
                        color: eventajaGreenTeal,
                        fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                ),
              ),
            )
          ],
        ),
        body: Container(
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
                        color: checkForAppBarTitleColor(context),
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
                height: ScreenUtil.instance.setWidth(150),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 50, left: 35),
                child: TextField(
                  onSubmitted: (value) {
                    navigateToNextStep();
                  },
                  style: TextStyle(color: checkForTextTitleColor(context)),
                  controller: textController,
                  autocorrect: false,
                  autofocus: false,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  // inputFormatters: [
                  //   // WhitelistingTextInputFormatter.digitsOnly,
                  //   // TextFieldFormatPrice(),
                  // ],
                  onChanged: (string) {
                    string = NumberFormat.decimalPattern().format(
                      int.parse(string.replaceAll(',', '')),
                    );
                    textController.value = TextEditingValue(
                      text: string,
                      selection: TextSelection.collapsed(offset: string.length),
                    );
                  },
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: checkForAppBarTitleColor(context)
                      )
                    ),
                    hintStyle: TextStyle(color: checkForTextTitleColor(context)),
                    hintText: 'enter your ticket price',
                  ),
                ),
              )
            ],
          ),
        ));
  }

  navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (textController.text == null ||
        textController.text == '' ||
        textController.text == ' ') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Input ticket price!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      prefs.setString(
          'SETUP_TICKET_PRICE', textController.text.replaceAll(",", ""));
      print(prefs.getString('SETUP_TICKET_PRICE'));
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) => CreateTicketStartDate()));
    }
  }
}
