import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/ManageEvent/ShowQr.dart';
import 'package:eventevent/Widgets/RecycleableWidget/PostMedia.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/Widgets/timeline/LovedOnYourFollowingDetails.dart';
import 'package:eventevent/Widgets/timeline/TimelineDashboard.dart';
import 'package:eventevent/Widgets/timeline/UserMediaDetail.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/PushNotification.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PostEvent/PostEvent.dart';
import 'eventCatalogWidget.dart';
import 'package:rxdart/rxdart.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

var scaffoldGlobalKey = GlobalKey<ScaffoldState>();
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();
final BehaviorSubject<RecievedNotification> didRecieveLocalNotificationSubject =
    BehaviorSubject<RecievedNotification>();
final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

class RecievedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  RecievedNotification(this.id, this.title, this.body, this.payload);
}

String pushToken;
var initializationSettingsAndroid;
var initializationSettingsIOS;
var initializationSettings;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  return Future<void>.value();
}

class DashboardWidget extends StatefulWidget {
  final isRest;
  final selectedPage;

  const DashboardWidget({Key key, this.isRest, this.selectedPage = 0})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DashboardWidgetState();
  }
}

class _DashboardWidgetState extends State<DashboardWidget>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  int _selectedPage = 0;
  String currentUserId;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String urlPrefix = '';

  // RateMyApp rateMyApp = RateMyApp(
  //   preferencesPrefix: 'rateMyApp_',
  //   minDays: 1,
  //   minLaunches: 1,
  //   remindDays: 2,
  //   remindLaunches: 5,
  //   googlePlayIdentifier: 'com.eventevent.android',
  //   appStoreIdentifier: 'com.trikarya.eventevent',
  // );

  StreamSubscription<Map> streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();

  void listenDynamicLink() async {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) {
      controllerData.sink.add((data.toString()));
      if (data.containsKey("+clicked_branch_link") &&
          data["+clicked_branch_link"] == true) {
        print(data);
        print(data['event_id']);
        Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailLoadingScreen(
          eventId: data['event_id'],
        )));
      }
      print(data);
      print(data['event_id']);
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      print(
          'InitSession error: ${platformException.code} - ${platformException.message}');
      controllerInitSession.add(
          'InitSession error: ${platformException.code} - ${platformException.message}');
    });
  }

  _saveCurrentRoute(String lastRoute) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('LastScreenRoute', lastRoute);
  }

  getProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      currentUserId = prefs.getString('Last User ID');
    });
  }

  @override
  void initState() {
    // rateMyApp.init().then((_) {
    //     rateMyApp.showStarRateDialog(context,
    //         title: 'Enjoying EventEvent?',
    //         message: 'Please leave a rating!', onRatingChanged: (stars) {
    //       return [
    //         FlatButton(
    //           child: Text('Ok'),
    //           onPressed: () {
    //             if (stars != null) {
    //               DoNotOpenAgainCondition(rateMyApp).doNotOpenAgain = true;
    //               rateMyApp.save().then((val) {
    //                 Navigator.pop(context);
    //               });
    //             } else {
    //               Navigator.pop(context);
    //             }
    //           },
    //         )
    //       ];
    //     },
    //         dialogStyle: DialogStyle(
    //             titleAlign: TextAlign.center,
    //             messageAlign: TextAlign.center,
    //             messagePadding: EdgeInsets.only(bottom: 20)),
    //         starRatingOptions: StarRatingOptions(
    //           starsFillColor: eventajaGreenTeal,
    //           allowHalfRating: true,
    //           initialRating: 5,
    //         ));
    // });

    listenDynamicLink();
    
    _saveCurrentRoute('/Dashboard');
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS =
        new IOSInitializationSettings(defaultPresentBadge: true);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification Payload: ' + payload);
      }
      selectNotificationSubject.add(payload);
    });

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          print(message['notification']);
        },
        onBackgroundMessage: myBackgroundMessageHandler,
        onResume: (Map<String, dynamic> message) async {
          List<Widget> navPages = [
            EventDetailsConstructView(id: '15'),
          ];

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => navPages[0]));
          print('on resume $message');
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('on launch $message');
        });

    // didRecieveLocalNotificationSubject.stream.listen((RecievedNotification recievedNotification) async {

    // });

    selectNotificationSubject.stream.listen((String payload) async {
      await onSelectNotification(payload);
    });

    if (widget.selectedPage == null) {
      _selectedPage = 0;
    }

    _selectedPage = widget.selectedPage;

    // registerNotification();
    // configureNotification();

    if (widget.isRest == true) {
      setState(() {
        urlPrefix = 'rest';
      });
    } else {
      setState(() {
        urlPrefix = 'home';
      });
    }

    getProfileData();

    print('push token: $pushToken');

    getPopup().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 77),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              image:
                                  NetworkImage(extractedData['data']['photo']),
                              fit: BoxFit.fill)),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                          )),
                    ),
                  ),
                ),
              );
            });
      } else {
        print(response.statusCode);
        print(response.body);
      }
    });
  }

  navigationHandler(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      Map payloadData = json.decode(payload);
      print(payloadData.toString());

      if (payloadData['data']['type'] == 'reminder_event') {
        navigationHandler(EventDetailLoadingScreen(
          eventId: payloadData['data']['id'],
        ));
      } else if (payloadData['data']['type'] == 'relationship') {
        navigationHandler(ProfileWidget(
          userId: payloadData['data']['id'],
          initialIndex: 0,
        ));
      } else if (payloadData['data']['type'] == 'live_stream_cancel') {
        navigationHandler(EventDetailLoadingScreen(
          eventId: payloadData['data']['id']
        ));
      } else if (payloadData['data']['type'] == 'photo_comment') {
        navigationHandler(UserMediaDetail(
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] ==
          'combined_relationship_impression') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'combined_relationship',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'relationship_comment') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'relationship',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'relationship_impression') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'relationship',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'thought_impression') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'thought',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'eventcheckin_impression') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'eventcheckin',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'eventcheckin_comment') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'eventcheckin',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'checkin_impression') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'checkin',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'checkin_comment') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'checkin',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'love_comment') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'love',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'love_impression') {
        navigationHandler(LovedOnYourFollowingDetails(
          mediaType: 'love',
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'event_comment') {
        navigationHandler(UserMediaDetail(
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'eventgoingstatus') {
        navigationHandler(EventDetailLoadingScreen(
          eventId: payloadData['data']['id']
        ));
      } else if (payloadData['data']['type'] == 'eventdetail_comment') {
        navigationHandler(EventDetailLoadingScreen(
          eventId: payloadData['data']['id']
        ));
      } else if (payloadData['data']['type'] == 'eventdetail_love') {
        navigationHandler(EventDetailLoadingScreen(
          eventId: payloadData['data']['id']
        ));
      } else if (payloadData['data']['type'] == 'photo_impression') {
        navigationHandler(UserMediaDetail(
          postID: payloadData['data']['id'],
          autoFocus: true,
        ));
      } else if (payloadData['data']['type'] == 'event') {
        navigationHandler(
            EventDetailLoadingScreen(
              eventId: payloadData['data']['id']
            ));
      } else if (payloadData['data']['type'] == 'eventinvite') {
        navigationHandler(
            EventDetailLoadingScreen(
              eventId: payloadData['data']['id']
            ));
      } else if (payloadData['data']['type'] == 'reminder_qr') {
        navigationHandler(ShowQr(
          qrUrl: payloadData['data']['id'],
        ));
      }
    }
  }

  @override
  void didChangeDependencies() {
    registerNotification();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    selectNotificationSubject.close();
    super.dispose();
  }

  void showNotification(message) async {
    var notificationAppLaunchDetail =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'com.eventeven2.android',
        'EventEvent notification channel',
        'channel description',
        playSound: true,
        enableVibration: true,
        channelShowBadge: true,
        importance: Importance.High,
        priority: Priority.High);

    var iosPlatformChannelSpecifics =
        new IOSNotificationDetails(presentBadge: true, presentSound: true);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iosPlatformChannelSpecifics);

    print('message: ' + message.toString());
    print('message: ' + message['notification'].toString());

    await flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'],
        message['notification']['body'],
        platformChannelSpecifics,
        payload: json.encode(message));

    // flutterLocalNotificationsPlugin.didReceiveLocalNotificationCallback();
  }

  Future saveDeviceToken(String pushTokens) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/device/token';

    final response = await http.post(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'token': pushTokens
    });

    print(response.statusCode);
    print(response.body);
    print('token sent');
    print(prefs.getKeys());
  }

  void registerNotification() {
    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print('onMessage: $message');
          showNotification(message);
          return;
        },
        onResume: (Map<String, dynamic> message) {
          print('onResume: $message');
          return;
        },
        onLaunch: (Map<String, dynamic> message) {
          print('onResume: $message');
          return;
        },
        onBackgroundMessage: Theme.of(context).platform == TargetPlatform.iOS
            ? null
            : myBackgroundMessageHandler);

    _firebaseMessaging.getToken().then((token) {
      print('firebase token: $token');
      setState(() {
        pushToken = token;
        saveDeviceToken(token);
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    super.didChangeAppLifecycleState(state);
  }

  Future<bool> _onWillPop() {
    if (_selectedPage == 0) {
      exit(0);
    } else {
      setState(() {
        _selectedPage = 0;
      });
    }
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

    final _pageOptions = [
      EventCatalog(isRest: widget.isRest),
      TimelineDashboard(isRest: widget.isRest),
      widget.isRest == true ? LoginRegisterWidget() : Container(),
      widget.isRest == true ? LoginRegisterWidget() : PushNotification(),
      widget.isRest == true
          ? LoginRegisterWidget()
          : ProfileWidget(
              initialIndex: 0,
              userId: currentUserId,
            ),
    ];

    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          // appBar: AppBar(
          //   leading: ,
          // ),
          key: scaffoldKey,
          backgroundColor: Colors.grey[100],
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: CupertinoTabBar(
                currentIndex: _selectedPage,
                onTap: (int index) {
                  setState(() {
                    if (index == 2 && widget.isRest == false) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            color: Colors.white,
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: 13, left: 25, right: 25, bottom: 30),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  )),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 50),
                                      child: SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(5),
                                          width:
                                              ScreenUtil.instance.setWidth(50),
                                          child: Image.asset(
                                            'assets/icons/icon_line.png',
                                            fit: BoxFit.fill,
                                          ))),
                                  SizedBox(
                                      height: ScreenUtil.instance.setWidth(35)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: 'PostEvent'),
                                              builder: (BuildContext context) =>
                                                  PostEvent()));
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'New Event',
                                                style: TextStyle(
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(16),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                  height: ScreenUtil.instance
                                                      .setWidth(5)),
                                              Text(
                                                'Create & sell your own event',
                                                style: TextStyle(
                                                  fontSize: ScreenUtil.instance
                                                      .setSp(10),
                                                ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            height: ScreenUtil.instance
                                                .setWidth(44),
                                            width: ScreenUtil.instance
                                                .setWidth(50),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/icons/page_post_event.png'),
                                                    fit: BoxFit.fill),
                                                borderRadius: BorderRadius.circular(11),
                                                boxShadow: <BoxShadow>[
                                                  BoxShadow(
                                                      blurRadius: 10,
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: .5)
                                                ]),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: ScreenUtil.instance.setWidth(19)),
                                  Divider(),
                                  SizedBox(
                                      height: ScreenUtil.instance.setWidth(16)),
                                  GestureDetector(
                                    onTap: () {
                                      // imageCaputreCamera();
                                      Navigator.of(context)
                                          .pushNamed('/CustomCamera');
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Post Media',
                                                style: TextStyle(
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(16),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                  height: ScreenUtil.instance
                                                      .setWidth(4)),
                                              Text(
                                                  'Share your excitement to the others ',
                                                  style: TextStyle(
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(10),
                                                  ))
                                            ],
                                          ),
                                          Container(
                                            height: ScreenUtil.instance
                                                .setWidth(44),
                                            width: ScreenUtil.instance
                                                .setWidth(50),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/icons/page_post_media.png'),
                                                    fit: BoxFit.fill),
                                                borderRadius: BorderRadius.circular(11),
                                                boxShadow: <BoxShadow>[
                                                  BoxShadow(
                                                      blurRadius: 10,
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: .5)
                                                ]),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        elevation: 1,
                      );
                    } else {
                      _selectedPage = index;
                    }
                  });
                },
                backgroundColor: Colors.white,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      title: Text(
                        'Discover',
                        style: TextStyle(
                            color: Colors.black26,
                            fontSize: ScreenUtil.instance.setSp(10)),
                      ),
                      icon: Image.asset("assets/icons/aset_icon/eventevent.png",
                          height: ScreenUtil.instance.setWidth(25),
                          width: ScreenUtil.instance.setWidth(25)),
                      activeIcon: Image.asset(
                        "assets/icons/aset_icon/eventevent.png",
                        height: ScreenUtil.instance.setWidth(25),
                        width: ScreenUtil.instance.setWidth(25),
                        color: eventajaGreenTeal,
                      )),
                  BottomNavigationBarItem(
                      title: Text(
                        'Media',
                        style: TextStyle(
                            color: Colors.black26,
                            fontSize: ScreenUtil.instance.setSp(10)),
                      ),
                      icon: Image.asset(
                        "assets/icons/aset_icon/timeline.png",
                        height: ScreenUtil.instance.setWidth(25),
                        width: ScreenUtil.instance.setWidth(25),
                      ),
                      activeIcon: Image.asset(
                        "assets/icons/aset_icon/timeline.png",
                        height: ScreenUtil.instance.setWidth(25),
                        width: ScreenUtil.instance.setWidth(25),
                        color: eventajaGreenTeal,
                      )),
                  BottomNavigationBarItem(
                      title: Text(
                        'Post',
                        style: TextStyle(
                            color: Colors.black26,
                            fontSize: ScreenUtil.instance.setSp(10)),
                      ),
                      icon: Image.asset("assets/icons/aset_icon/post.png",
                          height: ScreenUtil.instance.setWidth(25),
                          width: ScreenUtil.instance.setWidth(25)),
                      activeIcon: Image.asset(
                        "assets/icons/aset_icon/post.png",
                        height: ScreenUtil.instance.setWidth(25),
                        width: ScreenUtil.instance.setWidth(25),
                        color: eventajaGreenTeal,
                      )),
                  BottomNavigationBarItem(
                    title: Text(
                      'Notification',
                      style: TextStyle(
                          color: Colors.black26,
                          fontSize: ScreenUtil.instance.setSp(10)),
                    ),
                    icon: Image.asset("assets/icons/aset_icon/notif.png",
                        height: ScreenUtil.instance.setWidth(25),
                        width: ScreenUtil.instance.setWidth(25)),
                    activeIcon: Image.asset(
                      "assets/icons/aset_icon/notif.png",
                      height: ScreenUtil.instance.setWidth(25),
                      width: ScreenUtil.instance.setWidth(25),
                      color: eventajaGreenTeal,
                    ),
                  ),
                  BottomNavigationBarItem(
                    title: Text(
                      'Profile',
                      style: TextStyle(
                          color: Colors.black26,
                          fontSize: ScreenUtil.instance.setSp(10)),
                    ),
                    icon: Image.asset("assets/icons/aset_icon/profile.png",
                        height: ScreenUtil.instance.setWidth(25),
                        width: ScreenUtil.instance.setWidth(25)),
                    activeIcon: Image.asset(
                      "assets/icons/aset_icon/profile.png",
                      height: ScreenUtil.instance.setWidth(25),
                      width: ScreenUtil.instance.setWidth(25),
                      color: eventajaGreenTeal,
                    ),
                  )
                ]),
          ),
          body: _pageOptions[_selectedPage],
        ),
      ),
    );
  }

  Future<http.Response> getPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/announcement?X-API-KEY=$API_KEY';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }

  void imageCaputreCamera() async {
    var galleryFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );

    print(galleryFile.path);
    cropImage(galleryFile);
  }

  Future<Null> cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(
        ratioX: 2.0,
        ratioY: 3.0,
      ),
      maxHeight: ScreenUtil.instance.setWidth(512),
      maxWidth: ScreenUtil.instance.setWidth(512),
    );

    print(croppedImage.path);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => PostMedia(
                  imagePath: croppedImage,
                )));
  }

  settingBottomSheet() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return new Container(
            child: Wrap(
              children: <Widget>[
                new ListTile(
                  leading: new Icon(
                    Icons.add_circle_outline,
                    color: eventajaGreenTeal,
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
