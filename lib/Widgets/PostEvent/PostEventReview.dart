import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/static_map_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_places_picker/google_places_picker.dart';
import 'package:location/location.dart';
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

  List<String> categoryList = new List<String>();
  List<String> categoryIdList = new List<String>();
  List<String> additionalMedia = new List<String>();

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
      additionalMedia = [
        prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_1'),
        prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_2'),
        prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_3'),
        prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_4'),
        prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_5')
      ];
    });
  }

  saveFinalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_1', additionalMedia[0]);
      prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_2', additionalMedia[1]);
      prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_3', additionalMedia[2]);
      prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_4', additionalMedia[3]);
      prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_5', additionalMedia[4]);
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
      prefs.setString('CREATE_EVENT_ADDITIONAL_INFO', additionalInfoMapController.text);
    });

    Navigator.push(context, CupertinoPageRoute(builder: (context) => SelectTicketType()));
  }

  @override
  void initState() {
    super.initState();

    getData();
    initPlatformState();
    locationSubcription =
        location.onLocationChanged().listen((LocationData result) {
      setState(() {
        currentLocation = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var thisScaffold = new GlobalKey<ScaffoldState>();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        key: thisScaffold,
        appBar: AppBar(
          backgroundColor: Colors.white,
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
                    style: TextStyle(color: eventajaGreenTeal, fontSize: 18),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: eventNameController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
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
                      height: 15,
                    ),
                    Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 225,
                            width: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(imageUri), fit: BoxFit.fill),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Event Type',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Container(
                                  width: 170,
                                  height: 50,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        eventType == '0' ? 'PUBLIC' : 'PRIVATE',
                                        style: TextStyle(fontSize: 15),
                                      ))),
                              SizedBox(height: 20),
                              Text(
                                'Category',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Container(
                                  width: 170,
                                  height: 50,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        categoryList[0] +
                                            ', ' +
                                            categoryList[1] +
                                            ', ' +
                                            categoryList[2],
                                        style: TextStyle(fontSize: 15),
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
                          style: TextStyle(color: Colors.black54, fontSize: 18),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: 150,
                                height: 50,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      startDate,
                                      style: TextStyle(fontSize: 20),
                                    ))),
                            SizedBox(
                              width: 25,
                            ),
                            Container(
                                width: 150,
                                height: 50,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      endDate,
                                      style: TextStyle(fontSize: 20),
                                    ))),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Time',
                          style: TextStyle(color: Colors.black54, fontSize: 18),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: 150,
                                height: 50,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      startTime,
                                      style: TextStyle(fontSize: 20),
                                    ))),
                            SizedBox(
                              width: 25,
                            ),
                            Container(
                                width: 150,
                                height: 50,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      endTime,
                                      style: TextStyle(fontSize: 20),
                                    ))),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(
                      color: Colors.black54,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 15,
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
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Add your event\'s video and picture',
                      style: TextStyle(color: Colors.black26),
                    ),
                    SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
              addMed(),
              SizedBox(
                height: 20,
              ),
              Divider(
                color: Colors.black54,
              ),
              SizedBox(
                height: 15,
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
                            color: Colors.black54,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: descController,
                        maxLines: 10,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none)),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Contact',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset(
                                'assets/icons/btn_phone_active.png'),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 280,
                            height: 35,
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: telephoneController,
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
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
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                            width: 40,
                            child:
                                Image.asset('assets/icons/btn_mail_active.png'),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 280,
                            height: 35,
                            child: TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
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
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                            width: 40,
                            child:
                                Image.asset('assets/icons/btn_web_active.png'),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 280,
                            height: 35,
                            child: TextFormField(
                              controller: websiteController,
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
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
                      SizedBox(height: 15),
                      Text(
                        'Location Address',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 80,
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
                      SizedBox(height: 12),
                      TextFormField(
                        controller: additionalInfoMapController,
                        maxLines: 5,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
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
                      SizedBox(
                        height: 15,
                      ),
                      showMap()
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
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        padding: EdgeInsets.only(left: 10),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: additionalMedia[0] == ''
                ? Container()
                : Container(
                    child: Image.file(
                      File(additionalMedia[0]),
                      fit: BoxFit.fill,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: additionalMedia[1] == ''
                ? Container()
                : Container(
                    child: Image.file(
                      File(additionalMedia[1]),
                      fit: BoxFit.fill,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: additionalMedia[2] == ''
                ? Container()
                : Container(
                    child: Image.file(
                      File(additionalMedia[2]),
                      fit: BoxFit.fill,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: additionalMedia[3] == ''
                ? Container()
                : Container(
                    child: Image.file(
                      File(additionalMedia[3]),
                      fit: BoxFit.fill,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: additionalMedia[4] == ''
                ? Container()
                : Container(
                    child: Image.file(
                      File(additionalMedia[4]),
                      fit: BoxFit.fill,
                    ),
                  ),
          ),
          additionalMedia[4] == ''
              ? GestureDetector(
                  onTap: () {
                    //_showDialog();
                  },
                  child: Container(
                    color: Colors.grey,
                    height: 200,
                    width: 150,
                    child: Center(
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Image.asset(
                            'assets/bottom-bar/new-something-white.png'),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
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
      height: 300,
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
            height: 50,
            width: 50,
            child: Image.asset('assets/icons/location-transparent.png'),
          ),
        )
      ]),
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
