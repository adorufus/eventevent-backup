import 'dart:convert';

import 'package:eventevent/Widgets/Transaction/SelectedTicketQuantity.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                height: 170,
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
                        height: 150,
                        width: 100,
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
                        width: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              ticketListData[i]['ticket_name'],
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                                ticketListData[i]['availableTicketStatus'] ==
                                        '0'
                                    ? 'loading'
                                    : 'Available',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 25,
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
                              height: 20,
                            ),
                            Container(
                                height: 40,
                                width: 130,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: AssetImage(ticketButtonImageURI),
                                  fit: BoxFit.fill,
                                )),
                                child: Center(
                                    child: Text(
                                  ticketListData[i]['final_price'] == null
                                      ? '-'
                                      : 'Rp. ' +
                                          ticketListData[i]['final_price'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ))),
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

        print(ticketListData.toString());
      });
    }
  }
}
