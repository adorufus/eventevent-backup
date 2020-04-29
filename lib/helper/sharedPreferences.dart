import 'package:eventevent/helper/API/registerModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:eventevent/helper/API/loginModel.dart';
import 'dart:io'; import 'package:flutter_screenutil/flutter_screenutil.dart';

class SharedPrefs{
  saveCurrentSession(Map responseJson) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var id;
    var username;
    var cookie;
    var profilePicture;

    if(responseJson != null && responseJson.isNotEmpty){
      id = LoginModel.fromJson(responseJson).data.id;
      username = LoginModel.fromJson(responseJson).data.username;
      profilePicture = Register.fromJson(responseJson).data.pictureAvatarUrl;
    }
    else{
      id = null;      
    }
    
    await preferences.setString('Last User ID', (id != null) ? id : null);
    await preferences.setString('Last Username', (username != null) ? username : null);
    await preferences.setString('ProfilePicture', (profilePicture != null && profilePicture.length > 0) ? profilePicture : "");
  }

  sharedPreferences(String ticket_price_total, int ticketCount) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setString('ticket_price_total', ticket_price_total);
    await preferences.setInt('ticketCount', ticketCount);
  }
}