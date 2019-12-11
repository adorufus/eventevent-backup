import 'dart:convert';
import 'dart:io'; 

import 'package:eventevent/Widgets/Home/RestPageNeedLogin.dart';
import 'package:eventevent/Widgets/RecycleableWidget/PostMedia.dart';
import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/Widgets/timeline/TimelineDashboard.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/FirebaseMessagingHelper.dart';
import 'package:eventevent/helper/PushNotification.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PostEvent/PostEvent.dart';
import 'eventCatalogWidget.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:google_places_picker/google_places_picker.dart';
import 'package:eventevent/Widgets/RecycleableWidget/OpenCamera.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
String pushToken;
var initializationSettingsAndroid;
var initializationSettingsIOS;
var initializationSettings;
var scaffoldGlobalKey = GlobalKey<ScaffoldState>();

// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
//   if (message.containsKey('data')) {
//     // Handle data message
//     final dynamic data = message['data'];
//   }

//   if (message.containsKey('notification')) {
//     // Handle notification message
//     final dynamic notification = message['notification'];
//   }

//   // Or do other work.
// }

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async { return Future<void>.value(); }

class DashboardWidget extends StatefulWidget {
  final isRest;

  const DashboardWidget({Key key, this.isRest}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DashboardWidgetState();
  }
}

class _DashboardWidgetState extends State<DashboardWidget>
    with WidgetsBindingObserver {
  int _selectedPage = 0;
  String currentUserId;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String urlPrefix = '';

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

  void registerNotification() {
    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage: $message');
        showNotification(message);
        return;
      },
      onResume: (Map<String, dynamic> message){
        print('onResume: $message');
        return;
      },
      onLaunch: (Map<String, dynamic> message){
        print('onResume: $message');
        return;
      },
      onBackgroundMessage: Theme.of(context).platform == TargetPlatform.iOS ? null : myBackgroundMessageHandler
    );

    _firebaseMessaging.getToken().then((token){
      print('firebase token: $token');
      setState(() {
        pushToken = token;
        saveDeviceToken(token);
      });
    });
  }

  void configureNotification(){
    var initializationSettingAndroid = new AndroidInitializationSettings('launch_background');
    var initializationSettingIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingAndroid, initializationSettingIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'com.eventeven2.android',
        'EventEvent notification channel',
        'channel description',
        playSound: true,
        enableVibration: true,
        importance: Importance.Max,
        priority: Priority.High);

    var iosPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iosPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  @override
  void initState() {
    _saveCurrentRoute('/Dashboard');
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    
    // registerNotification();
    configureNotification();

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

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          print(message['notification']);
        },
        onBackgroundMessage: myBackgroundMessageHandler,
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('on launch $message');
        });
    getPopup().then((response) {
      var extractedData = json.decode(response.body);

      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return GestureDetector(
      //         onTap: () {
      //           Navigator.pop(context);
      //         },
      //         child: Material(
      //           color: Colors.transparent,
      //           child: Center(
      //             child: Container(
      //               height: MediaQuery.of(context).size.height,
      //               width: MediaQuery.of(context).size.width,
      //               margin: EdgeInsets.symmetric(horizontal: 20, vertical: 77),
      //               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      //               decoration: BoxDecoration(
      //                   color: Colors.white,
      //                   borderRadius: BorderRadius.circular(10),
      //                   image: DecorationImage(
      //                       image: NetworkImage(
      //                           'https://home.eventeventapp.com/photo_asset/5d663b08aebcb_popup.jpg'),
      //                       fit: BoxFit.fill)),
      //               child: GestureDetector(
      //                 onTap: (){
      //                   Navigator.pop(context);
      //                 },
      //                   child: Align(
      //                 alignment: Alignment.topRight,
      //                 child: Icon(
      //                   Icons.close,
      //                   color: Colors.white,
      //                   size: 30,
      //                 ),
      //               )),
      //             ),
      //           ),
      //         ),
      //       );
      //     });

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

  @override
  void didChangeDependencies() {
    registerNotification();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      widget.isRest == true ? LoginRegisterWidget() : TimelineDashboard(),
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
                    if (index == 2) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            color: Color(0xFF737373),
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
                                          height: ScreenUtil.instance.setWidth(5),
                                          width: ScreenUtil.instance.setWidth(50),
                                          child: Image.asset(
                                            'assets/icons/icon_line.png',
                                            fit: BoxFit.fill,
                                          ))),
                                  SizedBox(height: ScreenUtil.instance.setWidth(35)),
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
                                                    fontSize: ScreenUtil.instance.setSp(16),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: ScreenUtil.instance.setWidth(5)),
                                              Text(
                                                'Create & sell your own event',
                                                style: TextStyle(
                                                  fontSize: ScreenUtil.instance.setSp(10),
                                                ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            height: ScreenUtil.instance.setWidth(44),
                                            width: ScreenUtil.instance.setWidth(50),
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
                                  SizedBox(height: ScreenUtil.instance.setWidth(19)),
                                  Divider(),
                                  SizedBox(height: ScreenUtil.instance.setWidth(16)),
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
                                                    fontSize: ScreenUtil.instance.setSp(16),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: ScreenUtil.instance.setWidth(4)),
                                              Text(
                                                  'Share your excitement to the others ',
                                                  style: TextStyle(
                                                    fontSize: ScreenUtil.instance.setSp(10),
                                                  ))
                                            ],
                                          ),
                                          Container(
                                            height: ScreenUtil.instance.setWidth(44),
                                            width: ScreenUtil.instance.setWidth(50),
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
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      title: Text(
                        'Discover',
                        style: TextStyle(color: Colors.black26, fontSize: ScreenUtil.instance.setSp(10)),
                      ),
                      icon: Image.asset("assets/icons/aset_icon/eventevent.png",
                          height: ScreenUtil.instance.setWidth(25), width: ScreenUtil.instance.setWidth(25)),
                      activeIcon: Image.asset(
                        "assets/icons/aset_icon/eventevent.png",
                        height: ScreenUtil.instance.setWidth(25),
                        width: ScreenUtil.instance.setWidth(25),
                        color: eventajaGreenTeal,
                      )),
                  BottomNavigationBarItem(
                      title: Text(
                        'Timeline',
                        style: TextStyle(color: Colors.black26, fontSize: ScreenUtil.instance.setSp(10)),
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
                        style: TextStyle(color: Colors.black26, fontSize: ScreenUtil.instance.setSp(10)),
                      ),
                      icon: Image.asset("assets/icons/aset_icon/post.png",
                          height: ScreenUtil.instance.setWidth(25), width: ScreenUtil.instance.setWidth(25)),
                      activeIcon: Image.asset(
                        "assets/icons/aset_icon/post.png",
                        height: ScreenUtil.instance.setWidth(25),
                        width: ScreenUtil.instance.setWidth(25),
                        color: eventajaGreenTeal,
                      )),
                  BottomNavigationBarItem(
                    title: Text(
                      'Notification',
                      style: TextStyle(color: Colors.black26, fontSize: ScreenUtil.instance.setSp(10)),
                    ),
                    icon: Image.asset("assets/icons/aset_icon/notif.png",
                        height: ScreenUtil.instance.setWidth(25), width: ScreenUtil.instance.setWidth(25)),
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
                      style: TextStyle(color: Colors.black26, fontSize: ScreenUtil.instance.setSp(10)),
                    ),
                    icon: Image.asset("assets/icons/aset_icon/profile.png",
                        height: ScreenUtil.instance.setWidth(25), width: ScreenUtil.instance.setWidth(25)),
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

  void initLocalNotification() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS =
        new IOSInitializationSettings(defaultPresentBadge: true);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future<void> _showNotification(String title, String body,
      {String payload}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel desc',
        importance: Importance.Max, priority: Priority.High);
    var iosPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iosPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
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
}
