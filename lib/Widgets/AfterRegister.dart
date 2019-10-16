import 'dart:convert';
import 'dart:io';

import 'package:eventevent/helper/API/apiHelper.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/API/registerModel.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/sharedPreferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'dashboardWidget.dart';

class AfterRegister extends StatefulWidget {
  final username;
  final email;
  final password;

  const AfterRegister({Key key, this.username, this.email, this.password}) : super(key: key);

  @override
  _AfterRegisterState createState() => _AfterRegisterState();
}

class _AfterRegisterState extends State<AfterRegister> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var usernameController = new TextEditingController();
  var phoneController = new TextEditingController();
  var passwordController = new TextEditingController();
  var birthdateController = new TextEditingController();
  var firstNameController = new TextEditingController();
  var lastNameController = new TextEditingController();

  File profilePictureFile;
  String profilePictureURI = 'fa';
  int currentValue = 0;
  String birthDate;
  String gender = 'Male';

  bool isPasswordObsecure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              // googleSignIn.signOut();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
            ),
          ),
          centerTitle: true,
          title: Text('COMPLETE YOUR PROFILE', style: TextStyle(color: eventajaGreenTeal))),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: registerGoogleWidget()
          )
        ],
      ),
    );
  }

  Widget registerGoogleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10,),
        GestureDetector(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(
                  profilePictureURI
                ),
              ),
              SizedBox(height: 10,),
              Text('Tap to change / edit photo')
            ]
          )
        ),
        SizedBox(height: 15,),
        TextFormField(
          controller: firstNameController,
          decoration: InputDecoration(
            hintText: 'First Name',
          ),
        ),
        SizedBox(height: 15,),
        TextFormField(
          controller: lastNameController,
          decoration: InputDecoration(
            hintText: 'Last Name',
          ),
        ),
        SizedBox(height: 15,),
        TextFormField(
          controller: birthdateController,
          decoration: InputDecoration(
            hintText: 'Birth Date',
          ),
        ),
        SizedBox(height: 15,),
        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(
            hintText: '(Phone, e.g. 0818123456)',
          ),
        ),
        SizedBox(height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState((){
                currentValue = i;
                gender = 'Male';
              }),
              value: 0,
            ),
            Text('Male'),
            SizedBox(width: 30),
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState((){
                currentValue = i;
                gender = 'Female';
              }),
              value: 1,
            ),
            Text('Female'),
            SizedBox(width: 30),
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState((){
                currentValue = i;
                gender = 'Other';
              }),
              value: 2,
            ),
            Text('Other')
          ],
        ),
        SizedBox(height: 15,),
        GestureDetector(
          onTap: (){
            requestRegister(
              context,
              widget.username,
              widget.email,
              widget.password,
              firstNameController.text,
              lastNameController.text,
              birthdateController.text,
              phoneController.text,
              gender,
              _scaffoldKey
            )
            .catchError((e){
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ));
            });
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: eventajaGreenTeal,
              borderRadius: BorderRadius.circular(30)
            ),
            child: Center(
              child: Text('DONE', style: TextStyle(fontSize: 18 ,color: Colors.white, fontWeight: FontWeight.bold),)
            ),
          ),
        )
      ],
    );
  }

  Future<Register> requestRegister(
      BuildContext context,
      String username,
      String email,
      String password,
      String fullName,
      String lastName,
      String birthDay,
      String phoneNumber,
      String genderSpec,
      GlobalKey<ScaffoldState> _scaffoldKey) async {
        SharedPreferences prefs =await SharedPreferences.getInstance();
    final registerApiUrl = BaseApi().apiUrl + '/signup/register';

    print(username);
    print(email);
    print(password);
    print(fullName);
    print(lastName);
    print(birthDay);
    print(phoneNumber);
    print(genderSpec);

    Map<String, String> body = {
      'username': username,
      'email': email,
      'password': password,
      'gender': genderSpec,
      'fullName': fullName,
      'lastName': lastName,
      'birthDay': birthDay,
      'phone': phoneNumber,
      'X-API-KEY': apiKey,
      'pictureAvatarURL': "male.jpg"
    };

    final response = await http.post(registerApiUrl,
        body: body, headers: {'Authorization': "Basic YWRtaW46MTIzNA=="});

    print(response.statusCode);
    final myResponse = json.decode(response.body);

    if (response.statusCode == 201) {
      setState(() {
        prefs.setString('Session', response.headers['set-cookie']);
      });
      Map responseJson;

      setState(() {
        responseJson = jsonDecode(response.body);
      });

      SharedPrefs().saveCurrentSession(response, responseJson);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DashboardWidget()));
      return Register.fromJson(responseJson);
    } else if (response.statusCode == 400) {
      final responseJson = json.decode(response.body);
      //Register registerModel = new Register.fromJson(responseJson);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        content: Text(
          responseJson['desc'],
          style: TextStyle(color: Colors.white),
        ),
      ));
    } else if (myResponse.containsKey('username')) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        content: Text(
          'Username already taken',
          style: TextStyle(color: Colors.white),
        ),
      ));
    }
  }
}