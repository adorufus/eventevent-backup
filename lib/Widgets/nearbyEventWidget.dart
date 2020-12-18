import 'dart:async';
import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ClevertapHandler.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventevent/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

var session;
List nearbyEventData;

class ListenPage extends StatefulWidget {
  final isRest;

  const ListenPage({Key key, this.isRest}) : super(key: key);
  @override
  _ListenPageState createState() => _ListenPageState();
}

class _ListenPageState extends State<ListenPage> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  Location location = new Location();

  LocationData currentLocation;
  StreamSubscription<LocationData> locationSubcription;
  String err;
  int newPage = 0;
  Address adresses;
  var fullAddr;

  getPlace() async {}

  @override
  void initState() {
    super.initState();
    //ClevertapHandler.logPageView("Nearby");
    initPlatformState();
    location.onLocationChanged().listen((LocationData result) async {
      if (!mounted) return;
      setState(() {
        currentLocation = result;
        getAddress(currentLocation.latitude, currentLocation.longitude);
      });
      print(currentLocation.heading);
    });

    if (!mounted) {
      return;
    } else {
      fetchCurrentLocationEvent().then((response) {
        if (response.statusCode == 200) {
          if (mounted)
            setState(() {
              var extractedData = json.decode(response.body);
              nearbyEventData = extractedData['data'];
              nearbyEventData.removeWhere((item) =>
                  item['ticket_type']['type'] == 'free_limited_seating' ||
                  item['ticket_type']['type'] == 'paid_seating' ||
                  item['ticket_type']['type'] == 'paid_seating');
            });

          print(nearbyEventData);
        }
      });
    }
    //getLocationName();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    fetchCurrentLocationEvent(page: newPage).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          List updatedData = extractedData['data'];
          print('data: ' + updatedData.toString());
          nearbyEventData.addAll(updatedData);
          nearbyEventData.removeWhere((item) =>
              item['ticket_type']['type'] == 'free_limited_seating' ||
              item['ticket_type']['type'] == 'paid_seating' ||
              item['ticket_type']['type'] == 'paid_seating');
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      }
    });
  }

  getAddress(double lat, double long) async {
    print(lat);
    print(long);
    final coord = new Coordinates(-6.1799679, 106.7101003);
    final getAdresses =
        await Geocoder.local.findAddressesFromCoordinates(coord);
    if (!mounted) return;
    setState(() {
      adresses = getAdresses.first;
    });

    print(adresses.featureName);

    // print('${adresses.addressLine}');
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
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: nearbyEventData == null
              ? HomeLoadingScreen().myTicketLoading()
              : SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  controller: refreshController,
                  onRefresh: () {
                    setState(() {
                      newPage = 0;
                    });
                    fetchCurrentLocationEvent().then((response) {
                      if (response.statusCode == 200) {
                        setState(() {
                          var extractedData = json.decode(response.body);
                          nearbyEventData = extractedData['data'];
                          nearbyEventData.removeWhere((item) =>
                              item['ticket_type']['type'] ==
                                  'free_limited_seating' ||
                              item['ticket_type']['type'] == 'paid_seating' ||
                              item['ticket_type']['type'] == 'paid_seating');
                        });
                        if (mounted) setState(() {});
                        refreshController.refreshCompleted();
                      }
                    });
                  },
                  onLoading: _onLoading,
                  child: ListView(children: <Widget>[
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      width: MediaQuery.of(context).size.width,
                      height: ScreenUtil.instance.setWidth(50),
                      decoration: BoxDecoration(color: Colors.white,
                          // borderRadius: BorderRadius.circular(15),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1.5)
                          ]),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(3)),
                                Container(
                                  height: ScreenUtil.instance.setWidth(20),
                                  width: ScreenUtil.instance.setWidth(20),
                                  child: Image.asset(
                                      'assets/icons/icon_apps/location.png'),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(9),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 71,
                              child: Text(
                                adresses == null ? '-' : adresses.addressLine,
                                style: TextStyle(
                                    fontSize: ScreenUtil.instance.setSp(12)),
                                maxLines: 2,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount:
                          nearbyEventData == null ? 0 : nearbyEventData.length,
                      itemBuilder: (BuildContext context, i) {
                        Color itemColor;
                        String itemPriceText;

                        if (nearbyEventData[i]['isGoing'] == '1') {
                          itemColor = Colors.blue;
                          itemPriceText = 'Going!';
                        } else {
                          if (nearbyEventData[i]['ticket_type']['type'] ==
                                  'paid' ||
                              nearbyEventData[i]['ticket_type']['type'] ==
                                  'paid_live_stream' ||
                              nearbyEventData[i]['ticket_type']['type'] ==
                                  'paid_seating') {
                            if (nearbyEventData[i]['ticket']
                                    ['availableTicketStatus'] ==
                                '1') {
                              itemColor = Color(0xFF34B323);
                              itemPriceText = 'Rp. ' +
                                  formatPrice(
                                    price: nearbyEventData[i]['ticket']
                                            ['cheapestTicket']
                                        .toString(),
                                  );
                            } else {
                              if (nearbyEventData[i]['ticket']['salesStatus'] ==
                                  'comingSoon') {
                                itemColor = Color(0xFF34B323).withOpacity(0.3);
                                itemPriceText = 'COMING SOON';
                              } else if (nearbyEventData[i]['ticket']
                                      ['salesStatus'] ==
                                  'endSales') {
                                itemColor = Color(0xFF8E1E2D);
                                if (nearbyEventData[i]['status'] == 'ended') {
                                  itemPriceText = 'EVENT HAS ENDED';
                                }
                                itemPriceText = 'SALES ENDED';
                              } else {
                                itemColor = Color(0xFF8E1E2D);
                                itemPriceText = 'SOLD OUT';
                              }
                            }
                          } else if (nearbyEventData[i]['ticket_type']
                                  ['type'] ==
                              'no_ticket') {
                            itemColor = Color(0xFF652D90);
                            itemPriceText = 'NO TICKET';
                          } else if (nearbyEventData[i]['ticket_type']
                                  ['type'] ==
                              'on_the_spot') {
                            itemColor = Color(0xFF652D90);
                            itemPriceText =
                                nearbyEventData[i]['ticket_type']['name'];
                          } else if (nearbyEventData[i]['ticket_type']
                                  ['type'] ==
                              'free') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText =
                                nearbyEventData[i]['ticket_type']['name'];
                          } else if (nearbyEventData[i]['ticket_type']
                                  ['type'] ==
                              'free') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText =
                                nearbyEventData[i]['ticket_type']['name'];
                          } else if (nearbyEventData[i]['ticket_type']
                                  ['type'] ==
                              'paid_live_stream') {
                            itemColor = Color(0xFF34B323);
                            itemPriceText = 'Rp. ' +
                                nearbyEventData[i]['ticket']['cheapestTicket'];
                          } else if (nearbyEventData[i]['ticket_type']
                                  ['type'] ==
                              'free_live_stream') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText = "free";
                          } else if (nearbyEventData[i]['ticket_type']
                                      ['type'] ==
                                  'free_limited' ||
                              nearbyEventData[i]['ticket_type']['type'] ==
                                  'free_limited_seating') {
                            if (nearbyEventData[i]['ticket']
                                    ['availableTicketStatus'] ==
                                '1') {
                              itemColor = Color(0xFFFFAA00);
                              itemPriceText =
                                  nearbyEventData[i]['ticket_type']['name'];
                            } else {
                              if (nearbyEventData[i]['ticket']['salesStatus'] ==
                                  'comingSoon') {
                                itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                                itemPriceText = 'COMING SOON';
                              } else if (nearbyEventData[i]['ticket']
                                      ['salesStatus'] ==
                                  'endSales') {
                                itemColor = Color(0xFF8E1E2D);
                                if (nearbyEventData[i]['status'] == 'ended') {
                                  itemPriceText = 'EVENT HAS ENDED';
                                }
                                itemPriceText = 'SALES ENDED';
                              } else {
                                itemColor = Color(0xFF8E1E2D);
                                itemPriceText = 'SOLD OUT';
                              }
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
                                            isRest: widget.isRest,
                                            eventId: nearbyEventData[i]
                                                ['id'])));
                          },
                          child: new LatestEventItem(
                            image: nearbyEventData[i]['picture_timeline'],
                            title: nearbyEventData[i]['name'],
                            location: nearbyEventData[i]['address'],
                            itemColor: itemColor,
                            itemPrice: itemPriceText,
                            date:
                                DateTime.parse(nearbyEventData[i]['dateStart']),
                            type: nearbyEventData[i]['ticket_type']['type'],
                            isAvailable: nearbyEventData[i]['ticket']
                                ['availableTicketStatus'],
                          ),
                        );
                      },
                    )
                  ])),
        ),
      ),
    );
  }

  void initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      currentLocation = await location.getLocation();
      err = "";
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        err = 'Permission Denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        err = 'Permission denied - please enable location service';
      }
      currentLocation = null;
    }
    setState(() {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        prefs.setString('latitude', currentLocation.latitude.toString());
        prefs.setString('longitude', currentLocation.longitude.toString());
      }
    });
  }

  Future<http.Response> fetchCurrentLocationEvent({int page}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int currentPage = 1;

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
        'cookie': preferences.getString('Session')
      };
    }

    print(preferences.getString('latitude'));
    print(preferences.getString('longitude'));
    setState(() {
      session = preferences.getString('Session');
      if (page != null) {
        currentPage += page;
      }
    });
    final fetchNearbyEventApi = baseUrl +
        '/event/nearby?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b&latitude=${preferences.getString('latitude')}&longitude=${preferences.getString('longitude')}&page=$currentPage';
    final response = await http.get(fetchNearbyEventApi, headers: headers);

    print(response.body);

    return response;
  }
}
