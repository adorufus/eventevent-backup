import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ClevertapHandler.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  final isRest;

  const Search({Key key, this.isRest}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SearchState();
  }
}

class SearchState extends State<Search> {
  TextEditingController searchController = new TextEditingController();

  final dio = new Dio();

  String _searchText = "";
  int currentTab = 0;

  List events = new List();
  List profile = new List();

  List filteredEvents = new List();
  List filteredProfile = new List();

  bool isEventNotFound = false;
  bool isPeopleNotFound = false;

  bool isEventLoading = false;
  bool isPeopleLoading = false;

  RefreshController peopleSearchRefreshController =
      new RefreshController(initialRefresh: false);
  RefreshController eventSearchRefreshController;

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        _searchText = "";
        filteredEvents = events;
      } else {
        _searchText = searchController.text;
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil.instance.setWidth(75),
            child: Container(
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.fromLTRB(13, 15, 13, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: ScreenUtil.instance.setWidth(300),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1.5)
                          ]),
                      height: ScreenUtil.instance.setWidth(50),
                      child: Material(
                        borderRadius: BorderRadius.circular(40),
                        child: TextFormField(
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.search,
                          onFieldSubmitted: (value) {
                            if (value != null) {
                              //ClevertapHandler.handleSearch(value);
                              switch (currentTab) {
                                case 0:
                                  _getEvents();
                                  break;
                                case 1:
                                  _getProfile().then((response) {
                                    var extractedData =
                                        json.decode(response.body);
                                    List resultData = extractedData['data'];
                                    List tempList = new List();

                                    if (response.statusCode == 200) {
                                      isPeopleLoading = false;
                                      isPeopleNotFound = false;
                                      for (int i = 0;
                                          i < resultData.length;
                                          i++) {
                                        tempList.add(resultData[i]);
                                      }

                                      profile = tempList;
                                      filteredProfile = profile;
                                      if (mounted) setState(() {});
                                    } else if (response.statusCode == 400) {
                                      isPeopleLoading = false;
                                      isPeopleNotFound = true;
                                    }
                                  });
                                  break;
                                default:
                                  print(currentTab);
                              }
                            }
                          },
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(16)),
                          autofocus: true,
                          autocorrect: false,
                          decoration: InputDecoration(
                              prefixIcon: Image.asset(
                                'assets/icons/icon_apps/search.png',
                                scale: 3.5,
                                color: Color(0xFF81818B),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 15),
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(18)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 0))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 0)))),
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(15),
                                color: eventajaGreenTeal),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              DefaultTabController(
                length: 2,
                initialIndex: currentTab,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          onTap: (i) {
                            currentTab = i;
                            if (mounted) setState(() {});
                          },
                          unselectedLabelColor: Colors.grey,
                          labelStyle: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(12.5),
                              fontWeight: FontWeight.bold),
                          tabs: <Widget>[
                            Tab(
                              text: 'Event',
                            ),
                            Tab(
                              text: 'People',
                            ),
                          ],
                        ),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height / 1.3,
                          child: TabBarView(
                            children: <Widget>[
                              isEventNotFound == true
                                  ? EmptyState(
                                      imagePath:
                                          'assets/icons/empty_state/profile.png',
                                      reasonText:
                                          'No result for: \n ${searchController.text}',
                                    )
                                  : _buildList(),
                              isPeopleNotFound == true
                                  ? EmptyState(
                                      imagePath:
                                          'assets/icons/empty_state/profile.png',
                                      reasonText:
                                          'No result for: \n ${searchController.text} :(',
                                    )
                                  : _buildListProfile()
                            ],
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = new List();
      for (int i = 0; i < filteredEvents.length; i++) {
        if (filteredEvents[i]['name']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredEvents[i]);
        }
      }
      filteredEvents = tempList;

      return isEventLoading == true
          ? HomeLoadingScreen().myTicketLoading()
          : ListView.builder(
              itemCount: events == null ? 0 : filteredEvents.length,
              itemBuilder: (BuildContext context, i) {
                Color itemColor;
                String itemPriceText;

                if (filteredEvents[i]['ticket_type']['type'] == 'paid' ||
                    filteredEvents[i]['ticket_type']['type'] ==
                        'paid_seating' ||
                    filteredEvents[i]['ticket_type']['type'] ==
                        'paid_live_stream') {
                  if (filteredEvents[i]['ticket']['availableTicketStatus'] ==
                      '1') {
                    itemColor = Color(0xFF34B323);
                    itemPriceText = 'Rp' +
                        formatPrice(
                          price: filteredEvents[i]['ticket']['cheapestTicket']
                              .toString(),
                        );
                  } else {
                    if (filteredEvents[i]['ticket']['salesStatus'] ==
                        'comingSoon') {
                      itemColor = Color(0xFF34B323).withOpacity(0.3);
                      itemPriceText = 'COMING SOON';
                    } else if (filteredEvents[i]['ticket']['salesStatus'] ==
                        'endSales') {
                      itemColor = Color(0xFF8E1E2D);
                      if (filteredEvents[i]['status'] == 'ended') {
                        itemPriceText = 'EVENT HAS ENDED';
                      }
                      itemPriceText = 'SALES ENDED';
                    } else {
                      itemColor = Color(0xFF8E1E2D);
                      itemPriceText = 'SOLD OUT';
                    }
                  }
                } else if (filteredEvents[i]['ticket_type']['type'] ==
                    'no_ticket') {
                  itemColor = Color(0xFF652D90);
                  itemPriceText = 'NO TICKET';
                } else if (filteredEvents[i]['ticket_type']['type'] ==
                    'on_the_spot') {
                  itemColor = Color(0xFF652D90);
                  itemPriceText = filteredEvents[i]['ticket_type']['name'];
                } else if (filteredEvents[i]['ticket_type']['type'] == 'free') {
                  itemColor = Color(0xFFFFAA00);
                  itemPriceText = filteredEvents[i]['ticket_type']['name'];
                } else if (filteredEvents[i]['ticket_type']['type'] == 'free') {
                  itemColor = Color(0xFFFFAA00);
                  itemPriceText = filteredEvents[i]['ticket_type']['name'];
                } else if (filteredEvents[i]['ticket_type']['type'] ==
                        'free_limited' ||
                    filteredEvents[i]['ticket_type']['type'] ==
                        'free_live_stream') {
                  if (filteredEvents[i]['ticket']['availableTicketStatus'] ==
                      '1') {
                    itemColor = Color(0xFFFFAA00);
                    itemPriceText = "FREE";
                  } else {
                    if (filteredEvents[i]['ticket']['salesStatus'] ==
                        'comingSoon') {
                      itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                      itemPriceText = 'COMING SOON';
                    } else if (filteredEvents[i]['ticket']['salesStatus'] ==
                        'endSales') {
                      itemColor = Color(0xFF8E1E2D);
                      if (filteredEvents[i]['status'] == 'ended') {
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
                            builder: (context) => EventDetailLoadingScreen(
                                isRest: widget.isRest,
                                eventId: filteredEvents[i]['id'])));
                  },
                  child: LatestEventItem(
                    image: filteredEvents[i]['picture_timeline'],
                    isAvailable: filteredEvents[i]['ticket']
                        ['availableTicketStatus'],
                    itemPrice: itemPriceText,
                    itemColor: itemColor,
                    isHybridEvent: filteredEvents[i]['isHybridEvent'],
                    location: filteredEvents[i]['address'],
                    title: filteredEvents[i]['name'],
                    date: DateTime.parse(filteredEvents[i]['dateStart']),
                    type: filteredEvents[i]['ticket_type']['type'],
                  ),
                );
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (BuildContext context) =>
                //                 EventDetailsConstructView(
                //                   id: filteredEvents[i]['id'],
                //                 )));
                //   },
                //   child: Container(
                //     width: MediaQuery.of(context).size.width,
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       border: Border(bottom: BorderSide(color: Colors.grey[300])),
                //     ),
                //     child: Row(
                //       children: <Widget>[
                //         Container(
                //             margin: EdgeInsets.all(10),
                //             height: ScreenUtil.instance.setWidth(130),
                //             height: ScreenUtil.instance.setWidth(100),
                //             decoration: BoxDecoration(
                //                 image: DecorationImage(
                //                     image: NetworkImage(
                //                       filteredEvents[i]['picture'],
                //                     ),
                //                     fit: BoxFit.fill))),
                //         Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: <Widget>[
                //               Container(
                //                 width: ScreenUtil.instance.setWidth(230),
                //                 child: Text(
                //                   filteredEvents[i]['name'],
                //                   overflow: TextOverflow.ellipsis,
                //                 ),
                //               ),
                //               SizedBox(
                //                 height: ScreenUtil.instance.setWidth(15),
                //               ),
                //               Container(
                //                 width: ScreenUtil.instance.setWidth(230),
                //                 child: Text(filteredEvents[i]['address'],
                //                     overflow: TextOverflow.ellipsis),
                //               ),
                //               SizedBox(
                //                 height: ScreenUtil.instance.setWidth(15),
                //               ),
                //               Container(
                //                 width: ScreenUtil.instance.setWidth(230),
                //                 child: Text(salesStatus,
                //                     overflow: TextOverflow.ellipsis),
                //               ),
                //               SizedBox(
                //                 height: ScreenUtil.instance.setWidth(15),
                //               ),
                //               Container(
                //                   width: ScreenUtil.instance.setWidth(125),
                //                   height: ScreenUtil.instance.setWidth(45),
                //                   decoration: BoxDecoration(
                //                       borderRadius: BorderRadius.circular(25),
                //                       image: DecorationImage(
                //                           colorFilter: ColorFilter.mode(
                //                               Colors.black
                //                                   .withOpacity(opacityValue),
                //                               BlendMode.dstATop),
                //                           image: AssetImage(priceImageUri),
                //                           fit: BoxFit.fill)),
                //                   child: Center(
                //                     child: Text(
                //                         filteredEvents[i]['ticket_type']['type'] ==
                //                                 'paid'
                //                             ? filteredEvents[i]['status'] == 'ended' ? '' : 'Rp' +
                //                                 filteredEvents[i]['ticket']
                //                                     ['cheapestTicket']
                //                             : '',
                //                         style: TextStyle(
                //                             color: Colors.white,
                //                             fontWeight: FontWeight.bold,
                //                             fontSize: ScreenUtil.instance.setSp(18))),
                //                   ))
                //             ])
                //       ],
                //     ),
                //   ),
                // );
              });
    } else {
      return Container();
    }
  }

  int peopleNewPage = 0;

  void peopleOnLoad() async {
    setState(() {
      peopleNewPage += 1;
    });

    _getProfile(page: peopleNewPage, isLoadData: true).then((response) async {
      var extractedData = json.decode(response.body);
      List resultData = extractedData['data'];
      List tempList = new List();

      if (response.statusCode == 200) {
        isEventLoading = false;
        isEventNotFound = false;
        for (int i = 0; i < resultData.length; i++) {
          // tempList.removeWhere((data) => data['username'] == filteredProfile)
          tempList.add(resultData[i]);
        }

        profile = tempList;
        filteredProfile.addAll(profile);

        await Future.delayed(Duration(seconds: 3));
        if (mounted) setState(() {});
        peopleSearchRefreshController.loadComplete();
      } else if (response.statusCode == 400) {
        if (mounted) setState(() {});
        peopleSearchRefreshController.loadFailed();
      }
    });
  }

  void peopleOnRefresh() async {
    setState(() {
      peopleNewPage = 0;
    });
    _getProfile().then((response) async {
      var extractedData = json.decode(response.body);
      List resultData = extractedData['data'];
      List tempList = new List();

      if (response.statusCode == 200) {
        isEventLoading = false;
        isEventNotFound = false;
        for (int i = 0; i < resultData.length; i++) {
          tempList.add(resultData[i]);
        }

        profile = tempList;
        filteredProfile = profile;
        await Future.delayed(Duration(seconds: 3));
        if (mounted) setState(() {});
        peopleSearchRefreshController.refreshCompleted();
      } else if (response.statusCode == 400) {
        isEventLoading = false;
        isEventNotFound = true;

        if (mounted) setState(() {});
        peopleSearchRefreshController.refreshFailed();
      }
    });
  }

  Widget _buildListProfile() {
    if (!_searchText.isEmpty) {
      List tempList = new List();
      for (int i = 0; i < filteredProfile.length; i++) {
        if (filteredProfile[i]['username']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredProfile[i]);
        }
      }
      filteredProfile = tempList;
    }

    return isPeopleLoading == true
        ? HomeLoadingScreen().followListLoading()
        : SmartRefresher(
            controller: peopleSearchRefreshController,
            onLoading: peopleOnLoad,
            onRefresh: peopleOnRefresh,
            enablePullUp: true,
            child: ListView.builder(
              itemCount: filteredProfile == null ? 0 : filteredProfile.length,
              itemBuilder: (BuildContext context, i) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ProfileWidget(
                              isRest: widget.isRest,
                              initialIndex: 0,
                              userId: filteredProfile[i]['id'],
                            )));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(bottom: BorderSide(color: Colors.grey[300])),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(filteredProfile[i]['photo']),
                          backgroundColor: Colors.grey,
                        ),
                        SizedBox(width: ScreenUtil.instance.setWidth(20)),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  filteredProfile[i]['isVerified'] == '0'
                                      ? Container()
                                      : CircleAvatar(
                                          backgroundImage: AssetImage(
                                              'assets/icons/icon_apps/verif.png'),
                                          radius: 10,
                                        ),
                                  SizedBox(
                                    width: ScreenUtil.instance.setWidth(3),
                                  ),
                                  Container(
                                    width: ScreenUtil.instance.setWidth(150),
                                    child: Text(
                                      filteredProfile[i]['fullName'] == null
                                          ? filteredProfile[i]['username']
                                          : filteredProfile[i]['fullName'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(15),
                              ),
                              Container(
                                width: ScreenUtil.instance.setWidth(150),
                                child: Text(filteredProfile[i]['username'],
                                    style: TextStyle(color: Colors.grey),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(15),
                              ),
                            ]),
                        Expanded(
                          child: SizedBox(),
                        ),
                        Container(
                            margin: EdgeInsets.only(right: 20),
                            height: ScreenUtil.instance.setWidth(30),
                            width: ScreenUtil.instance.setWidth(80),
                            child: Image.asset(
                              'assets/icons/btn_follow.png',
                              fit: BoxFit.cover,
                            ))
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  Future<http.Response> _getProfile({int page, bool isLoadData = false}) async {
    int currentPage = 1;

    setState(() {
      if (isLoadData == false) {
        isPeopleLoading = true;
      }
      if (page != null) {
        currentPage += page;
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String baseUrl = '';
    Map<String, String> headers;

    if (widget.isRest) {
      baseUrl = BaseApi().restUrl;
      headers = {
        'Authorization': AUTH_KEY,
        'signature': SIGNATURE,
      };
    } else {
      baseUrl = BaseApi().apiUrl;
      headers = {
        'Authorization': AUTH_KEY,
        'cookie': prefs.getString('Session')
      };
    }

    String url = baseUrl +
        '/user/search?X-API-KEY=$API_KEY&people=${searchController.text}&page=$currentPage';

    final response = await http.get(url, headers: headers);

    print(response.statusCode);

    return response;
  }

  Future _getEvents() async {
    setState(() {
      isEventLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String baseUrl = '';
    Map<String, String> headers;

    if (widget.isRest) {
      baseUrl = BaseApi().restUrl;
      headers = {
        'Authorization': AUTH_KEY,
        'signature': SIGNATURE,
      };
    } else {
      baseUrl = BaseApi().apiUrl;
      headers = {
        'Authorization': AUTH_KEY,
        'cookie': prefs.getString('Session')
      };
    }

    String url = baseUrl +
        '/event/search?X-API-KEY=$API_KEY&event=${searchController.text}&page=1';

    final response = await http.get(url, headers: headers);

    print(response.statusCode);
    print(response.body);

    var extractedData = json.decode(response.body);
    List resultData = extractedData['data'];
    List tempList = new List();

    if (response.statusCode == 200) {
      setState(() {
        isEventLoading = false;
        isEventNotFound = false;
      });
      for (int i = 0; i < resultData.length; i++) {
        tempList.add(resultData[i]);
      }

      setState(() {
        events = tempList;
        filteredEvents = events;
      });
    } else if (response.statusCode == 400) {
      setState(() {
        isEventLoading = false;
        isEventNotFound = true;
      });
    }
  }
}
