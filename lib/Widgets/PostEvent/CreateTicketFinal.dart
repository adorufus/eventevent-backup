import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/ManageEvent/ManageCustomForm.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:async/async.dart';
import 'package:eventevent/Widgets/PostEvent/FinishPostEvent.dart';
import 'package:eventevent/Widgets/PostEvent/PostEventInvitePeople.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTicketFinal extends StatefulWidget {
  final from;

  const CreateTicketFinal({Key key, this.from}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CreateTicketFinalState();
  }
}

class CreateTicketFinalState extends State<CreateTicketFinal> {
  GlobalKey<ScaffoldState> thisScaffold = new GlobalKey<ScaffoldState>();

  String imageUri;
  String ticketQuantity;
  String ticketTypeId;
  String price;
  String finalPrice;
  String merchantPrice;
  String startDate = "";
  String endDate = "";
  String startTime = "";
  String endTime = "";
  String desc = "";
  String ticketPaidBy = 'owner';
  int _curValue = 0;
  int fee = 0;

  SharedPreferences prefs;

  bool isLoading = false;

  File imageFile;

  Dio dio = new Dio(BaseOptions(baseUrl: BaseApi().apiUrl));

  void getData() async {
    print('get data');
    prefs = await SharedPreferences.getInstance();

    setState(() {
      imageUri = prefs.getString('SETUP_TICKET_POSTER');
      ticketQuantity = prefs.getString('SETUP_TICKET_QTY');
      price = prefs.getString('SETUP_TICKET_PRICE');
      startDate = prefs.getString('SETUP_TICKET_START_DATE');
      endDate = prefs.getString('SETUP_TICKET_END_DATE');
      startTime = prefs.getString('SETUP_TICKET_START_TIME');
      endTime = prefs.getString('SETUP_TICKET_END_TIME');
      desc = prefs.getString('SETUP_TICKET_DESCRIPTION');
      ticketTypeId = prefs.getString('NEW_EVENT_TICKET_TYPE_ID');
      imageFile = new File(imageUri);
    });
  }

  @override
  void initState() {
    getData();

    if (price != null) {
      fee = (int.parse(price) * 3) ~/ 100;

      if (fee < 5000) {
        fee = 5000;
      }
    }

    setState(() {});
    super.initState();
  }

  @override
  void didUpdateWidget(CreateTicketFinal oldWidget) {
    getData();
    super.didUpdateWidget(oldWidget);
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
        key: thisScaffold,
        backgroundColor: Colors.white.withOpacity(.5),
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
            'REVIEW TICKETS',
            style: TextStyle(color: eventajaGreenTeal),
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            saveFinalData(context);
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
                    'Submit Ticket',
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
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
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
                                    child: Image.file(
                                        File(imageUri == null ? '' : imageUri),
                                        fit: BoxFit.fill),
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
                                            ScreenUtil.instance.setWidth(40),
                                        child: Text(ticketQuantity == null
                                            ? ''
                                            : ticketQuantity)),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(7)),
                                    Text(
                                      'Ticket Sales Starts',
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
                                            ScreenUtil.instance.setWidth(40),
                                        child:
                                            Text(startDate + ' ' + startTime)),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(7)),
                                    Text(
                                      'Ticket Sales Ends',
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
                                            ScreenUtil.instance.setWidth(40),
                                        child: Text(endDate + ' ' + endTime)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(color: Colors.black),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(15),
                          ),
                          Text(
                            'Description',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(18),
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(desc),
                          SizedBox(height: ScreenUtil.instance.setWidth(15)),
                          Divider(),
                          SizedBox(height: ScreenUtil.instance.setWidth(15)),
                          ticketTypeId == '5' ||
                                  ticketTypeId == '10' ||
                                  ticketTypeId == '2' ||
                                  ticketTypeId == '7'
                              ? Container()
                              : serviceFee(context),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
        ));
  }

  Widget serviceFee(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Image.asset(
              'assets/icon_eventevent_kecil.png',
              scale: 3,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              'Service Fee',
              style: TextStyle(
                  color: eventajaGreenTeal, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'Free applies at 3% or minimum Rp. 5000 / ticket sales.',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(20),
        ),
        Text('Choose who\'s going to pay the fee:'),
        SizedBox(height: ScreenUtil.instance.setWidth(10)),
        Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 2),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 6,
                      spreadRadius: 5,
                      color: Color(0xff8a8a8b).withOpacity(.2))
                ]),
            height: ScreenUtil.instance.setWidth(250),
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                        groupValue: _curValue,
                        onChanged: (int i) => setState(() {
                          _curValue = i;
                        }),
                        value: 0,
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Paid by you',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(20))),
                          SizedBox(height: ScreenUtil.instance.setWidth(10)),
                          Container(
                              height: ScreenUtil.instance.setWidth(50),
                              child: Text(
                                'eventevent fee will be \npaid by you, please see details.',
                                maxLines: 2,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                softWrap: true,
                              ))
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: ScreenUtil.instance.setWidth(28),
                            width: ScreenUtil.instance.setWidth(110),
                            decoration: BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Color(0xFF34B323).withOpacity(0.4),
                                      blurRadius: 2,
                                      spreadRadius: 1.5)
                                ],
                                color: Color(0xFF34B323),
                                borderRadius: BorderRadius.circular(15)),
                            child: Center(
                                child: Text(
                              'Rp. ' + price == null ? '' : price,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil.instance.setSp(14),
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(6),
                          ),
                          Text(
                            'Displayed Price',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          )
                        ],
                      ),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(13),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(20),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(50),
                      ),
                      Text('Ticket Price'),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(' :'),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(100),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text('Rp. ' + price),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(13),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(50),
                      ),
                      Row(
                        children: <Widget>[
                          Image.asset('assets/icon_eventevent_kecil.png',
                              scale: 3),
                          SizedBox(
                            width: ScreenUtil.instance.setWidth(5),
                          ),
                          Text('Fee'),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(' :'),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(67),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                        '- Rp. ' + fee.toString(),
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(13),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(10),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(50),
                      ),
                      Text('You\'ll get'),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(' :'),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(67),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                        'Rp. ' + (int.parse(price) - fee).toString(),
                        style: TextStyle(
                            color: eventajaGreenTeal,
                            fontSize: ScreenUtil.instance.setSp(18),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(13),
                      ),
                    ],
                  )
                ])),
        SizedBox(
          height: ScreenUtil.instance.setWidth(20),
        ),
        Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 2),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 6,
                      spreadRadius: 5,
                      color: Color(0xff8a8a8b).withOpacity(.2))
                ]),
            height: ScreenUtil.instance.setWidth(250),
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                        groupValue: _curValue,
                        onChanged: (int i) => setState(() {
                          _curValue = i;
                        }),
                        value: 1,
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Paid by attendee',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(20))),
                          SizedBox(height: ScreenUtil.instance.setWidth(10)),
                          Container(
                              height: ScreenUtil.instance.setWidth(50),
                              child: Text(
                                'eventevent fee will be paid by your \ncustomers, please see details.',
                                maxLines: 2,
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 11),
                                softWrap: true,
                              ))
                        ],
                      ),
                      Expanded(child: SizedBox()),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: ScreenUtil.instance.setWidth(28),
                            width: ScreenUtil.instance.setWidth(110),
                            decoration: BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Color(0xFF34B323).withOpacity(0.4),
                                      blurRadius: 2,
                                      spreadRadius: 1.5)
                                ],
                                color: Color(0xFF34B323),
                                borderRadius: BorderRadius.circular(15)),
                            child: Center(
                                child: Text(
                              'Rp. ' + (int.parse(price) + fee).toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil.instance.setSp(14),
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(8),
                          ),
                          Text(
                            'Displayed Price',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          )
                        ],
                      ),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(13),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(20),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(50),
                      ),
                      Text('Ticket Price'),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(' :'),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(100),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text('Rp. ' + price),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(13),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(50),
                      ),
                      Row(
                        children: <Widget>[
                          Image.asset('assets/icon_eventevent_kecil.png',
                              scale: 3),
                          SizedBox(
                            width: ScreenUtil.instance.setWidth(5),
                          ),
                          Text('Fee'),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(' :'),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(67),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                        '+ Rp. ' + fee.toString(),
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(13),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(10),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(50),
                      ),
                      Text('You\'ll get'),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(' :'),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(67),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                        'Rp. ' + (int.parse(price) + 5000).toString(),
                        style: TextStyle(
                            color: eventajaGreenTeal,
                            fontSize: ScreenUtil.instance.setSp(18),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(13),
                      ),
                    ],
                  )
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: <Widget>[
                  //     SizedBox(
                  //       width: ScreenUtil.instance.setWidth(55),
                  //     ),
                  //     Text('Ticket Price    :'),
                  //     SizedBox(
                  //       width: ScreenUtil.instance.setWidth(55),
                  //     ),
                  //     Text('Rp. ' + price)
                  //   ],
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: <Widget>[
                  //     SizedBox(
                  //       width: ScreenUtil.instance.setWidth(55),
                  //     ),
                  //     Text('Fee                 :'),
                  //     SizedBox(
                  //       width: ScreenUtil.instance.setWidth(55),
                  //     ),
                  //     Text(
                  //       'Rp. ' + '5,000',
                  //       style: TextStyle(color: Colors.grey[300]),
                  //     )
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: ScreenUtil.instance.setWidth(10),
                  // ),
                  // Divider(
                  //   color: Colors.black,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: <Widget>[
                  //     SizedBox(
                  //       width: ScreenUtil.instance.setWidth(55),
                  //     ),
                  //     Text('You\'ll get       :'),
                  //     SizedBox(
                  //       width: ScreenUtil.instance.setWidth(55),
                  //     ),
                  //     Text(
                  //       'Rp. ' + (int.parse(price) + 5000).toString(),
                  //       style: TextStyle(
                  //           color: eventajaGreenTeal,
                  //           fontSize: ScreenUtil.instance.setSp(18),
                  //           fontWeight: FontWeight.bold),
                  //     )
                  //   ],
                  // ),
                ]))
      ],
    ));
  }

  Future saveFinalData(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (ticketTypeId == '2' ||
        ticketTypeId == '5' ||
        ticketTypeId == '7' ||
        ticketTypeId == '10') {
    } else {
      if (_curValue == 0) {
        setState(() {
          ticketPaidBy = 'owner';
          finalPrice = (int.parse(price) - fee).toString();
          merchantPrice = price;
        });
      } else if (_curValue == 1) {
        setState(() {
          ticketPaidBy = 'attandee';
          finalPrice = (int.parse(price) + fee).toString();
          merchantPrice = price;
        });
      } else if (_curValue == 2) {
        setState(() {
          ticketPaidBy = 'op1';
          finalPrice = (int.parse(price) + 10000).toString();
          merchantPrice = price;
        });
      }
    }

    try {
      Map<String, dynamic> body = {
        'X-API-KEY': API_KEY,
        'eventID': prefs.getInt('NEW_EVENT_ID').toString(),
        'ticket_name': prefs.getString('SETUP_TICKET_NAME'),
        'quantity': prefs.getString('SETUP_TICKET_QTY'),
        'price': prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '5' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '2' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '2' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '7' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '10'
            ? '0'
            : price,
        'min_ticket': prefs.getString('SETUP_TICKET_MIN_BOUGHT'),
        'max_ticket': prefs.getString('SETUP_TICKET_MAX_BOUGHT'),
        'sales_start_date': prefs.getString('SETUP_TICKET_START_DATE') +
            ' ' +
            prefs.getString('SETUP_TICKET_START_TIME') +
            ':00',
        'sales_end_date': prefs.getString('SETUP_TICKET_END_DATE') +
            ' ' +
            prefs.getString('SETUP_TICKET_END_TIME') +
            ':00',
        'descriptions': prefs.getString('SETUP_TICKET_DESCRIPTION'),
        'show_remaining_ticket':
            prefs.getString('SETUP_TICKET_SHOW_REMAINING_TICKET'),
        'fee_paid_by': prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '5' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '2' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '2' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '7' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '10'
            ? ''
            : ticketPaidBy,
        'final_price': prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '5' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '2' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '2' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '7' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '10'
            ? '0'
            : ticketPaidBy == 'owner' ? price : finalPrice,
        'paid_ticket_type_id': prefs.getString('SETUP_TICKET_PAID_TICKET_TYPE'),
        'merchant_price': prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '5' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '2' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '2' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '7' ||
                prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '10'
            ? '0'
            : merchantPrice,
        'is_single_ticket': prefs.getString('SETUP_TICKET_IS_ONE_PURCHASE'),
        'ticket_image': await MultipartFile.fromFile(imageFile.path,
            filename: "eventeventticket-${DateTime.now().toString()}.jpg",
            contentType: MediaType('image', 'jpeg'))
      };

      if (prefs.getString('zoom_id') != '') {
        body['zoom_id'] = prefs.getString('zoom_id');
        body['zoom_description'] = prefs.getString('zoom_desc');
      }

      print(body);

      print(prefs.getString('SETUP_TICKET_NAME'));
      print(prefs.getString('SETUP_TICKET_DESCRIPTION'));
      print(prefs.getString('SETUP_TICKET_QTY'));
      print(prefs.getString('SETUP_TICKET_PRICE'));
      print(prefs.getString('SETUP_TICKET_MIN_BOUGHT'));
      print(prefs.getString('SETUP_TICKET_MAX_BOUGHT'));
      print(prefs.getString('SETUP_TICKET_START_DATE'));
      print(prefs.getString('SETUP_TICKET_START_TIME'));
      print(prefs.getString('SETUP_TICKET_END_DATE'));
      print(prefs.getString('SETUP_TICKET_END_TIME'));
      print(prefs.getString('SETUP_TICKET_SHOW_REMAINING_TICKET'));
      print(ticketPaidBy);
      print(finalPrice);

      var data = FormData.fromMap(body);
      Response response = await dio.post(
        '/ticket_setup/post',
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
        prefs.remove('zoom_id');
        prefs.remove('zoom_desc');
        setState(() {
          isLoading = false;
        });
        print(response.data);
        print('proccessing.....');
        if (prefs.getString('POST_EVENT_TYPE') == '0') {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (BuildContext context) => FinishPostEvent()));
        } else {
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
          } else {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (BuildContext context) => CustomFormActivator(
                      eventId: prefs.getInt("NEW_EVENT_ID").toString(),
                      from: "createEvent",
                    )));
          }
        }
      } else {
        print(response.data + response.statusCode);
      }
    } catch (e) {
      if (e is DioError) {
        setState(() {
          isLoading = false;
        });
        // var extractedError = json.decode(e.response.data);
        print(e.message);
        // print(extractedError);
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
  }
}
