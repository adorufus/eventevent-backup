import 'dart:convert';

import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CategoryPage extends StatefulWidget {
  final categoryId;

  const CategoryPage({Key key, this.categoryId}) : super(key: key);
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController refreshController =
      new RefreshController(initialRefresh: false);
  int newPage = 0;
  List eventByCategoryList;

  @override
  void initState() {
    fetchCategoryById().then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          eventByCategoryList = extractedData['data'];
        });
        if (mounted) setState(() {});
        refreshController.refreshCompleted();
      }
    }).catchError((e) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: e.toString(),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    });
    super.initState();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    fetchCategoryById(page: newPage).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          List updatedData = extractedData['data'];
          print('data: ' + updatedData.toString());
          eventByCategoryList.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
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
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(50),
          padding: EdgeInsets.symmetric(horizontal: 13),
          color: Colors.white,
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/icons/icon_apps/arrow.png',
                scale: 5.5,
                alignment: Alignment.centerLeft,
              ),
            ),
            title: Text('Category'),
            centerTitle: true,
            textTheme: TextTheme(
                title: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil.instance.setSp(14),
              color: Colors.black,
            )),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: eventByCategoryList == null
              ? Center(
                  child: Container(
                    width: ScreenUtil.instance.setWidth(25),
                    height: ScreenUtil.instance.setWidth(25),
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: CupertinoActivityIndicator(radius: 20),
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
                  onRefresh: () {
                    setState(() {
                      newPage = 0;
                    });

                    fetchCategoryById().then((response) {
                      if (response.statusCode == 200) {
                        setState(() {
                          var extractedData = json.decode(response.body);
                          eventByCategoryList = extractedData['data'];
                        });
                        if (mounted) setState(() {});
                        refreshController.refreshCompleted();
                      }
                    });

                    if (mounted) setState(() {});
                    refreshController.refreshCompleted();
                  },
                  onLoading: _onLoading,
                  controller: refreshController,
                  child: ListView.builder(
                    itemCount: eventByCategoryList == null
                        ? 0
                        : eventByCategoryList.length,
                    itemBuilder: (BuildContext context, i) {
                      Color itemColor;
                      String itemPriceText;

                      if (eventByCategoryList[i]['ticket_type']['type'] ==
                              'paid' ||
                          eventByCategoryList[i]['ticket_type']['type'] ==
                              'paid_seating') {
                        if (eventByCategoryList[i]['ticket']
                                ['availableTicketStatus'] ==
                            '1') {
                          itemColor = Color(0xFF34B323);
                          itemPriceText = eventByCategoryList[i]['ticket']
                              ['cheapestTicket'];
                        } else {
                          if (eventByCategoryList[i]['ticket']['salesStatus'] ==
                              'comingSoon') {
                            itemColor = Color(0xFF34B323).withOpacity(0.3);
                            itemPriceText = 'COMING SOON';
                          } else if (eventByCategoryList[i]['ticket']
                                  ['salesStatus'] ==
                              'endSales') {
                            itemColor = Color(0xFF8E1E2D);
                            if (eventByCategoryList[i]['status'] == 'ended') {
                              itemPriceText = 'EVENT HAS ENDED';
                            }
                            itemPriceText = 'SALES ENDED';
                          } else {
                            itemColor = Color(0xFF8E1E2D);
                            itemPriceText = 'SOLD OUT';
                          }
                        }
                      } else if (eventByCategoryList[i]['ticket_type']
                              ['type'] ==
                          'no_ticket') {
                        itemColor = Color(0xFF652D90);
                        itemPriceText = 'NO TICKET';
                      } else if (eventByCategoryList[i]['ticket_type']
                              ['type'] ==
                          'on_the_spot') {
                        itemColor = Color(0xFF652D90);
                        itemPriceText =
                            eventByCategoryList[i]['ticket_type']['name'];
                      } else if (eventByCategoryList[i]['ticket_type']
                              ['type'] ==
                          'free') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            eventByCategoryList[i]['ticket_type']['name'];
                      } else if (eventByCategoryList[i]['ticket_type']
                              ['type'] ==
                          'free') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            eventByCategoryList[i]['ticket_type']['name'];
                      } else if (eventByCategoryList[i]['ticket_type']
                              ['type'] ==
                          'free_live_stream') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            eventByCategoryList[i]['ticket_type']['name'];
                      } else if (eventByCategoryList[i]['ticket_type']
                              ['type'] ==
                          'free_limited') {
                        if (eventByCategoryList[i]['ticket']
                                ['availableTicketStatus'] ==
                            '1') {
                          itemColor = Color(0xFFFFAA00);
                          itemPriceText =
                              eventByCategoryList[i]['ticket_type']['name'];
                        } else if (eventByCategoryList[i]['ticket']
                                ['salesStatus'] ==
                            'endSales') {
                          itemColor = Color(0xFF8E1E2D);
                          if (eventByCategoryList[i]['status'] == 'ended') {
                            itemPriceText = 'EVENT HAS ENDED';
                          }
                          itemPriceText = 'SALES ENDED';
                        } else {
                          itemColor = Color(0xFF8E1E2D);
                          itemPriceText = 'SOLD OUT';
                        }
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EventDetailLoadingScreen(
                                          eventId: eventByCategoryList[i]
                                              ['id'])));
                        },
                        child: new LatestEventItem(
                          image: eventByCategoryList[i]['picture_timeline'],
                          title: eventByCategoryList[i]['name'],
                          location: eventByCategoryList[i]['address'],
                          itemColor: itemColor,
                          itemPrice: itemPriceText,
                          type: eventByCategoryList[i]['ticket_type']['type'],
                          isAvailable: eventByCategoryList[i]['ticket']
                              ['availableTicketStatus'],
                          date: DateTime.parse(
                              eventByCategoryList[i]['dateStart']),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Future<http.Response> fetchCategoryById({int page}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (page != null) {
        currentPage += page;
      }
    });

    final latestEventApi = BaseApi().apiUrl +
        '/event/category?X-API-KEY=$API_KEY&category=${widget.categoryId}&page=$currentPage';

    print(latestEventApi);

    final response = await http.get(latestEventApi, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': preferences.getString('Session')
    });

    print(response.body);

    return response;
  }
}
