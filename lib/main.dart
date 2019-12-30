import 'dart:io'; import 'package:firebase_messaging/firebase_messaging.dart';
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

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
final BehaviorSubject<RecievedNotification> didRecieveLocalNotificationPlugin = BehaviorSubject<RecievedNotification>();
final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

class RecievedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  RecievedNotification({@required this.id, @required this.title, @required this.body, @required this.payload});
}

List<CameraDescription> cameras;

Future<Null> main() async {

  Crashlytics.instance.enableInDevMode = true;
  // FlutterError.onError = Crashlytics.instance.recordFlutterError;

  // HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark));
  cameras = await availableCameras();
  WidgetsFlutterBinding.ensureInitialized();
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
  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    return MaterialApp(
      // navigatorObservers: [
      //   FirebaseAnalyticsObserver(analytics:  analytics)
      // ],
      title: 'EventEvent',
      debugShowCheckedModeBanner: false,
      navigatorObservers: <NavigatorObserver> [
        observer
      ],
      theme: ThemeData(
          fontFamily: 'Proxima',
          primarySwatch: eventajaGreen,
          backgroundColor: Colors.white),
      // home: CrashlyticsTester(),
      home: SplashScreen(analytics: analytics, observer: observer),
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
