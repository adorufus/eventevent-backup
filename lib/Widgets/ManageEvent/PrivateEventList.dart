import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
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

class PrivateEventList extends StatefulWidget {
  final type;
  final userId;

  const PrivateEventList({Key key, this.type, this.userId}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PrivateEventListState();
  }
}

class PrivateEventListState extends State<PrivateEventList> {
  List privateData;
  String imageUri = '';
  bool isEmpty = false;
  int newPage = 0;
  RefreshController refreshController =
      new RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    fetchMyEvent().then((response) {
      print(response.statusCode);
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        print(response.body);
        if (extractedData['data']['private']['data'].length == 0) {
          setState(() {
            isEmpty = true;
          });
        } else {
          setState(() {
            isEmpty = false;
            privateData = extractedData['data']['private']['data'];
          });
        }
      } else {
        print(response.body);
      }
    });
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
          List updatedData = extractedData['data']['private']['data'];
          print('data: ' + updatedData.toString());
          privateData.addAll(updatedData);
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
            : privateData == null
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
                            privateData =
                                extractedData['data']['private']['data'];
                            assert(privateData != null);

                            print(privateData);

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
                          privateData.length == null ? '0' : privateData.length,
                      itemBuilder: (BuildContext context, i) {
                        if (privateData.length == null) {
                          return Container(
                            child: Center(
                              child: Text('No Data'),
                            ),
                          );
                        }
                        Color itemColor;
                        String itemPriceText;

                        if (privateData[i]['ticket_type']['type'] == 'paid' ||
                            privateData[i]['ticket_type']['type'] ==
                                'paid_seating') {
                          if (privateData[i]['ticket']
                                  ['availableTicketStatus'] ==
                              '1') {
                            itemColor = Color(0xFF34B323);
                            itemPriceText =
                                privateData[i]['ticket']['cheapestTicket'];
                          } else {
                            if (privateData[i]['ticket']['salesStatus'] ==
                                'comingSoon') {
                              itemColor = Color(0xFF34B323).withOpacity(0.3);
                              itemPriceText = 'COMING SOON';
                            } else if (privateData[i]['ticket']
                                    ['salesStatus'] ==
                                'endSales') {
                              itemColor = Color(0xFF8E1E2D);
                              if (privateData[i]['status'] == 'ended') {
                                itemPriceText = 'EVENT HAS ENDED';
                              }
                              itemPriceText = 'SALES ENDED';
                            } else {
                              itemColor = Color(0xFF8E1E2D);
                              itemPriceText = 'SOLD OUT';
                            }
                          }
                        } else if (privateData[i]['ticket_type']['type'] ==
                            'no_ticket') {
                          itemColor = Color(0xFF652D90);
                          itemPriceText = 'NO TICKET';
                        } else if (privateData[i]['ticket_type']['type'] ==
                            'on_the_spot') {
                          itemColor = Color(0xFF652D90);
                          itemPriceText = privateData[i]['ticket_type']['name'];
                        } else if (privateData[i]['ticket_type']['type'] ==
                            'free') {
                          itemColor = Color(0xFFFFAA00);
                          itemPriceText = privateData[i]['ticket_type']['name'];
                        } else if (privateData[i]['ticket_type']['type'] ==
                            'free') {
                          itemColor = Color(0xFFFFAA00);
                          itemPriceText = privateData[i]['ticket_type']['name'];
                        } else if (privateData[i]['ticket_type']['type'] ==
                                'free_limited' ||
                            privateData[i]['ticket_type']['type'] ==
                                'free_limited_seating') {
                          if (privateData[i]['ticket']
                                  ['availableTicketStatus'] ==
                              '1') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText =
                                privateData[i]['ticket_type']['name'];
                          } else {
                            if (privateData[i]['ticket']['salesStatus'] ==
                                'comingSoon') {
                              itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                              itemPriceText = 'COMING SOON';
                            } else if (privateData[i]['ticket']
                                    ['salesStatus'] ==
                                'endSales') {
                              itemColor = Color(0xFF8E1E2D);
                              if (privateData[i]['status'] == 'ended') {
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
                                        eventId: privateData[i]['id']),
                              ),
                            );
                          },
                          child: new LatestEventItem(
                            image: privateData[i]['picture'],
                            title: privateData[i]['name'],
                            location: privateData[i]['address'],
                            itemColor: itemColor,
                            itemPrice: itemPriceText,
                            type: privateData[i]['ticket_type']['type'],
                            date: DateTime.parse(privateData[i]['dateStart']),
                            isAvailable: privateData[i]['ticket']
                                ['availableTicketStatus'],
                          ),
                        );
                      },
                    ),
                  ));
  }

  Widget buttonType(int index) {
    if (privateData[index]['ticket_type']['id'] == '5' ||
        privateData[index]['ticket_type']['id'] == '10') {
      imageUri = 'assets/btn_ticket/free-limited.png';
    } else if (privateData[index]['ticket_type']['id'] == '1') {
      imageUri = 'assets/btn_ticket/free.png';
    } else if (privateData[index]['ticket_type']['id'] == '2') {
      imageUri = 'assets/btn_ticket/no-ticket.png';
    } else if (privateData[index]['ticket_type']['id'] == '3') {
      imageUri = 'assets/btn_ticket/ots-800px.png';
    } else if (privateData[index]['ticket_type']['id'] == '4') {
      imageUri = 'assets/btn_ticket/paid.png';
    }

    return SizedBox(
      height: ScreenUtil.instance.setWidth(50),
      width: ScreenUtil.instance.setWidth(150),
      child: Image.asset(
        imageUri,
        fit: BoxFit.fill,
      ),
    );
  }

  Future<http.Response> fetchMyEvent({int page}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (page != null) {
        currentPage += page;
      }
    });

    String uri = BaseApi().apiUrl +
        '/user/${widget.type}?X-API-KEY=$API_KEY&page=$currentPage&userID=${widget.userId == prefs.getString('Last User ID') ? prefs.getString('Last User ID') : widget.userId}&isPrivate=1';

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
