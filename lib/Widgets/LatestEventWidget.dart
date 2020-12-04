import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ClevertapHandler.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LatestEventWidget extends StatefulWidget {
  final isRest;

  const LatestEventWidget({Key key, this.isRest}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _LatestEventWidget();
  }
}

class _LatestEventWidget extends State<LatestEventWidget> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  var session;
  List latestEventData;
  int newPage = 0;

  void _onLoading() async {
    //ClevertapHandler.logPageView("Latest");
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    fetchLatestEvent(newPage: newPage).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          List updatedData = extractedData['data'];
          if (updatedData == null) {
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          latestEventData.addAll(updatedData);
          latestEventData.removeWhere((item) =>
              item['ticket_type']['type'] == 'free_limited_seating' ||
              item['ticket_type']['type'] == 'paid_seating' ||
              item['ticket_type']['type'] == 'paid_seating');
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchLatestEvent().then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          latestEventData = extractedData['data'];
          latestEventData.removeWhere((item) =>
              item['ticket_type']['type'] == 'free_limited_seating' ||
              item['ticket_type']['type'] == 'paid_seating' ||
              item['ticket_type']['type'] == 'paid_seating');
        });
      }
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
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: latestEventData == null
              ? HomeLoadingScreen().myTicketLoading()
              : SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  
                  controller: refreshController,
                  onRefresh: () {
                    setState(() {
                      newPage = 0;
                    });
                    fetchLatestEvent(newPage: newPage).then((response) {
                      if (response.statusCode == 200) {
                        setState(() {
                          var extractedData = json.decode(response.body);
                          latestEventData = extractedData['data'];
                          latestEventData.removeWhere((item) =>
                              item['ticket_type']['type'] ==
                                  'free_limited_seating' ||
                              item['ticket_type']['type'] == 'paid_seating' ||
                              item['ticket_type']['type'] == 'paid_seating');
                        });
                        if (mounted) setState(() {});
                        refreshController.refreshCompleted();
                      }
                    });
                  },
                  onLoading: _onLoading,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount:
                        latestEventData == null ? 0 : latestEventData.length,
                    itemBuilder: (BuildContext context, i) {
                      Color itemColor;
                      String itemPriceText;
                      latestEventData.removeWhere(
                          (item) => item['type'] == 'free_limited_seating');
                      if (latestEventData[i]['isGoing'] == '1') {
                        itemColor = Colors.blue;
                        itemPriceText = 'Going!';
                      } else {
                        if (latestEventData[i]['ticket_type']['type'] ==
                                'paid' ||
                            latestEventData[i]['ticket_type']['type'] ==
                                'paid_seating') {
                          if (latestEventData[i]['ticket']
                                  ['availableTicketStatus'] ==
                              '1') {
                            itemColor = Color(0xFF34B323);
                            itemPriceText = 'Rp. ' +
                                latestEventData[i]['ticket']['cheapestTicket'] +
                                ',-';
                          } else {
                            if (latestEventData[i]['ticket']['salesStatus'] ==
                                'comingSoon') {
                              itemColor = Color(0xFF34B323).withOpacity(0.3);
                              itemPriceText = 'COMING SOON';
                            } else if (latestEventData[i]['ticket']
                                    ['salesStatus'] ==
                                'endSales') {
                              itemColor = Color(0xFF8E1E2D);
                              if (latestEventData[i]['status'] == 'ended') {
                                itemPriceText = 'EVENT HAS ENDED';
                              }
                              itemPriceText = 'SALES ENDED';
                            } else {
                              itemColor = Color(0xFF8E1E2D);
                              itemPriceText = 'SOLD OUT';
                            }
                          }
                        } else if (latestEventData[i]['ticket_type']['type'] ==
                            'no_ticket') {
                          itemColor = Color(0xFF652D90);
                          itemPriceText = 'NO TICKET';
                        } else if (latestEventData[i]['ticket_type']['type'] ==
                            'on_the_spot') {
                          itemColor = Color(0xFF652D90);
                          itemPriceText =
                              latestEventData[i]['ticket_type']['name'];
                        } else if (latestEventData[i]['ticket_type']['type'] ==
                            'free') {
                          itemColor = Color(0xFFFFAA00);
                          itemPriceText =
                              latestEventData[i]['ticket_type']['name'];
                        } else if (latestEventData[i]['ticket_type']['type'] ==
                            'free') {
                          itemColor = Color(0xFFFFAA00);
                          itemPriceText =
                              latestEventData[i]['ticket_type']['name'];
                        } else if (latestEventData[i]['ticket_type']['type'] ==
                            'paid_live_stream') {
                          itemColor = Color(0xFF34B323);
                          itemPriceText = 'Rp. ' +
                              latestEventData[i]['ticket']['cheapestTicket'];
                        } else if (latestEventData[i]['ticket_type']['type'] ==
                            'free_live_stream') {
                          itemColor = Color(0xFFFFAA00);
                          itemPriceText =
                              "FREE";
                        } else if (latestEventData[i]['ticket_type']['type'] ==
                                'free_limited' ||
                            latestEventData[i]['ticket_type']['type'] ==
                                'free_limited_seating') {
                          if (latestEventData[i]['ticket']
                                  ['availableTicketStatus'] ==
                              '1') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText =
                                latestEventData[i]['ticket_type']['name'];
                          } else {
                            if (latestEventData[i]['ticket']['salesStatus'] ==
                                'comingSoon') {
                              itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                              itemPriceText = 'COMING SOON';
                            } else if (latestEventData[i]['ticket']
                                    ['salesStatus'] ==
                                'endSales') {
                              itemColor = Color(0xFF8E1E2D);
                              if (latestEventData[i]['status'] == 'ended') {
                                itemPriceText = 'EVENT HAS ENDED';
                              }
                              itemPriceText = 'SALES ENDED';
                            } else {
                              itemColor = Color(0xFF8E1E2D);
                              itemPriceText = 'SOLD OUT';
                            }
                          }
                        }
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EventDetailLoadingScreen(
                                        isRest: widget.isRest,
                                          eventId: latestEventData[i]['id'])));
                        },
                        child: new LatestEventItem(
                          isHybridEvent: latestEventData[i]['isHybridEvent'],
                          image: latestEventData[i]['picture_timeline'],
                          title: latestEventData[i]['name'],
                          location: latestEventData[i]['address'],
                          itemColor: itemColor,
                          itemPrice: itemPriceText,
                          date: DateTime.parse(latestEventData[i]['dateStart']),
                          type: latestEventData[i]['ticket_type']['type'],
                          isAvailable: latestEventData[i]['ticket']
                              ['availableTicketStatus'],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Future<http.Response> fetchLatestEvent({int newPage}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int currentPage = 1;

    String baseUrl = '';
    Map<String, String> headers;

    if (widget.isRest) {
      baseUrl = BaseApi().restUrl;
      headers = {
        'Authorization': AUTHORIZATION_KEY,
        'signature': SIGNATURE,
      };
    } else {
      baseUrl = BaseApi().apiUrl;
      headers = {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session')
      };
    }

    setState(() {
      session = preferences.getString('Session');
      if (newPage != null) {
        currentPage += newPage;
      }
      print(currentPage);
    });

    final latestEventApi = baseUrl +
        '/event/category?category=0&page=$currentPage&X-API-KEY=$API_KEY';

    print(latestEventApi);

    final response = await http.get(latestEventApi, headers: headers);

    print(response.body);

    return response;
  }
}
