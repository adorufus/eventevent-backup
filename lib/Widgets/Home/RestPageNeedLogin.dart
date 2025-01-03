import 'dart:convert';

import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/PrivacyPolicy.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/Terms.dart';
import 'package:eventevent/Widgets/RegisterFacebook.dart';
import 'package:eventevent/Widgets/RegisterGoogle.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/Widgets/loginWidget.dart';
import 'package:eventevent/Widgets/registerWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RestPageNeedLogin extends StatefulWidget {
  final selectedPage;

  const RestPageNeedLogin({Key key, this.selectedPage}) : super(key: key);

  @override
  _RestPageNeedLoginState createState() => _RestPageNeedLoginState();
}

class _RestPageNeedLoginState extends State<RestPageNeedLogin> {
  String textMessage = '';
  String imageUri = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  String _userID;
  String googleTokenID;

  void initiateFacebookLogin() async {
    var facebookLogin = FacebookLogin();
    var facebookLoginResult = await facebookLogin.logInWithReadPermissions(
        ['email', 'public_profile', 'user_friends', 'user_gender']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.loggedIn:
        print(facebookLoginResult.accessToken.token);
        goLoginFb(facebookLoginResult.accessToken.token);
        onLoginStatusChanged(true);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.error:
        print("Error");
        onLoginStatusChanged(false);
        break;
    }
  }

  Future<GoogleSignInAuthentication> goLoginGoogle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _userID = user.uid;
        var tokenId = googleAuth.idToken;
        var accessToken = googleAuth.accessToken;
        return googleAuth;
      }
    });
    prefs.setBool('isUsingGoogle', true);
    prefs.setString('REGIS_GOOGLE_PHOTO', user.photoUrl);
    prefs.setString('REGIS_GOOGLE_PHONE', user.phoneNumber);
    prefs.setString('REGIS_GOOGLE_NAME', user.displayName);
    prefs.setString('REGIS_GOOGLE_EMAIL', user.email);
    return googleAuth;
  }

  Future proccesGoogle(String access_token, String id_token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/signin/google?X-API-KEY=$API_KEY&access_token=$access_token';

    final response = await http.get(
      url,
      headers: {
        'Authorization': AUTH_KEY,
      },
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      var extractedData = json.decode(response.body);

      prefs.setString('Session', response.headers['set-cookie']);
      prefs.setString('Last User ID', extractedData['data']['id']);
      prefs.setBool('isUsingGoogle', true);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DashboardWidget(
                    isRest: false,
                  )));
    } else {
      var extractedData = json.decode(response.body);
      if (extractedData['desc'] == 'User is not register') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => GoogleRegister()));
      }
    }
  }

  Future goLoginFb(String fbToken) async {
    String url =
        BaseApi().apiUrl + '/signin/facebook?X-API-KEY=$API_KEY&token=$fbToken';
    final response = await http.get(url, headers: {'Authorization': AUTH_KEY});

    print(response.statusCode);
    print(response.body);
    print(response.headers);

    if (response.statusCode == 200) {
      print(response.body);
      print('loginSuccess');

      SharedPreferences preferences = await SharedPreferences.getInstance();
      var extractedData = json.decode(response.body);

      preferences.setString('Session', response.headers['set-cookie']);
      preferences.setString('Last User ID', extractedData['data']['id']);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DashboardWidget(
                    isRest: false,
                  )));
    } else {
      var extractedData = json.decode(response.body);
      String message = extractedData['desc'];

      if (message == "User is not register") {
        var graphResponse = await http.get(
            'https://graph.facebook.com/v3.3/me?fields=name,first_name,last_name,email,picture,birthday,gender,accounts{phone}&access_token=$fbToken');
        var graphData = json.decode(graphResponse.body);
        String id = null;
        id = graphData['id'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          prefs.setString('REGIS_FB_ID', id);
          prefs.setString('REGIS_FB_PHOTO',
              "https://graph.facebook.com/" + id + "/picture?type=large");
          prefs.setString('REGIS_FB_BIRTH_DATE', graphData['birthday']);
          prefs.setString('REGIS_FB_GENDER', graphData['gender']);
          prefs.setString('REGIS_FB_EMAIL', graphData['email']);
          prefs.setString('REGIS_FB_FULLNAME', graphData['name']);
          prefs.setString('REGIS_FB_FIRST_NAME', graphData['first_name']);
          prefs.setString('REGIS_FB_LAST_NAME', graphData['last_name']);
        });
        print(graphData);

        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => RegisterFacebook()));
      }
    }
  }

  bool isLoggedIn = false;

  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }

  void getPackageInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String packageVersion = packageInfo.version;

    print(appName);
    print(packageName);
    print(packageVersion);
    prefs.setString('app_version', packageVersion);
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
      body: Container(
        child: ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(widget.selectedPage),
                Flexible(
                  child: SizedBox(),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close),
                )
              ],
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(10),
            ),
            Text(
              'Sign in to start using timeline and get updates from your friends and organizers',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(15),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: ScreenUtil.instance.setWidth(10),
                  horizontal: ScreenUtil.instance.setWidth(26)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  LoginWidget()));
                    },
                    child: Container(
                      width: ScreenUtil.instance.setWidth(147.41),
                      height: ScreenUtil.instance.setWidth(37.02),
                      decoration: BoxDecoration(
                          color: eventajaGreenTeal,
                          borderRadius: BorderRadius.circular(
                              ScreenUtil.instance.setWidth(180)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                blurRadius: 2,
                                color: eventajaGreenTeal.withOpacity(0.3),
                                spreadRadius: 1.5)
                          ]),
                      child: Center(
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.instance.setSp(12),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil.instance.setWidth(13)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RegisterWidget()));
                    },
                    child: Container(
                      width: ScreenUtil.instance.setWidth(147.41),
                      height: ScreenUtil.instance.setWidth(37.02),
                      decoration: BoxDecoration(
                          color: eventajaGreenTeal,
                          borderRadius: BorderRadius.circular(
                              ScreenUtil.instance.setWidth(180)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                blurRadius: 2,
                                color: eventajaGreenTeal.withOpacity(0.3),
                                spreadRadius: 1.5)
                          ]),
                      child: Center(
                        child: Text(
                          'REGISTER',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.instance.setSp(12),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                initiateFacebookLogin();
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil.instance.setWidth(26)),
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil.instance.setWidth(37.02),
                decoration: BoxDecoration(
                    color: Color(0xFF4C64B5),
                    borderRadius: BorderRadius.circular(180),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          blurRadius: 2,
                          color: Color(0xFF4C64B5).withOpacity(0.5),
                          spreadRadius: 1.5)
                    ]),
                child: Row(
                  children: <Widget>[
                    Container(
                        height: ScreenUtil.instance.setWidth(37),
                        width: ScreenUtil.instance.setWidth(37),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFF324b9c)),
                        child: Center(
                            child: Image.asset('assets/drawable/facebook.png',
                                scale: 3))),
                    Flexible(
                      child: Center(
                        child: Text(
                          'LOGIN WITH FACEBOOK',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.instance.setSp(12),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: ScreenUtil.instance.setWidth(10)),
            GestureDetector(
              onTap: () {
                goLoginGoogle().then((result) {
                  print(result.accessToken);
                  print(result.idToken);
                  proccesGoogle(result.accessToken, result.idToken);
                }).catchError((e) {
                  print(e);
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil.instance.setWidth(26)),
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil.instance.setWidth(37.02),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(180),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1.5)
                    ]),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      height: ScreenUtil.instance.setWidth(37),
                      width: ScreenUtil.instance.setWidth(37),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFFf9f9f9)),
                      child:
                          Image.asset('assets/drawable/google.png', scale: 3),
                    ),
                    Flexible(
                      child: Center(
                        child: Text(
                          'LOGIN WITH GOOGLE',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(12),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15, left: 5, right: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('By registering, you are agree with',
                      style:
                          TextStyle(fontSize: ScreenUtil.instance.setSp(11))),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Terms()));
                    },
                    child: Text(
                      ' Terms',
                      style: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(12),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(' and',
                      style:
                          TextStyle(fontSize: ScreenUtil.instance.setSp(11))),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicy()));
                    },
                    child: Text(
                      ' Privacy Policy',
                      style: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(12),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
