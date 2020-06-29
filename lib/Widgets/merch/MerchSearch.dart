import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/Widgets/merch/CollectionItem.dart';
import 'package:eventevent/Widgets/merch/MerchItem.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MerchSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MerchSearchState();
  }
}

class MerchSearchState extends State<MerchSearch>
    with TickerProviderStateMixin {
  TextEditingController searchController = new TextEditingController();

  final dio = new Dio();

  String _searchText = "";

  List merchs = new List();
  List sellerProfile = new List();

  List filteredMerch = new List();
  List filteredSellerProfile = new List();

  bool notFound = false;

  bool isLoading = false;
  TabController thisTabController;
  int currentTab = 0;

  @override
  void initState() {
    thisTabController = TabController(length: 2, vsync: this, initialIndex: currentTab);
    super.initState();
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
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        _searchText = "";
        filteredMerch = merchs;
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
                            // notFound = false;
                            if (value != null) {
                              if (currentTab == 1) {
                                _getProfile().then((response) {
                                  var extractedData =
                                      json.decode(response.body);
                                  List resultData = extractedData['data'];
                                  List tempList = new List();

                                  if (response.statusCode == 200) {
                                    isLoading = false;
                                    notFound = false;
                                    for (int i = 0;
                                        i < resultData.length;
                                        i++) {
                                      tempList.add(resultData[i]);
                                    }

                                    sellerProfile = tempList;
                                    filteredSellerProfile = sellerProfile;
                                  } else if (response.statusCode == 400) {
                                    isLoading = false;
                                    notFound = true;
                                  }

                                  if(mounted) setState((){});
                                });
                              } else if (currentTab == 0) {
                                _getEvents();
                              }
                            }
                          },
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(12)),
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
                initialIndex: 0,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          // controller: thisTabController,
                          onTap: (thisTabIndex){
                            currentTab = thisTabIndex;
                            if(mounted) setState((){});
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
                              notFound == true
                                  ? EmptyState(
                                      imagePath:
                                          'assets/icons/empty_state/profile.png',
                                      reasonText:
                                          'No result for: \n ${searchController.text}',
                                    )
                                  : _buildList(),
                              _buildListProfile()
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
      for (int i = 0; i < filteredMerch.length; i++) {
        if (filteredMerch[i]['product_name']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredMerch[i]);
        }
      }
      filteredMerch = tempList;

      return isLoading == true
          ? HomeLoadingScreen().myTicketLoading()
          : ListView.builder(
              itemCount: merchs == null ? 0 : filteredMerch.length,
              padding: EdgeInsets.symmetric(horizontal: 13),
              itemBuilder: (BuildContext context, i) {
                // Color itemColor;
                // String itemPriceText;

                // if (filteredMerch[i]['ticket_type']['type'] == 'paid' ||
                //     filteredMerch[i]['ticket_type']['type'] ==
                //         'paid_seating' ||
                //     filteredMerch[i]['ticket_type']['type'] ==
                //         'paid_live_stream') {
                //   if (filteredMerch[i]['ticket']['availableTicketStatus'] ==
                //       '1') {
                //     itemColor = Color(0xFF34B323);
                //     itemPriceText =
                //         filteredMerch[i]['ticket']['cheapestTicket'];
                //   } else {
                //     if (filteredMerch[i]['ticket']['salesStatus'] ==
                //         'comingSoon') {
                //       itemColor = Color(0xFF34B323).withOpacity(0.3);
                //       itemPriceText = 'COMING SOON';
                //     } else if (filteredMerch[i]['ticket']['salesStatus'] ==
                //         'endSales') {
                //       itemColor = Color(0xFF8E1E2D);
                //       if (filteredMerch[i]['status'] == 'ended') {
                //         itemPriceText = 'EVENT HAS ENDED';
                //       }
                //       itemPriceText = 'SALES ENDED';
                //     } else {
                //       itemColor = Color(0xFF8E1E2D);
                //       itemPriceText = 'SOLD OUT';
                //     }
                //   }
                // } else if (filteredMerch[i]['ticket_type']['type'] ==
                //     'no_ticket') {
                //   itemColor = Color(0xFF652D90);
                //   itemPriceText = 'NO TICKET';
                // } else if (filteredMerch[i]['ticket_type']['type'] ==
                //     'on_the_spot') {
                //   itemColor = Color(0xFF652D90);
                //   itemPriceText = filteredMerch[i]['ticket_type']['name'];
                // } else if (filteredMerch[i]['ticket_type']['type'] == 'free') {
                //   itemColor = Color(0xFFFFAA00);
                //   itemPriceText = filteredMerch[i]['ticket_type']['name'];
                // } else if (filteredMerch[i]['ticket_type']['type'] == 'free') {
                //   itemColor = Color(0xFFFFAA00);
                //   itemPriceText = filteredMerch[i]['ticket_type']['name'];
                // } else if (filteredMerch[i]['ticket_type']['type'] ==
                //         'free_limited' ||
                //     filteredMerch[i]['ticket_type']['type'] ==
                //         'free_live_stream') {
                //   if (filteredMerch[i]['ticket']['availableTicketStatus'] ==
                //       '1') {
                //     itemColor = Color(0xFFFFAA00);
                //     itemPriceText = filteredMerch[i]['ticket_type']['name'];
                //   } else {
                //     if (filteredMerch[i]['ticket']['salesStatus'] ==
                //         'comingSoon') {
                //       itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                //       itemPriceText = 'COMING SOON';
                //     } else if (filteredMerch[i]['ticket']['salesStatus'] ==
                //         'endSales') {
                //       itemColor = Color(0xFF8E1E2D);
                //       if (filteredMerch[i]['status'] == 'ended') {
                //         itemPriceText = 'EVENT HAS ENDED';
                //       }
                //       itemPriceText = 'SALES ENDED';
                //     } else {
                //       itemColor = Color(0xFF8E1E2D);
                //       itemPriceText = 'SOLD OUT';
                //     }
                //   }
                // }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventDetailLoadingScreen(
                                eventId: filteredMerch[i]['id'])));
                  },
                  child: CollectionItem(
                    itemColor: eventajaGreenTeal,
                    image: filteredMerch[i]['images']['mainImage'],
                    itemPrice: filteredMerch[i]['details'][0]['final_price'],
                    username: filteredMerch[i]['seller']['username'],
                    profileImage: filteredMerch[i]['seller']['photo'],
                    title: filteredMerch[i]['product_name'],
                  ),
                );
              });
    } else {
      return Container();
    }
  }

  Widget _buildListProfile() {
    if (!_searchText.isEmpty) {
      List tempList = new List();
      for (int i = 0; i < filteredSellerProfile.length; i++) {
        if (filteredSellerProfile[i]['username']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredSellerProfile[i]);
        }
      }
      filteredSellerProfile = tempList;
    }

    return isLoading == true
        ? HomeLoadingScreen().followListLoading()
        : filteredSellerProfile.length < 1
            ? EmptyState(
                imagePath: 'assets/icons/empty_state/profile.png',
                reasonText: 'No result for: \n ${searchController.text}',
              )
            : ListView.builder(
                itemCount: filteredSellerProfile == null
                    ? 0
                    : filteredSellerProfile.length,
                itemBuilder: (BuildContext context, i) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ProfileWidget(
                                initialIndex: 0,
                                userId: filteredSellerProfile[i]['id'],
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
                                NetworkImage(filteredSellerProfile[i]['photo']),
                            backgroundColor: Colors.grey,
                          ),
                          SizedBox(width: ScreenUtil.instance.setWidth(20)),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    filteredSellerProfile[i]['isVerified'] ==
                                            '0'
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
                                        filteredSellerProfile[i]['fullName'] ==
                                                null
                                            ? filteredSellerProfile[i]
                                                ['username']
                                            : filteredSellerProfile[i]
                                                ['fullName'],
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
                                  child: Text(
                                      filteredSellerProfile[i]['username'],
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
              );
  }

  Future<http.Response> _getProfile() async {
    setState(() {
      isLoading = true;
    });
    print('calling seller profile search api');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/product/search_seller?X-API-KEY=$API_KEY&page=1&search=${searchController.text}&limit=10';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);

    return response;
  }

  Future _getEvents() async {
    setState(() {
      isLoading = true;
    });
    print('calling merch search api');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/product/search?X-API-KEY=$API_KEY&page=1&search=${searchController.text}&limit=10';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);

    var extractedData = json.decode(response.body);
    List resultData = extractedData['data'];
    List tempList = new List();

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        notFound = false;
      });
      for (int i = 0; i < resultData.length; i++) {
        tempList.add(resultData[i]);
      }

      setState(() {
        merchs = tempList;
        filteredMerch = merchs;
      });
    } else if (response.statusCode == 400) {
      setState(() {
        isLoading = false;
        notFound = true;
      });
    }
  }
}
