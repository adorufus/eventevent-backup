import 'dart:async';
import 'dart:convert';
import 'dart:io'; import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/static_map_provider.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditEvent extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    
    return EditEventState();
  }
}

class EditEventState extends State<EditEvent>{
  TextEditingController telephoneController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController websiteController = new TextEditingController();
  TextEditingController additionalInfoMapController =
  new TextEditingController();
  TextEditingController descController = new TextEditingController();
  TextEditingController eventNameController = new TextEditingController();

  Location location = new Location();
  LocationData currentLocation;
  StreamSubscription<LocationData> locationSubcription;

  String ticketTypeID;
  String eventId;
  String dateStart;
  String dateEnd;
  String address;
  String timeStart;
  String timeEnd;
  String isPrivate;
  String lat;
  String long;
  String imageUriNetwork;
  File imageUri;
  String err = '';

  List<String> categoryList = new List<String>();
  List categoryEventData;
  List<String> additionalMedia = new List<String>();

  bool isLoading = false;

  getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      eventNameController.text = prefs.getString('EVENT_NAME');
      eventId = prefs.getString('NEW_EVENT_ID');
      telephoneController.text = prefs.getString('EVENT_TELEPHONE');
      emailController.text = prefs.getString('EVENT_EMAIL');
      websiteController.text = prefs.getString('EVENT_WEBSITE');
      descController.text = prefs.getString('EVENT_DESCRIPTION');
      dateStart = prefs.getString('DATE_START');
      dateEnd = prefs.getString('DATE_END');
      timeStart = prefs.getString('TIME_START');
      timeEnd = prefs.getString('TIME_END');
      isPrivate = prefs.getString('EVENT_TYPE');
      imageUriNetwork = prefs.getString('EVENT_IMAGE');
      categoryList = prefs.getStringList('EVENT_CATEGORY');
      address = prefs.getString('EVENT_ADDRESS');
      lat = prefs.getString('EVENT_LAT');
      long = prefs.getString('EVENT_LONG');
      imageUri = File.fromUri(Uri.https('https:'+imageUriNetwork, ""));
    });

    print(imageUriNetwork);
    print(imageUri);

    print(categoryList.toString());
  }

  @override
  void initState() {
    getData();
    fetchCategoryEvent();
    initPlatformState();
    locationSubcription =
        location.onLocationChanged().listen((LocationData result) {
          setState(() {
            currentLocation = result;
          });
        });
    super.initState();
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

  Future<http.MultipartRequest> postEditEvent() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String uri = BaseApi().apiUrl + '/event/update';

    var request = new http.MultipartRequest('POST', Uri.parse(uri));
    var stream = new http.ByteStream(DelegatingStream.typed(imageUri.openRead()));
    var length = await imageUri.length();

    request.headers.addAll({
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    request.fields.addAll({
      'X-API-CODE': API_KEY,
      'id': eventId,
      'name': eventNameController.text,
      'eventTypeID': (int.parse(isPrivate) + 1).toString(),
      'isPrivate': isPrivate,
      'address': address,
      'latitude': lat,
      'longitude': long,
      'dateStart': dateStart,
      'dateEnd': dateEnd,
      'timeEnd': timeEnd,
      'timeStart': timeStart,
      'description': descController.text,
      'phone': telephoneController.text,
      'email': emailController.text,
      'website': websiteController.text,
    });
    
    if(imageUri == null){

    }
    else{
      var multipartFile = new http.MultipartFile('photo', stream, length, filename: basename(imageUri.path));
      request.files.add(multipartFile);
    }

    return request;
  }

  var thisScaffold = new GlobalKey<ScaffoldState>();


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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: eventajaGreenTeal),)
          ),
          centerTitle: true,
          title: Text(
              'EDIT EVENT',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    postEditEvent().then((request){
                      request.send().then((response) async{
                        print(response.statusCode);

                        if(response.statusCode == null) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                          );
                        }

                        if(response.statusCode == 200 || response.statusCode == 201){
                          var myResponse = await http.Response.fromStream(response);
                          print(myResponse);
                        }
                      });
                    }).whenComplete((){

                    });
                  },
                  child: GestureDetector(
                    onTap:(){
                      postEditEvent().then((request) {
                        request.send().then((response){
                          print(response.statusCode);
                          if(response.statusCode == null){
                            isLoading = true;
                          }
                          if(response.statusCode == 201 || response.statusCode == 200){
                            isLoading = false;
                            Navigator.of(context).pop();
                          }
                        });
                      });
                    },
                    child: Text(
                      'Update',
                      style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(18)),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        body: categoryList.length == null || isLoading == true ? Container(child: Center(child: CircularProgressIndicator())) :  Container(
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
                              child: imageUri == null ? Image.network(imageUriNetwork, fit: BoxFit.fill,) : Image.file(File(imageUri.path), fit: BoxFit.fill),
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
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: ScreenUtil.instance.setWidth(10)),
                              Container(
                                  width: ScreenUtil.instance.setWidth(170),
                                  height: ScreenUtil.instance.setWidth(50),
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        isPrivate == '0' ? 'PUBLIC' : 'PRIVATE',
                                        style: TextStyle(fontSize: ScreenUtil.instance.setSp(15)),
                                      ))),
                              SizedBox(height: ScreenUtil.instance.setWidth(20)),
                              Text(
                                'Category',
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
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        categoryList.length == 1 ?
                                            categoryList[0] : categoryList.length == 2 ?
                                              categoryList[0] + ', ' + categoryList[1] : categoryList.length == 3 ?
                                                categoryList[0] + ', ' + categoryList[1] + ', ' + categoryList[2] : '',
                                        style: TextStyle(fontSize: ScreenUtil.instance.setSp(15)),
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
                          style: TextStyle(color: Colors.black54, fontSize: ScreenUtil.instance.setSp(18)),
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
                                      dateStart,
                                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(20)),
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
                                      dateEnd,
                                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(20)),
                                    ))),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(20),
                        ),
                        Text(
                          'Time',
                          style: TextStyle(color: Colors.black54, fontSize: ScreenUtil.instance.setSp(18)),
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
                                      timeStart,
                                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(20)),
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
                                      timeEnd,
                                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(20)),
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
                          color: Colors.black54,
                          fontSize: ScreenUtil.instance.setSp(18),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Add your event\'s video and picture',
                      style: TextStyle(color: Colors.black26),
                    ),
                    SizedBox(
                      height: ScreenUtil.instance.setWidth(15),
                    )
                  ],
                ),
              ),
              //addMed(context),
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
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
                      SizedBox(height: ScreenUtil.instance.setWidth(15)),
                      Text(
                        'Contact',
                        style: TextStyle(
                            color: Colors.black54,
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
                      SizedBox(height: ScreenUtil.instance.setWidth(15)),
                      Text(
                        'Location Address',
                        style: TextStyle(
                            color: Colors.black54,
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
                          address,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(12)),
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
                        height: ScreenUtil.instance.setWidth(15),
                      ),
                      showMap(context)
                    ],
                  ),
                ),
            ],
          ),
        ));
  }

  showPlacePicker(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationResult place = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PlacePicker('AIzaSyDO-ES5Iy3hOfiwz-IMQ-tXhOtH9d01RwI', displayLocation: LatLng(double.parse(currentLocation.latitude.toString()), double.parse(currentLocation.latitude.toString())
    ))));

    if (!mounted) {
      return;
    }
    print(place.name);
    setState(() {
      address = place.name;
      lat = place.latLng.latitude.toString();
      long = place.latLng.longitude.toString();
      prefs.setString('CREATE_EVENT_LOCATION_ADDRESS', place.name);
      prefs.setString('CREATE_EVENT_LOCATION_LAT', place.latLng.latitude.toString());
      prefs.setString('CREATE_EVENT_LOCATION_LONG', place.latLng.longitude.toString());
    });

    print(prefs.getString('CREATE_EVENT_LOCATION_ADDRESS'));
  }

  Widget showMap(BuildContext context) {
    StaticMapsProvider mapProvider = new StaticMapsProvider(
      GOOGLE_API_KEY: 'AIzaSyDjNpeyufzT81GAhQkCe85x83kxzfA7qbI',
      height: ScreenUtil.instance.setWidth(1024),
      width: ScreenUtil.instance.setWidth(1024),
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
                showPlacePicker(context);
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

  Widget addMed(BuildContext context) {
    return Container(
      height: ScreenUtil.instance.setWidth(200),
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
              height: ScreenUtil.instance.setWidth(200),
              width: ScreenUtil.instance.setWidth(150),
              child: Center(
                child: SizedBox(
                  height: ScreenUtil.instance.setWidth(50),
                  width: ScreenUtil.instance.setWidth(50),
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