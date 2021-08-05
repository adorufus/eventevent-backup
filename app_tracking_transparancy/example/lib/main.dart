import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:app_tracking_transparancy/app_tracking_transparancy.dart';

void main() => runApp(MaterialApp(
  home: MyApp(),
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String authStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initPlatformState());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if(await AppTrackingTransparancy.trackingAuthorizationStatus == TrackingStatus.notDetermined){
      final TrackingStatus status = await AppTrackingTransparancy.requestTrakingAuthorization();

        setState(() {
          authStatus = "$status";
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Auth Status: $authStatus\n'),
        ),
    );
  }
}
