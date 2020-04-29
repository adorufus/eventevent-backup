import 'dart:core';

import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/helper/API/registerModel.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      BaseApi.wowzaUrl +
          'live_streams/$streamingId/state',
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

