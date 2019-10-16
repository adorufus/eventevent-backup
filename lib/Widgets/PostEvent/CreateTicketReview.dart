import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/PostEvent/CreateTicketFinal.dart';
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

    setState(() {
      ticketTypeID = prefs.getString('NEW_EVENT_TICKET_TYPE_ID');
      eventNameController.text = prefs.getString('SETUP_TICKET_NAME');
      imageUri = prefs.getString('SETUP_TICKET_POSTER');
      ticketQuantityController.text = prefs.getString('SETUP_TICKET_QTY');
      priceController.text = prefs.getString('SETUP_TICKET_PRICE');
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
      prefs.setString('NEW_EVENT_TICKET_TYPE_ID', ticketTypeID);
      prefs.setString('SETUP_TICKET_NAME', eventNameController.text);
      prefs.setString('SETUP_TICKET_QTY', ticketQuantityController.text);
      prefs.setString('SETUP_TICKET_PRICE', priceController.text);
      prefs.setString('SETUP_TICKET_MIN_BOUGHT', minTicketController.text);
      prefs.setString('SETUP_TICKET_MAX_BOUGHT', maxTicketController.text);
      prefs.setString('SETUP_TICKET_NAME', eventNameController.text);
      prefs.setString('SETUP_TICKET_POSTER', imageUri);
      prefs.setString('SETUP_TICKET_SHOW_REMAINING_TICKET', __curValue.toString());
      prefs.setString('SETUP_TICKET_IS_ONE_PURCHASE', __curValue2.toString());
      prefs.setString('SETUP_TICKET_START_DATE', startDate);
      prefs.setString('SETUP_TICKET_END_DATE', endDate);
      prefs.setString('SETUP_TICKET_START_TIME', startTime);
      prefs.setString('SETUP_TICKET_END_TIME', endTime);
      prefs.setString('SETUP_TICKET_DESCRIPTION', descController.text);
    });

    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => CreateTicketFinal()));
  }

  @override
  void initState() {
    super.initState();

    getData();
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
                                child: Image.file(File(imageUri),
                                    fit: BoxFit.fill),
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
                                  'Ticket Quantity',
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
                                SizedBox(height: 20),
                                Text(
                                  'Set The Price',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Set your ticket price',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[300],
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Container(
                                    width: 170,
                                    height: 50,
                                    padding: EdgeInsets.only(left: 10),
                                    child: ticketTypeID == '5' ||
                                            ticketTypeID == '10'
                                        ? Text('FREE',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[300],
                                                fontWeight: FontWeight.bold))
                                        : TextFormField(
                                            controller: priceController,
                                            decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7))),
                                          ))
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      SizedBox(height: 15),
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
                                          fontSize: 18,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                        width: 170,
                                        height: 50,
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
                                                      BorderRadius.circular(
                                                          7))),
                                        )),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Max Ticket',
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
                                                      BorderRadius.circular(
                                                          7))),
                                        )),
                                  ])
                            ],
                          ),
                          Text(
                            'Ticket Sales Starts',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 18),
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
                                        startTime,
                                        style: TextStyle(fontSize: 20),
                                      ))),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Ticket Sales Ends',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 18),
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
                                        endDate,
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
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Show Remaining Ticket',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
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
                                width: 25,
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
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
                                width: 25,
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
                          SizedBox(height: 20),
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
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none)),
                          ),
                          SizedBox(height: 15),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: RaisedButton(
                              color: eventajaGreenTeal,
                              onPressed: (){
                                saveFinalData();
                              },
                              child: Text('CREATE EVENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),);
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
