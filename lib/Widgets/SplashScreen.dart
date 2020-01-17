import 'dart:async';
import 'dart:io'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  const SplashScreen({Key key, this.analytics, this.observer}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final int splashDuration = 3;

  Future<Null> getCurrentScreen() async{
    await widget.analytics.setCurrentScreen(screenName: 'SplashScreen', screenClassOverride: 'SplashScreen');
  }

  Future<Null> sendAnalytics(String nextScreen) async{
    await widget.analytics.logEvent(name: 'navigate_to_$nextScreen', parameters: {'Navigate': nextScreen});
    
  }

  startTime() async {
    return Timer(Duration(seconds: splashDuration), () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (preferences.getString('LastScreenRoute') == null) {
        sendAnalytics('LoginRegister');
        Navigator.of(context).pushReplacementNamed('/LoginRegister');
      } else {
        if (preferences.getString('LastScreenRoute') == "/Dashboard") {
          sendAnalytics(preferences.getString('LastScreenRoute'));
          if (preferences.getString('Session') != null) {
            sendAnalytics('Dashboard');
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DashboardWidget(isRest: false,)));
          } else {
            sendAnalytics('LoginRegister');
            Navigator.of(context).pushReplacementNamed('/LoginRegister');
          }
        } else if (preferences.getString('LastScreenRoute') ==
            '/LoginRegister') {
              sendAnalytics('LoginRegister');
          Navigator.pushReplacementNamed(context, '/LoginRegister');
        }
      }
    });
  }

  

  @override
  void initState() {
    startTime();
    super.initState();
    getCurrentScreen();

  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: eventajaGreenTeal,
          child: Center(
            child: Container(
              child: FlareActor('assets/flare/eventevent.flr', animation: 'Splash', sizeFromArtboard: true, artboard: 'Artboard',),
            )
          ),
        ),
      ),
    );
  }
}
