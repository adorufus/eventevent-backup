import 'dart:convert';
import 'dart:io';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Transaction/ProcessingPayment.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:async/async.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'CreateTicketName.dart';
import 'FinishPostEvent.dart';
import 'PostEventInvitePeople.dart';

class SelectTicketType extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelectTicketTypeState();
  }
}

class SelectTicketTypeState extends State<SelectTicketType> {
  GlobalKey<ScaffoldState> thisState = new GlobalKey<ScaffoldState>();
  List<dynamic> ticketType;
  String imageUri;
  String isPrivate;
  String base64Image;
  File imageFile;
  List<String> additionalMediaList = [];
  List<File> additionalMediaFiles = [];
  bool isLoading;
  

  @override
  void initState() {
    super.initState();

    getTicketTypeList();
    getData();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> imageBytes;

    setState(() {
      isPrivate = prefs.getString('POST_EVENT_TYPE');
      additionalMediaList.addAll(prefs.getStringList('POST_EVENT_ADDITIONAL_MEDIA'));

      print(additionalMediaFiles);

      imageFile = new File(prefs.getString('POST_EVENT_POSTER'));
      print(imageFile.path);
      base64Image = base64Encode(imageFile.readAsBytesSync());
      print(base64Image);
    });
  }

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
        key: thisState,
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
            'CHOOSE TICKET TYPE',
            style: TextStyle(color: eventajaGreenTeal),
          ),
        ),
        body: ticketType == null ? HomeLoadingScreen().myTicketLoading() : Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            itemCount: ticketType.length == null ? 0 : ticketType.length,
            itemBuilder: (BuildContext context, i) {
              if (ticketType[i]['id'] == '4') {
                imageUri = 'assets/btn_ticket/paid.png';
              }
              if (ticketType[i]['id'] == '9') {
                imageUri = 'assets/btn_ticket/paid.png';
              }
              if (ticketType[i]['id'] == '5') {
                imageUri = 'assets/btn_ticket/free-limited.png';
              }
              if (ticketType[i]['id'] == '10') {
                imageUri = 'assets/btn_ticket/free-limited.png';
              }
              if (ticketType[i]['id'] == '1') {
                imageUri = 'assets/btn_ticket/free.png';
              }
              if (ticketType[i]['id'] == '2') {
                imageUri = 'assets/btn_ticket/no-ticket.png';
              }
              if (ticketType[i]['id'] == '3') {
                imageUri = 'assets/btn_ticket/ots-800px.png';
              }
              return ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ProcessingPayment(
                        loadingType: 'create event',
                        ticketType: ticketType,
                        isPrivate: isPrivate,
                        imageFile: imageFile,
                        index: i,
                        additionalMedia: additionalMediaList,
                        context: context
                      );
                    }
                  )).then((val){
                    print('value $val');
                    if(val == null){

                    } else {
                      Flushbar(
                        animationDuration: Duration(milliseconds: 500),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.red,
                        flushbarPosition: FlushbarPosition.TOP,
                        message: val,
                      )..show(context);
                    }
                  });
                  //postEvent(i);
                },
                contentPadding:
                    EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                leading: SizedBox(
                  height: ScreenUtil.instance.setWidth(35),
                  width: ScreenUtil.instance.setWidth(120),
                  child: Image.asset(
                    imageUri,
                    fit: BoxFit.fill,
                  ),
                ),
                title: Text(
                  ticketType[i]['name'] == null ? '' : ticketType[i]['name'],
                  style: TextStyle(
                      fontSize: ScreenUtil.instance.setSp(18),
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  children: <Widget>[
                    Text(ticketType[i]['description'] == null
                        ? ''
                        : ticketType[i]['description']),
                  ],
                ),
              );
            },
          ),
        ));
  }

  Future getTicketTypeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/ticket_type/list?X-API-KEY=$API_KEY';

    final response = await http.get(url,
        headers: ({
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session')
        }));

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        ticketType = extractedData['data'];
      });
    }
  }

  Future postPhoto(int index, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      "Authorization": AUTHORIZATION_KEY,
      "X-API-KEY": API_KEY,
      "cookie": prefs.getString('Session')
    };

    String url = BaseApi().apiUrl + '/event/create';
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    var parsed;
    request.headers.addAll(headers);
    request.fields['name'] = prefs.getString('POST_EVENT_NAME');
    request.fields['eventTypeID'] =
        (int.parse(prefs.getString('POST_EVENT_TYPE')) + 1).toString();
    request.fields['ticketTypeID'] = ticketType[index]['id'];
    request.fields['address'] =
        prefs.getString('CREATE_EVENT_LOCATION_ADDRESS');
    request.fields['latitude'] = prefs.getString('CREATE_EVENT_LOCATION_LAT');
    request.fields['longitude'] = prefs.getString('CREATE_EVENT_LOCATION_LONG');
    request.fields['dateStart'] = prefs.getString('POST_EVENT_START_DATE');
    request.fields['timeStart'] = prefs.getString('POST_EVENT_START_TIME');
    request.fields['dateEnd'] = prefs.getString('POST_EVENT_END_DATE');
    request.fields['timeEnd'] = prefs.getString('POST_EVENT_END_TIME');
    request.fields['description'] = prefs.getString('CREATE_EVENT_DESCRIPTION');
    request.fields['phone'] = prefs.getString('CREATE_EVENT_TELEPHONE');
    request.fields['email'] = prefs.getString('CREATE_EVENT_EMAIL');
    request.fields['website'] = prefs.getString('CREATE_EVENT_WEBSITE');
    request.fields['isPrivate'] = prefs.getString('POST_EVENT_TYPE');
    request.fields['modifiedById'] = prefs.getString('Last User ID');

//    request.fields.addAll({
////      'X-API-KEY': API_KEY,
//      'eventTypeID':
//          (int.parse(prefs.getString('POST_EVENT_TYPE')) + 1).toString(),
//      'ticketTypeID': ticketType[index]['id'],
//      'name': prefs.getString('POST_EVENT_NAME'),
//      'address': prefs.getString('CREATE_EVENT_LOCATION_ADDRESS'),
//      'latitude': prefs.getString('CREATE_EVENT_LOCATION_LAT'),
//      'longitude': prefs.getString('CREATE_EVENT_LOCATION_LONG'),
//      'dateStart': prefs.getString('POST_EVENT_START_DATE'),
//      'timeStart': prefs.getString('POST_EVENT_START_TIME'),
//      'dateEnd': prefs.getString('POST_EVENT_END_DATE'),
//      'timeEnd': prefs.getString('POST_EVENT_END_TIME'),
//      'description': prefs.getString('CREATE_EVENT_DESCRIPTION'),
//      'phone': prefs.getString('CREATE_EVENT_TELEPHONE'),
//      'email': prefs.getString('CREATE_EVENT_EMAIL'),
//      'website': prefs.getString('CREATE_EVENT_WEBSITE'),
//      'isPrivate': prefs.getString('POST_EVENT_TYPE'),
//      'modifiedById': prefs.getString('Last User ID'),
//    });
    for (int i = 0;
        i < prefs.getStringList('POST_EVENT_CATEGORY_ID').length;
        i++) {
      setState(() {
        request.fields['category[]'] =
            prefs.getStringList('POST_EVENT_CATEGORY_ID')[i];
      });
    }
    var multipartFile = new http.MultipartFile('photo', stream, length,
        filename: basename(imageFile.path));
    request.files.add(multipartFile);

//    request.finalize();

    print(request.fields.toString());

    request.send().then((response) async {
      print(response.statusCode);
      print(response.stream.toString());
      var response2 = await http.Response.fromStream(response);
      print(response2.body);
      // response.stream.transform(utf8.decoder).map((value) => print(value[0]));
      // response.stream.transform(utf8.decoder).listen((value){
      //   print(value);
      // });

      if (response.statusCode == 200) {
        print('ini untuk setup ticket');
        print(ticketType[index]['id']);
        if (ticketType[index]['isSetupTicket'] == '1') {
          print('paid: ' + response2.body);

          setState(() {
            var extractedData = json.decode(response2.body);
            prefs.setString('SETUP_TICKET_PAID_TICKET_TYPE',
                ticketType[index]['paid_ticket_type']['id']);
            prefs.setString(
                'NEW_EVENT_TICKET_TYPE_ID', ticketType[index]['paid_ticket_type_id'] == null ? ticketType[index]['id'] : ticketType[index]['paid_ticket_type_id']);
            prefs.setInt('NEW_EVENT_ID', extractedData['data']['id']);
          });
          Navigator.of(context).push(
              CupertinoPageRoute(builder: (context) => CreateTicketName()));
        } else {
          if (isPrivate == '0') {
            if (ticketType[index]['id'] == '1' ||
                ticketType[index]['2'] ||
                ticketType[index]['3']) {
              var myResponse = await http.Response.fromStream(response);

              print('non Paid: ' + myResponse.body);
              setState(() {
                var extractedData = json.decode(myResponse.body);
                prefs.setString(
                    'NEW_EVENT_TICKET_TYPE_ID', ticketType[index]['id']);
                prefs.setInt('NEW_EVENT_ID', extractedData['data']['id']);
              });
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => FinishPostEvent()));
            }
          } else {
            print(ticketType[index]['id']);
            if (ticketType[index]['id'] == '1' ||
                ticketType[index]['id'] == '2' ||
                ticketType[index]['id'] == '3') {
              var myResponse = await http.Response.fromStream(response);

              print('non paid: ' + myResponse.body);
              setState(() {
                var extractedData = json.decode(myResponse.body);
                prefs.setString(
                    'NEW_EVENT_TICKET_TYPE_ID', ticketType[index]['id']);
                prefs.setInt('NEW_EVENT_ID', extractedData['data']['id']);
              });
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => PostEventInvitePeople(
                    calledFrom: "new event",
                  )));
            }
          }
        }
      }

      return http.Response.fromStream(response);
    }).then((extractJson) {
      print(prefs.getString('NEW_EVENT_ID'));
    }).catchError((error) => print(error));
  }
}
