import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/RecycleableWidget/EmptyState.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/utils.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CollectionPage extends StatefulWidget {
  final categoryId;
  final String collectionName;
  final headerImage;
  final isRest;

  const CollectionPage(
      {Key key,
      this.categoryId,
      this.collectionName,
      this.headerImage,
      this.isRest})
      : super(key: key);
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List eventByCategoryList;
  List userByCollectionList;

  RefreshController refreshController =
      new RefreshController(initialRefresh: false);
  int newPage = 0;

  bool isLoading;
  Widget errReasonWidget = Container();

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

    fetchUserByCollectionId().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          userByCollectionList = extractedData['data'];
        });
      }
    });
    super.initState();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    fetchCategoryById(page: newPage).then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          eventByCategoryList.addAll(extractedData['data']);
        });
      } else {
        if (extractedData['desc'] == 'Event Not Found') {
          setState(() {
            isLoading = false;
            errReasonWidget = EmptyState(
              emptyImage: 'assets/drawable/event_empty_state.png',
              reasonText: 'No Event Found',
            );
          });
        }
      }
    });

    refreshController.loadComplete();
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
          child: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: ScreenUtil.instance.setWidth(50),
              padding: EdgeInsets.symmetric(horizontal: 13),
              color: Colors.white,
              child: AppBar(
                brightness: Brightness.light,
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
                title: Text('Events Happening in ' +
                    widget.collectionName[0].toUpperCase() +
                    widget.collectionName.substring(1)),
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
        ),
        body: SafeArea(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            // footer:
            //     CustomFooter(builder: (BuildContext context, LoadStatus mode) {
            //   Widget body;
            //   if (mode == LoadStatus.idle) {
            //     body = Container();
            //   } else if (mode == LoadStatus.loading) {
            //     body = CupertinoActivityIndicator(radius: 20);
            //   } else if (mode == LoadStatus.failed) {
            //     body = Text("Load Failed!");
            //   } else if (mode == LoadStatus.canLoading) {
            //     body = Text('More');
            //   } else {
            //     body = Container();
            //   }

            //   return Container(
            //       height: ScreenUtil.instance.setWidth(35),
            //       child: Center(child: body));
            // }),
            controller: refreshController,
            onRefresh: () {
              setState(() {
                newPage = 0;
              });
              fetchCategoryById().then((response) {
                if (response.statusCode == 200) {
                  setState(() {
                    var extractedData = json.decode(response.body);
                    eventByCategoryList = extractedData['data'];
                    isLoading = false;
                  });
                  if (mounted) setState(() {});
                  refreshController.refreshCompleted();
                }
              });
              refreshController.refreshCompleted();
            },
            onLoading: _onLoading,
            child: ListView(
              children: <Widget>[
                Container(
                  height: ScreenUtil.instance.setWidth(200),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Color(0xff8a8a8b),
                      image: DecorationImage(
                          image: NetworkImage(
                            widget.headerImage,
                          ),
                          fit: BoxFit.cover)),
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(horizontal: 25),
                        child: Text('Organizers in this collections'),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(10),
                      ),
                      Container(
                          height: ScreenUtil.instance.setWidth(50),
                          color: Colors.white,
                          child: userByCollectionList == null
                              ? HomeLoadingScreen().peopleLoading()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: userByCollectionList == null
                                      ? 0
                                      : userByCollectionList.length,
                                  itemBuilder: (context, i) {
                                    return Container(
                                      padding: i == 0
                                          ? EdgeInsets.only(
                                              left: 25,
                                              right:
                                                  i == userByCollectionList.last
                                                      ? 15
                                                      : 0)
                                          : EdgeInsets.only(
                                              left: i == 1 ? 15 : 0,
                                              right: 15,
                                            ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfileWidget(
                                                            initialIndex: 0,
                                                            userId:
                                                                userByCollectionList[
                                                                    i]['id'],
                                                          )));
                                            },
                                            child: Container(
                                              height: ScreenUtil.instance
                                                  .setWidth(40.50),
                                              width: ScreenUtil.instance
                                                  .setWidth(41.50),
                                              decoration: BoxDecoration(
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        offset:
                                                            Offset(1.0, 1.0),
                                                        blurRadius: 3)
                                                  ],
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            userByCollectionList[
                                                                i]["photo"]),
                                                    fit: BoxFit.fill,
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )),
                    ],
                  ),
                ),
                Container(
                  child: isLoading == true
                      ? HomeLoadingScreen().myTicketLoading()
                      : eventByCategoryList == null
                          ? errReasonWidget
                          : ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: eventByCategoryList == null
                                  ? 0
                                  : eventByCategoryList.length,
                              itemBuilder: (BuildContext context, i) {
                                Color itemColor;
                                String itemPriceText;

                                if (eventByCategoryList[i]['ticket_type']
                                            ['type'] ==
                                        'paid' || eventByCategoryList[i]['ticket_type']['type'] == "paid_live_stream" ||
                                    eventByCategoryList[i]['ticket_type']
                                            ['type'] ==
                                        'paid_seating') {
                                  if (eventByCategoryList[i]['ticket']
                                          ['availableTicketStatus'] ==
                                      '1') {
                                    itemColor = Color(0xFF34B323);
                                    itemPriceText = 'Rp. ' +
                                        formatPrice(
                                          price: eventByCategoryList[i]
                                                  ['ticket']['cheapestTicket']
                                              .toString(),
                                        ) +
                                        ',-';
                                  } else {
                                    if (eventByCategoryList[i]['ticket']
                                            ['salesStatus'] ==
                                        'comingSoon') {
                                      itemColor =
                                          Color(0xFF34B323).withOpacity(0.3);
                                      itemPriceText = 'COMING SOON';
                                    } else if (eventByCategoryList[i]['ticket']
                                            ['salesStatus'] ==
                                        'endSales') {
                                      itemColor = Color(0xFF8E1E2D);
                                      if (eventByCategoryList[i]['status'] ==
                                          'ended') {
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
                                  itemPriceText = eventByCategoryList[i]
                                      ['ticket_type']['name'];
                                } else if (eventByCategoryList[i]['ticket_type']
                                        ['type'] ==
                                    'free') {
                                  itemColor = Color(0xFFFFAA00);
                                  itemPriceText = eventByCategoryList[i]
                                      ['ticket_type']['name'];
                                } else if (eventByCategoryList[i]['ticket_type']
                                        ['type'] ==
                                    'free') {
                                  itemColor = Color(0xFFFFAA00);
                                  itemPriceText = eventByCategoryList[i]
                                      ['ticket_type']['name'];
                                } else if (eventByCategoryList[i]['ticket_type']
                                        ['type'] ==
                                    'free_live_stream') {
                                  itemColor = Color(0xFFFFAA00);
                                  itemPriceText = eventByCategoryList[i]
                                      ['ticket_type']['name'];
                                } else if (eventByCategoryList[i]['ticket_type']
                                        ['type'] ==
                                    'free_limited') {
                                  if (eventByCategoryList[i]['ticket']
                                          ['availableTicketStatus'] ==
                                      '1') {
                                    itemColor = Color(0xFFFFAA00);
                                    itemPriceText = eventByCategoryList[i]
                                        ['ticket_type']['name'];
                                  } else if (eventByCategoryList[i]['ticket']
                                          ['salesStatus'] ==
                                      'endSales') {
                                    itemColor = Color(0xFF8E1E2D);
                                    if (eventByCategoryList[i]['status'] ==
                                        'ended') {
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
                                            settings: RouteSettings(
                                                name: 'EventDetails'),
                                            builder: (BuildContext context) =>
                                                EventDetailLoadingScreen(
                                                    isRest: widget.isRest,
                                                    eventId:
                                                        eventByCategoryList[i]
                                                            ['id'])));
                                  },
                                  child: new LatestEventItem(
                                    image: eventByCategoryList[i]['picture'],
                                    title: eventByCategoryList[i]['name'],
                                    location: eventByCategoryList[i]['address'],
                                    itemColor: itemColor,
                                    itemPrice: itemPriceText,
                                    type: eventByCategoryList[i]['ticket_type']
                                        ['type'],
                                    isAvailable: eventByCategoryList[i]
                                        ['ticket']['availableTicketStatus'],
                                    date: DateTime.parse(
                                        eventByCategoryList[i]['dateStart']),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<http.Response> fetchUserByCollectionId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

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

    final latestEventApi = baseUrl +
        '/collections/user?X-API-KEY=$API_KEY&id=${widget.categoryId}';

    print(latestEventApi);

    setState(() {
      isLoading = true;
    });

    final response = await http.get(latestEventApi, headers: headers);

    print(response.body);

    return response;
  }

  Future<http.Response> fetchCategoryById({int page}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (page != null) {
        currentPage += page;
      }
    });

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

    final latestEventApi = baseUrl +
        '/collections/event?X-API-KEY=$API_KEY&id=${widget.categoryId}&page=$currentPage';

    print(latestEventApi);

    // setState(() {
    //   isLoading = true;
    // });

    final response = await http.get(latestEventApi, headers: headers);

    print(response.body);

    return response;
  }
}
