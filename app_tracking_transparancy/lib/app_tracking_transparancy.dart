import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TrackingStatus {
  notDetermined,
  restricted,
  denied,
  authorized,
  notSupported,
}

class AppTrackingTransparancy {
  static const MethodChannel _channel =
      const MethodChannel('app_tracking_transparancy');

  static Future<TrackingStatus> get trackingAuthorizationStatus async {
    if(Platform.isIOS) {
      final int status = (await _channel.invokeMethod<int>('getTrackingStatus'));
      return TrackingStatus.values[status];
    }
    
    return TrackingStatus.notSupported;
  }

  static Future<TrackingStatus> requestTrakingAuthorization() async {
    if(Platform.isIOS) {
      final int status = (await _channel.invokeMethod<int>('requestTrackingAuthorization'));

      return TrackingStatus.values[status];
    }

    return TrackingStatus.notSupported;
  }

  static Future<String> getAdvertisingIdentifier() async {
    if(Platform.isIOS) {
      final String uuid = (await _channel.invokeMethod<String>("getAdertisingIdentifier"));
      return uuid;
    }

    return "";
  }

  static Future<bool> showCustomTrackingDialog(BuildContext context, {String title, String content}) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text("I'll decide later"),
              onPressed: (){
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: Text("Allow tracking"),
              onPressed: (){
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      }
    ) ?? false;
  }
}
