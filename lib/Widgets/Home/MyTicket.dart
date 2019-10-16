import 'dart:convert';

import 'package:eventevent/Widgets/Home/See%20All/MyTicketItem.dart';
import 'package:eventevent/Widgets/ProfileWidget/UseTicket.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
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

  bool notFound;

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
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        _searchText = "";
        filteredTickets = myTicketList;
      } else {
        _searchText = searchController.text;
      }
    });

    return SafeArea(
          child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(null, 100),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 65,
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
              title: Container(
                width: 280,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1.5)
                    ]),
                height: 32.95,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  child: TextFormField(
                    controller: searchController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (value) {
                      if (value != null) {
                        _getTickets();
                      }
                    },
                    style: TextStyle(fontSize: 12),
                    autofocus: true,
                    autocorrect: false,
                    decoration: InputDecoration(
                        prefixIcon: Image.asset(
                          'assets/icons/icon_apps/search.png',
                          scale: 4.5,
                          color: Color(0xFF81818B),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                        hintText: 'Search',
                        hintStyle: TextStyle(fontSize: 12),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide:
                                BorderSide(color: Color.fromRGBO(0, 0, 0, 0))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide:
                                BorderSide(color: Color.fromRGBO(0, 0, 0, 0)))),
                  ),
                ),
              ),
              centerTitle: false,
              textTheme: TextTheme(
                  title: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              )),
            ),
          ),
        ),
        body: Container(
          child: 
          // myTicketList == null
          //     ? Center(
          //         child: Container(
          //           width: 25,
          //           height: 25,
          //           child: FittedBox(
          //             fit: BoxFit.fill,
          //             child: CircularProgressIndicator(),
          //           ),
          //         ),
          //       )
          //     : 
              SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("Load data");
                    } else if (mode == LoadStatus.loading) {
                      body = CircularProgressIndicator();
                    } else if (mode == LoadStatus.failed) {
                      body = Text("Load Failed!");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text('More');
                    } else {
                      body = Container();
                    }

                    return Container(height: 35, child: Center(child: body));
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
                  child: notFound == true
                      ? Container(child: Center(child: Text('Ticket Not Found')))
                      : ListView.builder(
                      itemCount:
                          myTicketList == null ? 0 : myTicketList.length,
                      itemBuilder: (BuildContext context, i) {
                        Color ticketColor;
                        String ticketStatusText;

                        if (myTicketList[i]['usedStatus'] == 'available') {
                          ticketColor = eventajaGreenTeal;
                          ticketStatusText = 'Available';
                        } else if (myTicketList[i]['usedStatus'] == 'used') {
                          ticketColor = Color(0xFFA6A8AB);
                          ticketStatusText = 'Used';
                        } else if (myTicketList[i]['usedStatus'] ==
                            'expired') {
                          ticketColor = Color(0xFF8E1E2D);
                          ticketStatusText = 'Expired';
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        UseTicket(
                                          ticketTitle: myTicketList[i]
                                              ['ticket']['ticket_name'],
                                          ticketImage: myTicketList[i]
                                              ['ticket_image']['url'],
                                          ticketCode: myTicketList[i]
                                              ['ticket_code'],
                                          ticketDate: myTicketList[i]['event']
                                              ['dateStart'],
                                          ticketStartTime: myTicketList[i]
                                              ['event']['timeStart'],
                                          ticketEndTime: myTicketList[i]
                                              ['event']['timeEnd'],
                                          ticketDesc: myTicketList[i]['event']
                                              ['name'],
                                          ticketID: myTicketList[i]['id'],
                                          usedStatus:
                                              ticketStatusText.toUpperCase(),
                                        )));
                          },
                          child: Container(
                            child: new MyTicketItem(
                              image: myTicketList[i]['ticket_image']
                                  ['secure_url'],
                              title: myTicketList[i]['event']['name'],
                              ticketCode: myTicketList[i]['ticket_code'],
                              ticketStatus: ticketStatusText,
                              timeStart: myTicketList[i]['event']
                                  ['timeStart'],
                              timeEnd: myTicketList[i]['event']['timeEnd'],
                              ticketName: myTicketList[i]['ticket']
                                  ['ticket_name'],
                              ticketColor: ticketColor,
                              // topPadding: i == 0 ? 13.0 : 0.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildTicketList() {
    if (!(_searchText.isEmpty)) {
      List tempList = new List();
      for (int i = 0; i < filteredTickets.length; i++) {
        if (filteredTickets[i]['name'].toString()
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredTickets[i]);
        }
      }
      filteredTickets = tempList;

      return ListView.builder(
        itemCount: tickets == null ? 0 : filteredTickets.length,
        itemBuilder: (BuildContext context, i) {
          Color ticketColor;
          String ticketStatusText;

          if (filteredTickets[i]['usedStatus'] == 'available') {
            ticketColor = eventajaGreenTeal;
            ticketStatusText = 'Available';
          } else if (filteredTickets[i]['usedStatus'] == 'used') {
            ticketColor = Color(0xFFA6A8AB);
            ticketStatusText = 'Used';
          } else if (filteredTickets[i]['usedStatus'] == 'expired') {
            ticketColor = Color(0xFF8E1E2D);
            ticketStatusText = 'Expired';
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => UseTicket(
                            ticketTitle: filteredTickets[i]['ticket']
                                ['ticket_name'],
                            ticketImage: filteredTickets[i]['ticket_image']
                                ['url'],
                            ticketCode: filteredTickets[i]['ticket_code'],
                            ticketDate: filteredTickets[i]['event']
                                ['dateStart'],
                            ticketStartTime: filteredTickets[i]['event']
                                ['timeStart'],
                            ticketEndTime: filteredTickets[i]['event']
                                ['timeEnd'],
                            ticketDesc: filteredTickets[i]['event']['name'],
                            ticketID: filteredTickets[i]['id'],
                            usedStatus: ticketStatusText.toUpperCase(),
                          )));
            },
            child: Container(
              child: new MyTicketItem(
                image: filteredTickets[i]['ticket_image']['secure_url'],
                title: filteredTickets[i]['event']['name'],
                ticketCode: filteredTickets[i]['ticket_code'],
                ticketStatus: ticketStatusText,
                timeStart: filteredTickets[i]['event']['timeStart'],
                timeEnd: filteredTickets[i]['event']['timeEnd'],
                ticketName: filteredTickets[i]['ticket']['ticket_name'],
                ticketColor: ticketColor,
                // topPadding: i == 0 ? 13.0 : 0.0,
              ),
            ),
          );
        },
      );
    }

    // return ListView.builder(
    //   itemCount: filteredTickets == null ? 0 : filteredTickets.length,
    //   itemBuilder: (BuildContext context, i) {
    //     Color ticketColor;
    //     String ticketStatusText;

    //     if (filteredTickets[i]['usedStatus'] == 'available') {
    //       ticketColor = eventajaGreenTeal;
    //       ticketStatusText = 'Available';
    //     } else if (filteredTickets[i]['usedStatus'] == 'used') {
    //       ticketColor = Color(0xFFA6A8AB);
    //       ticketStatusText = 'Used';
    //     } else if (filteredTickets[i]['usedStatus'] == 'expired') {
    //       ticketColor = Color(0xFF8E1E2D);
    //       ticketStatusText = 'Expired';
    //     }

    //     return GestureDetector(
    //       onTap: () {
    //         Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //                 builder: (BuildContext context) => UseTicket(
    //                       ticketTitle: filteredTickets[i]['ticket']
    //                           ['ticket_name'],
    //                       ticketImage: filteredTickets[i]['ticket_image']
    //                           ['url'],
    //                       ticketCode: filteredTickets[i]['ticket_code'],
    //                       ticketDate: filteredTickets[i]['event']['dateStart'],
    //                       ticketStartTime: filteredTickets[i]['event']
    //                           ['timeStart'],
    //                       ticketEndTime: filteredTickets[i]['event']['timeEnd'],
    //                       ticketDesc: filteredTickets[i]['event']['name'],
    //                       ticketID: filteredTickets[i]['id'],
    //                       usedStatus: ticketStatusText.toUpperCase(),
    //                     )));
    //       },
    //       child: Container(
    //         child: new MyTicketItem(
    //           image: filteredTickets[i]['ticket_image']['secure_url'],
    //           title: filteredTickets[i]['event']['name'],
    //           ticketCode: filteredTickets[i]['ticket_code'],
    //           ticketStatus: ticketStatusText,
    //           timeStart: filteredTickets[i]['event']['timeStart'],
    //           timeEnd: filteredTickets[i]['event']['timeEnd'],
    //           ticketName: filteredTickets[i]['ticket']['ticket_name'],
    //           ticketColor: ticketColor,
    //           // topPadding: i == 0 ? 13.0 : 0.0,
    //         ),
    //       ),
    //     );
    //   },
    // );
  }

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

    return response;
  }

  Future<http.Response> getMyTicket({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
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
        notFound = false;
      });
      for (int i = 0; i < resultData.length; i++) {
        tempList.add(resultData[i]);
      }

      setState(() {
        tickets = tempList;
        filteredTickets = tickets;
      });
    } else if (response.statusCode == 400) {
      setState(() {
        notFound = true;
      });
    }

    return response;
  }
}
