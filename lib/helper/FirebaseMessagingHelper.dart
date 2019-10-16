import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
String pushToken;
var initializationSettingsAndroid;
var initializationSettingsIOS;
var initializationSettings;

class FirebaseMessagingHelper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FirebaseMessagingHelperState();
  }
}

class FirebaseMessagingHelperState extends State<FirebaseMessagingHelper> {
  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    firebaseCloudMessaging_listeners();
    initLocalNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
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

  Future<void> onSelectNotification(String payload) async{
    if(payload != null){
      debugPrint('notification payload: ' + payload);
    }
  }

  Future<void> _showNotification(String title, String body, {String payload}) async{
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id', 'channel name', 'channel desc',
      importance: Importance.Max, priority: Priority.High
    );
    var iosPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iosPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics, payload: payload
    );
  }

  void firebaseCloudMessaging_listeners() {
    _firebaseMessaging.getToken().then((token) {
      print(token);
      setState(() {
        pushToken = token;
      });
    });

    _firebaseMessaging.setAutoInitEnabled(true);

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
      _showNotification(message['title'], message['body']);
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
    });
  }
}
