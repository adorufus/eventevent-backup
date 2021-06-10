import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eventevent/helper/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/static_map_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'PostEventSelectTicketType.dart';

class PostEventReview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEventReviewState();
  }
}

class PostEventReviewState extends State<PostEventReview> {
  TextEditingController telephoneController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController websiteController = new TextEditingController();
  TextEditingController additionalInfoMapController =
      new TextEditingController();
  TextEditingController descController = new TextEditingController();

  String imageUri;
  String eventType;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String placeName = '';
  String lat = '';
  String long = '';
  String err;

  List categoryEventData;

  Location location = new Location();
  LocationData currentLocation;
  StreamSubscription<LocationData> locationSubcription;

  List<String> categoryList = [];
  List<String> categoryIdList = [];
  List<String> additionalMedia = [];

  TextEditingController eventNameController = new TextEditingController();

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      eventNameController.text = prefs.getString('POST_EVENT_NAME');
      imageUri = prefs.getString('POST_EVENT_POSTER');
      eventType = prefs.getString('POST_EVENT_TYPE');
      categoryList = prefs.getStringList('POST_EVENT_CATEGORY');
      categoryIdList = prefs.getStringList('POST_EVENT_CATEGORY_ID');
      startDate = prefs.getString('POST_EVENT_START_DATE');
      endDate = prefs.getString('POST_EVENT_END_DATE');
      startTime = prefs.getString('POST_EVENT_START_TIME');
      endTime = prefs.getString('POST_EVENT_END_TIME');
      placeName = prefs.getString('CREATE_EVENT_LOCATION_ADDRESS');
      lat = prefs.getString('CREATE_EVENT_LOCATION_LAT');
      long = prefs.getString('CREATE_EVENT_LOCATION_LONG');
      descController.text = prefs.getString('CREATE_EVENT_DESCRIPTION');
      telephoneController.text = prefs.getString('CREATE_EVENT_TELEPHONE');
      emailController.text = prefs.getString('CREATE_EVENT_EMAIL');
      websiteController.text = prefs.getString('CREATE_EVENT_WEBSITE');
      additionalInfoMapController.text =
          prefs.getString('CREATE_EVENT_ADDITIONAL_INFO');
      additionalMedia = prefs.getStringList('POST_EVENT_ADDITIONAL_MEDIA');
    });
  }

  saveFinalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setStringList('POST_EVENT_ADDITIONAL_MEDIA', additionalMedia);
      prefs.setString('POST_EVENT_NAME', eventNameController.text);
      prefs.setString('POST_EVENT_POSTER', imageUri);
      prefs.setString('POST_EVENT_TYPE', eventType);
      prefs.setStringList('POST_EVENT_CATEGORY_ID', categoryIdList);
      prefs.setString('POST_EVENT_START_DATE', startDate);
      prefs.setString('POST_EVENT_END_DATE', endDate);
      prefs.setString('POST_EVENT_START_TIME', startTime);
      prefs.setString('POST_EVENT_END_TIME', endTime);
      prefs.setString('CREATE_EVENT_LOCATION_ADDRESS', placeName);
      prefs.setString('CREATE_EVENT_LOCATION_LAT', lat);
      prefs.setString('CREATE_EVENT_LOCATION_LONG', long);
      prefs.setString('CREATE_EVENT_DESCRIPTION', descController.text);
      prefs.setString('CREATE_EVENT_TELEPHONE', telephoneController.text);
      prefs.setString('CREATE_EVENT_EMAIL', emailController.text);
      prefs.setString('CREATE_EVENT_WEBSITE', websiteController.text);
      prefs.setString(
          'CREATE_EVENT_ADDITIONAL_INFO', additionalInfoMapController.text);
    });

    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => SelectTicketType()));
  }

  @override
  void initState() {
    super.initState();

    getData();
    initPlatformState();
    locationSubcription =
        location.onLocationChanged().listen((LocationData result) {
      if (!mounted) return;
      setState(() {
        currentLocation = result;
      });
    });
  }

  var thisScaffold = new GlobalKey<ScaffoldState>();

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
        resizeToAvoidBottomInset: true,
        key: thisScaffold,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: appBarColor,
          elevation: 1,
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
            'SUMMARY',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    saveFinalData();
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(
                        color: eventajaGreenTeal,
                        fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                ),
              ),
            )
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Event Name',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(18),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil.instance.setWidth(5),
                    ),
                    TextFormField(
                      controller: eventNameController,
                      style: TextStyle(color: checkForTextTitleColor(context),),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: checkForContainerBackgroundColor(context),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8),
                          )),
                    ),
                    SizedBox(
                      height: ScreenUtil.instance.setWidth(15),
                    ),
                    Container(
                      height: ScreenUtil.instance.setWidth(250),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: ScreenUtil.instance.setWidth(225),
                            width: ScreenUtil.instance.setWidth(150),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  Image.file(File(imageUri), fit: BoxFit.fill),
                            ),
                          ),
                          SizedBox(
                            width: ScreenUtil.instance.setWidth(20),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Event Type',
                                style: TextStyle(
                                    fontSize: ScreenUtil.instance.setSp(18),
                                    color: checkForAppBarTitleColor(context),
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                  height: ScreenUtil.instance.setWidth(10)),
                              Container(
                                  width: ScreenUtil.instance.setWidth(170),
                                  height: ScreenUtil.instance.setWidth(50),
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      color: checkForContainerBackgroundColor(context),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        eventType == '0' ? 'PUBLIC' : 'PRIVATE',
                                        style: TextStyle(
                                          color: checkForTextTitleColor(context),
                                            fontSize:
                                                ScreenUtil.instance.setSp(15)),
                                      ))),
                              SizedBox(
                                  height: ScreenUtil.instance.setWidth(20)),
                              Text(
                                'Category',
                                style: TextStyle(
                                    fontSize: ScreenUtil.instance.setSp(18),
                                    color: checkForAppBarTitleColor(context),
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                  height: ScreenUtil.instance.setWidth(10)),
                              Container(
                                  width: ScreenUtil.instance.setWidth(170),
                                  height: ScreenUtil.instance.setWidth(50),
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      color: checkForContainerBackgroundColor(context),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        categoryList.toString(),
                                        style: TextStyle(
                                          color: checkForTextTitleColor(context),
                                            fontSize:
                                                ScreenUtil.instance.setSp(15)),
                                      )))
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Date',
                          style: TextStyle(
                              color: checkForAppBarTitleColor(context),
                              fontSize: ScreenUtil.instance.setSp(18)),
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(15),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: ScreenUtil.instance.setWidth(150),
                                height: ScreenUtil.instance.setWidth(50),
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: checkForContainerBackgroundColor(context),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      startDate,
                                      style: TextStyle(
                                        color: checkForTextTitleColor(context),
                                          fontSize:
                                              ScreenUtil.instance.setSp(20)),
                                    ))),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(25),
                            ),
                            Container(
                                width: ScreenUtil.instance.setWidth(150),
                                height: ScreenUtil.instance.setWidth(50),
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: checkForContainerBackgroundColor(context),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      endDate,
                                      style: TextStyle(
                                          color: checkForTextTitleColor(context),
                                          fontSize:
                                              ScreenUtil.instance.setSp(20)),
                                    ))),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(20),
                        ),
                        Text(
                          'Time',
                          style: TextStyle(
                              color: checkForAppBarTitleColor(context),
                              fontSize: ScreenUtil.instance.setSp(18)),
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(15),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: ScreenUtil.instance.setWidth(150),
                                height: ScreenUtil.instance.setWidth(50),
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: checkForContainerBackgroundColor(context),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      startTime,
                                      style: TextStyle(
                                          color: checkForTextTitleColor(context),
                                          fontSize:
                                              ScreenUtil.instance.setSp(20)),
                                    ))),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(25),
                            ),
                            Container(
                                width: ScreenUtil.instance.setWidth(150),
                                height: ScreenUtil.instance.setWidth(50),
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: checkForContainerBackgroundColor(context),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      endTime,
                                      style: TextStyle(
                                          color: checkForTextTitleColor(context),
                                          fontSize:
                                              ScreenUtil.instance.setSp(20)),
                                    ))),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: ScreenUtil.instance.setWidth(20)),
                    Divider(
                      color: Colors.black54,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(15),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Video & Picture',
                      style: TextStyle(
                          color: checkForAppBarTitleColor(context),
                          fontSize: ScreenUtil.instance.setSp(18),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Add your event\'s video and picture',
                      style: TextStyle(color: checkForTextTitleColor(context)),
                    ),
                    SizedBox(
                      height: ScreenUtil.instance.setWidth(15),
                    )
                  ],
                ),
              ),
              addMed(),
              SizedBox(
                height: ScreenUtil.instance.setWidth(20),
              ),
              Divider(
                color: Colors.black54,
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(15),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Description',
                        style: TextStyle(
                            color: checkForAppBarTitleColor(context),
                            fontSize: ScreenUtil.instance.setSp(18),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(10),
                      ),
                      TextFormField(
                        controller: descController,
                        maxLines: 10,
                        style: TextStyle(color: checkForTextTitleColor(context)),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: checkForContainerBackgroundColor(context),
                            enabledBorder:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none)),
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(15)),
                      Text(
                        'Contact',
                        style: TextStyle(
                            color: checkForAppBarTitleColor(context),
                            fontSize: ScreenUtil.instance.setSp(18),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(15)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(40),
                            width: ScreenUtil.instance.setWidth(40),
                            child: Image.asset(
                                'assets/icons/btn_phone_active.png'),
                          ),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(10),
                          ),
                          Container(
                            width: ScreenUtil.instance.setWidth(280),
                            height: ScreenUtil.instance.setWidth(35),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: telephoneController,
                              style: TextStyle(color: checkForTextTitleColor(context)),
                              decoration: InputDecoration(
                                  fillColor: checkForContainerBackgroundColor(context),
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(7)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(7))),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(10),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(40),
                            width: ScreenUtil.instance.setWidth(40),
                            child:
                                Image.asset('assets/icons/btn_mail_active.png'),
                          ),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(10),
                          ),
                          Container(
                            width: ScreenUtil.instance.setWidth(280),
                            height: ScreenUtil.instance.setWidth(35),
                            child: TextFormField(
                              controller: emailController,
                              style: TextStyle(color: checkForTextTitleColor(context)),
                              decoration: InputDecoration(
                                  fillColor: checkForContainerBackgroundColor(context),
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(7)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(7))),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(10),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(40),
                            width: ScreenUtil.instance.setWidth(40),
                            child:
                                Image.asset('assets/icons/btn_web_active.png'),
                          ),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(10),
                          ),
                          Container(
                            width: ScreenUtil.instance.setWidth(280),
                            height: ScreenUtil.instance.setWidth(35),
                            child: TextFormField(
                              controller: websiteController,
                              style: TextStyle(color: checkForTextTitleColor
                                (context)),
                              decoration: InputDecoration(
                                  fillColor: checkForContainerBackgroundColor(context),
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(7)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(7))),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(15)),
                      Text(
                        'Location Address',
                        style: TextStyle(
                            color: checkForAppBarTitleColor(context),
                            fontSize: ScreenUtil.instance.setSp(18),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(15)),
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
                      SizedBox(height: ScreenUtil.instance.setWidth(12)),
                      TextFormField(
                        controller: additionalInfoMapController,
                        maxLines: 5,
                        style: TextStyle(color: checkForTextTitleColor(context)),
                        decoration: InputDecoration(
                            fillColor: checkForContainerBackgroundColor(context),
                            hintStyle: TextStyle(color: checkForTextTitleColor(context)),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.transparent))),
                      ),
                      // SizedBox(
                      //   height: ScreenUtil.instance.setWidth(15),
                      // ),
                      // Container(
                      //   margin:
                      //       EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(13),
                      //       boxShadow: [
                      //         BoxShadow(
                      //             blurRadius: 5,
                      //             spreadRadius: 1.5,
                      //             color: Color(0xff8a8a8b).withOpacity(.2))
                      //       ],
                      //       color: Colors.white),
                      //   child: Column(
                      //     children: <Widget>[showMap()],
                      //   ),
                      // )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget addMed() {
    return Container(
      height: ScreenUtil.instance.setWidth(200),
      width: MediaQuery.of(context).size.width,
      child: ListView(
        padding: EdgeInsets.only(left: 10),
        scrollDirection: Axis.horizontal,
        children: mapIndexed(additionalMedia, (index, item) {
          return Padding(
            padding: EdgeInsets.only(right: 10),
            child: additionalMedia[index] == null
                ? Container()
                : Container(
                    child: Image.file(
                      File(additionalMedia[index]),
                      fit: BoxFit.fill,
                    ),
                  ),
          );
        }).toList(),
        // children: <Widget>[
        //   Padding(
        //     padding: EdgeInsets.only(right: 10),
        //     child: additionalMedia.length < 1
        //         ? Container()
        //         : Container(
        //             child: Image.file(
        //               File(additionalMedia[0]),
        //               fit: BoxFit.fill,
        //             ),
        //           ),
        //   ),
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: additionalMedia.length < 2
        //         ? Container()
        //         : Container(
        //             child: Image.file(
        //               File(additionalMedia[1]),
        //               fit: BoxFit.fill,
        //             ),
        //           ),
        //   ),
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: additionalMedia.length < 3
        //         ? Container()
        //         : Container(
        //             child: Image.file(
        //               File(additionalMedia[2]),
        //               fit: BoxFit.fill,
        //             ),
        //           ),
        //   ),
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: additionalMedia.length < 4
        //         ? Container()
        //         : Container(
        //             child: Image.file(
        //               File(additionalMedia[3]),
        //               fit: BoxFit.fill,
        //             ),
        //           ),
        //   ),
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: additionalMedia.length < 5
        //         ? Container()
        //         : Container(
        //             child: Image.file(
        //               File(additionalMedia[4]),
        //               fit: BoxFit.fill,
        //             ),
        //           ),
        //   ),
        //   additionalMedia.length < 5
        //       ? GestureDetector(
        //           onTap: () {
        //             //_showDialog();
        //           },
        //           child: Container(
        //             color: Colors.grey,
        //             height: ScreenUtil.instance.setWidth(200),
        //             width: ScreenUtil.instance.setWidth(150),
        //             child: Center(
        //               child: SizedBox(
        //                 height: ScreenUtil.instance.setWidth(50),
        //                 width: ScreenUtil.instance.setWidth(50),
        //                 child: Image.asset(
        //                     'assets/bottom-bar/new-something-white.png'),
        //               ),
        //             ),
        //           ),
        //         )
        //       : Container(),
        // ],
      ),
    );
  }

  Widget showMap() {
    StaticMapsProvider mapProvider = new StaticMapsProvider(
      GOOGLE_API_KEY: 'AIzaSyA2s9iDKooQ9Cwgr6HiDVQkG9p3fvsVmEI',
      height: 1024,
      width: 1024,
      latitude: lat,
      longitude: long,
      isRedirectToGMAP: false,
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil.instance.setWidth(200),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: mapProvider,
    );
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

  void handleEventTypeDialog() {}

  void handleEventCategoryDialog() {}

  showPlacePicker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationResult place = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
            'AIzaSyDO-ES5Iy3hOfiwz-IMQ-tXhOtH9d01RwI',
            displayLocation: LatLng(
                double.parse(currentLocation.latitude.toString()),
                double.parse(currentLocation.latitude.toString())))));

    if (!mounted) {
      return;
    }
    print(place.name);
    setState(() {
      placeName = place.name;
      lat = place.latLng.latitude.toString();
      long = place.latLng.longitude.toString();
      prefs.setString('CREATE_EVENT_LOCATION_ADDRESS', place.name);
      prefs.setString(
          'CREATE_EVENT_LOCATION_LAT', place.latLng.latitude.toString());
      prefs.setString(
          'CREATE_EVENT_LOCATION_LONG', place.latLng.longitude.toString());
    });

    print(prefs.getString('CREATE_EVENT_LOCATION_ADDRESS'));
  }

  Future fetchCategoryEvent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final categoryApi =
        BaseApi().apiUrl + '/category/list?X-API-KEY=$API_KEY&page=1';
    final response = await http.get(categoryApi, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': preferences.getString('Session')
    });

    print(response.body);

    if (response.statusCode == 200) {
      var extractedData = json.decode(response.body);
      setState(() {
        categoryEventData = extractedData['data'];
        assert(categoryEventData != null);
        categoryEventData.removeAt(0);
      });
    }
  }
}
