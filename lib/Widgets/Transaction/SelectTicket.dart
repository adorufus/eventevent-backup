import 'dart:convert';
import 'dart:math';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Transaction/SelectedTicketQuantity.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SelectTicketWidget extends StatefulWidget {
  final eventID;
  final eventDate;

  const SelectTicketWidget({Key key, this.eventID, this.eventDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SelectTicketWidgetState();
  }
}

class _SelectTicketWidgetState extends State<SelectTicketWidget> {
  List ticketListData;

  String ticketButtonImageURI = 'assets/btn_ticket/paid-value.png';
  String date;
  String dateEvent;
  Color itemColor;
  String ticketPrice;
  DateTime endTime;
  DateTime startTime;

  void initConvertDate(String dateEvent, String date) {
    int yearStart, monthStart, dateStart, hourStart, minuteStart, secondStart;
    String strHour, strMinute, strSecond;
    String month = "";
    yearStart = int.parse(dateEvent.substring(0, 4));
    monthStart = int.parse(dateEvent.substring(5, 7));

    if (monthStart == 1) {
      month = "January";
    } else if (monthStart == 2) {
      month = "February";
    } else if (monthStart == 3) {
      month = "March";
    } else if (monthStart == 4) {
      month = "April";
    } else if (monthStart == 5) {
      month = "May";
    } else if (monthStart == 6) {
      month = "June";
    } else if (monthStart == 7) {
      month = "July";
    } else if (monthStart == 8) {
      month = "August";
    } else if (monthStart == 9) {
      month = "September";
    } else if (monthStart == 10) {
      month = "October";
    } else if (monthStart == 11) {
      month = "November";
    } else if (monthStart == 12) {
      month = "December";
    }

    dateStart = int.parse(dateEvent.substring(8, 10));
    date = dateStart.toString() + " " + month + " " + yearStart.toString();
    print('date' + date);
  }

  @override
  void initState() {
    super.initState();
    getTicketList();
    dateEvent = widget.eventDate;
    date = dateEvent;
    initConvertDate(dateEvent, date);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'SELECT TICKET',
          style: TextStyle(color: eventajaGreenTeal),
        ),
        leading: GestureDetector(
          child: Icon(
            CupertinoIcons.clear,
            size: 50,
            color: eventajaGreenTeal,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ticketListData == null
          ? HomeLoadingScreen().myTicketLoading()
          : ListView.builder(
              itemCount: ticketListData == null ? 0 : ticketListData.length,
              itemBuilder: (BuildContext context, i) {
                String ticketStatus = 'Available';

                if (ticketListData[i]['availableTicketStatus'] == '1') {
                  ticketStatus = 'Available';
                } else if (DateTime.parse(ticketListData[i]['sales_end_date'])
                    .isBefore(DateTime.now())) {
                  ticketStatus =
                      'Ends on ${endTime.day} - ${endTime.month} - ${endTime.year}';
                } else if (DateTime.parse(ticketListData[i]['sales_start_date'])
                    .isAfter(DateTime.now())) {
                  ticketStatus =
                      'Starts on ${endTime.day} - ${endTime.month} - ${endTime.year}';
                } else if (ticketListData[i]['availableTicketStatus'] == '0') {
                  ticketStatus = 'Sold Out';
                  if (int.parse(ticketListData[i]['booked']) > 0) {
                    ticketStatus = 'Full Book';
                  }
                }

                if (ticketListData[i]['event']['ticket_type']['type'] ==
                        'paid' ||
                    ticketListData[i]['event']['ticket_type']['type'] ==
                        'paid_seating') {
                  if (ticketListData[i]['availableTicketStatus'] == '1') {
                    if (ticketListData[i]['final_price'] == '0') {
                      itemColor = Color(0xFFFFAA00);
                      ticketPrice = 'Free Limited';
                    } else if (int.parse(ticketListData[i]['final_price']) >
                        0) {
                      itemColor = Color(0xFF34B323);
                      ticketPrice = 'Rp. ' + ticketListData[i]['final_price'];
                    }
                  }

                  if (ticketListData[i]['is_single_ticket'] == '1' &&
                      ticketListData[i]['user_have_ticket'] == '1') {
                    itemColor = Color(0xff36b323).withOpacity(.2);
                    ticketPrice = 'Rp. ' + ticketListData[i]['final_price'];
                  }

                  if (ticketListData[i]['availableTicketStatus'] == '0' &&
                      int.parse(ticketListData[i]['final_price']) > 0) {
                    itemColor = Color(0xFF34B323).withOpacity(.2);
                    ticketPrice = 'Rp. ' + ticketListData[i]['final_price'];
                  }
                } else if (ticketListData[i]['event']['ticket_type']['type'] ==
                    'free_live_stream') {
                  itemColor = Color(0xFFFFAA00);
                  ticketPrice = "FREE";
                } else if (ticketListData[i]['event']['ticket_type']['type'] ==
                    'paid_live_stream') {
                  itemColor = Color(0xFF34B323);
                  ticketPrice = 'Rp. ' + ticketListData[i]['final_price'];
                } else if (ticketListData[i]['event']['ticket_type']['type'] ==
                        'free_limited' ||
                    ticketListData[i]['event']['ticket_type']['type'] ==
                        'free_limited_seating') {
                  if (ticketListData[i]['is_single_ticket'] == '1' &&
                      ticketListData[i]['user_have_ticket'] == '1') {
                    if (int.parse(ticketListData[i]['final_price']) > 0) {
                      itemColor = Color(0xff36b323).withOpacity(.2);
                      ticketPrice = 'Rp. ' + ticketListData[i]['final_price'];
                    }
                    itemColor = Color(0xff36b323).withOpacity(.2);
                    ticketPrice = 'Free Limited';
                  } else {
                    if (int.parse(ticketListData[i]['final_price']) > 0) {
                      itemColor = Color(0xFF34B323);
                      ticketPrice = 'Rp. ' + ticketListData[i]['final_price'];
                    } else {
                      itemColor = Color(0xFFFFAA00);
                      ticketPrice = 'Free Limited';
                    }
                  }
                }

                return GestureDetector(
                  onTap: () {
                    savePreferences(
                        ticketListData[i]['min_ticket'],
                        ticketListData[i]['max_ticket'],
                        ticketListData[i]['final_price']);
                    if (ticketListData[i]['is_single_ticket'] == '1' &&
                            ticketListData[i]['user_have_ticket'] == '1' ||
                        ticketListData[i]['availableTicketStatus'] == '0') {
                      //do nothing
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SelectedTicketQuantityWidget(
                            eventName: ticketListData[i]['event']['name'],
                            eventAddress: ticketListData[i]['event']['address'],
                            eventDate: ticketListData[i]['event']['dateStart'],
                            ticketName: ticketListData[i]['ticket_name'],
                            eventImage: ticketListData[i]
                                        .containsKey('ticket_image')
                                        .toString() ==
                                    'false'
                                ? 'assets/grey-fade.jpg'
                                : ticketListData[i]['ticket_image']
                                    ['secure_url'],
                            isSingleTicket:
                                ticketListData[i]['is_single_ticket'] == '1'
                                    ? true
                                    : false,
                            minTicket: ticketListData[i]['min_ticket'],
                            ticketDetail: ticketListData[i]['descriptions'],
                            ticketPrice: ticketListData[i]['final_price'],
                            ticketID: ticketListData[i]['id'],
                            ticketType: ticketListData[i]['paid_ticket_type']
                                ['type'],
                            eventStartTime: ticketListData[i]['event']
                                ['timeStart'],
                            eventEndTime: ticketListData[i]['event']['timeEnd'],
                          ),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: <Widget>[
                      Container(
                          height: ScreenUtil.instance.setWidth(170),
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 14, right: 14, top: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 2,
                                    spreadRadius: 5,
                                    color: Color(0xff8a8a8b).withOpacity(0.2))
                              ],
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: ScreenUtil.instance.setWidth(150),
                                  width: ScreenUtil.instance.setWidth(100),
                                  decoration: BoxDecoration(
                                    
                                      image: DecorationImage(
                                          image: ticketListData[i]
                                                      .containsKey(
                                                          'ticket_image')
                                                      .toString() ==
                                                  'false'
                                              ? AssetImage(
                                                  'assets/grey-fade.jpg')
                                              : NetworkImage(
                                                  ticketListData[i]
                                                          ['ticket_image']
                                                      ['secure_url'],
                                                ),
                                          fit: BoxFit.fill), borderRadius: BorderRadius.circular(10),),
                                ),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(15),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        ticketListData[i]['ticket_name'],
                                        style: TextStyle(
                                            fontSize:
                                                ScreenUtil.instance.setSp(20),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.brightness_1,
                                            size: 14,
                                            color: ticketListData[i][
                                                        'availableTicketStatus'] ==
                                                    '1'
                                                ? Colors.green
                                                : Colors.yellow,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(ticketStatus,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.instance.setWidth(9),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                180,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 20,
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.instance.setWidth(9),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        height: ScreenUtil.instance.setWidth(32 * 1.1),
                        width: ScreenUtil.instance.setWidth(110 * 1.1),
                                        decoration: BoxDecoration(
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: itemColor
                                                      .withOpacity(0.4),
                                                  blurRadius: 2,
                                                  spreadRadius: 1.5)
                                            ],
                                            color: itemColor,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: Center(
                                            child: Text(
                                          ticketPrice,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  ScreenUtil.instance.setSp(16),
                                              fontWeight: FontWeight.bold),
                                        )),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.instance.setWidth(6),
                                      ),
                                      ticketListData[i]
                                                  ['show_remaining_ticket'] ==
                                              '0'
                                          ? Container()
                                          : Flexible(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    180,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Center(
                                                      child: Text(
                                                          'Ticket(s) left: ${(int.parse(ticketListData[i]['quantity']) - int.parse(ticketListData[i]['sold']))} / ${ticketListData[i]['quantity']}',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  ScreenUtil
                                                                      .instance
                                                                      .setSp(
                                                                          15),
                                                              color:
                                                                  Colors.grey),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      Text(ticketListData[i]
                                                  ['is_single_ticket'] ==
                                              '0'
                                          ? ''
                                          : 'Limited to one purchase only', style: TextStyle(color: Colors.grey),)
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )),
                      ticketListData[i]['is_single_ticket'] == '1' &&
                              ticketListData[i]['user_have_ticket'] == '1'
                          ? Container(
                              height: ScreenUtil.instance.setWidth(170),
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  EdgeInsets.only(left: 20, right: 5, top: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'You Cannot Buy This Ticket Again',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future savePreferences(
      String minTicket, String maxTicket, String ticketPrice) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString('Min_Ticket', minTicket);
    preferences.setString('Max_Ticket', maxTicket);
    preferences.setString('Ticket_Price', ticketPrice);

    print('min ticket' + preferences.getString('Min_Ticket'));
    print('max ticket' + preferences.getString('Max_Ticket'));
    print('ticket price' + preferences.getString('Ticket_Price'));
  }

  Future getTicketList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var session;
    setState(() {
      session = preferences.getString('Session');
    });

    String ticketListURI = BaseApi().apiUrl +
        '/ticket_setup/list?X-API-KEY=${API_KEY}&eventID=${widget.eventID}';
    print(ticketListURI);

    final response = await http.get(ticketListURI, headers: {
      'Authorization': 'Basic YWRtaW46MTIzNA==',
      'cookie': session
    });

    print(response.statusCode);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        ticketListData = extractedData['data'];
        ticketListData.removeWhere((item) =>
            item['event']['ticket_type']['type'] == 'free_limited_seating' ||
            item['event']['ticket_type']['type'] == 'paid_seating' ||
            item['event']['ticket_type']['type'] == 'paid_seating');

        for (var ticketData in ticketListData) {
          print(ticketData);
          startTime = DateTime.parse(ticketData['sales_start_date']);
          endTime = DateTime.parse(ticketData['sales_end_date']);
        }

        print(ticketListData.toString());
      });
    }
  }
}
