import 'dart:convert';

import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    
    return SearchState();
  }
}

class SearchState extends State<Search> {
  TextEditingController searchController = new TextEditingController();

  final dio = new Dio();

  String _searchText = "";

  List events = new List();
  List profile = new List();

  List filteredEvents = new List();
  List filteredProfile = new List();

  bool notFound = false;

  @override
  Widget build(BuildContext context) {
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
                height: 75,
                child: Container(
                  color: Colors.white,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(13, 15, 13, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(width: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1.5
                            )
                          ]
                        ),
                        height: 32.95,
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
                                    var extractedData =
                                        json.decode(response.body);
                                    List resultData = extractedData['data'];
                                    List tempList = new List();

                                    if (response.statusCode == 200) {
                                      notFound = false;
                                      for (int i = 0;
                                          i < resultData.length;
                                          i++) {
                                        tempList.add(resultData[i]);
                                      }

                                      profile = tempList;
                                      filteredProfile = profile;
                                    } else if (response.statusCode == 400) {
                                      notFound = true;
                                    }
                                  });
                                }
                              },
                              style: TextStyle(fontSize: 12),
                              autofocus: true,
                              autocorrect: false,
                              decoration: InputDecoration(
                                  prefixIcon: Image.asset('assets/icons/icon_apps/search.png', scale: 4.5, color: Color(0xFF81818B),),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 15),
                                  hintText: 'Search',
                                  hintStyle: TextStyle(fontSize: 12),
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
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel', style: TextStyle(fontSize: 12, color: eventajaGreenTeal),))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Container(
              child: Column(
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
                              unselectedLabelColor: Colors.grey,
                              labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
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
                                      ? Container(child: Text('Not Found'))
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
      for (int i = 0; i < filteredEvents.length; i++) {
        if (filteredEvents[i]['name']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredEvents[i]);
        }
      }
      filteredEvents = tempList;

      return ListView.builder(
          itemCount: events == null ? 0 : filteredEvents.length,
          itemBuilder: (BuildContext context, i) {
            String priceImageUri;
            double opacityValue = 1;
            String salesStatus = '';

            if (filteredEvents[i]['status'] == 'active') {
              if (filteredEvents[i]['ticket']['salesStatus'] == 'soldOut' &&
                  filteredEvents[i]['ticket_type']['type'] == 'paid') {
                salesStatus = 'Sold Out';
                opacityValue = 0.5;
                priceImageUri = 'assets/btn_ticket/paid-value.png';
              } else if (filteredEvents[i]['ticket']['salesStatus'] ==
                      'available' &&
                  filteredEvents[i]['ticket_type']['type'] == 'paid') {
                opacityValue = 1;
                salesStatus = 'Available';
                priceImageUri = 'assets/btn_ticket/paid-value.png';
              } else if (filteredEvents[i]['ticket_type']['type'] ==
                  'no_ticket') {
                opacityValue = 1;
                priceImageUri = 'assets/btn_ticket/no-ticket.png';
              } else if (filteredEvents[i]['ticket_type']['type'] ==
                  'on_the_spot') {
                opacityValue = 1;
                priceImageUri = 'assets/btn_ticket/ots-800px.png';
              } else if (filteredEvents[i]['ticket_type']['type'] ==
                      'free_limited' &&
                  filteredEvents[i]['ticket']['salesStatus'] == 'soldOut') {
                salesStatus = 'Sold Out';
                opacityValue = 0.5;
                priceImageUri = 'assets/btn_ticket/free-limited.png';
              } else if (filteredEvents[i]['ticket_type']['type'] ==
                      'free_limited' &&
                  filteredEvents[i]['ticket']['salesStatus'] == 'available') {
                salesStatus = 'Available';
                opacityValue = 1;
                priceImageUri = 'assets/btn_ticket/free-limited.png';
              } else if (filteredEvents[i]['ticket_type']['type'] == 'free') {
                opacityValue = 1;
                priceImageUri = 'assets/btn_ticket/free.png';
              }
            } else if (filteredEvents[i]['status'] == 'canceled') {
              opacityValue = 1;
              priceImageUri = 'assets/btn_ticket/canceled.png';
            }
            if (filteredEvents[i]['status'] == 'ended') {
              opacityValue = 1;
              priceImageUri = 'assets/btn_ticket/event-ended.png';
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            EventDetailsConstructView(
                              id: filteredEvents[i]['id'],
                            )));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[300])),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(10),
                        height: 130,
                        width: 100,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                  filteredEvents[i]['picture'],
                                ),
                                fit: BoxFit.fill))),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 230,
                            child: Text(
                              filteredEvents[i]['name'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: 230,
                            child: Text(filteredEvents[i]['address'],
                                overflow: TextOverflow.ellipsis),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: 230,
                            child: Text(salesStatus,
                                overflow: TextOverflow.ellipsis),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                              width: 125,
                              height: 45,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  image: DecorationImage(
                                      colorFilter: ColorFilter.mode(
                                          Colors.black
                                              .withOpacity(opacityValue),
                                          BlendMode.dstATop),
                                      image: AssetImage(priceImageUri),
                                      fit: BoxFit.fill)),
                              child: Center(
                                child: Text(
                                    filteredEvents[i]['ticket_type']['type'] ==
                                            'paid'
                                        ? filteredEvents[i]['status'] == 'ended' ? '' : 'Rp. ' +
                                            filteredEvents[i]['ticket']
                                                ['cheapestTicket']
                                        : '',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ))
                        ])
                  ],
                ),
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
      for (int i = 0; i < filteredProfile.length; i++) {
        if (filteredProfile[i]['username']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredProfile[i]);
        }
      }
      filteredProfile = tempList;
    }

    return ListView.builder(
      itemCount: filteredProfile == null ? 0 : filteredProfile.length,
      itemBuilder: (BuildContext context, i) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300])),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(filteredProfile[i]['photo']),
                  backgroundColor: Colors.grey,
                ),
                SizedBox(width: 20),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 150,
                        child: Text(
                          filteredProfile[i]['fullName'] == null
                              ? filteredProfile[i]['username']
                              : filteredProfile[i]['fullName'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: 150,
                        child: Text(filteredProfile[i]['username'],
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ]),
                SizedBox(
                    height: 40,
                    width: 100,
                    child: Image.asset(
                      'assets/icons/btn_follow.png',
                      fit: BoxFit.fill,
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  Future<http.Response> _getProfile() async {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/event/search?X-API-KEY=$API_KEY&event=${searchController.text}&page=1';

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
        notFound = true;
      });
    }
  }
}
