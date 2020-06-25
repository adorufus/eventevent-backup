import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/MyTicketSearch.dart';
import 'package:eventevent/Widgets/Home/SeeAll/MyTicketItem.dart';
import 'package:eventevent/Widgets/ProfileWidget/UseTicket.dart';
import 'package:eventevent/Widgets/RecycleableWidget/SearchWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTicket extends StatefulWidget {
  @override
  _MyTicketState createState() => _MyTicketState();
}

class _MyTicketState extends State<MyTicket> {
  List myTicketList;
  List filteredTickets = new List();
  List tickets = new List();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController searchController = new TextEditingController();

  int newPage = 0;
  String _searchText = "";

  bool notFound = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getMyTicket().then((response) {
      var extractedData = json.decode(response.body);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          myTicketList = extractedData['data'];
        });
      }
    });
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    getMyTicket(newPage: newPage).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          List updatedData = extractedData['data'];
          if (updatedData == null) {
            // refreshController.loadFailed();
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          myTicketList.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      }
    }).catchError((e) {
      // refreshController.loadFailed();
      refreshController.loadNoData();
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

    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        searchController.text = '';
      }
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(65),
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
            title: Text(
              'My Tickets',
              style: TextStyle(color: eventajaGreenTeal),
            ),
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
      body: isLoading == true
          ? HomeLoadingScreen().myTicketLoading()
          : myTicketList == null
              ? EmptyState(
                  imagePath: 'assets/drawable/my_ticket_empty_state.png',
                  reasonText: 'You have no ticket :(',
                )
              : SafeArea(
                  child: SmartRefresher(
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
                      getMyTicket(newPage: newPage).then((response) {
                        if (response.statusCode == 200) {
                          setState(() {
                            var extractedData = json.decode(response.body);
                            myTicketList = extractedData['data'];
                          });
                          if (mounted) setState(() {});
                          refreshController.refreshCompleted();
                        }
                      });
                    },
                    onLoading: _onLoading,
                    child: ListView(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                top: 15, right: 25, left: 25, bottom: 15),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MyTicketSearch()));
                              },
                              child: Material(
                                  borderRadius: BorderRadius.circular(40),
                                  elevation: 2.0,
                                  shadowColor: Colors.black,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 15),
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.search),
                                        SizedBox(width: 10),
                                        Text(
                                          'Search ticket',
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      ],
                                    ),
                                  )),
                            )),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              myTicketList == null ? 0 : myTicketList.length,
                          itemBuilder: (BuildContext context, i) {
                            Color ticketColor;
                            String ticketStatusText;

                            print(
                                'PLAYBACK URL: ${myTicketList[i]['livestream']['playback_url']}');

                            if (myTicketList[i]['usedStatus'] == 'available') {
                              ticketColor = eventajaGreenTeal;
                              ticketStatusText = 'Available';
                            } else if (myTicketList[i]['usedStatus'] ==
                                'used') {
                              ticketColor = Color(0xFF652D90);
                              ticketStatusText = 'Used';
                            } else if (myTicketList[i]['usedStatus'] ==
                                'streaming') {
                              if (myTicketList[i]['livestream']
                                      ['on_demand_link'] !=
                                  null) {
                                ticketColor = eventajaGreenTeal;
                                ticketStatusText = 'On Demand Video';
                              } else {
                                ticketColor = eventajaGreenTeal;
                                ticketStatusText = 'Streaming';
                              }
                            } else if (myTicketList[i]['usedStatus'] ==
                                'playback') {
                              ticketColor = eventajaGreenTeal;
                              ticketStatusText = 'Watch Playback';
                            } else if (myTicketList[i]['usedStatus'] ==
                                'expired') {
                              if (myTicketList[i].containsKey('livestream')) {
                                if (myTicketList[i]['livestream']['zoom_id'] ==
                                    null) {
                                  ticketColor = eventajaGreenTeal;
                                  ticketStatusText = 'Playback';
                                } else {
                                  ticketColor = Color(0xFF8E1E2D);
                                  ticketStatusText = 'Expired Zoom Session';
                                }
                              } else {
                                ticketColor = Color(0xFF8E1E2D);
                                ticketStatusText = 'Expired';
                              }
                            } else if (myTicketList[i]['usedStatus'] ==
                                'refund') {
                              ticketColor = Colors.blue;
                              ticketStatusText = 'Refund';
                            }

                            print('ticketStatusText');

                            print(myTicketList[i]
                                .containsKey('ticket_image')
                                .toString());
                            print(myTicketList[i]['ticket_image'].toString());
                            String ticketImage;

                            if (myTicketList[i]['ticket_image'] == false) {
                              ticketImage = '';
                            } else {
                              ticketImage =
                                  myTicketList[i]['ticket_image']['secure_url'];
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            UseTicket(
                                              ticketDetail: myTicketList[i],
                                              eventId: myTicketList[i]
                                                  ['event_id'],
                                              ticketTitle: myTicketList[i]
                                                  ['ticket']['ticket_name'],
                                              ticketImage: myTicketList[i]
                                                  ['ticket_image']['url'],
                                              ticketCode: myTicketList[i]
                                                  ['ticket_code'],
                                              ticketDate: myTicketList[i]
                                                  ['event']['dateStart'],
                                              ticketStartTime: myTicketList[i]
                                                  ['event']['timeStart'],
                                              ticketEndTime: myTicketList[i]
                                                  ['event']['timeEnd'],
                                              ticketDesc: myTicketList[i]
                                                  ['event']['name'],
                                              ticketID: myTicketList[i]['id'],
                                              zoomId: myTicketList[i]
                                                  ['livestream']['zoom_id'],
                                              zoomDesc: myTicketList[i]
                                                      ['livestream']
                                                  ['zoom_description'],
                                              livestreamUrl: ticketStatusText ==
                                                      'On Demand Video'
                                                  ? myTicketList[i]
                                                          ['livestream']
                                                      ['on_demand_link']
                                                  : ticketStatusText ==
                                                              "Streaming" ||
                                                          ticketStatusText ==
                                                              'Watch Playback' ||
                                                          ticketStatusText ==
                                                              'Playback' ||
                                                          ticketStatusText ==
                                                              'Expired'
                                                      ? myTicketList[i]['livestream']['playback_url'] ==
                                                              'not_available'
                                                          ? myTicketList[i]
                                                                  ['livestream']
                                                              ['playback']
                                                          : myTicketList[i]
                                                                  ['livestream']
                                                              ['playback_url']
                                                      : '',
                                              usedStatus: ticketStatusText,
                                            )));
                              },
                              child: Container(
                                child: new MyTicketItem(
                                  image: myTicketList[i]
                                              .containsKey('ticket_image')
                                              .toString() ==
                                          'true'
                                      ? ticketImage ?? ''
                                      : '',
                                  title: myTicketList[i]['event']['name'],
                                  ticketCode: myTicketList[i]['ticket_code'],
                                  ticketStatus: ticketStatusText,
                                  timeStart: myTicketList[i]['event']
                                      ['timeStart'],
                                  timeEnd: myTicketList[i]['event']['timeEnd'],
                                  date: DateTime.parse(
                                      myTicketList[i]['event']['dateStart']),
                                  ticketName: myTicketList[i]['ticket']
                                      ['ticket_name'],
                                  ticketColor: ticketColor,
                                  // topPadding: i == 0 ? 13.0 : 0.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Widget _buildTicketList() {
  //   if (!(_searchText.isEmpty)) {
  //     List tempList = new List();
  //     for (int i = 0; i < filteredTickets.length; i++) {
  //       if (filteredTickets[i]['name']
  //           .toString()
  //           .toLowerCase()
  //           .contains(_searchText.toLowerCase())) {
  //         tempList.add(filteredTickets[i]);
  //       }
  //     }
  //     filteredTickets = tempList;

  //     return ListView.builder(
  //       itemCount: tickets == null ? 0 : filteredTickets.length,
  //       itemBuilder: (BuildContext context, i) {
  //         Color ticketColor;
  //         String ticketStatusText;

  //         if (filteredTickets[i]['usedStatus'] == 'available') {
  //           ticketColor = eventajaGreenTeal;
  //           ticketStatusText = 'Available';
  //         } else if (filteredTickets[i]['usedStatus'] == 'used') {
  //           ticketColor = Color(0xFF652D90);
  //           ticketStatusText = 'Used';
  //         } else if (filteredTickets[i]['usedStatus'] == 'expired') {
  //           ticketColor = Color(0xFF8E1E2D);
  //           ticketStatusText = 'Expired';
  //         }

  //         return GestureDetector(
  //           onTap: () {
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (BuildContext context) => UseTicket(
  //                           ticketTitle: filteredTickets[i]['ticket']
  //                               ['ticket_name'],
  //                           ticketImage: filteredTickets[i]['ticket_image']
  //                               ['url'],
  //                           ticketCode: filteredTickets[i]['ticket_code'],
  //                           ticketDate: filteredTickets[i]['event']
  //                               ['dateStart'],
  //                           ticketStartTime: filteredTickets[i]['event']
  //                               ['timeStart'],
  //                           ticketEndTime: filteredTickets[i]['event']
  //                               ['timeEnd'],
  //                           ticketDesc: filteredTickets[i]['event']['name'],
  //                           ticketID: filteredTickets[i]['id'],
  //                           usedStatus: ticketStatusText.toUpperCase(),
  //                         )));
  //           },
  //           child: Container(
  //             child: new MyTicketItem(
  //               image: filteredTickets[i]['ticket_image']['secure_url'],
  //               title: filteredTickets[i]['event']['name'],
  //               ticketCode: filteredTickets[i]['ticket_code'],
  //               ticketStatus: ticketStatusText,
  //               timeStart: filteredTickets[i]['event']['timeStart'],
  //               timeEnd: filteredTickets[i]['event']['timeEnd'],
  //               date: DateTime.parse(filteredTickets[i]['event']['dateStart']),
  //               ticketName: filteredTickets[i]['ticket']['ticket_name'],
  //               ticketColor: ticketColor,
  //               // topPadding: i == 0 ? 13.0 : 0.0,
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }

  //   // return ListView.builder(
  //   //   itemCount: filteredTickets == null ? 0 : filteredTickets.length,
  //   //   itemBuilder: (BuildContext context, i) {
  //   //     Color ticketColor;
  //   //     String ticketStatusText;

  //   //     if (filteredTickets[i]['usedStatus'] == 'available') {
  //   //       ticketColor = eventajaGreenTeal;
  //   //       ticketStatusText = 'Available';
  //   //     } else if (filteredTickets[i]['usedStatus'] == 'used') {
  //   //       ticketColor = Color(0xFF652D90);
  //   //       ticketStatusText = 'Used';
  //   //     } else if (filteredTickets[i]['usedStatus'] == 'expired') {
  //   //       ticketColor = Color(0xFF8E1E2D);
  //   //       ticketStatusText = 'Expired';
  //   //     }

  //   //     return GestureDetector(
  //   //       onTap: () {
  //   //         Navigator.push(
  //   //             context,
  //   //             MaterialPageRoute(
  //   //                 builder: (BuildContext context) => UseTicket(
  //   //                       ticketTitle: filteredTickets[i]['ticket']
  //   //                           ['ticket_name'],
  //   //                       ticketImage: filteredTickets[i]['ticket_image']
  //   //                           ['url'],
  //   //                       ticketCode: filteredTickets[i]['ticket_code'],
  //   //                       ticketDate: filteredTickets[i]['event']['dateStart'],
  //   //                       ticketStartTime: filteredTickets[i]['event']
  //   //                           ['timeStart'],
  //   //                       ticketEndTime: filteredTickets[i]['event']['timeEnd'],
  //   //                       ticketDesc: filteredTickets[i]['event']['name'],
  //   //                       ticketID: filteredTickets[i]['id'],
  //   //                       usedStatus: ticketStatusText.toUpperCase(),
  //   //                     )));
  //   //       },
  //   //       child: Container(
  //   //         child: new MyTicketItem(
  //   //           image: filteredTickets[i]['ticket_image']['secure_url'],
  //   //           title: filteredTickets[i]['event']['name'],
  //   //           ticketCode: filteredTickets[i]['ticket_code'],
  //   //           ticketStatus: ticketStatusText,
  //   //           timeStart: filteredTickets[i]['event']['timeStart'],
  //   //           timeEnd: filteredTickets[i]['event']['timeEnd'],
  //   //           ticketName: filteredTickets[i]['ticket']['ticket_name'],
  //   //           ticketColor: ticketColor,
  //   //           // topPadding: i == 0 ? 13.0 : 0.0,
  //   //         ),
  //   //       ),
  //   //     );
  //   //   },
  //   // );
  // }

  Future<http.Response> _getTickets() async {
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

    return response;
  }

  Future<http.Response> getMyTicket({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      isLoading = true;
      if (newPage != null) {
        currentPage += newPage;
      }
    });

    var urlApi = BaseApi().apiUrl +
        '/tickets/all?X-API-KEY=$API_KEY&page=$currentPage&search=';
    final response = await http.get(urlApi, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    var extractedData = json.decode(response.body);
    List resultData = extractedData['data'];
    List tempList = new List();

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        notFound = false;
      });

      if (resultData == null) {
        print('empty');
        setState(() {
          notFound = true;
        });
      } else {
        setState(() {
          notFound = false;
        });
        for (int i = 0; i < resultData.length; i++) {
          tempList.add(resultData[i]);
        }

        setState(() {
          tickets = tempList;
          filteredTickets = tickets;
        });
      }
    } else if (response.statusCode == 400) {
      setState(() {
        isLoading = false;
        notFound = true;
      });
    }

    return response;
  }
}
