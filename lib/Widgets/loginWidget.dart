import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/ForgotPassword.dart';
import 'package:eventevent/Widgets/RegisterFacebook.dart';
import 'package:eventevent/Widgets/RegisterGoogle.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/API/loginModel.dart';
import 'package:eventevent/helper/sharedPreferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/API/apiHelper.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginWidgetState();
  }
}

class _LoginWidgetState extends State<LoginWidget> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  ///Buat GlobalKey Scaffold agar bisa dipanggil di Class lain
  final TextEditingController _usernameController = TextEditingController();

  ///Buat controller untuk mengambil dan menyimpan input username
  final TextEditingController _passwordController = TextEditingController();

  ///Buat controller untuk mengambil dan menyimpan input password

  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  String _userID;
  String googleTokenID;
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: CupertinoNavigationBar(
        padding:
            EdgeInsetsDirectional.only(start: 15, bottom: 10, end: 15, top: 5),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            backEvent();
          },
          child: Icon(Icons.arrow_back, color: eventajaGreenTeal),
        ),
        middle: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: eventajaGreenTeal),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 40, right: 40, top: 45),
                child: Material(
                  color: Colors.white,
                  child: loginForm(),
                ),
              ),
            ],
          ),
          Positioned(
              child: isLoading == true
                  ? Container(
                      child: Center(child: CircularProgressIndicator()),
                      color: Colors.black.withOpacity(0.5),
                    )
                  : Container())
        ],
      ),
    );
  }

  ///Buat fungsi tombol back
  bool backEvent() {
    return Navigator.pop(context);
  }

  ///Construct LoginForm Widget
  Widget loginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextFormField(
          controller: _usernameController,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Username',
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: <Widget>[
            Container(
              width: 250,
              child: TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.text,
                autofocus: false,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  // fillColor: Colors.white,
                  // filled: true,
                  hintText: 'Password',
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
              child: Container(height: 20, width: 20, child: Icon(Icons.remove_red_eye, color: hidePassword == true ? Colors.grey : eventajaGreenTeal,)),
            )
          ],
        ),
        SizedBox(
          height: 40,
        ),
        ButtonTheme(
          minWidth: 500,
          height: 50,
          child: RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Text('Login',
                style: TextStyle(fontSize: 15, color: Colors.white)),
            color: eventajaGreenTeal,
            onPressed: () {
              if (_usernameController.text.length == 0 ||
                  _usernameController.text == null) {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      'Email / Username cannot be empty',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              } else if (_passwordController.text.length == 0 ||
                  _passwordController.text == null) {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      'Password connot be empty',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              } else {
                requestLogin(context, _usernameController.text,
                    _passwordController.text, _scaffoldKey);
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
        ),
        GestureDetector(
          child: Text(
            'Forgot Your Password?',
            style: TextStyle(fontSize: 15),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => ForgotPassword()));
          },
        ),
        SizedBox(
          height: 25,
        ),
        Divider(
          height: 15,
        ),
        GestureDetector(
              onTap: () {
                initiateFacebookLogin();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 26),
                width: MediaQuery.of(context).size.width,
                height: 37.02,
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
                        height: 37,
                        width: 37,
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
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
                margin: EdgeInsets.symmetric(horizontal: 26),
                width: MediaQuery.of(context).size.width,
                height: 37.02,
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
                      height: 37,
                      width: 37,
                      decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFFf9f9f9)),
                      child: Image.asset('assets/drawable/google.png', scale: 3),
                    ),
                    Flexible(
                      child: Center(
                        child: Text(
                          'LOGIN WITH GOOGLE',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Future<GoogleSignInAuthentication> goLoginGoogle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    final FirebaseUser user = await _auth.signInWithCredential(credential);
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
        'Authorization': AUTHORIZATION_KEY,
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
              builder: (BuildContext context) => DashboardWidget()));
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
    final response =
        await http.get(url, headers: {'Authorization': AUTHORIZATION_KEY});

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
              builder: (BuildContext context) => DashboardWidget()));
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

  bool isLoggedIn = false;

  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }

  ///Untuk fetching RequestLogin
  Future<LoginModel> requestLogin(BuildContext context, String username,
      String password, GlobalKey<ScaffoldState> _scaffoldKey) async {
    final loginApiUrl = BaseApi().apiUrl + '/signin/login?=';
    final String apiKey = '47d32cb10889cbde94e5f5f28ab461e52890034b';

    Map<String, String> body = {
      'username': username,
      'password': password,
      'X-API-KEY': apiKey
    };

    this.setState(() {
      isLoading = true;
    });

    final response = await http.post(loginApiUrl,
        headers: {HttpHeaders.authorizationHeader: "Basic YWRtaW46MTIzNA=="},
        body: body);

    this.setState(() {
      isLoading = false;
    });

    print('status code: ' + response.statusCode.toString());
    print(response.body);

    ///Jika statusCode == 200 maka lanjutkan proses dan alihkan ke halaman berikutnya

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('apiHelper-line41:' + cookies);
      print('username: ' + prefs.getString('Last Username').toString());
      print('id: ' + prefs.getString('Last User ID').toString());
      final responseJson = json.decode(response.body);

      ///simpan sesi saat ini
      setState(() {
        prefs.setString('Session', response.headers['set-cookie']);
      });

      SharedPrefs().saveCurrentSession(response, responseJson);
      Navigator.pushReplacementNamed(context, '/Dashboard');
      return LoginModel.fromJson(responseJson);
    }

    ///Jika statusCode == 400 maka munculin Snackbar error Belum teregister / salah input akun
    else if (response.statusCode == 400) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        content: Text(
          'You\'re not registered!',
          style: TextStyle(color: Colors.white),
        ),
      ));
    }

    ///Jika statusCode == 408 maka munculin Snackbar error Request Timeout!
    else if (response.statusCode == 408) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        content: Text('Request Timeout! please retry submiting data'),
      ));
    }

    ///Else, simpan sessi gagal
    else {
      final responseJson = json.decode(response.body);
      SharedPrefs().saveCurrentSession(response, responseJson);
    }
    print(LoginModel().description);
  }
}
