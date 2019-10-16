import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChangePassword extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChangePasswordState();
  }
}

class ChangePasswordState extends State<ChangePassword>{

  GlobalKey<ScaffoldState> thisScaffold = new GlobalKey<ScaffoldState>();

  TextEditingController currentPasswordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: thisScaffold,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('CHANGE PASSWORD', style: TextStyle(color: eventajaGreenTeal),),
        leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,)),
        actions: <Widget>[
          Center(
            child: GestureDetector(
              onTap: (){
                FocusScope.of(context).unfocus();
                postChangePassword();
              },
              child: Text('Save', style: TextStyle(color: eventajaGreenTeal, fontSize: 18),),
            ),
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
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
                  prefixIcon: Icon(Icons.lock, color: Colors.grey,),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  prefixStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'New Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey,),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  prefixStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey,),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  prefixStyle: TextStyle(color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future postChangePassword() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/password/change';

    if(currentPasswordController.text == null || currentPasswordController.text == '' || currentPasswordController.text == ' '){
      thisScaffold.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Current Password cannot be empty!'),
      ));
    }
    else if(newPasswordController.text == null || newPasswordController.text == '' || newPasswordController.text == ' '){
      thisScaffold.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('New password cannot be empty!'),
      ));
    }
    else if(confirmPasswordController.text != newPasswordController.text){
      thisScaffold.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('New password didn\'t match!'),
      ));
    }
    else if(confirmPasswordController.text == null || confirmPasswordController.text == '' || confirmPasswordController.text == ' '){
      thisScaffold.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Confirm password cannot be empty!'),
      ));
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': prefs.getString('Session')
      },
      body: {
        'X-API-KEY': API_KEY,
        'old_password': currentPasswordController.text,
        'new_password': newPasswordController.text
      }
    );

    var extractedData = json.decode(response.body);

    if(response.statusCode == 200){
      print('berhasil: ' + response.body);
      thisScaffold.currentState.showSnackBar(SnackBar(
        backgroundColor: eventajaGreenTeal,
        content: Text(extractedData['desc']),
      ));
      Future.delayed(Duration(seconds: 3), (){
        Navigator.of(context).pop();
      });

    }
    else if(response.statusCode == 400 && extractedData['desc'] == "Wrong current password"){
      thisScaffold.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Wrong current password!'),
      ));
    }
  }
}