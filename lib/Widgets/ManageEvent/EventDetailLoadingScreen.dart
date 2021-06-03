import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/LoveItem.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class EventDetailLoadingScreen extends StatefulWidget {
  final eventId;
  final isRest;

  const EventDetailLoadingScreen({Key key, this.eventId, this.isRest = false})
      : super(key: key);

  @override
  _EventDetailLoadingScreenState createState() =>
      _EventDetailLoadingScreenState();
}

class _EventDetailLoadingScreenState extends State<EventDetailLoadingScreen> {
  Map<String, dynamic> detailData;

  Map<String, dynamic> ticketType = Map<String, dynamic>();
  Map<String, dynamic> ticketStat = Map<String, dynamic>();
  List goingData = [];
  DateTime _dDay;
  DateTime eventStartDate;
  String dateTime = '-';
  String month = '-';
  Color itemColor = Colors.red;

  String creatorFullName = "";
  String creatorName = "";
  String creatorImageUri = " ";
  String startTime = "";
  String endTime = "";
  String isGoing = "";
  String address = "";
  String lat = "";
  String long = "";
  String isPrivate = '0';
  String ticketTypeURI = "";
  String ticketPrice = "";
  String isLoved = "0";
  String email = 'assets/icons/btn_email.png';
  String phoneNumber = 'assets/icons/btn_phone.png';
  String website = 'assets/icons/btn_web.png';
  String loveBtn = 'assets/icons/btn_love_small.png';
  String eventID = "";
  int loveCount = 0;
  DateTime ticketStartDate;
  Map commentData;

  bool isTimeout = false;
  bool refresh = false;

  String errorReason = '';

  BranchContentMetaData metaData;
  BranchUniversalObject buo;
  BranchLinkProperties lp;
  BranchEvent eventStandard;
  BranchEvent eventCustom;

  void initDeepLinkData(String eventName, String imageUrl, String eventId) {
    setState(() {
      metaData = BranchContentMetaData()
          .addCustomMetadata('event_name', eventName)
          .addCustomMetadata('event_id', eventId)
          .addCustomMetadata('image_url', imageUrl);

      buo = BranchUniversalObject(
          canonicalIdentifier: 'event_$eventId',
          title: eventName,
          imageUrl: imageUrl,
          contentDescription: 'you can see the event description on the app',
          contentMetadata: metaData,
          publiclyIndex: true,
          keywords: [],
          locallyIndex: true);
    });

    print(buo);

    FlutterBranchSdk.registerView(buo: buo);
    FlutterBranchSdk.listOnSearch(buo: buo);

    lp = BranchLinkProperties(
      feature: "sharing",
    );

    lp.addControlParam(
        '\$desktop_url', 'http://eventevent.com/event/${widget.eventId}');
  }

  Future<http.Response> getEventDetailsSpecificInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String session = '';
    Map<String, String> headers;
    String baseUrl = BaseApi().apiUrl;

    setState(() {
      session = preferences.getString('Session');
      if (widget.isRest == true) {
        baseUrl = BaseApi().restUrl;
        headers = {'Authorization': AUTH_KEY, 'signature': SIGNATURE};
      } else if (widget.isRest == false) {
        baseUrl = BaseApi().apiUrl;
        headers = {'Authorization': AUTH_KEY, 'cookie': session};
      }
    });

    final detailsInfoUrl =
        baseUrl + '/event/detail?X-API-KEY=$API_KEY&eventID=${widget.eventId}';

    print(detailsInfoUrl);
    http.Response myResponse;

    try {
      final response = await http.get(detailsInfoUrl, headers: headers);
      print('event detail page -> ' + response.statusCode.toString());
      print('event detail page -> ' + response.body);

      myResponse = response;
      setState(() {});

      return response;
    } on SocketException catch (e) {
      print(e.message);
      errorReason = 'Sorry, looks like we lost the connection :(';
      isTimeout = true;
      setState(() {});
      return myResponse;
    } on HttpException catch (e) {
      print(e.message);
      errorReason = 'Something went wrong';
      isTimeout = true;
      setState(() {});
      return myResponse;
    } on SignalException catch (e) {
      errorReason = e.message;
      isTimeout = true;
      setState(() {});
      return myResponse;
    } on WebSocketException catch (e) {
      errorReason = e.message;
      isTimeout = true;
      setState(() {});
      return myResponse;
    }
  }

  void getDetail() {
    getEventDetailsSpecificInfo().then((response) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var extractedData = json.decode(response.body);
      if (response.statusCode.toString().startsWith('4') &&
          extractedData['desc'] == null &&
          extractedData['error'] == Null) {
        errorReason = 'Something is missing';
        isTimeout = true;
        setState(() {});
      } else {
        errorReason = 'Something went wrong';
        isTimeout = true;
        setState(() {});
      }

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          detailData = extractedData['data'];
          goingData = detailData['going']['data'];
          ticketType = extractedData['data']['ticket_type'];
          ticketStat = extractedData['data']['ticket'];
          creatorFullName = extractedData['data']['creatorFullName'];
          creatorName = extractedData['data']['creatorName'];
          creatorImageUri = extractedData['data']['creatorPhoto'];
          startTime = extractedData['data']['timeStart'];
          endTime = extractedData['data']['timeEnd'];
          isGoing = extractedData['data']['isGoing'];
          address = detailData['address'];
          lat = detailData['latitude'];
          long = detailData['longitude'];
          isPrivate = detailData['isPrivate'];
          isLoved = detailData['isLoved'];
          email = detailData['email'];
          phoneNumber = detailData['phone'];
          website = detailData['website'];
          eventID = detailData['id'];
          loveCount = int.parse(isLoved);

          initDeepLinkData(
              detailData['name'], detailData['photo'], detailData['id']);

          if (detailData['ticket']['sales_start_date'] == null) {
          } else {
            ticketStartDate =
                DateTime.parse(detailData['ticket']['sales_start_date']);
          }

          for (var data in detailData['comment']) {
            commentData = data;
          }

          print(commentData);

          // print(_dDay.toString());
          // setState((){
          //   if(detailData['status'] == 'active'){
          //     if(detailData['ticket_type']['type'] == 'free'){
          //       ticketTypeURI = 'assets/btn_ticket/free.png';
          //     }
          //     else if(detailData['ticket_type']['type'] == 'free_limited'){
          //       ticketTypeURI = 'assets/btn_ticket/free-limited.png';
          //     }
          //     else if(detailData['ticket_type']['type'] == 'on_the_spot'){
          //       ticketTypeURI = 'assets/btn_ticket/paid-value.png';
          //     }
          //     else if(detailData['ticket_type']['type'] == 'paid'){
          //       ticketTypeURI = 'assets/btn_ticket/paid-value.png';
          //     }
          //     else if(detailData['ticketTypeID'] == '2'){
          //       ticketTypeURI = 'assets/btn_ticket/paid-value.png';
          //     }
          //   }

          //   if(detailData['ticket_type']['type'] == 'no_ticket'){
          //       ticketTypeURI = 'assets/btn_ticket/paid-value.png';
          //     }
          // });

          print('type' + detailData['ticket_type'].toString());

          setState(() {
            _dDay = DateTime.parse(
                detailData['ticket']['sales_start_date'] == null
                    ? detailData['dateStart']
                    : detailData['ticket']['sales_start_date']);
            eventStartDate = DateTime.parse(detailData['dateStart']);

            switch (eventStartDate.month) {
              case 1:
                month = 'January';
                break;
              case 2:
                month = 'February';
                break;
              case 3:
                month = 'March';
                break;
              case 4:
                month = 'April';
                break;
              case 5:
                month = 'May';
                break;
              case 6:
                month = 'June';
                break;
              case 7:
                month = 'July';
                break;
              case 8:
                month = 'August';
                break;
              case 9:
                month = 'September';
                break;
              case 10:
                month = 'October';
                break;
              case 11:
                month = 'November';
                break;
              case 12:
                month = 'December';
                break;
            }

            dateTime = eventStartDate.day.toString() +
                ' ' +
                month +
                ' ' +
                eventStartDate.year.toString();
          });

          print('isGoing' + detailData['isGoing'].toString());

          if (detailData['isGoing'] == '1') {
            itemColor = Colors.blue;
            ticketPrice = 'Going!';
          } else if (detailData['status'] == 'canceled') {
            itemColor = Colors.red;
            ticketPrice = 'Canceled';
          }
          if (detailData['ticket']['salesStatus'] == 'endSales') {
            itemColor = Color(0xFF8E1E2D);
            if (detailData['status'] == 'ended') {
              ticketPrice = 'EVENT HAS ENDED';
            }
            ticketPrice = 'SALES ENDED';
          } else {
            if (detailData['ticket_type']['type'] == 'paid' ||
                detailData['ticket_type']['type'] == 'paid_seating') {
              if (detailData['ticket']['availableTicketStatus'] == '1') {
                if (detailData['ticket']['cheapestTicket'] == '0') {
                  itemColor = Color(0xFFFFAA00);
                  ticketPrice = 'Free Limited';
                } else {
                  itemColor = Color(0xFF34B323);
                  ticketPrice = 'Rp' +
                      formatPrice(
                        price:
                            detailData['ticket']['cheapestTicket'].toString(),
                      );
                }
              } else {
                if (detailData['ticket']['salesStatus'] == 'comingSoon') {
                  itemColor = Color(0xFF34B323).withOpacity(0.3);
                  ticketPrice = 'COMING SOON';
                } else if (detailData['ticket']['salesStatus'] == 'endSales') {
                  itemColor = Color(0xFF8E1E2D);
                  if (detailData['status'] == 'ended') {
                    ticketPrice = 'EVENT HAS ENDED';
                  }
                  ticketPrice = 'SALES ENDED';
                } else {
                  itemColor = Color(0xFF8E1E2D);
                  ticketPrice = 'SOLD OUT';
                }
              }
            } else if (detailData['ticket_type']['type'] == 'no_ticket') {
              itemColor = Color(0xFF652D90);
              ticketPrice = 'NO TICKET';
            } else if (detailData['ticket_type']['type'] == 'on_the_spot') {
              itemColor = Color(0xFF652D90);
              ticketPrice = detailData['ticket_type']['name'];
            } else if (detailData['ticket_type']['type'] == 'free') {
              itemColor = Color(0xFFFFAA00);
              ticketPrice = detailData['ticket_type']['name'];
            } else if (detailData['ticket_type']['type'] == 'free') {
              itemColor = Color(0xFFFFAA00);
              ticketPrice = detailData['ticket_type']['name'];
            } else if (detailData['ticket_type']['type'] ==
                'free_live_stream') {
              if (detailData['ticket']['salesStatus'] == 'endSales') {
                itemColor = Color(0xFF8E1E2D);
                if (detailData['status'] == 'ended') {
                  ticketPrice = 'EVENT HAS ENDED';
                }
                ticketPrice = 'SALES ENDED';
              }
              itemColor = Color(0xFFFFAA00);
              ticketPrice = "FREE";
            } else if (detailData['ticket_type']['type'] ==
                'paid_live_stream') {
              if (detailData['ticket']['salesStatus'] == 'endSales') {
                itemColor = Color(0xFF8E1E2D);
                if (detailData['status'] == 'ended') {
                  ticketPrice = 'EVENT HAS ENDED';
                }
                ticketPrice = 'SALES ENDED';
              }
              itemColor = Color(0xFF34B323);
              ticketPrice = 'Rp' +
                  formatPrice(
                    price: detailData['ticket']['cheapestTicket'].toString(),
                  );
            } else if (detailData['ticket_type']['type'] == 'free_limited') {
              if (detailData['ticket']['availableTicketStatus'] == '1') {
                itemColor = Color(0xFFFFAA00);
                ticketPrice = 'Free Limited';
              } else {
                if (detailData['ticket']['salesStatus'] == 'comingSoon') {
                  itemColor = Color(0xFF34B323).withOpacity(0.3);
                  ticketPrice = 'COMING SOON';
                } else if (detailData['ticket']['salesStatus'] == 'endSales') {
                  itemColor = Color(0xFF8E1E2D);
                  if (detailData['status'] == 'ended') {
                    ticketPrice = 'EVENT HAS ENDED';
                  }
                  ticketPrice = 'SALES ENDED';
                } else {
                  itemColor = Color(0xFFFFAA00);
                  ticketPrice = 'SOLD OUT';
                }
              }
            }
          }
        });
        preferences.setString('eventID', detailData['id']);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                settings: RouteSettings(isInitialRoute: true),
                builder: (context) => EventDetailsConstructView(
                      isRest: widget.isRest,
                      buo: buo,
                      commentData: commentData,
                      creatorFullName: creatorFullName,
                      creatorImageUri: creatorImageUri,
                      creatorName: creatorName,
                      dateTime: dateTime,
                      dDay: _dDay,
                      eventStartDate: eventStartDate,
                      detailData: detailData,
                      email: email,
                      endTime: endTime,
                      getEventDetailSpecificInfo: getEventDetailsSpecificInfo,
                      goingData: goingData,
                      id: widget.eventId,
                      isPrivate: isPrivate,
                      itemColor: itemColor,
                      lat: lat,
                      long: long,
                      lp: lp,
                      phoneNumber: phoneNumber,
                      startTime: startTime,
                      ticketPrice: ticketPrice,
                      ticketStat: ticketStat,
                      ticketType: ticketType,
                      website: website,
                    )));

        print(detailData['id']);
        print(loveCount);
        print(isPrivate);
        print(creatorFullName);
        print(creatorName);
        print(creatorImageUri);
        print(startTime);
        print(endTime);
        print(ticketTypeURI);
        print(ticketType['isSetupTicket']);
        print(ticketStat);
      }
    }).timeout(Duration(seconds: 15), onTimeout: () {
      setState(() {
        isTimeout = true;
        errorReason = 'Connection Timeout';
      });
    }).catchError((error) {
      print('Exception custom: $error');
    });
  }

  @override
  void initState() {
    getDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(null, 100),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil.instance.setWidth(75),
            padding: EdgeInsets.symmetric(horizontal: 13),
            child: AppBar(
              brightness: Brightness.light,
              elevation: 0,
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
            ),
          ),
        ),
        body: isTimeout == true
            ? EmptyState(
                imagePath: 'assets/icons/empty_state/error.png',
                isTimeout: true,
                reasonText: errorReason,
                refreshButtonCallback: () {
                  setState(() {
                    isTimeout = false;
                    getDetail();
                  });
                },
              )
            : Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 11, vertical: 13),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300],
                                highlightColor: Colors.grey[100],
                                enabled: true,
                                child: Container(
                                  width: ScreenUtil.instance
                                      .setWidth(122.86 * 1.3),
                                  height: ScreenUtil.instance
                                      .setWidth(184.06 * 1.3),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/grey-fade.jpg'),
                                          fit: BoxFit.fill)),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 13),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(30),
                                          width:
                                              ScreenUtil.instance.setWidth(30),
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey[300],
                                            highlightColor: Colors.grey[100],
                                            enabled: true,
                                            child: Container(
                                              height: ScreenUtil.instance
                                                  .setWidth(30),
                                              width: ScreenUtil.instance
                                                  .setWidth(30),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/grey-fade.jpg'))),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              ScreenUtil.instance.setWidth(5),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'loading',
                                              style: TextStyle(
                                                  fontSize: ScreenUtil.instance
                                                      .setSp(12),
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text('loading',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(11))),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Container(
                                        width:
                                            ScreenUtil.instance.setWidth(180),
                                        child: Text(
                                          'loading',
                                          style: TextStyle(
                                              fontSize:
                                                  ScreenUtil.instance.setSp(12),
                                              color: Colors.grey),
                                        )),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Container(
                                        height:
                                            ScreenUtil.instance.setWidth(35),
                                        width:
                                            ScreenUtil.instance.setWidth(180),
                                        child: Text(
                                          'loading',
                                          style: TextStyle(
                                              fontSize:
                                                  ScreenUtil.instance.setSp(15),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey),
                                        )),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(17)),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          width:
                                              ScreenUtil.instance.setWidth(10),
                                          height:
                                              ScreenUtil.instance.setWidth(12),
                                          child: Image.asset(
                                              'assets/icons/location-transparent.png',
                                              color: Colors.grey),
                                        ),
                                        SizedBox(
                                            width: ScreenUtil.instance
                                                .setWidth(5)),
                                        Text(
                                          'loading',
                                          style: TextStyle(
                                              fontSize: ScreenUtil.instance
                                                  .setSp(11)),
                                          maxLines: 1,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(5)),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          width:
                                              ScreenUtil.instance.setWidth(10),
                                          height:
                                              ScreenUtil.instance.setWidth(12),
                                          child: Image.asset(
                                            'assets/icons/btn_time_green.png',
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(
                                            width: ScreenUtil.instance
                                                .setWidth(5)),
                                        Text('loading',
                                            style: TextStyle(
                                                fontSize: ScreenUtil.instance
                                                    .setSp(11))),
                                      ],
                                    ),
                                    SizedBox(
                                      height: ScreenUtil.instance.setWidth(15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ScreenUtil.instance.setWidth(15)),
                        Container(
                          width: ScreenUtil.instance.setWidth(333.7),
                          height: ScreenUtil.instance.setWidth(59.1),
                          margin: EdgeInsets.symmetric(
                              horizontal: 13, vertical: 13),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: checkForContainerBackgroundColor(context),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 5,
                                    spreadRadius: 1.5,
                                    color: Color(0xff8a8a8b).withOpacity(.5))
                              ]),
                          child: Row(
                            children: <Widget>[
                              LoveItem(
                                isComment: false,
                                isAlreadyLoved: false,
                                loveCount: 0,
                              ),
                              SizedBox(
                                width: ScreenUtil.instance.setWidth(10),
                              ),
                              LoveItem(
                                  isComment: true,
                                  isAlreadyCommented: false,
                                  commentCount: ''),
                              Expanded(
                                child: SizedBox(),
                              ),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(33),
                                width: ScreenUtil.instance.setWidth(33),
                                child:
                                    Image.asset('assets/icons/btn_phone.png'),
                              ),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(33),
                                width: ScreenUtil.instance.setWidth(33),
                                child: Image.asset('assets/icons/btn_mail.png'),
                              ),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(33),
                                width: ScreenUtil.instance.setWidth(33),
                                child: Image.asset(
                                  'assets/icons/btn_web.png',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Container(
                            // margin: EdgeInsets.symmetric(
                            //     horizontal: 13, vertical: 13),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Who\'s Invited',
                                        style: TextStyle(
                                            color: Color(0xff8a8a8b),
                                            fontSize:
                                                ScreenUtil.instance.setSp(11)),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(10)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 13),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Who\'s Going',
                                      style: TextStyle(
                                          color: Color(0xff8a8a8b),
                                          fontSize:
                                              ScreenUtil.instance.setSp(11)),
                                    ),
                                    Expanded(
                                      child: SizedBox(),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: ScreenUtil.instance.setWidth(10)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(20),
                        ),
                        Container(),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(5),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 13, vertical: 13),
                          height: ScreenUtil.instance.setWidth(40),
                          decoration: BoxDecoration(
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Container(
                                  height: ScreenUtil.instance.setWidth(115),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      // Row(
                                      //   children: <Widget>[
                                      //     CircleAvatar(
                                      //       backgroundImage: ,
                                      //     )
                                      //   ],
                                      // )
                                      Text(
                                        'Detail',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      Divider(
                                        thickness: 2,
                                        color: Theme.of(context).dividerColor,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: ScreenUtil.instance.setWidth(112),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      // Row(
                                      //   children: <Widget>[
                                      //     CircleAvatar(
                                      //       backgroundImage: ,
                                      //     )
                                      //   ],
                                      // )
                                      Text(
                                        'Activity',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      Divider(
                                        thickness: 2,
                                        color: Theme.of(context).dividerColor,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  height: ScreenUtil.instance.setWidth(112),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      // Row(
                                      //   children: <Widget>[
                                      //     CircleAvatar(
                                      //       backgroundImage: ,
                                      //     )
                                      //   ],
                                      // )
                                      Text(
                                        'Comments',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      Divider(
                                        thickness: 2,
                                        color: Theme.of(context).dividerColor,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ));
  }
}
