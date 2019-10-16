import 'dart:core';

import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/helper/API/registerModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'baseApi.dart';
import 'dart:async';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/sharedPreferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

final String apiKey = '47d32cb10889cbde94e5f5f28ab461e52890034b';

String cookies = '';

GoogleSignIn googleSignIn = new GoogleSignIn();



requestLogout(BuildContext context) async {
  final logoutApiUrl = BaseApi().apiUrl + '/signout';

  Map<String, String> body = {
    'X-API-KEY': apiKey
  };

  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  final response = await http.post(
    logoutApiUrl,
    body: body,
    headers: {'Authorization': "Basic YWRtaW46MTIzNA==", 'cookie': prefs.getString('Session')}
  );

  print(response.statusCode);

  if(prefs.getBool('isUsingGoogle') == true){
    googleSignIn.signOut();
  }

  if(response.statusCode == 200){
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginRegisterWidget()), (Route<dynamic> route) => false);
    prefs.clear();
    print(prefs.getKeys());
  }
}