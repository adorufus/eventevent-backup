import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GiveFeedback extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GiveFeedbackState();
  }
}

class GiveFeedbackState extends State<GiveFeedback> {
  TextEditingController feedbackController = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: appBarColor,
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
          'FEEDBACK',
          style: TextStyle(color: eventajaGreenTeal),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              postFeedback();
            },
            child: Center(
              child: Text(
                'Submit',
                style: TextStyle(
                    color: eventajaGreenTeal,
                    fontSize: ScreenUtil.instance.setSp(18)),
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil.instance.setWidth(20),
          )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: TextFormField(
            controller: feedbackController,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white),
          ),
        ),
      ),
    );
  }

  Future postFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/feedback/post';

    final response = await http.post(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'comment': feedbackController.text
    });

    print(response.statusCode);
    print(response.body);

    var extractedData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Feedback submited, thank you',
        backgroundColor: eventajaGreenTeal,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    } else {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: extractedData['desc'],
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }
  }
}
