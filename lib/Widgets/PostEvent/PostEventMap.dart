import 'dart:async';

import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/static_map_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:google_places_picker/google_places_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';

import 'PostEventCreatorDetails.dart';

class PostEventMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEventMapState();
  }
}

class PostEventMapState extends State<PostEventMap>{
  var thisScaffold = new GlobalKey<ScaffoldState>();
  TextEditingController additionalInfoController = new TextEditingController();

  String placeName = '';
  String lat = '';
  String long = '';
  String err;
  Location location = new Location();
  LocationData currentLocation;
  StreamSubscription<LocationData> locationSubcription;

  showPlacePicker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var place = await PluginGooglePlacePicker.showPlacePicker();

    if (!mounted) {
      return;
    }
    print(place.address);
    setState(() {
      placeName = place.address;
      lat = place.latitude.toString();
      long = place.longitude.toString();
      prefs.setString('CREATE_EVENT_LOCATION_ADDRESS', place.address);
      prefs.setString('CREATE_EVENT_LOCATION_LAT', place.latitude.toString());
      prefs.setString('CREATE_EVENT_LOCATION_LONG', place.longitude.toString());
    });

    print(prefs.getString('CREATE_EVENT_LOCATION_ADDRESS'));
  }

  void initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      currentLocation = await location.getLocation();
      err = "";
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        err = 'Permission Denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        err =
            'Permission denied - please ask the user to enable location service';
      }
      currentLocation = null;
    }
    setState(() {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        prefs.setString('latitude', currentLocation.latitude.toString());
        prefs.setString('longitude', currentLocation.longitude.toString());
        lat = currentLocation.latitude.toString();
        long = currentLocation.longitude.toString();
      }
    });
  }

  saveDataAndNext() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(additionalInfoController.text == null || additionalInfoController.text == ''){
      prefs.setString('CREATE_EVENT_ADDITIONAL_INFO', '');
    }
    else{
      prefs.setString('CREATE_EVENT_ADDITIONAL_INFO', additionalInfoController.text);
    }
  }

  Widget showMap() {
    StaticMapsProvider mapProvider = new StaticMapsProvider(
      GOOGLE_API_KEY: 'AIzaSyDjNpeyufzT81GAhQkCe85x83kxzfA7qbI',
      height: 1024,
      width: 1024,
      latitude: lat,
      longitude: long,
      isRedirectToGMAP: false,
    );

    return Container(
      height: ScreenUtil.instance.setWidth(300),
      width: MediaQuery.of(context).size.width,
      child: Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        Positioned(
          left: 15,
          child: GestureDetector(
              onTap: () {
                showPlacePicker();
              },
              child: mapProvider),
        ),
        Center(
          child: SizedBox(
            height: ScreenUtil.instance.setWidth(50),
            width: ScreenUtil.instance.setWidth(50),
            child: Image.asset('assets/icons/location-transparent.png'),
          ),
        )
      ]),
    );
  }

  navigateToNextStep(){
    if(placeName == null || placeName == ''){
      thisScaffold.currentState.showSnackBar(SnackBar(
        content: Text('Please select location first!'),
        backgroundColor: Colors.red,
      ));
    }
    else{
      saveDataAndNext();
      Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => PostEventCreatorDetails()));
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    locationSubcription =
        location.onLocationChanged().listen((LocationData result) {
      setState(() {
        currentLocation = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
        key: thisScaffold,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
            ),
          ),
          centerTitle: true,
          title: Text(
            'CREATE EVENT',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    navigateToNextStep();
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                ),
              ),
            )
          ],
        ),
        body: Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 15, top: 15, right: 15),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Event Location',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(20),
                  ),
                  Divider(
                    color: Colors.grey,
                    height: ScreenUtil.instance.setWidth(5),
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   height: ScreenUtil.instance.setWidth(5),
                  //   child: Center(
                  //     child: RaisedButton(
                  //       onPressed: (){
                  //         showPlacePicker();
                  //       },
                  //       child: Text('Show map picker'),
                  //     )
                  //   ),
                  // ),
                  Container(
                    height: MediaQuery.of(context).size.height / 1.32,
                    child: ListView(children: <Widget>[
                      showMap(),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(20),
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Location Address',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil.instance.setSp(18)),
                          )),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(12),
                      ),
                      Container(
                        height: ScreenUtil.instance.setWidth(80),
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(right: 18),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: eventajaGreenTeal,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          placeName,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(20),
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Aditional Address Information',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil.instance.setSp(18)),
                          )),
                      SizedBox(height: ScreenUtil.instance.setWidth(12)),
                      TextFormField(
                        controller: additionalInfoController,
                        maxLines: 5,
                        decoration: InputDecoration(
                            fillColor: Colors.grey.withOpacity(0.2),
                            filled: true,
                            hintText: 'Type additional information here, example: Near lion statue, or on the second floor',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.transparent))),
                      )
                    ]),
                  )
                ],
              ),
            )));
  }
}
