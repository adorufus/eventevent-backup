import 'dart:async';

import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:eventevent/helper/colorsManagement.dart';

class ListenPage extends StatefulWidget {
  @override
  _ListenPageState createState() => _ListenPageState();
}

class _ListenPageState extends State<ListenPage> {

  Location location = new Location();

  LocationData currentLocation;
  StreamSubscription<LocationData> locationSubcription;
  String err;

  @override
  void initState() {
    super.initState();

    initPlatformState();
    locationSubcription = location.onLocationChanged().listen((LocationData result){
      setState(() {
        currentLocation = result;
      });
    });
    
      }
    
      @override
      Widget build(BuildContext context) { 
        return Scaffold(
          backgroundColor: checkForBackgroundColor(context),
          body: Center(child: Text('Get Longitude Latitude | Lat: ${currentLocation.latitude} Long: ${currentLocation.longitude}'),),
        ); 
      }
    
      void initPlatformState() async {
        Map<String, double> myLocation;
        try{
          currentLocation = await location.getLocation();
          err = "";
        }on PlatformException catch(e){
          if(e.code == "PERMISSION_DENIED"){
            err = 'Permission Denied';
          }
          else if(e.code == 'PERMISSION_DENIED_NEVER_ASK'){
            err = 'Permission denied - please ask the user to enable location service';
          }
          myLocation = null;
        }
        setState(() {
          // currentLocation = myLocation;
        });
      }
}