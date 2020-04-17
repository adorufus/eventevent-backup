import 'dart:io';

import 'package:eventevent/Models/PopularEventModel.dart';
import 'package:dio/dio.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventListProviders {

  final String _endpoints = BaseApi().apiUrl;
  final Dio _dio = Dio();

  Future<PopularEventModel> getPopularEvent(bool isRest, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Cookie cookie = Cookie.fromSetCookieValue(preferences.getString('Session'));

    Map<String, dynamic> headerType;

    if(isRest == true){
      headerType = {
        'Authorization': AUTHORIZATION_KEY,
        'signature': SIGNATURE
      };
    }
    else if(isRest == false){
      headerType = {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session')
      };
    }

    try {
      Response response = await _dio.get(
        _endpoints + '/event/popular?X-API-KEY=$API_KEY&page=1&total=20',
        options: Options(
          headers: headerType,
          responseType: ResponseType.json,
        ),
      );

      print(response.data);

      return PopularEventModel.fromJson(response.data);

    } on DioError catch (error) {
      Flushbar(
        message: error.message,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        animationDuration: Duration(milliseconds: 500),
      ).show(context);
    }

    return null;
  }
}
