import 'dart:convert';

import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LatestEventWidget extends StatefulWidget {
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
    await Future.delayed(Duration(milliseconds: 2000));
    setState((){
      newPage += 1;
    });

    fetchLatestEvent(newPage: newPage).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          List updatedData = extractedData['data'];
          if(updatedData == null){
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          latestEventData.addAll(updatedData);
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
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
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
              ? Center(
                  child: Container(
                    width: ScreenUtil.instance.setWidth(25),
                    height: ScreenUtil.instance.setWidth(25),
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("Load data");
                    } else if (mode == LoadStatus.loading) {
                      body = CircularProgressIndicator();
                    } else if (mode == LoadStatus.failed) {
                      body = Text("Load Failed!");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text('More');
                    } else {
                      body = Container();
                    }

                    return Container(height: ScreenUtil.instance.setWidth(35), child: Center(child: body));
                  }),
                  controller: refreshController,
                  onRefresh: () {
                    setState((){
                      newPage = 0;
                    });
                    fetchLatestEvent(newPage: newPage).then((response) {
                      if (response.statusCode == 200) {
                        setState(() {
                          var extractedData = json.decode(response.body);
                          latestEventData = extractedData['data'];
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

                      if (latestEventData[i]['ticket_type']['type'] == 'paid' ||
                          latestEventData[i]['ticket_type']['type'] ==
                              'paid_seating') {
                        if (latestEventData[i]['ticket']
                                ['availableTicketStatus'] ==
                            '1') {
                          itemColor = Color(0xFF34B323);
                          itemPriceText =
                              latestEventData[i]['ticket']['cheapestTicket'];
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
                        itemPriceText = latestEventData[i]['ticket_type']['name'];
                      } else if (latestEventData[i]['ticket_type']['type'] ==
                          'free') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText = latestEventData[i]['ticket_type']['name'];
                      } else if (latestEventData[i]['ticket_type']['type'] ==
                          'free') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText = latestEventData[i]['ticket_type']['name'];
                      } else if (latestEventData[i]['ticket_type']['type'] ==
                          'free_limited') {
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EventDetailsConstructView(
                                          id: latestEventData[i]['id'])));
                        },
                        child: new LatestEventItem(
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

    setState(() {
      session = preferences.getString('Session');
      if(newPage != null){
        currentPage += newPage;
      }
      print(currentPage);
    });

    final latestEventApi = BaseApi().apiUrl +
        '/event/category?category=0&page=$currentPage&X-API-KEY=$API_KEY';

    print(latestEventApi);

    final response = await http.get(latestEventApi, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': session
    });

    print(response.body);

    return response;
  }
}
