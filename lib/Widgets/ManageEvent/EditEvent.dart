import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eventevent/Widgets/timeline/EditEventItem/EditCategoryList.dart';
import 'package:eventevent/Widgets/timeline/EditEventItem/EditEventDate.dart';
import 'package:eventevent/Widgets/timeline/EditEventItem/EditEventTime.dart';
import 'package:eventevent/Widgets/timeline/EditEventItem/EditEventType.dart';
import 'package:eventevent/helper/utils.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/static_map_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thumbnails/thumbnails.dart';
import 'package:http_parser/src/media_type.dart';

class EditEvent extends StatefulWidget {
  final additional;

  const EditEvent({Key key, this.additional}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return EditEventState();
  }
}

class EditEventState extends State<EditEvent> {
  TextEditingController telephoneController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController websiteController = new TextEditingController();
  TextEditingController additionalInfoMapController =
      new TextEditingController();
  TextEditingController descController = new TextEditingController();
  TextEditingController eventNameController = new TextEditingController();
  Dio dio = new Dio(BaseOptions(
      baseUrl: BaseApi().apiUrl, connectTimeout: 15000, receiveTimeout: 15000));

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
  double progres = 0;
  String err = '';

  List<String> categoryList = new List<String>();
  List<String> categoryId = new List<String>();
  List categoryEventData;
  List currentAdditionalMedia = [];
  List<String> additionalMedia = [];
  List<String> additionalMediaPhoto = [];
  List<String> additionalMediaID = [];
  List<String> removedAdditionalMedia = [];

  bool isLoading = false;

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      eventNameController.text = prefs.getString('EVENT_NAME');
      eventId = prefs.getString('NEW_EVENT_ID');
      telephoneController.text = prefs.getString('EVENT_PHONE');
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
      currentAdditionalMedia = widget.additional;

      for (int i = 0; i < currentAdditionalMedia.length; i++) {
        additionalMedia.add(currentAdditionalMedia[i]['posterPathThumb']);
        additionalMediaPhoto.add(currentAdditionalMedia[i]['posterPathThumb']);
        additionalMediaID.add(currentAdditionalMedia[i]['id']);

        print('add med photo: ' + additionalMediaPhoto.toString());
        print('additional id: ' + additionalMediaID.toString());
      }
    });

    print(imageUriNetwork);
    print(imageUri);
    print('current additional media: ' + currentAdditionalMedia.toString());

    print(categoryList.toString());
  }

  @override
  void initState() {
    getData();
    fetchCategoryEvent();
    initPlatformState();
    locationSubcription =
        location.onLocationChanged().listen((LocationData result) {
      if (!mounted) return;
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
          currentLocation.longitude != null &&
          lat == null &&
          long == null) {
        prefs.setString('latitude', currentLocation.latitude.toString());
        prefs.setString('longitude', currentLocation.longitude.toString());
        lat = currentLocation.latitude.toString();
        long = currentLocation.longitude.toString();
      }
    });
  }

  Future postEditEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isLoading = true;
    setState(() {});

    var data = {
      'X-API-KEY': API_KEY,
      'id': eventId,
      'name': eventNameController.text,
      'eventTypeID': (int.parse(isPrivate) + 1).toString(),
      'isPrivate': isPrivate,
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
      'photo': imageUri == null
          ? ''
          : await MultipartFile.fromFile(imageUri.path,
              filename:
                  "eventevent_event_photo-${DateTime.now().toString()}.jpg"),
      'addVideo': prefs.getString('POST_EVENT_ADDITIONAL_VIDEO') == null
          ? ''
          : await MultipartFile.fromFile(
              prefs.getString('POST_EVENT_ADDITIONAL_VIDEO'),
              filename: 'eventevent_video-${DateTime.now()}.mp4',
              contentType: MediaType('video', 'quicktime')),
    };

    for (int i = 0; i < removedAdditionalMedia.length; i++) {
      data['removeContent[$i]'] = removedAdditionalMedia[i];
    }

    for (int i = 0; i < additionalMedia.length; i++) {
      print(lookupMimeType(additionalMedia[i]));
      print(path.basename(additionalMedia[i]));
      data['addPhoto[$i]'] = additionalMedia[i].startsWith('http') ||
              additionalMedia[i].contains('.mp4') ||
              additionalMedia[i].contains('.mov')
          ? ''
          : await MultipartFile.fromFile(additionalMedia[i],
              filename: path.basename(additionalMedia[i]));
      // additionalMedia[i].startsWith('http')
      //     ? ''
      //     : UploadFileInfo(
      //         File(additionalMedia[i]),
      //         additionalMedia[i].contains('.mp4')
      //             ? 'eventeventVideo-${DateTime.now()}.mp4'
      //             : 'eventeventImage-${DateTime.now()}.jpg',
      //         contentType: ContentType('image', 'jpg'));
    }

    for (int i = 0; i < categoryId.length; i++) {
      setState(() {
        data['category[$i]'] = categoryId[i];
      });
    }

    print('data: $data');

    try {
      Response response = await dio.post('/event/update',
          options: Options(headers: {
            'Authorization': AUTH_KEY,
            'cookie': prefs.getString('Session')
          }, responseType: ResponseType.plain), onSendProgress: (sent, total) {
        print('hit test');
        print(
            'data uploaded: ' + sent.toString() + ' from ' + total.toString());
        setState(() {
          progres = ((sent / total) * 100);
          print('test');
          print(progres);
        });
      }, data: FormData.fromMap(data));
      if (response.statusCode == 201 || response.statusCode == 200) {
        prefs.remove('POST_EVENT_ADDITIONAL_VIDEO');
        isLoading = false;
        setState(() {});
        Navigator.of(context).pop(true);
      }
    } on DioError catch (e) {
      prefs.remove('POST_EVENT_ADDITIONAL_VIDEO');
      isLoading = false;
      setState(() {});
      var extractedError = json.decode(e.response.data);
      Flushbar(
        message: extractedError['desc'],
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        animationDuration: Duration(milliseconds: 500),
      ).show(context);
      if (e.response != null) {
        print(e.response.data);
      } else if (e.message != null) {
        print(e.message);
        print(e.response.data);
      }
    }
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
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context, false);
            },
            child: Icon(
              Icons.close,
              color: eventajaGreenTeal,
              size: 30,
            )),
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
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  postEditEvent();
                },
                child: Text(
                  'Update',
                  style: TextStyle(
                      color: eventajaGreenTeal,
                      fontSize: ScreenUtil.instance.setSp(18)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: categoryList.length == null
          ? Container(
              child: Center(child: CupertinoActivityIndicator(radius: 20)))
          : Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                  GestureDetector(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: Container(
                                      height: ScreenUtil.instance.setWidth(225),
                                      width: ScreenUtil.instance.setWidth(150),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: imageUri == null
                                            ? imageUriNetwork == null
                                                ? Image.asset(
                                                    'assets/grey-fade.jpg')
                                                : Image.network(
                                                    imageUriNetwork,
                                                    fit: BoxFit.fill,
                                                  )
                                            : Image.file(File(imageUri.path),
                                                fit: BoxFit.fill),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil.instance.setWidth(20),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Event Type',
                                        style: TextStyle(
                                            fontSize:
                                                ScreenUtil.instance.setSp(18),
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(10)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditEventType()))
                                              .then((value) {
                                            if (value != null) {
                                              isPrivate = value;
                                            }
                                            setState(() {});
                                          });
                                        },
                                        child: Container(
                                            width: ScreenUtil.instance
                                                .setWidth(170),
                                            height: ScreenUtil.instance
                                                .setWidth(50),
                                            padding: EdgeInsets.only(left: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  isPrivate == '0'
                                                      ? 'PUBLIC'
                                                      : 'PRIVATE',
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil
                                                          .instance
                                                          .setSp(15)),
                                                ))),
                                      ),
                                      SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(20)),
                                      Text(
                                        'Category',
                                        style: TextStyle(
                                            fontSize:
                                                ScreenUtil.instance.setSp(18),
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(10)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditCategoryList()))
                                              .then((values) {
                                            if (values == null) {
                                            } else {
                                              print(values['myListName']);
                                              categoryList =
                                                  values['myListName'];
                                              categoryId = values['myList'];
                                            }
                                            setState(() {});
                                          });
                                        },
                                        child: Container(
                                            width: ScreenUtil.instance
                                                .setWidth(170),
                                            height: ScreenUtil.instance
                                                .setWidth(50),
                                            padding: EdgeInsets.only(left: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  categoryList.length == 1
                                                      ? categoryList[0]
                                                      : categoryList.length == 2
                                                          ? categoryList[0] +
                                                              ', ' +
                                                              categoryList[1]
                                                          : categoryList
                                                                      .length ==
                                                                  3
                                                              ? categoryList[
                                                                      0] +
                                                                  ', ' +
                                                                  categoryList[
                                                                      1] +
                                                                  ', ' +
                                                                  categoryList[
                                                                      2]
                                                              : '',
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil
                                                          .instance
                                                          .setSp(15)),
                                                ))),
                                      )
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
                                      color: Colors.black54,
                                      fontSize: ScreenUtil.instance.setSp(18)),
                                ),
                                SizedBox(
                                  height: ScreenUtil.instance.setWidth(15),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditEventDate()),
                                        ).then((value) {
                                          if (value != null) {
                                            print(value);
                                            dateStart = value;
                                          }
                                          setState(() {});
                                        });
                                      },
                                      child: Container(
                                        width:
                                            ScreenUtil.instance.setWidth(150),
                                        height:
                                            ScreenUtil.instance.setWidth(50),
                                        padding: EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            dateStart == null ? '' : dateStart,
                                            style: TextStyle(
                                                fontSize: ScreenUtil.instance
                                                    .setSp(20)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.instance.setWidth(25),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditEventDate()),
                                        ).then((value) {
                                          if (value != null) {
                                            print(value);
                                            dateEnd = value;
                                          }
                                          setState(() {});
                                        });
                                      },
                                      child: Container(
                                        width:
                                            ScreenUtil.instance.setWidth(150),
                                        height:
                                            ScreenUtil.instance.setWidth(50),
                                        padding: EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            dateEnd == null ? '' : dateEnd,
                                            style: TextStyle(
                                                fontSize: ScreenUtil.instance
                                                    .setSp(20)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil.instance.setWidth(20),
                                ),
                                Text(
                                  'Time',
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
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditEventTime()))
                                            .then((value) {
                                          if (value != null) {
                                            timeStart = value;
                                            setState(() {});
                                          }
                                        });
                                      },
                                      child: Container(
                                          width:
                                              ScreenUtil.instance.setWidth(150),
                                          height:
                                              ScreenUtil.instance.setWidth(50),
                                          padding: EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                timeStart == null
                                                    ? ''
                                                    : timeStart,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(20)),
                                              ))),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.instance.setWidth(25),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditEventTime()))
                                            .then((value) {
                                          if (value != null) {
                                            timeEnd = value;
                                            setState(() {});
                                          }
                                        });
                                      },
                                      child: Container(
                                          width:
                                              ScreenUtil.instance.setWidth(150),
                                          height:
                                              ScreenUtil.instance.setWidth(50),
                                          padding: EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                timeEnd == null ? '' : timeEnd,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(20)),
                                              ))),
                                    ),
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
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none),
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
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(7))),
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
                                  child: Image.asset(
                                      'assets/icons/btn_mail_active.png'),
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
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(7))),
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
                                  child: Image.asset(
                                      'assets/icons/btn_web_active.png'),
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
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
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
                                address == null ? '' : address,
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
                                      borderSide: BorderSide(
                                          color: Colors.transparent)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.transparent))),
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
                ),
                isLoading == true
                    ? Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CupertinoActivityIndicator(),
                              Text('Uploading: ${progres.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageUri = image;

      cropImage(imageUri);
    });
  }

  Future cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 2.0, ratioY: 3.0),
      maxHeight: 512,
      maxWidth: 512,
    );

    imageUri = croppedImage;

    setState(() {});
  }

  showPlacePicker(BuildContext context) async {
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
      address = place.name;
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

  Widget showMap(BuildContext context) {
    StaticMapsProvider mapProvider = new StaticMapsProvider(
      GOOGLE_API_KEY: 'AIzaSyA2s9iDKooQ9Cwgr6HiDVQkG9p3fvsVmEI',
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

  Widget addMed() {
    print('length: ' + additionalMediaPhoto.length.toString());
    return Container(
      height: ScreenUtil.instance.setWidth(200),
      width: MediaQuery.of(context).size.width,
      child: ListView(
        padding: EdgeInsets.only(left: 10),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: additionalMediaPhoto.length < 1
                ? Container()
                : Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // getAdditionalImage(0);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1.5,
                                    color: Color(0xff8a8a8b).withOpacity(.2),
                                    blurRadius: 2)
                              ]),
                          child: additionalMediaPhoto[0].startsWith('http')
                              ? Image.network(
                                  additionalMediaPhoto[0],
                                  fit: BoxFit.fill,
                                )
                              : Image.file(
                                  File(additionalMediaPhoto[0]),
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                      additionalMediaPhoto.length > 1
                          ? Container()
                          : Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (additionalMediaID[0] == null) {
                                  } else {
                                    removedAdditionalMedia
                                        .add(additionalMediaID[0]);
                                  }
                                  additionalMediaPhoto.removeAt(0);
                                  setState(() {});
                                },
                                child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    )),
                              ),
                            )
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: additionalMediaPhoto.length < 2
                ? Container()
                : Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // getAdditionalImage(1);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1.5,
                                    color: Color(0xff8a8a8b).withOpacity(.2),
                                    blurRadius: 2)
                              ]),
                          child: additionalMediaPhoto[1].startsWith('http')
                              ? Image.network(
                                  additionalMediaPhoto[1],
                                  fit: BoxFit.fill,
                                )
                              : Image.file(
                                  File(additionalMediaPhoto[1]),
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                      additionalMediaPhoto.length > 2
                          ? Container()
                          : Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (additionalMediaID[1] == null) {
                                  } else {
                                    removedAdditionalMedia
                                        .add(additionalMediaID[1]);
                                  }
                                  additionalMediaPhoto.removeAt(1);
                                  setState(() {});
                                },
                                child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    )),
                              ),
                            )
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: additionalMediaPhoto.length < 3
                ? Container()
                : Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // getAdditionalImage(2);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1.5,
                                    color: Color(0xff8a8a8b).withOpacity(.2),
                                    blurRadius: 2)
                              ]),
                          child: additionalMediaPhoto[2].startsWith('http')
                              ? Image.network(
                                  additionalMediaPhoto[2],
                                  fit: BoxFit.fill,
                                )
                              : Image.file(
                                  File(additionalMediaPhoto[2]),
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                      additionalMediaPhoto.length > 3
                          ? Container()
                          : Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (additionalMediaID[2] == null) {
                                  } else {
                                    removedAdditionalMedia
                                        .add(additionalMediaID[2]);
                                  }
                                  additionalMediaPhoto.removeAt(2);
                                  setState(() {});
                                },
                                child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    )),
                              ),
                            )
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: additionalMediaPhoto.length < 4
                ? Container()
                : Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // getAdditionalImage(3);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1.5,
                                    color: Color(0xff8a8a8b).withOpacity(.2),
                                    blurRadius: 2)
                              ]),
                          child: additionalMediaPhoto[3].startsWith('http')
                              ? Image.network(
                                  additionalMediaPhoto[3],
                                  fit: BoxFit.fill,
                                )
                              : Image.file(
                                  File(additionalMediaPhoto[3]),
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                      additionalMediaPhoto.length > 4
                          ? Container()
                          : Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (additionalMediaID[3] == null) {
                                  } else {
                                    removedAdditionalMedia
                                        .add(additionalMediaID[3]);
                                  }
                                  additionalMediaPhoto.removeAt(3);
                                  print(additionalMediaPhoto.length);
                                  setState(() {});
                                },
                                child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    )),
                              ),
                            )
                    ],
                  ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: additionalMediaPhoto.length < 5
                ? Container()
                : Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // getAdditionalImage(0);
                        },
                        child: Container(
                          height: ScreenUtil.instance.setWidth(200),
                          width: ScreenUtil.instance.setWidth(150),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1.5,
                                    color: Color(0xff8a8a8b).withOpacity(.2),
                                    blurRadius: 2)
                              ]),
                          child: additionalMediaPhoto[4].startsWith('http')
                              ? Image.network(
                                  additionalMediaPhoto[4],
                                  fit: BoxFit.fill,
                                )
                              : Image.file(
                                  File(additionalMediaPhoto[4]),
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                      additionalMediaPhoto.length > 5
                          ? Container()
                          : Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (additionalMediaID[4] == null) {
                                  } else {
                                    removedAdditionalMedia
                                        .add(additionalMediaID[4]);
                                  }
                                  additionalMediaPhoto.removeAt(4);
                                  setState(() {});
                                },
                                child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    )),
                              ),
                            )
                    ],
                  ),
          ),
          additionalMediaPhoto.length < 5
              ? GestureDetector(
                  onTap: () {
                    _showDialog();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/grey-fade.jpg'),
                            fit: BoxFit.fill),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 1.5,
                              color: Color(0xff8a8a8b).withOpacity(.2),
                              blurRadius: 2)
                        ]),
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
        // mapIndexed(additionalMedia, (index, item) {
        //   print('item: ' + item);
        //   print('lenght: ' + additionalMedia.length.toString());
        //   print('index: ' + additionalMedia[index]);
        //   return Padding(
        //     padding: EdgeInsets.only(right: 10),
        //     child: GestureDetector(
        //             onTap: () {
        //               getAdditionalImage(index);
        //             },
        //             child: Container(
        //               child: additionalMedia[index].startsWith('http')
        //                   ? Image.network(
        //                       additionalMedia[index],
        //                       fit: BoxFit.fill,
        //                     )
        //                   : Image.file(
        //                       File(additionalMedia[index]),
        //                       fit: BoxFit.fill,
        //                     ),
        //             ),
        //           ),
        //   );
        // }).toList(),
      ),
    );
  }

  void _showDialog() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              additionalMedia.length == 4
                  ? Container()
                  : ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Choose Photo from Library'),
                      onTap: () {
                        imageSelectorGalery();
                        Navigator.pop(context);
                      },
                    ),
              additionalMedia.length != 4
                  ? Container()
                  : ListTile(
                      leading: new Icon(Icons.videocam),
                      title: new Text('Choose Video from Library'),
                      onTap: () {
                        videoSelectorGalery();
                        Navigator.pop(context);
                      },
                    ),
              additionalMedia.length == 4
                  ? Container()
                  : ListTile(
                      leading: new Icon(Icons.camera_alt),
                      title: new Text('Take Photo from Camera'),
                      onTap: () {
                        imageCaptureCamera();
                      }),
              new ListTile(
                leading: new Icon(Icons.close),
                title: new Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  imageSelectorGalery() async {
    var galleryFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    print(galleryFile.path);

    thisCropImage(galleryFile);
  }

  videoSelectorGalery() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var galleryFile = await ImagePicker.pickVideo(source: ImageSource.gallery);

    print(galleryFile.path);

    var appDocDir;

    if (Platform.isAndroid) {
      appDocDir = await getExternalStorageDirectory();
      print(appDocDir.runtimeType);
    } else {
      appDocDir = await getLibraryDirectory();
    }

    String fileFolder = appDocDir.path;

    String thumbnail = await Thumbnails.getThumbnail(
      thumbnailFolder: fileFolder,
      videoFile: galleryFile.path,
      imageType: ThumbFormat.JPEG,
      quality: 50,
    );

    print(thumbnail);

    setState(() {
      preferences.setString('POST_EVENT_ADDITIONAL_VIDEO', galleryFile.path);
      print(preferences.getString('POST_EVENT_ADDITIONAL_VIDEO'));
    });

    thisCropImage(File(thumbnail));
  }

  void imageCaptureCamera() async {
    var galleryFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (!mounted) return;

    thisCropImage(galleryFile);
  }

  thisCropImage(File galleryFile) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: galleryFile.path,
      aspectRatio: CropAspectRatio(
        ratioX: 2.0,
        ratioY: 3.0,
      ),
      maxWidth: 512,
      maxHeight: 512,
    );

    print(croppedImage.path);
    setState(() {
      additionalMediaPhoto.add(croppedImage.path.toString());
      additionalMedia.add(
          preferences.getString('POST_EVENT_ADDITIONAL_VIDEO') == null ||
                  preferences.getString('POST_EVENT_ADDITIONAL_VIDEO') == ''
              ? croppedImage.path.toString()
              : preferences.getString('POST_EVENT_ADDITIONAL_VIDEO'));
    });

    print('additionalMedia: ' + additionalMedia.toString());
    print('additionalMedia: ' + additionalMediaPhoto.toString());
  }

  Future getAdditionalImage(int index) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      additionalMedia[index] = image.path;

      cropAdditionalImage(additionalMedia[index], index);
    });
  }

  Future cropAdditionalImage(String image, int index) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image,
      aspectRatio: CropAspectRatio(ratioX: 2.0, ratioY: 3.0),
      maxHeight: 512,
      maxWidth: 512,
    );

    additionalMedia[index] = croppedImage.path;
    additionalMediaPhoto[index] = croppedImage.path;

    setState(() {});
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
      if (!mounted) return;
      setState(() {
        categoryEventData = extractedData['data'];
        assert(categoryEventData != null);
        categoryEventData.removeAt(0);
      });
    }
  }
}
