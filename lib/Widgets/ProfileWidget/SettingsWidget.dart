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
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
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
      appVersion = appVersion + prefs.getString('app_version');
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
                        padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
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
                        padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
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
                        padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
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
                        padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
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
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text('Oops'),
                          content: Text('Do you want to log out?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text('Yes'),
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                setSharedPreferencesToEmpty();

                                requestLogout(context).then((response) async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  if (prefs.getBool('isUsingGoogle') == true) {
                                    googleSignIn.signOut();
                                  }

                                  if (response.statusCode == 200) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginRegisterWidget()),
                                        (Route<dynamic> route) => false);
                                    prefs.clear();
                                    print(prefs.getKeys());
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    print(response.body);
                                  }
                                });
                              },
                            )
                          ],
                        );
                      });
//              showDialog(
//                  context: context,
//                  builder: (BuildContext context){
//                    return GestureDetector(
//                      onTap: (){
//                        Navigator.pop(context);
//                      },
//                      child: Material(
//                        color: Colors.transparent,
//                        child: Center(
//                          child: Container(
//                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.instance.setWidth(8), vertical: ScreenUtil.instance.setWidth(8)),
//                            decoration: BoxDecoration(
//                                color: Colors.white,
//                                borderRadius: BorderRadius.circular(10)
//                            ),
//                            height: ScreenUtil.instance.setWidth(150),
//                            width: ScreenUtil.instance.setWidth(250),
//                            child: Column(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: <Widget>[
//                                SizedBox(height: ScreenUtil.instance.setWidth(10),),
//                                Text('Oops', style: TextStyle(color: Colors.black54,fontSize: ScreenUtil.instance.setSp(18), fontWeight: FontWeight.bold),),
//                                SizedBox(height: ScreenUtil.instance.setWidth(10),),
//                                Text('Do you want to log out?', textAlign: TextAlign.center,),
//                                SizedBox(
//                                  height: ScreenUtil.instance.setWidth(13),
//                                ),
//                                Row(
//                                  mainAxisAlignment: MainAxisAlignment.center,
//                                  crossAxisAlignment: CrossAxisAlignment.center,
//                                  children: <Widget>[
//                                    GestureDetector(
//                                      onTap: (){
//                                        Navigator.pop(context);
//                                      },
//                                      child: Text('Cancel', style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),),
//                                    ),
//                                    SizedBox(
//                                      width: ScreenUtil.instance.setWidth(50),
//                                    ),
//                                    GestureDetector(
//                                      onTap: (){
//                                        setSharedPreferencesToEmpty();
//                                        requestLogout(context);
//                                      },
//                                      child: Text('Ok', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
//                                    )
//
//                                  ],
//                                )
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
//                    );
//                  }
//              );
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
                        padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
                        child: Text(
                          'Privacy Policy',
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
          isLoading == false
              ? Container()
              : Center(
                  child: CupertinoActivityIndicator(
                    animating: true,
                    radius: 15,
                  ),
                )
        ],
      ),
    );
  }

  Future<http.Response> requestLogout(BuildContext context) async {
    final logoutApiUrl = BaseApi().apiUrl + '/signout';

    Map<String, String> body = {'X-API-KEY': apiKey};

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });

    Future.delayed(Duration(seconds: 3));

    final response = await http.post(logoutApiUrl, body: body, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);

    return response;
  }
}
