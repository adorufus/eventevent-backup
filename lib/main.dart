import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eventevent/Providers/EventListProviders.dart';
import 'package:eventevent/Widgets/ManageEvent/ShowQr.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WithdrawBank.dart';
import 'package:eventevent/Widgets/timeline/UserMediaDetail.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/CrashlyticsTester.dart';
import 'package:eventevent/Widgets/PostEvent/PostEvent.dart';
import 'package:eventevent/Widgets/ProfileWidget/editProfile.dart';
import 'package:eventevent/Widgets/RecycleableWidget/CustomCamera.dart';
import 'package:eventevent/Widgets/SplashScreen.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/Widgets/loginWidget.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/Widgets/registerWidget.dart';
import 'package:eventevent/helper/PushNotification.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:camera/camera.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widgets/loginRegisterWidget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/services.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  Crashlytics.instance.enableInDevMode = false;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  // HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, statusBarIconBrightness: Brightness.light));
  // try{
    cameras = await availableCameras();
  // } on CameraException catch (e){
  //   print('code: ${e.code} message: ${e.description}');
  // }

  runZoned((){
    runApp(new RunApp());
  }, onError: Crashlytics.instance.recordError);
}

class RunApp extends StatefulWidget {
  // This widget is the root of your application.

  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  _RunAppState createState() => _RunAppState();
}

class _RunAppState extends State<RunApp> {
  Widget homeScreenWidget = LoginRegisterWidget();
  

  

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // navigatorObservers: [
      //   FirebaseAnalyticsObserver(analytics:  analytics)
      // ],
      title: 'EventEvent',
      debugShowCheckedModeBanner: false,
      navigatorObservers: <NavigatorObserver>[RunApp.observer],
      theme: ThemeData(
          fontFamily: 'Proxima',
          primarySwatch: eventajaGreen,
          brightness: Brightness.light,
          backgroundColor: Colors.white),
      // home: CrashlyticsTester(),
      home:
       AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.light),
        child: SplashScreen(
            analytics: RunApp.analytics, observer: RunApp.observer),
      ),
      routes: <String, WidgetBuilder>{
        '/LoginRegister': (BuildContext context) =>
            AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                    statusBarColor: Colors.white,
                    statusBarIconBrightness: Brightness.light),
                child: LoginRegisterWidget()),
        '/WithdrawBank': (BuildContext context) => WithdrawBank(),
        '/Login': (BuildContext context) => AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.light),
            child: LoginWidget()),
        '/Register': (BuildContext context) => AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.light),
            child: RegisterWidget()),
        '/Dashboard': (BuildContext context) => AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.light),
            child: DashboardWidget()),
        '/Profile': (BuildContext context) => AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.light),
            child: ProfileWidget()),
        '/EventDetails': (BuildContext context) => AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.light),
            child: EventDetailsConstructView()),
        '/EditProfile': (BuildContext context) => AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.light),
            child: EditProfileWidget()),
        '/PostEvent': (BuildContext context) => AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.light),
            child: PostEvent()),
        '/CustomCamera': (BuildContext context) => AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.light),
            child: CustomCamera(cameras)), 
      },
    );
  }

  getHomeScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('Session') != null ||
        prefs.getString('Session') != '') {
      homeScreenWidget = DashboardWidget();
    } else {
      homeScreenWidget = LoginRegisterWidget();
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 5;
  }
}
