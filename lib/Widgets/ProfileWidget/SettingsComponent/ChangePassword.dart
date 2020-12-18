import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChangePassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChangePasswordState();
  }
}

class ChangePasswordState extends State<ChangePassword> {
  GlobalKey<ScaffoldState> thisScaffold = new GlobalKey<ScaffoldState>();

  TextEditingController currentPasswordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

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
      key: thisScaffold,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'CHANGE PASSWORD',
          style: TextStyle(color: eventajaGreenTeal),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
            )),
        actions: <Widget>[
          Center(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                postChangePassword();
              },
              child: Text(
                'Save',
                style: TextStyle(
                    color: eventajaGreenTeal,
                    fontSize: ScreenUtil.instance.setSp(18)),
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil.instance.setWidth(15),
          )
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Current Password',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.grey,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  prefixStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(30),
              ),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'New Password',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.grey,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  prefixStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.grey,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  prefixStyle: TextStyle(color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future postChangePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/password/change';

    if (currentPasswordController.text == null ||
        currentPasswordController.text == '' ||
        currentPasswordController.text == ' ') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Current password cannot be empty!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else if (newPasswordController.text == null ||
        newPasswordController.text == '' ||
        newPasswordController.text == ' ') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'New password cannot be empty!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else if (confirmPasswordController.text != newPasswordController.text) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'New password didn\'t match!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else if (confirmPasswordController.text == null ||
        confirmPasswordController.text == '' ||
        confirmPasswordController.text == ' ') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Confirm password cannot be empty!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }

    final response = await http.post(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'old_password': currentPasswordController.text,
      'new_password': newPasswordController.text
    });

    var extractedData = json.decode(response.body);

    if (response.statusCode == 200) {
      print('berhasil: ' + response.body);
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: extractedData['desc'],
        backgroundColor: eventajaGreenTeal,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop();
      });
    } else if (response.statusCode == 400 &&
        extractedData['desc'] == "Wrong current password") {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Wrong current password!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }
  }
}
