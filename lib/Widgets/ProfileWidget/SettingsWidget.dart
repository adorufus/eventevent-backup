import 'dart:io';

import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/BankAccountList.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/ChangePassword.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/Feedback.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/PrivacyPolicy.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/Terms.dart';
import 'package:eventevent/Widgets/ProfileWidget/editProfile.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WithdrawBank.dart';
import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/helper/API/apiHelper.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ClevertapHandler.dart';
import 'package:eventevent/helper/WebView.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:launch_review/launch_review.dart';
import 'package:http/http.dart' as http;

class SettingsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsWidgetState();
  }
}

class _SettingsWidgetState extends State<SettingsWidget> {
  String appVersion = 'Current version v';
  bool isLoading = false;

  Future setSharedPreferencesToEmpty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getKeys());
  }

  getInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      appVersion = appVersion + '${Platform.isAndroid ? '3.1.0' : '3.1.0'}';
    });

    print(appVersion);
  }

  @override
  void initState() {
    getInfo();
    super.initState();
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
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: eventajaGreenTeal,
          ),
        ),
        title: Text(
          'SETTINGS',
          style: TextStyle(color: eventajaGreenTeal),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          // SettingsList(
          //   sections: [
          //     SettingsSection(
          //       title: 'REVIEW',
          //       tiles: [
          //         SettingsTile(
          //           title: 'Rate Eventevent on App Store / Google Play',
          //           onTap: () {
          //             LaunchReview.launch(
          //                 androidAppId: 'com.eventevent.android');
          //           },
          //         )
          //       ],
          //     ),
          //     SettingsSection(
          //       title: 'BANK ACCOUNT & WITHDRAW',
          //       tiles: [
          //         SettingsTile(
          //           title: 'Bank Account',
          //           onTap: (){

          //           },
          //         ),
          //         SettingsTile(
          //           title: 'Withdraw',
          //           onTap: (){

          //           },
          //         ),
          //       ],
          //     ),
          //     SettingsSection(
          //       title: 'ACCOUNT SETTINGS',
          //       tiles: [
          //         SettingsTile(
          //           title: 'Edit Profile',
          //           onTap: (){

          //           },
          //         ),
          //         SettingsTile(
          //           title: 'Change Password',
          //           onTap: (){

          //           },
          //         ),
          //       ],
          //     ),
          //     SettingsSection(
          //       title: 'FEEDBACK',
          //       tiles: [
          //         SettingsTile(
          //           title: 'Give Us Feedback',
          //           onTap: (){

          //           },
          //         ),
          //       ],
          //     ),
          //     SettingsSection(
          //       tiles: [
          //         SettingsTile(
          //           title: 'Log Out',
          //           onTap: (){

          //           },
          //         ),
          //       ],
          //     ),
          //     SettingsSection(
          //       title: 'TERMS AND CONDITION',
          //       tiles: [
          //         SettingsTile(
          //           title: 'Terms',
          //           onTap: (){

          //           },
          //         ),
          //         SettingsTile(
          //           title: 'Privacy Policy',
          //           onTap: (){

          //           },
          //         ),
          //         SettingsTile(
          //           title: 'Open Source Library',
          //           onTap: (){

          //           },
          //         )
          //       ],
          //     ),
          //   ],
          // ),
          ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'REVIEW',
                  style: TextStyle(
                      fontSize: ScreenUtil.instance.setSp(18),
                      color: Colors.grey[600]),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        LaunchReview.launch(
                            androidAppId: 'com.eventevent.android');
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 30, bottom: 10, top: 10),
                        child: Text(
                          'Rate EventEvent on App Store / Google Play',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(25),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'BANK ACCOUNT & WITHDRAW',
                  style: TextStyle(
                      fontSize: ScreenUtil.instance.setSp(18),
                      color: Colors.grey[600]),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    BankAccountList()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 30, top: 15),
                        child: Text(
                          'Bank Account',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    WithdrawBank()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 30, top: 10, bottom: 10),
                        child: Text(
                          'Withdraw',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(25),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'ACCOUNT SETTINGS',
                  style: TextStyle(
                      fontSize: ScreenUtil.instance.setSp(18),
                      color: Colors.grey[600]),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EditProfileWidget()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 30, top: 15),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ChangePassword()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 30, top: 10, bottom: 10),
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(25),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'FEEDBACK',
                  style: TextStyle(
                      fontSize: ScreenUtil.instance.setSp(18),
                      color: Colors.grey[600]),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    GiveFeedback()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 30, top: 10, bottom: 10),
                        child: Text(
                          'Give us feedback',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(25),
              ),
              GestureDetector(
                onTap: () {
                  showCupertinoDialog(
                      context: context,
                      builder: (BuildContext thisContext) {
                        return StatefulBuilder(
                          builder: (thisContext, setState) =>
                              CupertinoAlertDialog(
                            title: Text('Oops'),
                            content: Text('Do you want to log out?'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text('No'),
                                onPressed: () {
                                  Navigator.pop(thisContext);
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text('Yes'),
                                onPressed: () {
                                  Navigator.pop(thisContext);

                                  setState(() {
                                    isLoading = true;
                                  });

                                  requestLogout(context);

                                  setSharedPreferencesToEmpty();
                                },
                              )
                            ],
                          ),
                        );
                      });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 30, bottom: 10, top: 10),
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(25),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'Terms and Condition',
                  style: TextStyle(
                      fontSize: ScreenUtil.instance.setSp(18),
                      color: Colors.grey[600]),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => Terms()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 30, top: 15),
                        child: Text(
                          'Terms',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    PrivacyPolicy()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 30, top: 10, bottom: 10),
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => WebViewTest(
                                      url:
                                          'https://eventevent.com/opensourcelibrary',
                                    )));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 30, top: 10, bottom: 10),
                        child: Text(
                          'Open Source Library',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(25),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: ScreenUtil.instance.setWidth(50),
                    color: Colors.white,
                    child: Center(
                        child: Text(
                      appVersion,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: ScreenUtil.instance.setSp(18)),
                    ))),
              ),
            ],
          ),
          isLoading == true
              ? Center(
                  child: CupertinoActivityIndicator(
                    animating: true,
                    radius: 15,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Future requestLogout(BuildContext context) async {
    final logoutApiUrl = BaseApi().apiUrl + '/signout';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> body = {
      'X-API-KEY': apiKey,
      'streaming_token': prefs.containsKey('streaming_key') &&
              prefs.getString('streaming_key') != null
          ? prefs.getString('streaming_key')
          : ''
    };

    setState(() {
      isLoading = true;
    });

    print(isLoading);

    // Future.delayed(Duration(seconds: 3));

    final response = await http.post(logoutApiUrl, body: body, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);

    if (prefs.getBool('isUsingGoogle') == true) {
      googleSignIn.signOut();
    }

    String deviceType = Platform.isIOS ? 'iOS' : 'Android';

    if (response.statusCode == 200) {
      ClevertapHandler.removeUserProfile(deviceType);
      setState(() {
        isLoading = false;
      });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginRegisterWidget()),
          (Route<dynamic> route) => false);
      prefs.clear();
      print(prefs.getKeys());
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.body);
    }
  }
}
