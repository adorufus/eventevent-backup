import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/RecycleableWidget/EmptyState.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PublicEventList extends StatefulWidget {
  final type;
  final userId;

  const PublicEventList({Key key, this.type, this.userId}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PublicEventListState();
  }
}

class PublicEventListState extends State<PublicEventList> {
  List publicData;
  String imageUri;
  int newPage;
  bool isEmpty = false;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    fetchMyEvent().then((response) {
      print(response.statusCode);
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (extractedData['data']['public']['data'].length == 0) {
          print(response.body);
          setState(() {
            isEmpty = true;
          });
        } else {
          isEmpty = false;
          print(response.body);
          setState(() {
            publicData = extractedData['data']['public']['data'];
          });
        }
      } else {
        isEmpty = true;
      }
    });
    print('user id: ' + widget.userId);
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    fetchMyEvent(page: newPage).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          List updatedData = extractedData['data']['public']['data'];
          print('data: ' + updatedData.toString());
          publicData.addAll(updatedData);
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
    return Container(
      width: MediaQuery.of(context).size.width,
      child: isEmpty == true
          ? EmptyState(
              emptyImage: 'assets/drawable/event_empty_state.png',
              reasonText: 'You Have No Event Created Yet',
            )
          : publicData == null
              ? Container(
                  child: Center(
                  child: CupertinoActivityIndicator(radius: 20),
                ))
              : SmartRefresher(
                  controller: refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onLoading: _onLoading,
                  onRefresh: () {
                    setState(() {
                      newPage = 0;
                    });

                    fetchMyEvent().then((response) {
                      if (response.statusCode == 200) {
                        setState(() {
                          var extractedData = json.decode(response.body);
                          publicData = extractedData['data']['public']['data'];
                          assert(publicData != null);

                          print(publicData);

                          return extractedData;
                        });
                      }
                    });

                    if (mounted) setState(() {});
                    refreshController.refreshCompleted();
                  },
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
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        publicData.length == null ? '0' : publicData.length,
                    itemBuilder: (BuildContext context, i) {
                      if (publicData.length == null) {
                        return Container(
                          child: Center(
                            child: Text('No Data'),
                          ),
                        );
                      }
                      Color itemColor;
                      String itemPriceText;

                      if (publicData[i]['ticket_type']['type'] == 'paid' ||
                          publicData[i]['ticket_type']['type'] ==
                              'paid_seating' ||
                          publicData[i]['ticket_type']['type'] ==
                              'paid_live_stream') {
                        if (publicData[i]['ticket']['availableTicketStatus'] ==
                            '1') {
                          itemColor = Color(0xFF34B323);
                          itemPriceText =
                              publicData[i]['ticket']['cheapestTicket'];
                        } else {
                          if (publicData[i]['ticket']['salesStatus'] ==
                              'comingSoon') {
                            itemColor = Color(0xFF34B323).withOpacity(0.3);
                            itemPriceText = 'COMING SOON';
                          } else if (publicData[i]['ticket']['salesStatus'] ==
                              'endSales') {
                            itemColor = Color(0xFF8E1E2D);
                            if (publicData[i]['status'] == 'ended') {
                              itemPriceText = 'EVENT HAS ENDED';
                            }
                            itemPriceText = 'SALES ENDED';
                          } else {
                            itemColor = Color(0xFF8E1E2D);
                            itemPriceText = 'SOLD OUT';
                          }
                        }
                      } else if (publicData[i]['ticket_type']['type'] ==
                          'no_ticket') {
                        itemColor = Color(0xFF652D90);
                        itemPriceText = 'NO TICKET';
                      } else if (publicData[i]['ticket_type']['type'] ==
                          'on_the_spot') {
                        itemColor = Color(0xFF652D90);
                        itemPriceText = publicData[i]['ticket_type']['name'];
                      } else if (publicData[i]['ticket_type']['type'] ==
                          'free') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText = publicData[i]['ticket_type']['name'];
                      } else if (publicData[i]['ticket_type']['type'] ==
                          'free') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText = publicData[i]['ticket_type']['name'];
                      } else if (publicData[i]['ticket_type']['type'] ==
                          'free_live_stream') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText = publicData[i]['ticket_type']['name'];
                      } else if (publicData[i]['ticket_type']['type'] ==
                              'free_limited' ||
                          publicData[i]['ticket_type']['type'] ==
                              'free_limited_seating') {
                        if (publicData[i]['ticket']['availableTicketStatus'] ==
                            '1') {
                          itemColor = Color(0xFFFFAA00);
                          itemPriceText = publicData[i]['ticket_type']['name'];
                        } else {
                          if (publicData[i]['ticket']['salesStatus'] ==
                              'comingSoon') {
                            itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                            itemPriceText = 'COMING SOON';
                          } else if (publicData[i]['ticket']['salesStatus'] ==
                              'endSales') {
                            itemColor = Color(0xFF8E1E2D);
                            if (publicData[i]['status'] == 'ended') {
                              itemPriceText = 'EVENT HAS ENDED';
                            }
                            itemPriceText = 'SALES ENDED';
                          } else {
                            itemColor = Color(0xFF8E1E2D);
                            itemPriceText = 'SOLD OUT';
                          }
                        }
                      }

                      print(itemColor);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EventDetailsConstructView(
                                          id: publicData[i]['eventID'])));
                        },
                        child: new LatestEventItem(
                          image: publicData[i]['picture'],
                          title: publicData[i]['name'],
                          location: publicData[i]['address'],
                          itemColor: itemColor,
                          itemPrice: itemPriceText,
                          date: DateTime.parse(publicData[i]['dateStart']),
                          type: publicData[i]['ticket_type']['type'],
                          isAvailable: publicData[i]['ticket']
                              ['availableTicketStatus'],
                        ),
                      );
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (BuildContext context) =>
                      //             EventDetailsConstructView(
                      //               id: publicData[i]['id'],
                      //             )));
                      //   },
                      //   child: Container(
                      //     color: Colors.white,
                      //     padding: EdgeInsets.symmetric(
                      //         horizontal: 10, vertical: 10),
                      //     width: MediaQuery.of(context).size.width,
                      //     height: ScreenUtil.instance.setWidth(300),
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: <Widget>[
                      //         Row(
                      //           mainAxisAlignment: MainAxisAlignment.start,
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: <Widget>[
                      //             SizedBox(
                      //               width: ScreenUtil.instance.setWidth(150),
                      //               child: Image.network(
                      //                   publicData[i]['picture'],
                      //                   fit: BoxFit.fill),
                      //             ),
                      //             SizedBox(width: ScreenUtil.instance.setWidth(20)),
                      //             Column(
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment.start,
                      //               children: <Widget>[
                      //                 Text(
                      //                   publicData[i]['dateStart'],
                      //                   style:
                      //                       TextStyle(color: eventajaGreenTeal),
                      //                 ),
                      //                 SizedBox(
                      //                   height: ScreenUtil.instance.setWidth(20),
                      //                 ),
                      //                 Text(
                      //                   publicData[i]['name'],
                      //                   style: TextStyle(
                      //                       color: Colors.black54,
                      //                       fontWeight: FontWeight.bold,
                      //                       fontSize: ScreenUtil.instance.setSp(20)),
                      //                 ),
                      //                 SizedBox(
                      //                   height: ScreenUtil.instance.setWidth(20),
                      //                 ),
                      //                 Text(
                      //                   publicData[i]['isPrivate'] == '0'
                      //                       ? 'PUBLIC EVENT'
                      //                       : 'PRIVATE EVENT',
                      //                   style: TextStyle(fontSize: ScreenUtil.instance.setSp(18)),
                      //                 ),
                      //                 SizedBox(
                      //                   height: ScreenUtil.instance.setWidth(50),
                      //                 ),
                      //                 buttonType(i)
                      //               ],
                      //             )
                      //           ],
                      //         ),
                      //         SizedBox(height: ScreenUtil.instance.setWidth(20)),
                      //         Divider()
                      //       ],
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ),
    );
  }

  Widget buttonType(int index) {
    if (publicData[index]['ticket_type']['id'] == '5' ||
        publicData[index]['ticket_type']['id'] == '10') {
      imageUri = 'assets/btn_ticket/free-limited.png';
    } else if (publicData[index]['ticket_type']['id'] == '1') {
      imageUri = 'assets/btn_ticket/free.png';
    } else if (publicData[index]['ticket_type']['id'] == '2') {
      imageUri = 'assets/btn_ticket/no-ticket.png';
    } else if (publicData[index]['ticket_type']['id'] == '3') {
      imageUri = 'assets/btn_ticket/ots-800px.png';
    }

    return SizedBox(
      height: ScreenUtil.instance.setWidth(50),
      width: ScreenUtil.instance.setWidth(100),
      child: Image.asset(imageUri),
    );
  }

  Future fetchMyEvent({int page}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (page != null) {
        currentPage += page;
      }
    });

    print(prefs.getString('Last User ID'));
    String uri = BaseApi().apiUrl +
        '/user/${widget.type}?X-API-KEY=$API_KEY&page=$currentPage&userID=${widget.userId == prefs.getString('Last User ID') ? prefs.getString('Last User ID') : widget.userId}&isPrivate=0';

    print(uri);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': prefs.getString('Session')
      },
    );

    return response;
  }
}
