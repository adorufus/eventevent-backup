import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/ManageEvent/SubmitEditTicket.dart';
import 'package:eventevent/Widgets/PostEvent/FinishPostEvent.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/Widgets/timeline/EditEventItem/EditEventDate.dart';
import 'package:eventevent/Widgets/timeline/EditEventItem/EditEventTime.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/DateTimeConverter.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditTicket extends StatefulWidget {
  final Map ticketDetail;

  const EditTicket({Key key, this.ticketDetail}) : super(key: key);

  @override
  _EditTicketState createState() => _EditTicketState();
}

class _EditTicketState extends State<EditTicket> {
  GlobalKey<ScaffoldState> thisScaffold = new GlobalKey<ScaffoldState>();
  TextEditingController ticketNameController,
      ticketQuantityController,
      priceController,
      minTicketController,
      maxTicketController,
      descController;
  Dio dio = new Dio(BaseOptions(
      baseUrl: BaseApi().apiUrl, connectTimeout: 15000, receiveTimeout: 15000));

  String startDate = '';
  String startTime = '';
  String endDate = '';
  String endTime = '';
  int __curValue = 0;
  int __curValue2 = 0;
  bool isLoading = false;
  File imageFile;
  File imageUri;

  setupValue() {
    setState(() {
      ticketNameController =
          TextEditingController(text: widget.ticketDetail['ticket_name']);
      ticketQuantityController =
          TextEditingController(text: widget.ticketDetail['quantity']);
      priceController =
          TextEditingController(text: widget.ticketDetail['price']);
      minTicketController =
          TextEditingController(text: widget.ticketDetail['min_ticket']);
      maxTicketController =
          TextEditingController(text: widget.ticketDetail['max_ticket']);
      descController =
          TextEditingController(text: widget.ticketDetail['descriptions']);

      startDate = DateTimeConverter.convertToDate(
          DateTime.parse(widget.ticketDetail['sales_start_date']), '-');
      endDate = DateTimeConverter.convertToDate(
          DateTime.parse(widget.ticketDetail['sales_end_date']), '-');
      startTime = DateTimeConverter.convertToTime(
          DateTime.parse(widget.ticketDetail['sales_start_date']), ':');
      endTime = DateTimeConverter.convertToTime(
          DateTime.parse(widget.ticketDetail['sales_end_date']), ':');
      __curValue = int.parse(widget.ticketDetail['show_remaining_ticket']);
      __curValue2 = int.parse(widget.ticketDetail['is_single_ticket']);
    });
  }

  @override
  void initState() {
    setupValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          // saveFinalData();
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                blurRadius: 2,
                spreadRadius: 1.5,
                color: Color(0xff8a8a8b).withOpacity(.3),
                offset: Offset(0, -1))
          ]),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            height: ScreenUtil.instance.setWidth(50),
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(50),
              child: RaisedButton(
                color: eventajaGreenTeal,
                onPressed: () {
                  saveFinalData(context);
                },
                child: Text(
                  'UPDATE TICKET',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
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
                        controller: ticketNameController,
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
                                      ? widget.ticketDetail
                                              .containsKey('ticket_image')
                                          ? Image.asset('assets/grey-fade.jpg')
                                          : Image.network(
                                              widget.ticketDetail[
                                                  'ticket_image']['secure_url'],
                                              fit: BoxFit.fill)
                                      : Image.file(File(imageUri.path),
                                          fit: BoxFit.cover),
                                ),
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
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(10)),
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
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(20)),
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
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(10)),
                                Container(
                                    width: ScreenUtil.instance.setWidth(170),
                                    height: ScreenUtil.instance.setWidth(50),
                                    padding: EdgeInsets.only(left: 10),
                                    child: widget.ticketDetail[
                                                    'paid_ticket_type_id'] ==
                                                '2' ||
                                            widget.ticketDetail[
                                                    'paid_ticket_type_id'] ==
                                                '4' ||
                                            widget.ticketDetail[
                                                    'paid_ticket_type_id'] ==
                                                '7'
                                        ? Text('FREE',
                                            style: TextStyle(
                                                fontSize: ScreenUtil.instance
                                                    .setSp(18),
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
                                          fontSize:
                                              ScreenUtil.instance.setSp(18),
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Container(
                                        width:
                                            ScreenUtil.instance.setWidth(170),
                                        height:
                                            ScreenUtil.instance.setWidth(50),
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
                                          fontSize:
                                              ScreenUtil.instance.setSp(18),
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Container(
                                        width:
                                            ScreenUtil.instance.setWidth(170),
                                        height:
                                            ScreenUtil.instance.setWidth(50),
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
                                        builder: (context) => EditEventDate()),
                                  ).then((value) {
                                    if (value != null) {
                                      print(value);
                                      startDate = value;
                                    }
                                    setState(() {});
                                  });
                                },
                                child: Container(
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
                                              fontSize: ScreenUtil.instance
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
                                              EditEventTime())).then((value) {
                                    if (value != null) {
                                      startTime = value;
                                      setState(() {});
                                    }
                                  });
                                },
                                child: Container(
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
                                              fontSize: ScreenUtil.instance
                                                  .setSp(20)),
                                        ))),
                              ),
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
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditEventDate()),
                                  ).then((value) {
                                    if (value != null) {
                                      print(value);
                                      endDate = value;
                                    }
                                    setState(() {});
                                  });
                                },
                                child: Container(
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
                                              fontSize: ScreenUtil.instance
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
                                              EditEventTime())).then((value) {
                                    if (value != null) {
                                      endTime = value;
                                      setState(() {});
                                    }
                                  });
                                },
                                child: Container(
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
                                              fontSize: ScreenUtil.instance
                                                  .setSp(20)),
                                        ))),
                              ),
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
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none),
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
          isLoading == false
              ? Container()
              : Container(
                  color: Colors.black45,
                  child: Center(
                    child: CupertinoActivityIndicator(
                      animating: true,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Future saveFinalData(BuildContext context) async {
    if (widget.ticketDetail['paid_ticket_type_id'] == '2' ||
        widget.ticketDetail['paid_ticket_type_id'] == '4' ||
        widget.ticketDetail['paid_ticket_type_id'] == '7') {
      setState(() {
        isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();

      try {
        Map<String, dynamic> body = {
          'X-API-KEY': API_KEY,
          'id': widget.ticketDetail['id'],
          'ticket_name': ticketNameController.text,
          'quantity': ticketQuantityController.text,
          'price': '0',
          'min_ticket': minTicketController.text,
          'max_ticket': maxTicketController.text,
          'sales_start_date': startDate + ' ' + startTime,
          'sales_end_date': endDate + ' ' + endTime,
          'descriptions': descController.text,
          'show_remaining_ticket': __curValue.toString(),
          'fee_paid_by': '',
          'final_price': '0',
          'paid_ticket_type_id':
              prefs.getString('SETUP_TICKET_PAID_TICKET_TYPE'),
          'is_single_ticket': __curValue2.toString(),
          'ticket_image': imageFile == null
              ? ''
              : await MultipartFile.fromFile(
                  imageFile.path,
                  filename: "eventeventticket-${DateTime.now().toString()}.jpg",
                )
        };

        print(body);

        var data = FormData.fromMap(body);
        Response response = await dio.post(
          '/ticket_setup/update',
          options: Options(
            headers: {
              'Authorization': AUTHORIZATION_KEY,
              'cookie': prefs.getString('Session')
            },
            responseType: ResponseType.plain,
          ),
          data: data,
        );

        var extractedData = json.decode(response.data);

        print(response.data);

        if (response.statusCode == 201 || response.statusCode == 200) {
          setState(() {
            isLoading = false;
          });
          print(response.data);
          print('proccessing.....');
          if (prefs.getString('Previous Widget') == 'AddNewTicket') {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardWidget(
                          isRest: false,
                          selectedPage: 4,
                          userId: prefs.getString('Last User ID'),
                        )),
                ModalRoute.withName('/Dashboard'));
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventDetailLoadingScreen(
                        eventId: prefs.getInt('NEW_EVENT_ID').toString())));
          }
        } else {
          print(response.data + response.statusCode);
        }
      } catch (e) {
        if (e is DioError) {
          setState(() {
            isLoading = false;
          });
          var extractedError = json.decode(e.response.data);
          print(e.message);
          print(extractedError);
        }
        if (e is FileSystemException) {
          setState(() {
            isLoading = false;
          });
          print(e.message);
        }
        if (e is NoSuchMethodError) {
          setState(() {
            isLoading = false;
          });
          print(e.stackTrace);
        }
      }
    } else {
      Map ticketDetail = {
        'id': widget.ticketDetail['id'],
        'ticket_name': ticketNameController.text,
        'quantity': ticketQuantityController.text,
        'price': priceController.text,
        'min_ticket': minTicketController.text,
        'max_ticket': maxTicketController.text,
        'sales_start_date': startDate + ' ' + startTime,
        'sales_end_date': endDate + ' ' + endTime,
        'show_remaining_ticket': __curValue.toString(),
        'single_ticket': __curValue2.toString(),
        'description': descController.text,
        'ticket_type_id': '1',
        'image_url': imageUri != null
            ? await MultipartFile.fromFile(imageUri.path,
                filename:
                    "eventevent_ticket_photo-${DateTime.now().toString()}.jpg")
            : ''
      };

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SubmitEditTicket(
                    ticketDetail: ticketDetail,
                  )));
    }
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
}
