import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/MerchBannerModel.dart';
import 'package:eventevent/Providers/EventListProviders.dart';
import 'package:eventevent/Redux/Reducers/BannerReducers.dart';
import 'package:eventevent/Redux/Reducers/appReducers.dart';
import 'package:eventevent/Widgets/ManageEvent/ShowQr.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WithdrawBank.dart';
import 'package:eventevent/Widgets/timeline/UserMediaDetail.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_redux/flutter_redux.dart';
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
import 'package:redux/redux.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Redux/Reducers/logger.dart';
import 'Widgets/loginRegisterWidget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/services.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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

  // Map<Permission, PermissionStatus> permissions =
  //     await [Permission.location, Permission.storage].request();
  // PermissionStatus checkPermission = permissions[Permission.storage];

  // print(checkPermission.toString());

  // if (checkPermission == PermissionStatus.granted) {}
  // File storage = File(Platform.isIOS ? (await getLibraryDirectory()).absolute.path + '/appstate.json' : (await getExternalStorageDirectory()).absolute.path + '/appstate.json');
  // final persistor = Persistor<AppState>(
  //     storage: FileStorage(storage),
  //     serializer: JsonSerializer<AppState>(AppState.fromJson));

  // final initialState = await persistor.load();

  final store = new Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [
      thunkMiddleware,
      apiMiddleware,
      loggingMiddleware,
      // persistor.createMiddleware()
    ],
  );

  runZoned(() {
    runApp(new RunApp(
      store: store,
    ));
  }, onError: Crashlytics.instance.recordError);
}

class RunApp extends StatefulWidget {
  // This widget is the root of your application.

  final store;

  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  const RunApp({Key key, this.store}) : super(key: key);

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
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
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
      ),
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
