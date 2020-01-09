import 'dart:convert' show json, utf8;

import 'package:eventevent/Widgets/ManageEvent/ShowQr.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WithdrawBank.dart';
import 'package:eventevent/Widgets/TransactionHistory.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/Widgets/timeline/LovedOnYourFollowingDetails.dart';
import 'package:eventevent/Widgets/timeline/UserMediaDetail.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class PushNotification extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PushNotificationState();
  }
}

class PushNotificationState extends State<PushNotification> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController refreshController =
      new RefreshController(initialRefresh: false);
  List notificationData;
  StreamController _notificationStreamController;
  int count = 1;
  int newPage = 0;

  String pushToken;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS =
        new IOSInitializationSettings(defaultPresentBadge: true);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _notificationStreamController = new StreamController();
    getNotification().then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          notificationData = extractedData['data'];
          assert(notificationData != null);

          print(notificationData);

//          _showNotification(
//              notificationData[0]['fullName'], notificationData[0]['caption'],
//              payload: 'test');

          // for(int i =   0; i <= notificationData.length; i +r= notificationData.length){
          //   _showNotification(notificationData[i]['fullName'], notificationData[i]['caption']);
          // }

          return extractedData;
        });
      }
    });
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
        .show(0, title, body, platformChannelSpecifics, payload: payload);
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    getNotification(page: newPage).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          List updatedData = extractedData['data'];
          print('data: ' + updatedData.toString());
          notificationData.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      }
    });
  }

  // Future<void> onDidReceiveLocalNotification(int id, String title, String body, String payload) async{
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) => CupertinoAlertDialog(
  //       title: Text(title),
  //       content: Text(body),
  //       actions: [
  //         CupertinoDialogAction(
  //           isDefaultAction: true,
  //           child: Text('Ok'),
  //           onPressed: ()async{
  //             Navigator.of
  //           },
  //         )
  //       ],
  //     )
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
        key: scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size(null, 100),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil.instance.setWidth(75),
            child: Container(
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.fromLTRB(13, 15, 13, 0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Notification',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil.instance.setSp(14)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Container(
          child: notificationData == null
              ? Container(
                  child: Center(
                    child: CupertinoActivityIndicator(radius: 20),
                  ),
                )
              : SmartRefresher(
                  controller: refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("Load data");
                    } else if (mode == LoadStatus.loading) {
                      body = CupertinoActivityIndicator(radius: 20);
                    } else if (mode == LoadStatus.failed) {
                      body = Text("Load Failed!");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text('More');
                    } else {
                      body = Container();
                    }

                    return Container(
                        height: ScreenUtil.instance.setWidth(35),
                        child: Center(child: body));
                  }),
                  onRefresh: () {
                    setState(() {
                      newPage = 0;
                    });

                    getNotification().then((response) {
                      if (response.statusCode == 200) {
                        setState(() {
                          var extractedData = json.decode(response.body);
                          notificationData = extractedData['data'];
                          assert(notificationData != null);

                          print(notificationData);

//                          _showNotification(notificationData[0]['fullName'],
//                              notificationData[0]['caption'],
//                              payload: 'test');

                          // for(int i =   0; i <= notificationData.length; i +r= notificationData.length){
                          //   _showNotification(notificationData[i]['fullName'], notificationData[i]['caption']);
                          // }

                          return extractedData;
                        });
                      }
                    });

                    if (mounted) setState(() {});
                    refreshController.refreshCompleted();
                  },
                  onLoading: _onLoading,
                  child: ListView(children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 13, right: 13, top: 13),
                      height: ScreenUtil.instance.setWidth(60),
                      decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                spreadRadius: 1.5)
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        WithdrawBank()));
                          },
                          leading: Container(
                            height: ScreenUtil.instance.setWidth(25),
                            width: ScreenUtil.instance.setWidth(25),
                            child: Image.asset(
                                'assets/icons/icon_apps/my_balance.png',
                                scale: 3),
                          ),
                          title: Text('My Balance',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(13))),
                          trailing: Icon(
                            Icons.navigate_next,
                            size: 25,
                            color: eventajaGreenTeal,
                          )),
                    ),
                    SizedBox(height: ScreenUtil.instance.setWidth(9)),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 13),
                      height: ScreenUtil.instance.setWidth(60),
                      decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                spreadRadius: 1.5)
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        TransactionHistory()));
                          },
                          leading: Container(
                              width: ScreenUtil.instance.setWidth(25),
                              height: ScreenUtil.instance.setWidth(25),
                              child: Image.asset(
                                  'assets/icons/icon_apps/paymentstatus.png')),
                          title: Text('Payment Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(13))),
                          trailing: Icon(
                            Icons.navigate_next,
                            size: 25,
                            color: eventajaGreenTeal,
                          )),
                    ),
                    ColumnBuilder(
                      itemCount: notificationData.length == 0
                          ? 0
                          : notificationData.length,
                      itemBuilder: (context, i) {
                        return Container(
                          height: ScreenUtil.instance.setWidth(60),
                          margin: EdgeInsets.symmetric(horizontal: 13),
                          child:
                              // Container(
                              //     child: Row(
                              //   crossAxisAlignment: CrossAxisAlignment.center,
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //   children: <Widget>[
                              //     Image.asset('assets/icons/icon_apps/nearby.png',
                              //         scale: 3),
                              //         SizedBox(width: ScreenUtil.instance.setWidth(13)),
                              //     Column(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       children: <Widget>[
                              //         Text(
                              //           notificationData[i]['fullName'] + ':',
                              //           style: TextStyle(
                              //               fontSize: ScreenUtil.instance.setSp(13),
                              //               fontWeight: FontWeight.bold),
                              //         ),
                              //         Container(
                              //           height: ScreenUtil.instance.setWidth(40),
                              //           child: Text(
                              //             notificationData[i]['caption'],
                              //             maxLines: 5,
                              //             softWrap: true,
                              //           ),
                              //         ),
                              //       ],
                              //     )
                              //   ],
                              // ))

                              ListTile(
                            onTap: () {
                              doNavigateOnPressedNotification(i);
                            },
                            contentPadding: EdgeInsets.only(bottom: 15),
                            leading: Container(
                              height: ScreenUtil.instance.setWidth(25),
                              width: ScreenUtil.instance.setWidth(25),
                              child: Image.asset(
                                'assets/icons/icon_apps/announcement.png',
                              ),
                            ),
                            title: Text(
                              notificationData[i]['fullName'] + ':',
                              style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(13),
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(notificationData[i]['caption']),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
        ));
  }

  doNavigateOnPressedNotification(int index) {
    if (notificationData[index]['type'] == 'reminder_event') {
      navigationHandler(EventDetailsConstructView(
        id: notificationData[index]['id'],
      ));
    } else if (notificationData[index]['type'] == 'relationship') {
      navigationHandler(ProfileWidget(
        userId: notificationData[index]['id'],
        initialIndex: 0,
      ));
    } else if (notificationData[index]['type'] == 'live_stream_cancel') {
      navigationHandler(EventDetailsConstructView(
        id: notificationData[index]['id'],
      ));
    } else if (notificationData[index]['type'] == 'photo_comment') {
      navigationHandler(UserMediaDetail(
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] ==
        'combined_relationship_impression') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'combined_relationship',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'relationship_comment') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'relationship',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'relationship_impression') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'relationship',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'thought_impression') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'thought',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'eventcheckin_impression') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'eventcheckin',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'eventcheckin_comment') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'eventcheckin',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'checkin_impression') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'checkin',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'checkin_comment') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'checkin',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'love_comment') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'love',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'love_impression') {
      navigationHandler(LovedOnYourFollowingDetails(
        mediaType: 'love',
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'event_comment') {
      navigationHandler(UserMediaDetail(
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'eventgoingstatus') {
      navigationHandler(EventDetailsConstructView(
        id: notificationData[index]['id'],
      ));
    } else if (notificationData[index]['type'] == 'photo_impression') {
      navigationHandler(UserMediaDetail(
        postID: notificationData[index]['id'],
        autoFocus: true,
      ));
    } else if (notificationData[index]['type'] == 'event') {
      navigationHandler(
          EventDetailsConstructView(id: notificationData[index]['id']));
    } else if (notificationData[index]['type'] == 'eventinvite') {
      navigationHandler(
          EventDetailsConstructView(id: notificationData[index]['id']));
    } else if (notificationData[index]['type'] == 'reminder_qr') {
      navigationHandler(ShowQr(
        qrUrl: notificationData[index][''],
      ));
    }
  }

  navigationHandler(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future<http.Response> getNotification({int page}) async {
    print('[BackgroundFetch] Headless event received1.');
    SharedPreferences preferences = await SharedPreferences.getInstance();

    int currentPage = 1;

    setState(() {
      if (page != null) {
        currentPage += page;
      }
    });

    var url = BaseApi().apiUrl +
        '/user/notification?X-API-KEY=$API_KEY&page=$currentPage';

    var response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    });

    print(response.statusCode);

    return response;

    // BackgroundFetch.finish();
    return json.decode(response.body);
  }

  Future<Null> _handleRefresh() async {
    count++;
    print(count);
    getNotification().then((res) async {
      _notificationStreamController.add(res);
      return res;
    });
  }

  Future fetchPushNotif(String body, String title, String token) async {
    print('[BackgroundFetch] Headless event received1.');
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/device/notif';

    final response = await http.post(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'body': body,
      'title': title,
      'token': token
    });

    print(response.statusCode);
    // BackgroundFetch.finish();
  }

  // loadNotification(GlobalKey<ScaffoldState> scaffoldKey) async {
  //   getNotification().then((res) async {
  //     setState(() {
  //       _notificationStreamController.add(res);
  //       print(res['desc']);
  //       return res;
  //     });
  //   }).timeout(Duration(minutes: 5), onTimeout: () {
  //     scaffoldKey.currentState.showSnackBar(SnackBar(
  //       content: Text('Request Timeout!'),
  //       backgroundColor: Colors.red,
  //     ));
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
  }
}
