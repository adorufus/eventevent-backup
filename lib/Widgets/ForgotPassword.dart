import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPassword> {
  var _usernameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
            child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal)),
        centerTitle: true,
        title: Text(
          'LOGIN HELP',
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 50),
        child: ListView(
          children: <Widget>[
            Center(
                child: Column(
              children: <Widget>[
                Text(
                  'FIND YOUR ACCOUNT',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.5)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Enter your username or the email address associated with your account.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                )
              ],
            )),
            SizedBox(
              height: 20,
            ),
            TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Image.asset(
                    'assets/drawable/username.png',
                    scale: 2,
                  ),
                  hintText: 'Email / Username',
                )),
            SizedBox(height: 50),
            GestureDetector(
              onTap: (){
                requestForgotPassword(_usernameController.text);
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: eventajaGreenTeal),
                child: Center(
                    child: Text('SEARCH',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future requestForgotPassword(String username) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/forgot/password';
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session'),
      },
      body: {
        'X-API-KEY': API_KEY,
        'username': username
      }
    );

    print(response.statusCode);
    print(response.body);

    if(response.statusCode == 201){
      var extractedData = json.decode(response.body);
      Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => SuccessResetPassword(username: username,)
      ));
    }
  }
}

class SuccessResetPassword extends StatelessWidget{
  final username;

  const SuccessResetPassword({Key key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal)
        ),
        title: Text('RESET PASSWORD', style: TextStyle(color: eventajaGreenTeal),),
        centerTitle: true
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 35),
        child: Center(
          child: Text('Hi $username, an email has been set to your account\'s email address, Please check your email to continue', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
        ),
      ),
    );
  }
}
