import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final int splashDuration = 2;
  startTime() async {
    return Timer(Duration(seconds: splashDuration), () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (preferences.getString('LastScreenRoute') == null) {
        Navigator.of(context).pushReplacementNamed('/LoginRegister');
      } else {
        if (preferences.getString('LastScreenRoute') == "/Dashboard") {
          if (preferences.getString('Session') != null) {
            Navigator.of(context).pushReplacementNamed('/Dashboard');
          } else {
            Navigator.of(context).pushReplacementNamed('/LoginRegister');
          }
        } else if (preferences.getString('LastScreenRoute') == '/LoginRegister') {
          Navigator.pushReplacementNamed(context, '/LoginRegister');
        }
      }
    });
  }

  @override
  void initState() {
    startTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}
