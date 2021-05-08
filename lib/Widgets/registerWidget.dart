import 'dart:convert';

import 'package:eventevent/Widgets/AfterRegister.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterWidgetState();
  }
}

class _RegisterWidgetState extends State<RegisterWidget> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailValidationController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _emailValidationNode = FocusNode();

  bool hidePassword = true;
  bool isEmailMatch = false;
  Widget validationEmailIcon;
  Widget reEnterEmailIcon;
  Widget validationUsernameIcon;
  String usernameStatus = '';
  String emailStatus = '';

  bool isLoading = false;

  @override
  void initState() {
    _usernameFocusNode.addListener(() {
      print(_usernameFocusNode.hasFocus);
      if (_usernameFocusNode.hasFocus == false) {
        isLoading = true;
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          message: 'Checking username...',
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 3),
          animationDuration: Duration(milliseconds: 500),
        )..show(context);
        checkUsername(_usernameController.text).then((response) async {
          var extractedData = json.decode(response.body);

          if (extractedData['status'] == 'NOK') {
            isLoading = false;
            setState(() {
              usernameStatus = 'nonavail';
              validationUsernameIcon = Icon(
                Icons.close,
                color: Colors.red,
              );
            });
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: extractedData['desc'],
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 500),
            )..show(context);
          } else if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
              usernameStatus = 'avail';
              validationUsernameIcon = Icon(
                Icons.check,
                color: eventajaGreenTeal,
              );
            });
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: 'Username available',
              backgroundColor: eventajaGreenTeal,
              duration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 500),
            )..show(context);
          }
        });
      }
    });
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus == false) {
        Pattern pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(_emailController.text)) {
          setState(() {
            isLoading = false;
            validationEmailIcon = Icon(
              Icons.close,
              color: Colors.red,
            );
          });
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            message: 'Invalid Email Format!',
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            animationDuration: Duration(milliseconds: 500),
          )..show(context);
        } else {
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            message: 'Checking Email...',
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 3),
            animationDuration: Duration(milliseconds: 500),
          )..show(context);
          checkEmail(_emailController.text).then((response) {
            var extractedData = json.decode(response.body);

            if (extractedData['status'] == 'NOK') {
              setState(() {
                isLoading = false;
                emailStatus = 'nonavail';
                validationEmailIcon = Icon(
                  Icons.close,
                  color: Colors.red,
                );
              });
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                message: extractedData['desc'],
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
                animationDuration: Duration(milliseconds: 500),
              )..show(context);
            } else if (response.statusCode == 200) {
              isLoading = false;
              setState(() {
                emailStatus = 'avail';
                validationEmailIcon = Icon(
                  Icons.check,
                  color: eventajaGreenTeal,
                );
              });
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                message: 'Email available',
                backgroundColor: eventajaGreenTeal,
                duration: Duration(seconds: 3),
                animationDuration: Duration(milliseconds: 500),
              )..show(context);
            }
          });
        }
      }
    });

    _emailValidationNode.addListener(() {
      if (_emailValidationNode.hasFocus == false) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          message: 'Checking Email...',
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 3),
          animationDuration: Duration(milliseconds: 500),
        )..show(context);

        checkEmail(_emailValidationController.text).then((response) {
          var extractedData = json.decode(response.body);

          if (extractedData['status'] == 'NOK') {
            isLoading = false;
            setState(() {
              emailStatus = 'nonavail';
              validationEmailIcon = Icon(
                Icons.close,
                color: Colors.red,
              );
            });
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: extractedData['desc'],
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 500),
            )..show(context);
          } else if (response.statusCode == 200) {
            // isLoading = false;
            setState(() {
              if (_emailController.text == "" ||
                  _emailController.text == null) {
                validationEmailIcon = Icon(
                  Icons.close,
                  color: Colors.red,
                );

                Flushbar(
                  flushbarPosition: FlushbarPosition.TOP,
                  message: 'Please input your email above',
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 6),
                  animationDuration: Duration(milliseconds: 500),
                )..show(context);
              } else {
                if (_emailValidationController.text == _emailController.text) {
                  reEnterEmailIcon = Icon(
                    Icons.check,
                    color: Colors.green,
                  );
                  isEmailMatch = true;
                  emailStatus = 'avail';
                  if (mounted) setState(() {});
                } else {
                  reEnterEmailIcon = Icon(
                    Icons.close,
                    color: Colors.red,
                  );
                  isEmailMatch = false;
                  if (mounted) setState(() {});
                }
              }
            });

            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: 'Email available',
              backgroundColor: eventajaGreenTeal,
              duration: Duration(seconds: 2),
              animationDuration: Duration(milliseconds: 500),
            )..show(context);
          }
        });
      }
    });
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
    return SafeArea(
      bottom: false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: CupertinoNavigationBar(
          padding: EdgeInsetsDirectional.only(
              start: 15, bottom: 10, end: 15, top: 5),
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              backEvent();
            },
            child: Icon(Icons.arrow_back, color: eventajaGreenTeal),
          ),
          middle: Text(
            'Register',
            style: TextStyle(
                fontSize: ScreenUtil.instance.setSp(20),
                color: eventajaGreenTeal),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 40, right: 40, top: 45),
                  child: Material(
                    color: Colors.white,
                    child: registerForm(),
                  ),
                )
              ],
            ),
            Positioned(
                child: isLoading == true
                    ? Container(
                        child: Center(
                            child: CupertinoActivityIndicator(radius: 20)),
                        color: Colors.black.withOpacity(0.5),
                      )
                    : Container())
          ],
        ),
      ),
    );
  }

  bool backEvent() {
    return Navigator.pop(context);
  }

  Widget registerForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextFormField(
          controller: _usernameController,
          keyboardType: TextInputType.text,
          focusNode: _usernameFocusNode,
          autofocus: false,
          onFieldSubmitted: (i) async {
            isLoading = true;
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: 'Checking username...',
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 500),
            )..show(context);
            checkUsername(_usernameController.text).then((response) async {
              var extractedData = json.decode(response.body);

              if (extractedData['status'] == 'NOK') {
                isLoading = false;
                setState(() {
                  usernameStatus = 'nonavail';
                  validationUsernameIcon = Icon(
                    Icons.close,
                    color: Colors.red,
                  );
                });
                Flushbar(
                  flushbarPosition: FlushbarPosition.TOP,
                  message: extractedData['desc'],
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  animationDuration: Duration(milliseconds: 500),
                )..show(context);
              } else if (response.statusCode == 200) {
                isLoading = false;
                setState(() {
                  usernameStatus = 'avail';
                  validationUsernameIcon = Icon(
                    Icons.check,
                    color: eventajaGreenTeal,
                  );
                });
                Flushbar(
                  flushbarPosition: FlushbarPosition.TOP,
                  message: 'Username available',
                  backgroundColor: eventajaGreenTeal,
                  duration: Duration(seconds: 3),
                  animationDuration: Duration(milliseconds: 500),
                )..show(context);
              }
            });
          },
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Username',
              border: InputBorder.none,
              suffixIcon: validationUsernameIcon),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.text,
          autofocus: false,
          focusNode: _emailFocusNode,
          onFieldSubmitted: (i) async {
            setState(() {
              isLoading = true;
            });
            Pattern pattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regex = new RegExp(pattern);
            if (!regex.hasMatch(i)) {
              isLoading = false;
              setState(() {
                validationEmailIcon = Icon(
                  Icons.close,
                  color: Colors.red,
                );
              });
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                message: 'Invalid Email Format!',
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
                animationDuration: Duration(milliseconds: 500),
              )..show(context);
            } else {
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                message: 'Checking Email...',
                backgroundColor: Colors.grey,
                duration: Duration(seconds: 3),
                animationDuration: Duration(milliseconds: 500),
              )..show(context);
              checkEmail(_emailController.text).then((response) {
                var extractedData = json.decode(response.body);

                if (extractedData['status'] == 'NOK') {
                  isLoading = false;
                  setState(() {
                    emailStatus = 'nonavail';
                    validationEmailIcon = Icon(
                      Icons.close,
                      color: Colors.red,
                    );
                  });
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message: extractedData['desc'],
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    animationDuration: Duration(milliseconds: 500),
                  )..show(context);
                } else if (response.statusCode == 200) {
                  isLoading = false;
                  setState(() {
                    emailStatus = 'avail';
                    validationEmailIcon = Icon(
                      Icons.check,
                      color: eventajaGreenTeal,
                    );
                  });
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message: 'Email available',
                    backgroundColor: eventajaGreenTeal,
                    duration: Duration(seconds: 3),
                    animationDuration: Duration(milliseconds: 500),
                  )..show(context);
                }
              });
            }
          },
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Email',
              border: InputBorder.none,
              suffixIcon: validationEmailIcon),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: _emailValidationController,
          keyboardType: TextInputType.text,
          autofocus: false,
          focusNode: _emailValidationNode,
          onFieldSubmitted: (i) async {
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: 'Checking Email...',
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 500),
            )..show(context);

            checkEmail(i).then((response) {
              var extractedData = json.decode(response.body);

              if (extractedData['status'] == 'NOK') {
                isLoading = false;
                setState(() {
                  emailStatus = 'nonavail';
                  validationEmailIcon = Icon(
                    Icons.close,
                    color: Colors.red,
                  );
                });
                Flushbar(
                  flushbarPosition: FlushbarPosition.TOP,
                  message: extractedData['desc'],
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  animationDuration: Duration(milliseconds: 500),
                )..show(context);
              } else if (response.statusCode == 200) {
                // isLoading = false;
                setState(() {
                  if (_emailController.text == "" ||
                      _emailController.text == null) {
                    validationEmailIcon = Icon(
                      Icons.close,
                      color: Colors.red,
                    );

                    Flushbar(
                      flushbarPosition: FlushbarPosition.TOP,
                      message: 'Please input your email above',
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 6),
                      animationDuration: Duration(milliseconds: 500),
                    )..show(context);
                  } else {
                    if (i == _emailController.text) {
                      reEnterEmailIcon = Icon(
                        Icons.check,
                        color: Colors.green,
                      );
                      isEmailMatch = true;
                      emailStatus = 'avail';
                      if (mounted) setState(() {});
                    } else {
                      reEnterEmailIcon = Icon(
                        Icons.close,
                        color: Colors.red,
                      );
                      isEmailMatch = false;
                      if (mounted) setState(() {});
                    }
                  }
                });

                Flushbar(
                  flushbarPosition: FlushbarPosition.TOP,
                  message: 'Email available',
                  backgroundColor: eventajaGreenTeal,
                  duration: Duration(seconds: 2),
                  animationDuration: Duration(milliseconds: 500),
                )..show(context);
              }
            });
          },
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Re-enter Your Email',
              border: InputBorder.none,
              suffixIcon: reEnterEmailIcon),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        Row(
          children: <Widget>[
            Container(
              width: ScreenUtil.instance.setWidth(250),
              child: TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.text,
                autofocus: false,
                obscureText: hidePassword,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Password',
                    border: InputBorder.none),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
              child: Container(
                  height: ScreenUtil.instance.setWidth(20),
                  width: ScreenUtil.instance.setWidth(20),
                  child: Icon(
                    Icons.remove_red_eye,
                    color:
                        hidePassword == true ? Colors.grey : eventajaGreenTeal,
                  )),
            ),
            SizedBox(
              width: ScreenUtil.instance.setWidth(13),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil.instance.setWidth(15)),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: ButtonTheme(
            minWidth: ScreenUtil.instance.setWidth(500),
            height: ScreenUtil.instance.setWidth(50),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Text('REGISTER',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.instance.setSp(15),
                      color: Colors.white)),
              color: eventajaGreenTeal,
              onPressed: () {
                isLoading = true;
                Pattern pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regex = new RegExp(pattern);
                if (_usernameController.text.length == 0 ||
                    _usernameController.text == null ||
                    _emailController.text.length == 0 ||
                    _passwordController.text.length == 0) {
                  isLoading = false;
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message: 'Please check your input',
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    animationDuration: Duration(milliseconds: 500),
                  )..show(context);
                } else if (!regex.hasMatch(_emailController.text)) {
                  isLoading = false;
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message: 'Invalid Email Format',
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    animationDuration: Duration(milliseconds: 500),
                  )..show(context);
                } else if (_passwordController.text.length < 8) {
                  isLoading = false;
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message: 'Password at least 8 characters',
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    animationDuration: Duration(milliseconds: 500),
                  )..show(context);
                } else if (usernameStatus == 'nonavail' ||
                    emailStatus == 'nonavail') {
                  isLoading = false;
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message: 'Please check your input',
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    animationDuration: Duration(milliseconds: 500),
                  )..show(context);
                } else if (isEmailMatch == false) {
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message: 'Email validation not match',
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    animationDuration: Duration(milliseconds: 500),
                  )..show(context);
                } else if (usernameStatus == 'avail' &&
                    emailStatus == 'avail' &&
                    isEmailMatch == true) {
                  isLoading = false;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AfterRegister(
                              username: _usernameController.text,
                              email: _emailController.text,
                              password: _passwordController.text)));
                }
              },
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        Divider(
          height: ScreenUtil.instance.setWidth(15),
        )
      ],
    );
  }

  Future<http.Response> checkUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/signup/check_username?username=$username&X-API-KEY=$API_KEY';

    final response = await http.get(url, headers: {
      'Authorization': AUTH_KEY,
    });

    return response;
  }

  Future<http.Response> checkEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/signup/check_email?email=$email&X-API-KEY=$API_KEY';

    final response = await http.get(url, headers: {
      'Authorization': AUTH_KEY,
    });

    return response;
  }
}
