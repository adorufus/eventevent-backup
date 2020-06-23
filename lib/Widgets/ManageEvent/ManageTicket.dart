import 'dart:convert';

import 'package:eventevent/Widgets/ManageEvent/AddNewTicket.dart';
import 'package:eventevent/Widgets/ManageEvent/EditTicketDetail.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:flutter/cupertino.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ManageTicket extends StatefulWidget {
  final String eventID;
  final isLivestream;

  const ManageTicket({Key key, this.eventID, @required this.isLivestream}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ManageTicketState();
  }
}

class ManageTicketState extends State<ManageTicket> {
  String ticketID;
  List ticketList;
  Map ticketDetails;
  List imageUri;

  @override
  void initState() {
    super.initState();
    getTicketList();
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
      appBar: AppBar(
        brightness: Brightness.light,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child:
                Icon(Icons.arrow_back_ios, color: eventajaGreenTeal, size: 15)),
        backgroundColor: Colors.white,
        centerTitle: true,
        title:
            Text('MANAGE TICKETS', style: TextStyle(color: eventajaGreenTeal)),
      ),
      body: ticketList == null
          ? Container(
              child: Center(
                child: CupertinoActivityIndicator(radius: 20),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  ColumnBuilder(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    itemCount: ticketList == null ? 0 : ticketList.length,
                    itemBuilder: (BuildContext context, i) {
                      Color itemColor;
                      String itemPriceText;
                      ticketList.removeWhere((item) =>
                          item['event']['ticket_type']['type'] ==
                          'free_limited_seating');
                      if (ticketList[i]['event']['ticket_type']['type'] ==
                              'paid' ||
                          ticketList[i]['event']['ticket_type']['type'] ==
                              'paid_seating') {
                        itemColor = Color(0xFF34B323);
                        itemPriceText =
                            'Rp. ' + ticketList[i]['final_price'] + ',-';
                      } else if (ticketList[i]['event']['ticket_type']
                              ['type'] ==
                          'no_ticket') {
                        itemColor = Color(0xFF652D90);
                        itemPriceText = 'NO TICKET';
                      } else if (ticketList[i]['event']['ticket_type']
                              ['type'] ==
                          'on_the_spot') {
                        itemColor = Color(0xFF652D90);
                        itemPriceText =
                            ticketList[i]['event']['ticket_type']['name'];
                      } else if (ticketList[i]['event']['ticket_type']
                              ['type'] ==
                          'free') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            ticketList[i]['event']['ticket_type']['name'];
                      } else if (ticketList[i]['event']['ticket_type']
                              ['type'] ==
                          'free') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            ticketList[i]['event']['ticket_type']['name'];
                      } else if (ticketList[i]['paid_ticket_type']
                              ['type'] ==
                          'paid_live_stream') {
                        itemColor = eventajaGreenTeal;
                        itemPriceText = 'Rp. ' + ticketList[i]['final_price'];
                      } else if (ticketList[i]['paid_ticket_type']
                              ['type'] ==
                          'free_live_stream') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            ticketList[i]['event']['ticket_type']['name'];
                      } else if (ticketList[i]['event']['ticket_type']
                                  ['type'] ==
                              'free_limited' ||
                          ticketList[i]['event']['ticket_type']['type'] ==
                              'free_limited_seating') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            ticketList[i]['event']['ticket_type']['name'];
                      }

                      print(ticketID);
                      return GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('Previous Widget', 'AddNewTicket');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditTicketDetail(
                                        ticketTitle: ticketList[i]
                                            ['ticket_name'],
                                        ticketImage: ticketList[i]
                                            ['ticket_image']['secure_url'],
                                        ticketQuantity: ticketList[i]
                                            ['quantity'],
                                        ticketDescription: ticketList[i]
                                            ['descriptions'],
                                        ticketSalesStartDate: ticketList[i]
                                            ['sales_start_date'],
                                        ticketSalesEndDate: ticketList[i]
                                            ['sales_end_date'],
                                        eventStartDate: ticketList[i]['event']
                                            ['dateStart'],
                                        eventEndDate: ticketList[i]['event']
                                            ['dateEnd'],
                                        eventStartTime: ticketList[i]['event']
                                            ['timeStart'],
                                        eventEndTime: ticketList[i]['event']
                                            ['timeEnd'],
                                        ticketDetail: ticketList[i],
                                      )));
                        },
                        child: Container(
                          height: ScreenUtil.instance.setWidth(200),
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(150),
                                width: ScreenUtil.instance.setWidth(100),
                                child: Image.network(
                                  ticketList[i]['ticket_image']['secure_url'],
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(width: ScreenUtil.instance.setWidth(20)),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    ticketList[i]['ticket_name'],
                                    style: TextStyle(
                                        fontSize: ScreenUtil.instance.setSp(18),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Available',
                                          style: TextStyle(
                                              color: Colors.grey[300],
                                              fontSize: ScreenUtil.instance
                                                  .setSp(18)),
                                        )
                                      ]),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 5),
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
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ticketList[i]
                                                    ['paid_ticket_type_id'] ==
                                                '2' ||
                                            ticketList[i]
                                                    ['paid_ticket_type_id'] ==
                                                '7'
                                        ? Container()
                                        : Center(
                                            child: Text(
                                            itemPriceText,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )),
                                  ),
                                  Text(
                                      'Ticket(s) left: ${(int.parse(ticketList[i]['quantity']) - int.parse(ticketList[i]['sold']))} / ${ticketList[i]['quantity']}')
                                ],
                              ),
                              SizedBox(width: ScreenUtil.instance.setWidth(20)),
                              Icon(
                                Icons.navigate_next,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      prefs.setInt('NEW_EVENT_ID', int.parse(widget.eventID));
                      print(prefs.getInt('NEW_EVENT_ID'));
                      prefs.setString('Previous Widget', 'AddNewTicket');
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => AddNewTicket(isLivestream: widget.isLivestream,)));
                    },
                    child: Container(
                      color: Colors.white,
                      height: ScreenUtil.instance.setWidth(150),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add_circle_outline,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          Text(
                            'Add Ticket',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(18),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[300]),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future getTicketList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/ticket_setup/list?X-API-KEY=$API_KEY&eventID=${widget.eventID}';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        ticketList = extractedData['data'];

        for (int i = 0; i < ticketList.length; i++) {
          print(ticketList[i]['id']);
          getTicketData(ticketList[i]['id']);
        }
      });
    }
  }

  Future getTicketData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url =
        BaseApi().apiUrl + '/ticket_setup/tickets?X-API-KEY=$API_KEY&id=$id';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        prefs.setInt('NEW_EVENT_ID', int.parse(widget.eventID));
        var extractedData = json.decode(response.body);
        ticketDetails = extractedData['data'];
        print(extractedData);
      });
    }
  }
}
