import 'dart:convert';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/API/registerModel.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/sharedPreferences.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:eventevent/helper/ClevertapHandler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class RegisterFacebook extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterFacebookState();
  }
}

class RegisterFacebookState extends State<RegisterFacebook> {

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
    getFbUserProfile();
  }
  
  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
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
          title: Text('COMPLETE YOUR PROFILE', style: TextStyle(color: eventajaGreenTeal))),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: registerFbWidget()
          )
        ],
      ),
    );
  }

  Widget registerFbWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: ScreenUtil.instance.setWidth(10),),
        GestureDetector(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(
                  profilePictureURI
                ),
              ),
              SizedBox(height: ScreenUtil.instance.setWidth(10),),
              Text('Tap to change / edit photo')
            ]
          )
        ),
        SizedBox(height: ScreenUtil.instance.setWidth(15),),
        TextFormField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: 'Username',
            icon: Image.asset('assets/drawable/username.png', scale: 2,),
          ),
        ),
        SizedBox(height: ScreenUtil.instance.setWidth(15),),
        TextFormField(
          controller: birthdateController,
          decoration: InputDecoration(
            hintText: 'Birth Date',
            icon: Image.asset('assets/drawable/cake.png', scale: 5,)
          ),
        ),
        SizedBox(height: ScreenUtil.instance.setWidth(15),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState(() => currentValue = i),
              value: 0,
            ),
            Text('Male'),
            SizedBox(width: ScreenUtil.instance.setWidth(30)),
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState(() => currentValue = i),
              value: 1,
            ),
            Text('Female'),
            SizedBox(width: ScreenUtil.instance.setWidth(30)),
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState(() => currentValue = i),
              value: 2,
            ),
            Text('Other')
          ],
        ),
        SizedBox(height: ScreenUtil.instance.setWidth(15),),
        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(
            hintText: '(Phone, e.g. 0818123456)',
            icon: Icon(CupertinoIcons.phone_solid, color: Colors.grey, size: 25,),

          ),
        ),
        SizedBox(height: ScreenUtil.instance.setWidth(15),),
        TextFormField(
          controller: passwordController,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          obscureText: isPasswordObsecure,
          decoration: InputDecoration(
            hintText: 'Password',
            icon: Image.asset('assets/drawable/password.png', scale: 2.5,),
            suffixIcon: GestureDetector(
              onTap: (){
                setState(() {
                  isPasswordObsecure = !isPasswordObsecure;
                });
                print(isPasswordObsecure.toString());
              },
              child: Image.asset('assets/drawable/show-password.png', scale: 3,),
            )
          ),
        ),
        SizedBox(height: ScreenUtil.instance.setWidth(15),),
        GestureDetector(
          onTap: (){
            postRegister();
          },
                  child: Container(
            height: ScreenUtil.instance.setWidth(50),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: eventajaGreenTeal,
              borderRadius: BorderRadius.circular(30)
            ),
            child: Center(
              child: Text('DONE', style: TextStyle(fontSize: ScreenUtil.instance.setSp(18) ,color: Colors.white, fontWeight: FontWeight.bold),)
            ),
          ),
        )
      ],
    );
  }

  void getFbUserProfile() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState((){
      profilePictureURI = preferences.getString('REGIS_FB_PHOTO');
      birthDate = preferences.getString('REGIS_FB_BIRTH_DATE');
      birthdateController.text = birthDate;
      if(currentValue != null){
        if(preferences.getString('REGIS_FB_GENDER') == 'male'){
          currentValue = 0;
          gender = 'Male';
        }
        else if(preferences.getString('REGIS_FB_GENDER') == 'female'){
          currentValue = 1;
          gender = 'Female';
        }
        else{
          currentValue = 2;
          gender = 'Other';
        }
      }
    });
    print(profilePictureURI);
  }

  Future<Register> postRegister() async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/signup/register';

    final response = await http.post(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY
      },
      body: {
        'X-API-KEY': API_KEY,
        'email': preferences.getString('REGIS_FB_EMAIL'),
        'password': passwordController.text,
        'fullName': preferences.getString('REGIS_FB_FULLNAME'),
        'gender': gender,
        'username': usernameController.text,
        'phone': phoneController.text,
        'isLoginFacebook': '1',
        'facebookID': preferences.getString('REGIS_FB_ID'),
        'photo': profilePictureURI,
        'lastName': preferences.getString('REGIS_FB_LAST_NAME'),
        'register_device': Platform.isIOS ? 'IOS' : 'android'
      }
    );

    if(response.statusCode == 201){
      final responseJson = json.decode(response.body);
      ClevertapHandler.pushUserProfile(responseJson['data']['fullName'], responseJson['data']['lastName'], responseJson['data']['email'], responseJson['data']['pictureNormalURL'], responseJson['data']['birthday'] == null ? '-' : responseJson['data']['birthday'], responseJson['data']['username'], responseJson['data']['gender'], responseJson['data']['phone']);
      preferences.setString('Session', response.headers['set-cookie']);
      SharedPrefs().saveCurrentSession(responseJson);
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => DashboardWidget(isRest: false,)));
      return Register.fromJson(responseJson);
    }
    else{
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
