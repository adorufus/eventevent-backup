import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeeAllItem extends StatefulWidget {
  final initialIndex;

  const SeeAllItem({Key key, this.initialIndex}) : super(key: key);

  @override
  _SeeAllItemState createState() => _SeeAllItemState();
}

class _SeeAllItemState extends State<SeeAllItem> {
  List popularEventList;
  List discoverEventList;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  int newPage = 0;

  void _onPopularLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    popularEventData(newPage: newPage).then((response) {
      var extractedData = json.decode(response.body);
      List updatedData = extractedData['data'];

      if (response.statusCode == 200) {
        setState(() {
          if (updatedData == null) {
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          popularEventList.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      } else if (extractedData['desc'] == 'Media Posts list is not found' ||
          updatedData == null) {
        refreshController.loadNoData();
      } else {
        refreshController.loadFailed();
      }
    });
  }

  void _onDiscoverLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    discoverEventData(newPage: newPage).then((response) {
      var extractedData = json.decode(response.body);
      List updatedData = extractedData['data'];

      if (response.statusCode == 200) {
        setState(() {
          if (updatedData == null) {
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          discoverEventList.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      } else if (extractedData['desc'] == 'Media Posts list is not found' ||
          updatedData == null) {
        refreshController.loadNoData();
      } else {
        refreshController.loadFailed();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    popularEventData().then((response) {
      print(response.statusCode);
      print(response.body);

      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          popularEventList = extractedData['data'];
        });
      }
    });

    discoverEventData().then((response) {
      print(response.statusCode);
      print(response.body);

      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          discoverEventList = extractedData['data'];
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(75),
          child: Container(
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.fromLTRB(13, 15, 13, 0),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(15.49),
                          width: ScreenUtil.instance.setWidth(9.73),
                          child: Image.asset(
                            'assets/icons/icon_apps/arrow.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 2.8),
                  Text(
                    'All Event',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(14)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: widget.initialIndex,
          length: 2,
          child: ListView(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: TabBar(
                  tabs: <Widget>[
                    Tab(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/icons/icon_apps/popular.png',
                            scale: 4.5,
                          ),
                          SizedBox(width: ScreenUtil.instance.setWidth(8)),
                          Text('Popular',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(12.5))),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/icons/icon_apps/discover.png',
                            scale: 4.5,
                          ),
                          SizedBox(width: ScreenUtil.instance.setWidth(8)),
                          Text('Discover',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(12.5))),
                        ],
                      ),
                    )
                  ],
                  unselectedLabelColor: Colors.grey,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 141,
                child: TabBarView(
                  children: <Widget>[popularEvent(), discoverEvent()],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget popularEvent() {
    return Container(
        child: popularEventList == null
            ? HomeLoadingScreen().myTicketLoading()
            : SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("Load data");
                  } else if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator(radius: 20);
                  } else if (mode == LoadStatus.failed) {
                    body = Text("Load Failed!");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text('More');
                  } else {
                    body = Container();
                  }

                  return Container(
                      height: ScreenUtil.instance.setWidth(35),
                      child: Center(child: body));
                }),
                controller: refreshController,
                onRefresh: () {
                  setState(() {
                    newPage = 0;
                  });
                  popularEventData(newPage: newPage).then((response) {
                    var extractedData = json.decode(response.body);

                    print(response.statusCode);
                    print(response.body);

                    if (response.statusCode == 200) {
                      setState(() {
                        popularEventList = extractedData['data'];
                      });
                      if (mounted) setState(() {});
                      refreshController.refreshCompleted();
                    } else {
                      if (mounted) setState(() {});
                      refreshController.refreshFailed();
                    }
                  });
                },
                onLoading: _onPopularLoading,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      popularEventList == null ? 0 : popularEventList.length,
                  itemBuilder: (BuildContext context, i) {
                    Color itemColor;
                    String itemPriceText;

                    if (popularEventList[i]['ticket_type']['type'] == 'paid' ||
                        popularEventList[i]['ticket_type']['type'] ==
                            'paid_seating') {
                      if (popularEventList[i]['ticket']
                              ['availableTicketStatus'] ==
                          '1') {
                        itemColor = Color(0xFF34B323);
                        itemPriceText = 'Rp. ' +
                            popularEventList[i]['ticket']['cheapestTicket'];
                      } else {
                        if (popularEventList[i]['ticket']['salesStatus'] ==
                            'comingSoon') {
                          itemColor = Color(0xFF34B323).withOpacity(0.3);
                          itemPriceText = 'COMING SOON';
                        } else if (popularEventList[i]['ticket']
                                ['salesStatus'] ==
                            'endSales') {
                          itemColor = Color(0xFF8E1E2D);
                          if (popularEventList[i]['status'] == 'ended') {
                            itemPriceText = 'EVENT HAS ENDED';
                          }
                          itemPriceText = 'SALES ENDED';
                        } else {
                          itemColor = Color(0xFF8E1E2D);
                          itemPriceText = 'SOLD OUT';
                        }
                      }
                    } else if (popularEventList[i]['ticket_type']['type'] ==
                        'no_ticket') {
                      itemColor = Color(0xFF652D90);
                      itemPriceText = 'NO TICKET';
                    } else if (popularEventList[i]['ticket_type']['type'] ==
                        'on_the_spot') {
                      itemColor = Color(0xFF652D90);
                      itemPriceText =
                          popularEventList[i]['ticket_type']['name'];
                    } else if (popularEventList[i]['ticket_type']['type'] ==
                        'free') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText =
                          popularEventList[i]['ticket_type']['name'];
                    } else if (popularEventList[i]['ticket_type']['type'] ==
                        'free') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText =
                          popularEventList[i]['ticket_type']['name'];
                    } else if (popularEventList[i]['ticket_type']['type'] ==
                        'free_live_stream') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText =
                          popularEventList[i]['ticket_type']['name'];
                    } else if (popularEventList[i]['ticket_type']['type'] ==
                        'free_limited') {
                      if (popularEventList[i]['ticket']
                              ['availableTicketStatus'] ==
                          '1') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            popularEventList[i]['ticket_type']['name'];
                      } else {
                        if (popularEventList[i]['ticket']['salesStatus'] ==
                            'comingSoon') {
                          itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                          itemPriceText = 'COMING SOON';
                        } else if (popularEventList[i]['ticket']
                                ['salesStatus'] ==
                            'endSales') {
                          itemColor = Color(0xFF8E1E2D);
                          if (popularEventList[i]['status'] == 'ended') {
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
                                    EventDetailLoadingScreen(
                                        eventId: popularEventList[i]['id'])));
                      },
                      child: new LatestEventItem(
                          image: popularEventList[i]['picture_timeline'],
                          title: popularEventList[i]['name'],
                          location: popularEventList[i]['address'],
                          itemColor: itemColor,
                          itemPrice: itemPriceText,
                          type: popularEventList[i]['ticket_type']['type'],
                          date:
                              DateTime.parse(popularEventList[i]['dateStart']),
                          isAvailable: popularEventList[i]['ticket']
                              ['availableTicketStatus']),
                    );
                  },
                )));
  }

  Widget discoverEvent() {
    return Container(
        child: discoverEventList == null
            ? HomeLoadingScreen().myTicketLoading()
            : SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("Load data");
                  } else if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator(radius: 20);
                  } else if (mode == LoadStatus.failed) {
                    body = Text("Load Failed!");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text('More');
                  } else {
                    body = Container();
                  }

                  return Container(
                      height: ScreenUtil.instance.setWidth(35),
                      child: Center(child: body));
                }),
                controller: refreshController,
                onRefresh: () {
                  setState(() {
                    newPage = 0;
                  });
                  discoverEventData(newPage: newPage).then((response) {
                    var extractedData = json.decode(response.body);

                    print(response.statusCode);
                    print(response.body);

                    if (response.statusCode == 200) {
                      setState(() {
                        discoverEventList = extractedData['data'];
                      });
                      if (mounted) setState(() {});
                      refreshController.refreshCompleted();
                    } else {
                      if (mounted) setState(() {});
                      refreshController.refreshFailed();
                    }
                  });
                },
                onLoading: _onDiscoverLoading,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      discoverEventList == null ? 0 : discoverEventList.length,
                  itemBuilder: (BuildContext context, i) {
                    Color itemColor;
                    String itemPriceText;

                    if (discoverEventList[i]['ticket_type']['type'] == 'paid' ||
                        discoverEventList[i]['ticket_type']['type'] ==
                            'paid_seating') {
                      if (discoverEventList[i]['ticket']
                              ['availableTicketStatus'] ==
                          '1') {
                        itemColor = Color(0xFF34B323);
                        itemPriceText = 'Rp. ' +
                            discoverEventList[i]['ticket']['cheapestTicket'];
                      } else {
                        if (discoverEventList[i]['ticket']['salesStatus'] ==
                            'comingSoon') {
                          itemColor = Color(0xFF34B323).withOpacity(0.3);
                          itemPriceText = 'COMING SOON';
                        } else if (discoverEventList[i]['ticket']
                                ['salesStatus'] ==
                            'endSales') {
                          itemColor = Color(0xFF8E1E2D);
                          if (discoverEventList[i]['status'] == 'ended') {
                            itemPriceText = 'EVENT HAS ENDED';
                          }
                          itemPriceText = 'SALES ENDED';
                        } else {
                          itemColor = Color(0xFF8E1E2D);
                          itemPriceText = 'SOLD OUT';
                        }
                      }
                    } else if (discoverEventList[i]['ticket_type']['type'] ==
                        'no_ticket') {
                      itemColor = Color(0xFF652D90);
                      itemPriceText = 'NO TICKET';
                    } else if (discoverEventList[i]['ticket_type']['type'] ==
                        'on_the_spot') {
                      itemColor = Color(0xFF652D90);
                      itemPriceText =
                          discoverEventList[i]['ticket_type']['name'];
                    } else if (discoverEventList[i]['ticket_type']['type'] ==
                        'free') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText =
                          discoverEventList[i]['ticket_type']['name'];
                    } else if (discoverEventList[i]['ticket_type']['type'] ==
                        'free') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText =
                          discoverEventList[i]['ticket_type']['name'];
                    } else if (discoverEventList[i]['ticket_type']['type'] ==
                        'free_live_stream') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText =
                          discoverEventList[i]['ticket_type']['name'];
                    } else if (discoverEventList[i]['ticket_type']['type'] ==
                        'free_limited') {
                      if (discoverEventList[i]['ticket']
                              ['availableTicketStatus'] ==
                          '1') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            discoverEventList[i]['ticket_type']['name'];
                      } else {
                        if (discoverEventList[i]['ticket']['salesStatus'] ==
                            'comingSoon') {
                          itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                          itemPriceText = 'COMING SOON';
                        } else if (discoverEventList[i]['ticket']
                                ['salesStatus'] ==
                            'endSales') {
                          itemColor = Color(0xFF8E1E2D);
                          if (discoverEventList[i]['status'] == 'ended') {
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
                                    EventDetailLoadingScreen(
                                        eventId: discoverEventList[i]['id'])));
                      },
                      child: new LatestEventItem(
                          image: discoverEventList[i]['picture_timeline'],
                          title: discoverEventList[i]['name'],
                          location: discoverEventList[i]['address'],
                          itemColor: itemColor,
                          itemPrice: itemPriceText,
                          type: discoverEventList[i]['ticket_type']['type'],
                          date:
                              DateTime.parse(discoverEventList[i]['dateStart']),
                          isAvailable: discoverEventList[i]['ticket']
                              ['availableTicketStatus']),
                    );
                  },
                )));
  }

  Future<http.Response> popularEventData({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (newPage != null) {
        currentPage += newPage;
      }

      print(currentPage);
    });

    final catalogApiUrl = BaseApi().apiUrl +
        '/event/popular?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b&page=$currentPage&total=20';
    final response = await http.get(catalogApiUrl, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': prefs.getString('Session')
    });

    return response;
  }

  Future<http.Response> discoverEventData({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (newPage != null) {
        currentPage += newPage;
      }
    });

    final catalogApiUrl = BaseApi().apiUrl +
        '/event/discover?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b&page=$currentPage&total=20';
    final response = await http.get(catalogApiUrl, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}
