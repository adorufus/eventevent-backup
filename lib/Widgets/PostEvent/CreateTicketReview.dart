import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/Widgets/PostEvent/CreateTicketFinal.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/static_map_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'PostEventSelectTicketType.dart';

class CreateTicketReview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateTicketReviewState();
  }
}

class CreateTicketReviewState extends State<CreateTicketReview> {
  TextEditingController ticketQuantityController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController minTicketController = new TextEditingController();
  TextEditingController maxTicketController = new TextEditingController();
  TextEditingController telephoneController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController websiteController = new TextEditingController();
  TextEditingController additionalInfoMapController =
      new TextEditingController();
  TextEditingController descController = new TextEditingController();

  String imageUri;
  String ticketTypeID;
  String quantity;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String placeName = '';
  String lat = '';
  String long = '';
  String err;
  int __curValue = 0;
  int __curValue2 = 0;

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

    print('ticket type id: '  + prefs.getString('NEW_EVENT_TICKET_TYPE_ID'));

    setState(() {
      ticketTypeID = prefs.getString('SETUP_TICKET_PAID_TICKET_TYPE');
      eventNameController.text = prefs.getString('SETUP_TICKET_NAME');
      imageUri = prefs.getString('SETUP_TICKET_POSTER');
      ticketQuantityController.text = prefs.getString('SETUP_TICKET_QTY');
      priceController.text = ticketTypeID == '5' ||
                                        ticketTypeID == '10' || ticketTypeID == '7' ? "0" : prefs.getString('SETUP_TICKET_PRICE');
      minTicketController.text = prefs.getString('SETUP_TICKET_MIN_BOUGHT');
      maxTicketController.text = prefs.getString('SETUP_TICKET_MAX_BOUGHT');
      __curValue =
          int.parse(prefs.getString('SETUP_TICKET_SHOW_REMAINING_TICKET'));
      __curValue2 = int.parse(prefs.getString('SETUP_TICKET_IS_ONE_PURCHASE'));
      startDate = prefs.getString('SETUP_TICKET_START_DATE');
      endDate = prefs.getString('SETUP_TICKET_END_DATE');
      startTime = prefs.getString('SETUP_TICKET_START_TIME');
      endTime = prefs.getString('SETUP_TICKET_END_TIME');
      descController.text = prefs.getString('SETUP_TICKET_DESCRIPTION');
    });
  }

  saveFinalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('SETUP_TICKET_PAID_TICKET_TYPE', ticketTypeID);
      prefs.setString('SETUP_TICKET_NAME', eventNameController.text);
      prefs.setString('SETUP_TICKET_QTY', ticketQuantityController.text);
      prefs.setString('SETUP_TICKET_PRICE', priceController.text);
      prefs.setString('SETUP_TICKET_MIN_BOUGHT', minTicketController.text);
      prefs.setString('SETUP_TICKET_MAX_BOUGHT', maxTicketController.text);
      prefs.setString('SETUP_TICKET_POSTER', imageUri);
      prefs.setString(
          'SETUP_TICKET_SHOW_REMAINING_TICKET', __curValue.toString());
      prefs.setString('SETUP_TICKET_IS_ONE_PURCHASE', __curValue2.toString());
      prefs.setString('SETUP_TICKET_START_DATE', startDate);
      prefs.setString('SETUP_TICKET_END_DATE', endDate);
      prefs.setString('SETUP_TICKET_START_TIME', startTime);
      prefs.setString('SETUP_TICKET_END_TIME', endTime);
      prefs.setString('SETUP_TICKET_DESCRIPTION', descController.text);
      prefs.setString('Previous Widget', "New Event");
    });

    Map ticketDetail = {
        'id': ticketTypeID,
        'ticket_name': eventNameController.text,
        'quantity': ticketQuantityController.text,
        'price': priceController.text,
        'min_ticket': minTicketController.text,
        'max_ticket': maxTicketController.text,
        'sales_start_date': startDate + ' ' + startTime,
        'sales_end_date': endDate + ' ' + endTime,
        'show_remaining_ticket': __curValue.toString(),
        'single_ticket': __curValue2.toString(),
        'description': descController.text,
        'image_url': imageUri != null
            ? imageUri
            : ''
      };

    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => CreateTicketFinal(
          ticketDetail: ticketDetail,
        )));
  }

  @override
  void initState() {
    super.initState();

    getData();
    locationSubcription =
        location.onLocationChanged().listen((LocationData result) {
          if(!mounted)
            return;
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
      key: thisScaffold,
      appBar: AppBar(
        brightness: Brightness.light,
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
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          saveFinalData();
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                spreadRadius: 1.5,
                color: Color(0xff8a8a8b).withOpacity(.3),
                offset: Offset(0, -1)
              )
            ]
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            height: ScreenUtil.instance.setWidth(50),
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(50),
                          child: RaisedButton(
                color: eventajaGreenTeal,
                onPressed: () {
                  saveFinalData();
                },
                child: Text(
                  'CREATE TICKET',
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
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
                    'Ticket Name',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(18),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(5),
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
                            child: Image.file(File(imageUri), fit: BoxFit.fill),
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
                              'Ticket Quantity',
                              style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(18),
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: ScreenUtil.instance.setWidth(10)),
                            Container(
                                width: ScreenUtil.instance.setWidth(170),
                                height: ScreenUtil.instance.setWidth(50),
                                padding: EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  controller: ticketQuantityController,
                                  decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(7))),
                                )),
                            SizedBox(height: ScreenUtil.instance.setWidth(20)),
                            Text(
                              'Set The Price',
                              style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(18),
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Set your ticket price',
                              style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(15),
                                  color: Colors.grey[300],
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: ScreenUtil.instance.setWidth(10)),
                            Container(
                                width: ScreenUtil.instance.setWidth(170),
                                height: ScreenUtil.instance.setWidth(50),
                                padding: EdgeInsets.only(left: 10),
                                child: ticketTypeID == '5' ||
                                        ticketTypeID == '10' || ticketTypeID == '7'
                                    ? Text('FREE',
                                        style: TextStyle(
                                            fontSize:
                                                ScreenUtil.instance.setSp(18),
                                            color: Colors.grey[300],
                                            fontWeight: FontWeight.bold))
                                    : TextFormField(
                                        controller: priceController,
                                        decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(7))),
                                      ))
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  SizedBox(height: ScreenUtil.instance.setWidth(15)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Min Ticket',
                                  style: TextStyle(
                                      fontSize: ScreenUtil.instance.setSp(18),
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(10)),
                                Container(
                                    width: ScreenUtil.instance.setWidth(170),
                                    height: ScreenUtil.instance.setWidth(50),
                                    padding: EdgeInsets.only(left: 10),
                                    child: TextFormField(
                                      controller: minTicketController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(7))),
                                    )),
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Max Ticket',
                                  style: TextStyle(
                                      fontSize: ScreenUtil.instance.setSp(18),
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(10)),
                                Container(
                                    width: ScreenUtil.instance.setWidth(170),
                                    height: ScreenUtil.instance.setWidth(50),
                                    padding: EdgeInsets.only(left: 10),
                                    child: TextFormField(
                                      controller: maxTicketController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(7))),
                                    )),
                              ])
                        ],
                      ),
                      Text(
                        'Ticket Sales Starts',
                        style: TextStyle(
                            color: Colors.black54,
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    startDate,
                                    style: TextStyle(
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    startTime,
                                    style: TextStyle(
                                        fontSize:
                                            ScreenUtil.instance.setSp(20)),
                                  ))),
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(20),
                      ),
                      Text(
                        'Ticket Sales Ends',
                        style: TextStyle(
                            color: Colors.black54,
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    endDate,
                                    style: TextStyle(
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    endTime,
                                    style: TextStyle(
                                        fontSize:
                                            ScreenUtil.instance.setSp(20)),
                                  ))),
                        ],
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(15)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Show Remaining Ticket',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: ScreenUtil.instance.setSp(18),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(10),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            groupValue: __curValue,
                            onChanged: (int i) =>
                                setState(() => __curValue = i),
                            value: 1,
                          ),
                          Text('Yes'),
                          SizedBox(
                            width: ScreenUtil.instance.setWidth(25),
                          ),
                          Radio(
                            groupValue: __curValue,
                            onChanged: (int i) => setState(() {
                              __curValue = i;
                              print(MaterialTapTargetSize.values);
                            }),
                            value: 0,
                          ),
                          Text('No')
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'One Purchase Per User',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: ScreenUtil.instance.setSp(18),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(10),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            groupValue: __curValue2,
                            onChanged: (int i) =>
                                setState(() => __curValue2 = i),
                            value: 1,
                          ),
                          Text('Yes'),
                          SizedBox(
                            width: ScreenUtil.instance.setWidth(25),
                          ),
                          Radio(
                            groupValue: __curValue2,
                            onChanged: (int i) => setState(() {
                              __curValue2 = i;
                              print(MaterialTapTargetSize.values);
                            }),
                            value: 0,
                          ),
                          Text('No')
                        ],
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(20)),
                      Text(
                        'Description',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: ScreenUtil.instance.setSp(18),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(10),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
