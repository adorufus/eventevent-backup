import 'dart:io';

import 'package:eventevent/Widgets/PostEvent/PostEvent.dart';
import 'package:eventevent/Widgets/ProfileWidget/editProfile.dart';
import 'package:eventevent/Widgets/RecycleableWidget/CustomCamera.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/Widgets/loginWidget.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/Widgets/registerWidget.dart';
import 'package:eventevent/helper/PushNotification.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widgets/loginRegisterWidget.dart';
import 'package:google_places_picker/google_places_picker.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  // HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark));
  cameras = await availableCameras();
  runApp(new MyApp());
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  Widget homeScreenWidget = LoginRegisterWidget();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventEvent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Proxima',
          primarySwatch: eventajaGreen,
          backgroundColor: Colors.white),
      home: homeScreenWidget,
      routes: <String, WidgetBuilder>{
        '/LoginRegister': (BuildContext context) => LoginRegisterWidget(),
        '/Login': (BuildContext context) => LoginWidget(),
        '/Register': (BuildContext context) => RegisterWidget(),
        '/Dashboard': (BuildContext context) => DashboardWidget(),
        '/Profile': (BuildContext context) => ProfileWidget(),
        '/EventDetails': (BuildContext context) => EventDetailsConstructView(),
        '/EditProfile': (BuildContext context) => EditProfileWidget(),
        '/PostEvent': (BuildContext context) => PostEvent(),
        '/CustomCamera': (BuildContext context) => CustomCamera(cameras)
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
