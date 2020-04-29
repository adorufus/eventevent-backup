import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/Home/SeeAll/MyTicketItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/ProfileWidget/UseTicket.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
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

class MyTicketSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyTicketSearchState();
  }
}

class MyTicketSearchState extends State<MyTicketSearch> {
  TextEditingController searchController = new TextEditingController();

  final dio = new Dio();

  String _searchText = "";

  List events = new List();
  List profile = new List();

  List filteredEvents = new List();
  List filteredProfile = new List();

  bool notFound = false;

  bool isLoading = false;

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

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              _getEvents();
                              _getProfile().then((response) {
                                var extractedData = json.decode(response.body);
                                List resultData = extractedData['data'];
                                List tempList = new List();

                                if (response.statusCode == 200) {
                                  isLoading = false;
                                  notFound = false;
                                  for (int i = 0; i < resultData.length; i++) {
                                    tempList.add(resultData[i]);
                                  }

                                  profile = tempList;
                                  filteredProfile = profile;
                                } else if (response.statusCode == 400) {
                                  isLoading = false;
                                  notFound = true;
                                }
                              });
                            }
                          },
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(12)),
                          autofocus: true,
                          autocorrect: false,
                          decoration: InputDecoration(
                              prefixIcon: Image.asset(
                                'assets/icons/icon_apps/search.png',
                                scale: 4.5,
                                color: Color(0xFF81818B),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 15),
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(12)),
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
                                  fontSize: ScreenUtil.instance.setSp(12),
                                  color: eventajaGreenTeal),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          child: notFound == true
              ? EmptyState(
                  imagePath: 'assets/icons/empty_state/profile.png',
                  reasonText: 'No result for: \n ${searchController.text}',
                )
              : _buildList(),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = new List();
      for (int i = 0; i < filteredEvents.length; i++) {
        if (filteredEvents[i]['ticket']['ticket_name']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredEvents[i]);
        }
      }
      filteredEvents = tempList;

      return isLoading == true
          ? HomeLoadingScreen().myTicketLoading()
          : ListView.builder(
              itemCount: events == null ? 0 : filteredEvents.length,
              itemBuilder: (BuildContext context, i) {
                Color ticketColor;
                String ticketStatusText;

                if (filteredEvents[i]['usedStatus'] == 'available') {
                  ticketColor = eventajaGreenTeal;
                  ticketStatusText = 'Available';
                } else if (filteredEvents[i]['usedStatus'] == 'used') {
                  ticketColor = Color(0xFF652D90);
                  ticketStatusText = 'Used';
                } else if (filteredEvents[i]['usedStatus'] == 'expired') {
                  ticketColor = Color(0xFF8E1E2D);
                  ticketStatusText = 'Expired';
                } else if (filteredEvents[i]['usedStatus'] == 'refund') {
                  ticketColor = Colors.blue;
                  ticketStatusText = 'Refund';
                }

                print(filteredEvents[i].containsKey('ticket_image').toString());
                print(filteredEvents[i]['ticket_image'].toString());
                String ticketImage;

                if (filteredEvents[i]['ticket_image'] == false) {
                  ticketImage = '';
                } else {
                  ticketImage = filteredEvents[i]['ticket_image']['secure_url'];
                }

                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UseTicket(
                                              ticketTitle: filteredEvents[i]
                                                  ['ticket']['ticket_name'],
                                              ticketImage: filteredEvents[i]
                                                  ['ticket_image']['url'],
                                              ticketCode: filteredEvents[i]
                                                  ['ticket_code'],
                                              ticketDate: filteredEvents[i]
                                                  ['event']['dateStart'],
                                              ticketStartTime: filteredEvents[i]
                                                  ['event']['timeStart'],
                                              ticketEndTime: filteredEvents[i]
                                                  ['event']['timeEnd'],
                                              ticketDesc: filteredEvents[i]
                                                  ['event']['name'],
                                              ticketID: filteredEvents[i]['id'],
                                              usedStatus: ticketStatusText
                                                  .toUpperCase(),
                                            )));
                    },
                    child: MyTicketItem(
                      image: filteredEvents[i]
                                  .containsKey('ticket_image')
                                  .toString() ==
                              'true'
                          ? ticketImage ?? ''
                          : '',
                      title: filteredEvents[i]['event']['name'],
                      ticketCode: filteredEvents[i]['ticket_code'],
                      ticketStatus: ticketStatusText,
                      timeStart: filteredEvents[i]['event']['timeStart'],
                      timeEnd: filteredEvents[i]['event']['timeEnd'],
                      date: DateTime.parse(
                          filteredEvents[i]['event']['dateStart']),
                      ticketName: filteredEvents[i]['ticket']['ticket_name'],
                      ticketColor: ticketColor,
                    ));
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
                //                         filteredEvents[i]['paid_ticket_type']['type'] ==
                //                                 'paid'
                //                             ? filteredEvents[i]['status'] == 'ended' ? '' : 'Rp. ' +
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

  Future<http.Response> _getProfile() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/user/search?X-API-KEY=$API_KEY&people=${searchController.text}&page=1';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/tickets/all?X-API-KEY=$API_KEY&page=1&search=${searchController.text}';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);
    print(response.body);

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
        events = tempList;
        filteredEvents = events;
      });
    } else if (response.statusCode == 400) {
      setState(() {
        isLoading = false;
        notFound = true;
      });
    }
  }
}
