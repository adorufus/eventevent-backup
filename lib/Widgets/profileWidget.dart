import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/Widgets/editProfileWidget.dart';
import 'package:eventevent/helper/API/apiHelper.dart';
import 'package:eventevent/helper/ClevertapHandler.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:eventevent/helper/API/profileModel.dart';
import 'package:http/http.dart' as http;
import 'package:eventevent/helper/API/apiHelper.dart' as apiHelper;
import 'package:shared_preferences/shared_preferences.dart';
import 'ProfileWidget/profileHeader.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:http/http.dart' as http;

class ProfileWidget extends StatefulWidget {
  final initialIndex;
  final userId;

  const ProfileWidget({Key key, this.initialIndex, this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileWidgetState();
  }
}

class _ProfileWidgetState extends State<ProfileWidget> {

  String fullName;
  String firstName;
  String username;
  String pictureUri;
  String userId;
  String email;
  String phone;
  String website;
  String eventCreated;
  String eventGoing;
  String follower;
  String following;
  String lastName;
  String bio;
  String isVerified;
  String isFollowing;

  List userData;

  @override
  void initState() {
    super.initState();
    if (!mounted) {
      return;
    } else {
      print(widget.userId);
      initializeClevertap();
      getUserProfileData();
    }
  }

  void initializeClevertap() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if(widget.userId == preferences.getString("Last User ID")){
      ClevertapHandler.logPageView("Self-Profile");
    } else {
      ClevertapHandler.handleViewUserProfile(username, widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return userData == null
        ? HomeLoadingScreen().profileLoading(context)
        : ProfileHeader(
            username: username,
            fullName: fullName,
            firstName: firstName,
            email: email,
            phone: phone,
            website: website,
            profilePhotoURL: pictureUri,
            currentUserId: widget.userId,
            eventCreatedCount: eventCreated,
            eventGoingCount: eventGoing,
            follower: follower,
            following: following,
            lastName: lastName,
            bio: bio,
            initialIndex: widget.initialIndex,
            isVerified: isVerified,
            isFollowing: userData[0]['isFollowed'],
          );
  }

  Future getUserProfileData() async {
    print('get profile data....');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var session = preferences.getString('Session');

    final userProfileAPI =
        BaseApi().apiUrl + '/user/detail?X-API-KEY=$API_KEY&userID=${widget.userId}';
    print(userProfileAPI);
    final response = await http.get(userProfileAPI, headers: {
      'Authorization': 'Basic YWRtaW46MTIzNA==',
      'cookie': session
    });
    var extractedData = json.decode(response.body);

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        userData = extractedData['data'];
        username = userData[0]['username'];
        firstName = userData[0]['firstName'];
        email = userData[0]['email'];
        phone = userData[0]['phone'];
        website = userData[0]['website'];
        fullName = userData[0]['fullName'];
        lastName = userData[0]['lastName'];
        pictureUri = userData[0]['pictureFullURL'];
        eventCreated = userData[0]['countEventCreated'];
        eventGoing = userData[0]['countEventGoing'];
        following = userData[0]['countFollowing'];
        follower = userData[0]['countFollower'];
        bio = userData[0]['shortBio'];
        isVerified = userData[0]['isVerified'];
        isFollowing = userData[0]['isFollowed'];
      });
    }
  }
}
