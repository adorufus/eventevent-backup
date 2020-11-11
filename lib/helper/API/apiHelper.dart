import 'dart:core';

import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/helper/API/registerModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

Future<http.Response> getWowzaLivestreamState(String streamingId) async {
  final response = await http.get(
    BaseApi.wowzaUrl + 'live_streams/$streamingId/state',
    headers: {
      'wsc-api-key': WOWZA_API_KEY,
      'wsc-access-key': WOWZA_ACCESS_KEY,
      'Content-Type': 'application/json'
    },
  );

  print("FETCHING CURRENT LIVESTREAM STATE, PLEASE WAIT.....");
  print(
      "WOWZA RESPONSE: ${response.body} WITH STATUS CODE: ${response.statusCode}");

  return response;
}

Future<http.Response> getWatchLivestreamToken(String eventId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String url = BaseApi().apiUrl + '/signin/login?=';

  final response = await http.post(
    url,
    body: {
      'username': prefs.getString('UserUsername'),
      'password': prefs.getString('UserPw'),
      'streaming_event_id': eventId,
      'X-API-KEY': API_KEY
    },
    headers: {
      'Authorization': AUTHORIZATION_KEY,
    }
  );

  return response;
}

Future<http.Response> getEventStreamingDetail(String token) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String url = BaseApi().apiUrl + '/event/streaming_detail?X-API-KEY=$API_KEY&streaming_token=$token';

  final response = await http.get(
    url,
    headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    }
  );

  return response;
}

Future<http.Response> getMerchTransactionDetail(String transactionId, bool isSeller) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String url = BaseApi().apiUrl + '/transaction/detail_transaction?X-API-KEY=$API_KEY&transaction_id=$transactionId${isSeller == true ? '&is_seller=true' : ''}';

  print(url);
  final response = await http.get(
    url,
    headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString("Session")
    }
  );

  return response;
}