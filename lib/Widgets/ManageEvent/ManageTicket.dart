import 'dart:convert';

import 'package:eventevent/Providers/ThemeProvider.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/ManageEvent/AddNewTicket.dart';
import 'package:eventevent/Widgets/ManageEvent/EditTicketDetail.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ManageTicket extends StatefulWidget {
  final String eventID;
  final isLivestream;

  const ManageTicket({Key key, this.eventID, @required this.isLivestream})
      : super(key: key);

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
                Icon(Icons.arrow_back_ios, color: checkForAppBarTitleColor(context), size: 15)),
        centerTitle: true,
        title:
            Text('MANAGE TICKETS', style: TextStyle(color: checkForAppBarTitleColor(context))),
      ),
      body: ticketList == null
          ? HomeLoadingScreen().myTicketLoading()
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  Container(
                    child: ColumnBuilder(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      itemCount: ticketList == null ? 0 : ticketList.length,
                      itemBuilder: (BuildContext context, i) {
                        Color itemColor;
                        String itemPriceText;
                        ticketList.removeWhere((item) =>
                            item['event']['ticket_type']['type'] ==
                            'free_limited_seating');
                        if (ticketList[i]['paid_ticket_type']['type'] ==
                                'paid' ||
                            ticketList[i]['paid_ticket_type']['type'] ==
                                'paid_seating') {
                          itemColor = Color(0xFF34B323);
                          itemPriceText = 'Rp' +
                              formatPrice(
                                price: ticketList[i]['final_price'].toString(),
                              );
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
                        } else if (ticketList[i]['event']['ticket_type']
                                ['type'] ==
                            'paid_live_stream') {
                          itemColor = itemColor = Color(0xFF34B323);
                          itemPriceText = 'Rp' +
                              formatPrice(
                                price: ticketList[i]['final_price'].toString(),
                              );
                        } else if (ticketList[i]['event']['ticket_type']
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
                                                  .containsKey("ticket_image")
                                              ? ticketList[i]['ticket_image']
                                                  ['secure_url']
                                              : ticketList[i]['event']
                                                  ['pictureAvatarPath'],
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
                            height: ScreenUtil.instance.setWidth(170),
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(
                                left: 14, right: 14, bottom: 10),
                            decoration: BoxDecoration(
                                color: checkForContainerBackgroundColor(context),
                                boxShadow: Provider.of<ThemeProvider>
                                  (context).isDarkMode ? null : [
                                  BoxShadow(
                                      blurRadius: 2,
                                      spreadRadius: 5,
                                      color: Color(0xff8a8a8b).withOpacity(0.2))
                                ],
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: EdgeInsets.only(left: 11),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: ScreenUtil.instance.setWidth(150),
                                    width: ScreenUtil.instance.setWidth(100),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        ticketList[i]
                                                .containsKey("ticket_image")
                                            ? ticketList[i]['ticket_image']
                                                ['secure_url']
                                            : ticketList[i]['event']
                                                ['pictureAvatarPath'],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ScreenUtil.instance.setWidth(9)),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: 200,
                                        child: Text(
                                          ticketList[i]['ticket_name'],
                                          style: TextStyle(
                                              fontSize:
                                                  ScreenUtil.instance.setSp(20),
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        height: ScreenUtil.instance
                                            .setWidth(32 * 1.1),
                                        width: ScreenUtil.instance
                                            .setWidth(110 * 1.1),
                                        decoration: BoxDecoration(
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color:
                                                    itemColor.withOpacity(0.4),
                                                blurRadius: 2,
                                                spreadRadius: 1.5)
                                          ],
                                          color: itemColor,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: ticketList[i][
                                                        'paid_ticket_type_id'] ==
                                                    '2' ||
                                                ticketList[i][
                                                        'paid_ticket_type_id'] ==
                                                    '7'
                                            ? Container()
                                            : Center(
                                                child: Text(
                                                itemPriceText,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.instance.setWidth(3),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 12),
                                        child: Text(
                                            'Ticket(s) left: ${(int.parse(ticketList[i]['quantity']) - int.parse(ticketList[i]['sold']))} / ${ticketList[i]['quantity']}',
                                            style: TextStyle(
                                                fontSize: ScreenUtil.instance
                                                    .setSp(12),
                                                color: Colors.grey),
                                            textAlign: TextAlign.center),
                                      )
                                    ],
                                  ),

                                  // SizedBox(
                                  //     width: ScreenUtil.instance.setWidth(20)),
                                  Expanded(child: Container()),
                                  Icon(
                                    Icons.navigate_next,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      prefs.setInt('NEW_EVENT_ID', int.parse(widget.eventID));
                      print(prefs.getInt('NEW_EVENT_ID'));
                      prefs.setString('Previous Widget', 'AddNewTicket');
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => AddNewTicket(
                                isLivestream: widget.isLivestream,
                              )));
                    },
                    child: Container(
                      color: checkForContainerBackgroundColor(context),
                      height: ScreenUtil.instance.setWidth(150),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/drawable/add.png', scale: 2),
                          // Icon(
                          //   Icons.add_circle_outline,
                          //   size: 80,
                          //   color: Colors.grey[300],
                          // ),
                          SizedBox(height: 10),
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
      'Authorization': AUTH_KEY,
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
      'Authorization': AUTH_KEY,
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
