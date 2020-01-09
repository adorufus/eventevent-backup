import 'dart:convert';

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
      backgroundColor: Colors.white.withOpacity(0.90),
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
      body: ListView.builder(
        itemCount: ticketListData == null ? 0 : ticketListData.length,
        itemBuilder: (BuildContext context, i) {
          if (ticketListData[i]['event']['ticket_type']['type'] == 'paid' ||
              ticketListData[i]['event']['ticket_type']['type'] ==
                  'paid_seating') {
            if (ticketListData[i]['availableTicketStatus'] == '1') {
              if (ticketListData[i]['final_price'] == '0') {
                itemColor = Color(0xFFFFAA00);
                ticketPrice = 'Free Limited';
              } else if (int.parse(ticketListData[i]['final_price']) > 0) {
                itemColor = Color(0xFF34B323);
                ticketPrice = ticketListData[i]['final_price'];
              }
            }

            if (ticketListData[i]['availableTicketStatus'] == '0' &&
                int.parse(ticketListData[i]['final_price']) > 0) {
              itemColor = Color(0xFF34B323).withOpacity(.2);
              ticketPrice = ticketListData[i]['final_price'];
            }
          } else if (ticketListData[i]['event']['ticket_type']['type'] ==
                  'free_limited' ||
              ticketListData[i]['event']['ticket_type']['type'] ==
                  'free_limited_seating') {
            itemColor = Color(0xFFFFAA00);
            ticketPrice = 'Free Limited';
          }

          return GestureDetector(
            onTap: () {
              savePreferences(
                  ticketListData[i]['min_ticket'],
                  ticketListData[i]['max_ticket'],
                  ticketListData[i]['final_price']);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SelectedTicketQuantityWidget(
                        eventName: ticketListData[i]['event']['name'],
                        eventAddress: ticketListData[i]['event']['address'],
                        eventDate: ticketListData[i]['event']['dateStart'],
                        ticketName: ticketListData[i]['ticket_name'],
                        eventImage: ticketListData[i]['ticket_image']
                            ['secure_url'],
                        ticketDetail: ticketListData[i]['descriptions'],
                        ticketPrice: ticketListData[i]['final_price'],
                        ticketID: ticketListData[i]['id'],
                        ticketType: ticketListData[i]['paid_ticket_type']
                            ['type'],
                        eventStartTime: ticketListData[i]['event']['timeStart'],
                        eventEndTime: ticketListData[i]['event']['timeEnd'],
                      )));
            },
            child: Container(
                height: ScreenUtil.instance.setWidth(170),
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 20, right: 5, top: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: ScreenUtil.instance.setWidth(150),
                        width: ScreenUtil.instance.setWidth(100),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: ticketListData[i]['ticket_image']
                                            ['secure_url'] ==
                                        null
                                    ? AssetImage('assets/grey-fade.jpg')
                                    : NetworkImage(ticketListData[i]
                                        ['ticket_image']['secure_url']))),
                      ),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(15),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              ticketListData[i]['ticket_name'],
                              style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(15),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                                ticketListData[i]['availableTicketStatus'] ==
                                        '0'
                                    ? 'Sold Out'
                                    : 'Available',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(25),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 180,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            Container(
                              height: ScreenUtil.instance.setWidth(28),
                              width: ScreenUtil.instance.setWidth(133),
                              decoration: BoxDecoration(
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: itemColor.withOpacity(0.4),
                                        blurRadius: 2,
                                        spreadRadius: 1.5)
                                  ],
                                  color: itemColor,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Center(
                                  child: Text(
                                ticketPrice,
                                // type == 'paid' ||
                                //         type == 'paid_seating'
                                //     ? isAvailable == '1'
                                //         ? 'Rp. ' +
                                //             itemPrice.toUpperCase() +
                                //             ',-'
                                //         : itemPrice.toUpperCase()
                                //     : itemPrice.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.instance.setSp(10),
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                            Text(ticketListData[i]['is_single_ticket'] == '0'
                                ? ''
                                : 'Limited to one purchase only')
                          ],
                        ),
                      )
                    ],
                  ),
                )),
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

        for (var ticketData in ticketListData) {
          print(ticketData);
        }

        print(ticketListData.toString());
      });
    }
  }
}
