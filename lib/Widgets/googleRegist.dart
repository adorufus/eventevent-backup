import 'dart:convert';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/API/registerModel.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/sharedPreferences.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:googleapis/people/v1.dart';

class GoogleRegisterStart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GoogleRegisterState();
  }
}

class GoogleRegisterState extends State<GoogleRegisterStart> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var usernameController = new TextEditingController();
  var phoneController = new TextEditingController();
  var passwordController = new TextEditingController();
  var birthdateController = new TextEditingController();

  String profilePictureURI;
  String birthDate;
  String gender;

  int currentValue = 0;

  bool isPasswordObsecure = true;

  @override
  void initState() {
    super.initState();
    getGoogleUserProfile();
  }

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
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
          elevation: 0,
          backgroundColor: Colors.white,
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
          title: Text('COMPLETE YOUR PROFILE',
              style: TextStyle(color: eventajaGreenTeal))),
      body: ListView(
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: registerGoogleWidget())
        ],
      ),
    );
  }

  Widget registerGoogleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: ScreenUtil.instance.setWidth(10),
        ),
        GestureDetector(
            child: Column(children: <Widget>[
          CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(profilePictureURI),
          ),
          SizedBox(
            height: ScreenUtil.instance.setWidth(10),
          ),
          Text('Tap to change / edit photo')
        ])),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: 'Username',
            icon: Image.asset(
              'assets/drawable/username.png',
              scale: 2,
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: birthdateController,
          decoration: InputDecoration(
              hintText: 'Birth Date',
              icon: Image.asset(
                'assets/drawable/cake.png',
                scale: 5,
              )),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState(() {
                currentValue = i;
                gender = 'Male';
              }),
              value: 0,
            ),
            Text('Male'),
            SizedBox(width: ScreenUtil.instance.setWidth(30)),
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState(() {
                currentValue = i;
                gender = 'Female';
              }),
              value: 1,
            ),
            Text('Female'),
            SizedBox(width: ScreenUtil.instance.setWidth(30)),
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState(() {
                currentValue = i;
                gender = 'Other';
              }),
              value: 2,
            ),
            Text('Other')
          ],
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(
            hintText: '(Phone, e.g. 0818123456)',
            icon: Icon(
              CupertinoIcons.phone_solid,
              color: Colors.grey,
              size: 25,
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: passwordController,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          obscureText: isPasswordObsecure,
          decoration: InputDecoration(
              hintText: 'Password',
              icon: Image.asset(
                'assets/drawable/password.png',
                scale: 2.5,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    isPasswordObsecure = !isPasswordObsecure;
                  });
                  print(isPasswordObsecure.toString());
                },
                child: Image.asset(
                  'assets/drawable/show-password.png',
                  scale: 3,
                ),
              )),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        GestureDetector(
          onTap: () {
            postRegister().catchError((e) {
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                message: e.toString(),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
                animationDuration: Duration(milliseconds: 500),
              )..show(context);
            });
          },
          child: Container(
            height: ScreenUtil.instance.setWidth(50),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: eventajaGreenTeal,
                borderRadius: BorderRadius.circular(30)),
            child: Center(
                child: Text(
              'DONE',
              style: TextStyle(
                  fontSize: ScreenUtil.instance.setSp(18),
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )),
          ),
        )
      ],
    );
  }

  void getGoogleUserProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      profilePictureURI = preferences.getString('REGIS_GOOGLE_PHOTO');
      // birthDate = preferences.getString('REGIS_GOOGLE_BIRTH_DATE');
      //birthdateController.text = birthDate;
      currentValue = 0;
    });
    print(profilePictureURI);
  }

  Future<Register> postRegister() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/signup/register';

    Map<String, dynamic> body = {
      'X-API-KEY': API_KEY,
      'email': preferences.getString('REGIS_GOOGLE_EMAIL'),
      'password': passwordController.text,
      'fullName': preferences.getString('REGIS_GOOGLE_NAME'),
      'gender': gender,
      'username': usernameController.text,
      'phone': phoneController.text,
      'photo': profilePictureURI,
      'lastName': 'test',
      'register_device': Platform.isIOS ? 'IOS' : 'android'
    };

    final response = await http.post(url,
        headers: {'Authorization': AUTHORIZATION_KEY}, body: body);

    if (response.statusCode == 201) {
      final responseJson = json.decode(response.body);
      preferences.setString('Session', response.headers['set-cookie']);
      SharedPrefs().saveCurrentSession(responseJson);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DashboardWidget(isRest: false,)));
      return Register.fromJson(responseJson);
    } else if (response.statusCode == 400) {
      final responseJson = json.decode(response.body);
      print(responseJson['desc']);
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: responseJson['desc'],
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }
  }
}
