import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/SeeAll/MyTicketItem.dart';

import 'package:eventevent/Widgets/ProfileWidget/UseTicket.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTicketWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyTicketWidgetState();
  }
}

class _MyTicketWidgetState extends State<MyTicketWidget> {
  var session;
  String userId;

  Map<String, dynamic> ticketData;
  Map<String, dynamic> publicData;

  List ticketDetailData = [];

  bool isLoading = false;
  bool isEmpty = false;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  int newPage = 0;

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    getDataTicket(newPage: newPage).then((response) {
      var extractedData = json.decode(response.body);

      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          print(isLoading);
          List updatedData = extractedData['data'];
          if (updatedData == null) {
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          ticketDetailData.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      } else {
        refreshController.loadFailed();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDataTicket().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (extractedData['desc'] == 'Ticket not found') {
          isEmpty = true;
          isLoading = false;
          if (mounted) setState(() {});
        } else {
          setState(() {
            isLoading = false;
            print(isLoading);

            ticketDetailData = extractedData['data'];
          });
        }
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
    return isLoading == true
        ? HomeLoadingScreen().myTicketLoading()
        : isEmpty
            ? EmptyState(
                imagePath: 'assets/drawable/my_ticket_empty_state.png',
                reasonText: 'You have no ticket :(',
              )
            : SmartRefresher(
                enablePullDown: false,
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
                onLoading: _onLoading,
                child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount:
                        ticketDetailData == null ? 0 : ticketDetailData.length,
                    itemBuilder: (BuildContext context, i) {
                      Color ticketColor;
                      String ticketStatusText;

                      if (ticketDetailData[i]['usedStatus'] == 'available') {
                        if (ticketDetailData[i].containsKey("livestream")) {
                          if (ticketDetailData[i]['livestream']
                                  ['streaming_type'] ==
                              "zoom") {
                            ticketColor = Colors.blue;
                            ticketStatusText = 'ZOOM';
                          } else if (ticketDetailData[i]['livestream']
                                  ['streaming_type'] ==
                              "wowza") {
                            ticketColor = eventajaGreenTeal;
                            ticketStatusText = 'Streaming';
                          } else if (ticketDetailData[i]['livestream']
                                      ['streaming_type'] ==
                                  "on demand" ||
                              ticketDetailData[i]['livestream']
                                      ['on_demand_link'] !=
                                  null ||
                              ticketDetailData[i]['livestream']
                                      ['on_demand_link'] !=
                                  "") {
                            ticketColor = eventajaGreenTeal;
                            ticketStatusText = 'On Demand Video';
                          }
                        } else {
                          ticketColor = eventajaGreenTeal;
                          ticketStatusText = 'Available';
                        }
                      } else if (ticketDetailData[i]['usedStatus'] == 'used') {
                        if (ticketDetailData[i].containsKey("livestream")) {
                          if (ticketDetailData[i]['livestream']
                                  ['streaming_type'] ==
                              "zoom") {
                            ticketColor = Colors.blue;
                            ticketStatusText = 'ZOOM';
                          } else if (ticketDetailData[i]['livestream']
                                      ['streaming_type'] ==
                                  null &&
                              ticketDetailData[i]['livestream']
                                      ['link_streaming'] !=
                                  null) {
                            //playback
                            ticketColor = eventajaGreenTeal;
                            ticketStatusText = 'Playback';
                          }
                        } else {
                          ticketColor = Color(0xFF652D90);
                          ticketStatusText = 'Used';
                        }
                      } else if (ticketDetailData[i]['usedStatus'] ==
                          'streaming') {
                        if (ticketDetailData[i].containsKey("livestream")) {
                          if (ticketDetailData[i]['livestream']
                                  ['streaming_type'] ==
                              "zoom") {
                            ticketColor = Colors.blue;
                            ticketStatusText = 'ZOOM';
                          } else if (ticketDetailData[i]['livestream']
                                  ['streaming_type'] ==
                              "wowza") {
                            ticketColor = eventajaGreenTeal;
                            ticketStatusText = 'Streaming';
                          } else if (ticketDetailData[i]['livestream']
                                      ['streaming_type'] ==
                                  "on demand" ||
                              ticketDetailData[i]['livestream']
                                      ['on_demand_link'] !=
                                  null ||
                              ticketDetailData[i]['livestream']
                                      ['on_demand_link'] !=
                                  "") {
                            ticketColor = eventajaGreenTeal;
                            ticketStatusText = 'On Demand Video';
                          }
                        }
                      } else if (ticketDetailData[i]['usedStatus'] ==
                          'playback') {
                        if (ticketDetailData[i].containsKey("livestream")) {
                          ticketColor = eventajaGreenTeal;
                          ticketStatusText = 'Playback';
                        }
                      } else if (ticketDetailData[i]['usedStatus'] ==
                          'expired') {
                        if (ticketDetailData[i].containsKey('livestream')) {
                          if (ticketDetailData[i]['livestream']
                                  ['streaming_type'] ==
                              "on demand") {
                            if (ticketDetailData[i]['livestream']
                                        ['on_demand_link'] !=
                                    null ||
                                ticketDetailData[i]['livestream']
                                        ['on_demand_link'] !=
                                    "") {
                              ticketColor = eventajaGreenTeal;
                              ticketStatusText = 'On Demand Video';
                            }

                            ticketColor = eventajaGreenTeal;
                            ticketStatusText = 'On Demand Video';
                          } else if (ticketDetailData[i]['livestream']
                                  ['streaming_type'] ==
                              'zoom') {
                            ticketColor = Color(0xFF8E1E2D);
                            ticketStatusText = 'ZOOM';
                          } else if (ticketDetailData[i]['livestream']
                                  ['streaming_type'] ==
                              'wowza') {
                            ticketColor = eventajaGreenTeal;
                            ticketStatusText = 'Playback';
                          } else if (ticketDetailData[i]['livestream']
                                  ['streaming_type'] ==
                              null) {
                            if (ticketDetailData[i]['livestream']
                                    ['link_streaming'] !=
                                null) {
                              ticketColor = eventajaGreenTeal;
                              ticketStatusText = 'Streaming';
                            }
                          }
                        } else {
                          ticketColor = Color(0xFF8E1E2D);
                          ticketStatusText = 'Expired';
                        }
                      } else if (ticketDetailData[i]['usedStatus'] ==
                          'refund') {
                        ticketColor = Colors.blue;
                        ticketStatusText = 'Refund';
                      }

                      // print('status text ' + ticketStatusText);

                      print(ticketDetailData[i]
                          .containsKey('ticket_image')
                          .toString());

                      print(ticketDetailData[i]['ticket_image'].runtimeType);

                      return GestureDetector(
                        onTap: () {
                          print('ticket status text: ' + ticketStatusText);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => UseTicket(
                                ticketDetail: ticketDetailData[i],
                                eventId: ticketDetailData[i]['event_id'],
                                ticketTitle: ticketDetailData[i]['ticket']
                                    ['ticket_name'],
                                ticketImage:
                                    ticketDetailData[i]['ticket_image'] == false
                                        ? 'assets/grey-fade.jpg'
                                        : ticketDetailData[i]['ticket_image']
                                            ['url'],
                                ticketCode: ticketDetailData[i]['ticket_code'],
                                ticketDate: ticketDetailData[i]['event']
                                    ['dateStart'],
                                ticketStartTime: ticketDetailData[i]['event']
                                    ['timeStart'],
                                ticketEndTime: ticketDetailData[i]['event']
                                    ['timeEnd'],
                                ticketDesc: ticketDetailData[i]['event']
                                    ['name'],
                                ticketID: ticketDetailData[i]['id'],
                                usedStatus: ticketStatusText,
                                zoomId: ticketDetailData[i]
                                        .containsKey("livestream")
                                    ? ticketDetailData[i]['livestream']
                                                ['zoom_id'] ==
                                            null
                                        ? ""
                                        : ticketDetailData[i]['livestream']
                                            ['zoom_id']
                                    : "",
                                zoomDesc: ticketDetailData[i]
                                        .containsKey("livestream")
                                    ? ticketDetailData[i]['livestream']
                                                ['zoom_description'] ==
                                            null
                                        ? ""
                                        : ticketDetailData[i]['livestream']
                                            ['zoom_description']
                                    : "",
                                livestreamUrl: ticketStatusText == 'On Demand Video'
                                    ? ticketDetailData[i].containsKey("livestream")
                                        ? ticketDetailData[i]['livestream']
                                                    ['on_demand_link'] ==
                                                ""
                                            ? ticketDetailData[i]['livestream']
                                                ['on_demand_embed']
                                            : ticketDetailData[i]['livestream']
                                                ['on_demand_link']
                                        : ''
                                    : !ticketDetailData[i].containsKey("livestream") ? '' : ticketStatusText == "Streaming" ||
                                            ticketStatusText ==
                                                'Watch Playback' ||
                                            ticketStatusText == 'Playback' ||
                                            ticketStatusText == 'Expired'
                                        ? !ticketDetailData[i].containsKey("livestream") ? '' : ticketDetailData[i]['livestream']
                                                    ['playback_url'] ==
                                                'not_available'
                                            ? ticketDetailData[i]['livestream']
                                                ['playback']
                                            : ticketDetailData[i]['livestream']
                                                ['playback_url']
                                        : '',
                              ),
                            ),
                          );
                        },
                        child: new MyTicketItem(
                          image: ticketDetailData[i]
                                          .containsKey('ticket_image')
                                          .toString() ==
                                      'false' ||
                                  ticketDetailData[i]['ticket_image'] == false
                              ? ''
                              : ticketDetailData[i]['ticket_image']
                                          .runtimeType
                                          .toString() ==
                                      'List<dynamic>'
                                  ? ticketDetailData[i]['event']
                                      ['pictureTimelinePath']
                                  : ticketDetailData[i]['ticket_image']
                                      ['secure_url'],
                          title: ticketDetailData[i]['event']['name'],
                          ticketCode: ticketDetailData[i]['ticket_code'],
                          ticketStatus: ticketStatusText,
                          timeStart: ticketDetailData[i]['event']['timeStart'],
                          timeEnd: ticketDetailData[i]['event']['timeEnd'],
                          date: DateTime.parse(
                              ticketDetailData[i]['event']['dateStart']),
                          ticketName: ticketDetailData[i]['ticket']
                              ['ticket_name'],
                          ticketColor: ticketColor,
                          // topPadding: i == 0 ? 13.0 : 0.0,
                        ),
                      );
                    }),
              );
  }

  Future<http.Response> getDataTicket({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int currentPage = 1;

    setState(() {
      isLoading = true;
      session = prefs.getString('Session');
      userId = prefs.getString('Last User ID');
      if (newPage != null) {
        currentPage += newPage;
      }

      print(currentPage);
    });

    var urlApi =
        BaseApi().apiUrl + '/tickets/all?X-API-KEY=$API_KEY&page=$currentPage';
    final response = await http.get(urlApi, headers: {
      'Authorization': 'Basic YWRtaW46MTIzNA==',
      'cookie': session
    });

    print(response.statusCode);
    print(response.body);

    return response;
  }
}
