import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FollowUnfollow{
  Future follow(String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String session = prefs.getString('Session');

    String url = BaseApi().apiUrl + '/user/follow?X-API-KEY=$API_KEY&userID=$userID';

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Basic YWRtaW46MTIzNA==',
        'cookie': session
      }
    );

    print(response.statusCode);
    print(response.body);
  }

  Future unfollow(String userID) async {
    String url = BaseApi().apiUrl + '/user/unfollow?X-API-KEY=$API_KEY&userID=$userID';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String session = prefs.getString('Session');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Basic YWRtaW46MTIzNA==',
        'cookie': session
      }
    );

    print(response.statusCode);
    print(response.body);
  }
}