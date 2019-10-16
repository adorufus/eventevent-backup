import 'dart:convert';

import 'package:eventevent/Widgets/AfterRegister.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/API/registerModel.dart';
import 'package:eventevent/helper/sharedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/API/apiHelper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterWidgetState();
  }
}

class _RegisterWidgetState extends State<RegisterWidget> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
        padding:
            EdgeInsetsDirectional.only(start: 15, bottom: 10, end: 15, top: 5),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            backEvent();
          },
          child: Icon(Icons.arrow_back, color: eventajaGreenTeal),
        ),
        middle: Text(
          'Register',
          style: TextStyle(fontSize: 20, color: eventajaGreenTeal),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 40, right: 40, top: 45),
            child: Material(
              color: Colors.white,
              child: registerForm(),
            ),
          )
        ],
      ),
    );
  }

  bool backEvent() {
    return Navigator.pop(context);
  }

  Widget registerForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextFormField(
          controller: _usernameController,
          keyboardType: TextInputType.text,
          autofocus: false,
          onEditingComplete: (){
            checkUsername(_usernameController.text).then((response){
              var extractedData = json.decode(response.body);
              if(extractedData['status'] == 'NOK'){
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(extractedData['desc'], style: TextStyle(color: Colors.white)),
                  duration: Duration(seconds: 2),
                ));
              }
            });
          },
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Username',
              border: InputBorder.none),
        ),
        SizedBox(
          height: 15,
        ),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.text,
          autofocus: false,
          onEditingComplete: (){
            checkEmail(_emailController.text).then((response){
              var extractedData = json.decode(response.body);
              if(extractedData['status'] == 'NOK'){
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(extractedData['desc'], style: TextStyle(color: Colors.white)),
                  duration: Duration(seconds: 2),
                ));
              }
            });
          },
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Email',
              border: InputBorder.none),
        ),
        SizedBox(
          height: 15,
        ),
        TextFormField(
          controller: _passwordController,
          keyboardType: TextInputType.text,
          autofocus: false,
          obscureText: true,
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Password',
              border: InputBorder.none),
        ),
        SizedBox(height: 15),
        ButtonTheme(
          minWidth: 500,
          height: 50,
          child: RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Text('Register',
                style: TextStyle(fontSize: 15, color: Colors.white)),
            color: eventajaGreenTeal,
            onPressed: () {
              Pattern pattern =
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regex = new RegExp(pattern);
              if (_usernameController.text.length == 0 ||
                  _usernameController.text == null ||
                  _emailController.text.length == 0 ||
                  _passwordController.text.length == 0) {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    'Please check your input',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ));
              } else if (!regex.hasMatch(_emailController.text)) {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    'Invalid Email Format',
                    style: TextStyle(color: Colors.white),
                  ),
                ));
              } else if (_passwordController.text.length < 8) {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    'Password at least 8 characters',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AfterRegister(
                  username: _usernameController.text,
                  email: _emailController.text,
                  password: _passwordController.text
                )));
              }
            },
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Divider(
          height: 15,
        )
      ],
    );
  }

  Future<http.Response> checkUsername(String username) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/signup/check_username?username=$username&X-API-KEY=$API_KEY';

    final response = await http.get(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
      }
    );

    return response;
  }

  Future<http.Response> checkEmail(String email) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/signup/check_email?email=$email&X-API-KEY=$API_KEY';

    final response = await http.get(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
      }
    );

    return response;
  }
}
