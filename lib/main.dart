import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:clevertap_plugin/clevertap_plugin.dart';
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
  

  CleverTapPlugin _clevertapPlugin;
  var inboxInitialized = false;
  var optOut = false;
  var offLine = false;
  var enableDeviceNetworkingInfo = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    CleverTapPlugin.setDebugLevel(3);
    CleverTapPlugin.createNotificationChannel("com.eventevent.android", "Eventevent clevertap", "for clevertap notification", 3, true);
    CleverTapPlugin.registerForPush();
    var initialUrl = CleverTapPlugin.getInitialUrl();
  }

  Future<void> initPlatformState() async {
    if(!mounted) return;
  }

  void activateClevertapHandler() {
    _clevertapPlugin = new CleverTapPlugin();
    _clevertapPlugin.setCleverTapPushAmpPayloadReceivedHandler(pushAmpPayloadReceived);
    _clevertapPlugin.setCleverTapInAppNotificationDismissedHandler(inAppNotificationDismissed);
    _clevertapPlugin.setCleverTapProfileDidInitializeHandler(profileDidInitialize);
    _clevertapPlugin.setCleverTapProfileSyncHandler(profileDidUpdate);
    _clevertapPlugin.setCleverTapInboxDidInitializeHandler(inboxDidInitialize);
    _clevertapPlugin.setCleverTapInboxMessagesDidUpdateHandler(inboxMessagesDidUpdate);
    _clevertapPlugin.setCleverTapExperimentsDidUpdateHandler(ctExperimentsUpdated);
    _clevertapPlugin.setCleverTapDisplayUnitsLoadedHandler(onDisplayUnitsLoaded);
    _clevertapPlugin.setCleverTapInAppNotificationButtonClickedHandler(inAppNotificationButtonClicked);
    _clevertapPlugin.setCleverTapInboxNotificationButtonClickedHandler(inboxNotificationButtonClicked);
    _clevertapPlugin.setCleverTapFeatureFlagUpdatedHandler(featureFlagsUpdated);
    _clevertapPlugin.setCleverTapProductConfigInitializedHandler(productConfigInitialized);
    _clevertapPlugin.setCleverTapProductConfigFetchedHandler(productConfigFetched);
    _clevertapPlugin.setCleverTapProductConfigActivatedHandler(productConfigActivated);
  }

  void inAppNotificationDismissed(Map<String,dynamic> map){
    this.setState((){
      print("inAppNotificationDismissed called");
    });
  }

  void inAppNotificationButtonClicked(Map<String,dynamic> map){
    this.setState((){
      print("inAppNotificationButtonClicked called = ${map.toString()}");
    });
  }

  void inboxNotificationButtonClicked(Map<String,dynamic> map){
    this.setState((){
      print("inboxNotificationButtonClicked called = ${map.toString()}");
    });
  }

  void profileDidInitialize(){
    this.setState((){
      print("profileDidInitialize called");
    });
  }

  void profileDidUpdate(Map<String,dynamic> map){
    this.setState((){
      print("profileDidUpdate called");
    });
  }

  void inboxDidInitialize(){
    this.setState((){
      print("inboxDidInitialize called");
      inboxInitialized = true;
    });
  }

  void inboxMessagesDidUpdate(){
    this.setState(() async {
      print("inboxMessagesDidUpdate called");
      int unread = await CleverTapPlugin.getInboxMessageUnreadCount();
      int total = await CleverTapPlugin.getInboxMessageCount();
      print("Unread count = "+unread.toString());
      print("Total count = "+total.toString());
    });
  }

  void ctExperimentsUpdated(){
    this.setState(() async {
      print("CTExperimentsUpdated called");
      bool booleanVar = await CleverTapPlugin.getBooleanVariable("boolVar", false);
      print("Boolean var = " + booleanVar.toString());
      double doubleVar = await CleverTapPlugin.getDoubleVariable("doubleVar", 9.99);
      print("Double var = " + doubleVar.toString());
      int integerVar = await CleverTapPlugin.getIntegerVariable("integerVar", 999);
      print("Integer var = "+integerVar.toString());
      String stringVar = await CleverTapPlugin.getStringVariable("stringVar", "defaultString");
      print("String var = "+stringVar.toString());
      List<dynamic> boolList = await CleverTapPlugin.getListOfBooleanVariable("boolListVar", null);
      print("List of bool = "+boolList.toString());
      List<dynamic> doubleList = await CleverTapPlugin.getListOfDoubleVariable("doubleListVar", null);
      print("List of double = "+doubleList.toString());
      List<dynamic> intList = await CleverTapPlugin.getListOfIntegerVariable("integerListVar", null);
      print("Integer List = "+intList.toString());
      List<dynamic> stringList = await CleverTapPlugin.getListOfStringVariable("stringListVar", null);
      print("String List = "+stringList.toString());
//      Map<String,bool> boolMap = await CleverTapPlugin.getMapOfBooleanVariable("boolMapVar", null);
//      print("Map of bool = "+boolMap.toString());
//      Map<String,double> doubleMap = await CleverTapPlugin.getMapOfDoubleVariable("doubleMapVar", null);
//      print("Map of double = "+doubleMap.toString());
//      Map<String,int> intMap = await CleverTapPlugin.getMapOfIntegerVariable("integerMapVar", null);
//      print("Map of int = "+boolMap.toString());
//      Map<String,String> strMap = await CleverTapPlugin.getMapOfStringVariable("stringMapVar", null);
//      print("Map of string = "+strMap.toString());
    });
  }

  void onDisplayUnitsLoaded(List<dynamic> displayUnits){
    this.setState(() async {
      List displayUnits = await CleverTapPlugin.getAllDisplayUnits();
      print("Display Units = "+ displayUnits.toString());
    });
  }

  void featureFlagsUpdated(){
    print("Feature Flags Updated");
    this.setState(() async {
      bool booleanVar = await CleverTapPlugin.getFeatureFlag("BoolKey", false);
      print("Feature flag = " + booleanVar.toString());
    });
  }

  void productConfigInitialized(){
    print("Product Config Initialized");
    this.setState(() async {
      await CleverTapPlugin.fetch();
    });
  }

  void productConfigFetched(){
    print("Product Config Fetched");
    this.setState(() async {
      await CleverTapPlugin.activate();
    });

  }

  void productConfigActivated(){
    print("Product Config Activated");
    this.setState(() async {
      String stringvar = await CleverTapPlugin.getProductConfigString("StringKey");
      print("PC String = " + stringvar.toString());
      int intvar = await CleverTapPlugin.getProductConfigLong("IntKey");
      print("PC int = " + intvar.toString());
      double doublevar = await CleverTapPlugin.getProductConfigDouble("DoubleKey");
      print("PC double = " + doublevar.toString());
    });
  }

  void pushAmpPayloadReceived(Map<String,dynamic> map){
    print("pushAmpPayloadReceived called");
    this.setState(() async {
      var data = jsonEncode(map);
      print("JSON = "+data.toString());
      CleverTapPlugin.createNotification(data);
    });
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
      home: AnnotatedRegion<SystemUiOverlayStyle>(
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
