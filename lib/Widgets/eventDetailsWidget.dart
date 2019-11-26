import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/Widgets/LoveItem.dart';
import 'package:eventevent/Widgets/ManageEvent/EditEvent.dart';
import 'package:eventevent/Widgets/ManageEvent/EventStatistic.dart';
import 'package:eventevent/Widgets/ManageEvent/ManageTicket.dart';
import 'package:eventevent/Widgets/ManageEvent/ShowQr.dart';
import 'package:eventevent/Widgets/ManageEvent/TicketSales.dart';
import 'package:eventevent/Widgets/Transaction/SelectTicket.dart';
import 'package:eventevent/Widgets/Transaction/SuccesPage.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/static_map_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_branch_io_plugin/flutter_branch_io_plugin.dart';
import 'dart:ui';
import 'package:marquee/marquee.dart';
//import 'package:eventevent/helper/MarqueeWidget.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_android_lifecycle/flutter_android_lifecycle.dart';

class EventDetailsConstructView extends StatefulWidget {
  final Map<String, dynamic> eventDetailsData;
  final String id;
  final String name;
  final String image;
  EventDetailsConstructView(
      {Key key, this.eventDetailsData, this.id, this.name, this.image})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventDetailsConstructViewState();
  }
}

class _EventDetailsConstructViewState extends State<EventDetailsConstructView>
    with AutomaticKeepAliveClientMixin<EventDetailsConstructView> {
  ScrollController _scrollController = new ScrollController();
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
  String currentUserId = "";

  int loveCount = 0;
  int loveClickedCount = 0;

  bool ticketPriceStringVisibility;
  bool isTicketUnavailable;
  bool isLoveClicked = false;

  Map<String, dynamic> detailData;
  Map<String, dynamic> invitedData = Map<String, dynamic>();
  Map<String, dynamic> ticketType = Map<String, dynamic>();
  Map<String, dynamic> ticketStat = Map<String, dynamic>();
  List goingData = [];
  List invitedUserList = [];

  Timer _timer;
  DateTime _currentTime;
  DateTime _dDay;

  Color itemColor = Colors.red;

  var session;

  String _data = '-';
  String generatedLink = '-';
  String error = '-';
  String defaultTab = '0';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //testGetData();
    try {
      setUpBranch();
    } catch (error) {
      setState(() {
        this.error = error.toString();
      });
      print("Branch Error ${error.toString()}");
    }

    branchIoInit();

    getEventDetailsSpecificInfo();
    getInvitedUser();
    getData();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), _onTimeChange);
  }

  void setUpBranch() {
    FlutterBranchIoPlugin.setupBranchIO();

    FlutterBranchIoPlugin.listenToDeepLinkStream().listen((string) {
      print("DEEPLINK $string");
      setState(() {
        this._data = string;
      });
    });

    FlutterAndroidLifecycle.listenToOnStartStream().listen((string) {
      print("ONSTART");
      FlutterBranchIoPlugin.setupBranchIO();
    });

    FlutterBranchIoPlugin.listenToGeneratedLinkStream().listen((link) {
      print('GET LINK IN FLUTTER');
      print('thelink' + link);
      setState(() {
        this.generatedLink = link;

        print('thisgeneratedlink: ' + generatedLink);
      });
    });

    FlutterBranchIoPlugin.generateLink(
        FlutterBranchUniversalObject()
            .setCanonicalIdentifier('event_' + widget.id)
            .setTitle(widget.name)
            .setContentDescription('')
            .setContentImageUrl(widget.image)
            .setContentIndexingMode(BUO_CONTENT_INDEX_MODE.PUBLIC)
            .setLocalIndexMode(BUO_CONTENT_INDEX_MODE.PUBLIC),
        lpFeature: 'sharing',
        lpControlParams: {
          '\$desktop_url': 'http://eventevent.com/event/${widget.id}'
        });
  }

  Future branchIoInit() async {
    String url = 'https://api2.branch.io/v1/url';

    var body = json.encode({
      'branch_key': 'key_live_ijCwqgMyqksKHN0YEnvjJiocuzi2ciR4',
      'feature': 'sharing',
      'data': {
        "\$canonical_identifier": "event_${widget.id}",
        "\$og_title": "",
        "\$og_image_url": widget.image,
        "\$desktop_url": "http://eventevent.com/event/${widget.id}",
      }
    });

    final response = await http
        .post(url, body: body, headers: {'Content-Type': 'application/json'});

    print(response.statusCode);
    print(response.body);

    var extractedData = json.decode(response.body);

    setState(() {
      generatedLink = extractedData['url'];
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onTimeChange(Timer timer) {
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      currentUserId = prefs.getString('Last User ID');
    });
  }

  saveId(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('NEW_EVENT_ID', eventId);
    print(prefs.getString('NEW_EVENT_ID'));
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
    return detailData == null
        ? Container(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(null, 100),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil.instance.setWidth(75),
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
                  actions: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString(
                            'EVENT_VIEWED', detailData['countView']);
                        prefs.setString('EVENT_LOVED', detailData['countLove']);
                        prefs.setString('EVENT_NAME', detailData['name']);

                        print(prefs.getString('EVENT_VIEWED'));
                        print(prefs.getString('EVENT_LOVED'));
                        print(prefs.getString('EVENT_NAME'));

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                EventStatistic()));
                      },
                      child: detailData['createdByID'] == null
                          ? Container(
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : detailData['createdByID'] != currentUserId
                              ? Container()
                              : Icon(
                                  Icons.insert_chart,
                                  color: eventajaGreenTeal,
                                  size: 30,
                                ),
                    ),
                    SizedBox(width: ScreenUtil.instance.setWidth(8)),
                    Icon(
                      Icons.person_add,
                      color: eventajaGreenTeal,
                      size: 30,
                    ),
                    SizedBox(width: ScreenUtil.instance.setWidth(8)),
                    GestureDetector(
                      onTap: () {
                        ShareExtend.share(generatedLink, 'text');
                      },
                      child: Icon(
                        Icons.share,
                        color: eventajaGreenTeal,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: ScreenUtil.instance.setWidth(8)),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();

                                        List<String> categoryList =
                                            new List<String>();
                                        List<String> categoryIdList =
                                            new List<String>();
                                        for (var i = 0;
                                            i <
                                                detailData['category']['data']
                                                    .length;
                                            i++) {
                                          print(i.toString());
                                          categoryList.add(
                                              detailData['category']['data'][i]
                                                  ['name']);
                                          categoryIdList.add(
                                              detailData['category']['data'][i]
                                                  ['id']);
                                        }

                                        prefs.setString(
                                            'NEW_EVENT_ID', detailData['id']);
                                        prefs.setString(
                                            'EVENT_NAME', detailData['name']);
                                        prefs.setString('EVENT_TYPE',
                                            detailData['isPrivate']);
                                        prefs.setStringList(
                                            'EVENT_CATEGORY', categoryList);
                                        prefs.setStringList(
                                            'EVENT_CATEGORY_ID_LIST',
                                            categoryIdList);
                                        prefs.setString('DATE_START',
                                            detailData['dateStart']);
                                        prefs.setString(
                                            'DATE_END', detailData['dateEnd']);
                                        prefs.setString('TIME_START',
                                            detailData['timeStart']);
                                        prefs.setString(
                                            'TIME_END', detailData['timeEnd']);
                                        prefs.setString('EVENT_DESCRIPTION',
                                            detailData['description']);
                                        prefs.setString(
                                            'EVENT_PHONE', detailData['phone']);
                                        prefs.setString(
                                            'EVENT_EMAIL', detailData['email']);
                                        prefs.setString('EVENT_WEBSITE',
                                            detailData['website']);
                                        prefs.setString('EVENT_LAT',
                                            detailData['latitude']);
                                        prefs.setString('EVENT_LONG',
                                            detailData['longitude']);
                                        prefs.setString('EVENT_ADDRESS',
                                            detailData['address']);
                                        prefs.setString('EVENT_IMAGE',
                                            detailData['photoFull']);

                                        print(prefs
                                            .getStringList('EVENT_CATEGORY')
                                            .toString());

                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        EditEvent()));
                                      },
                                      child: Text('Edit Event'),
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: eventajaGreenTeal,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: detailData == null
                ? Container(child: Center(child: CircularProgressIndicator()))
                // :
                : Container(
                    color: Colors.white,
                    child: ListView(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 13, vertical: 13),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: ScreenUtil.instance.setWidth(122.86),
                                height: ScreenUtil.instance.setWidth(184.06),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                        image: detailData['photo'] == null
                                            ? AssetImage('assets/grey-fade.jpg')
                                            : NetworkImage(detailData['photo']),
                                        fit: BoxFit.fill)),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: 13),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              height: ScreenUtil.instance
                                                  .setWidth(30),
                                              width: ScreenUtil.instance
                                                  .setWidth(30),
                                              child: Container(
                                                height: ScreenUtil.instance
                                                    .setWidth(30),
                                                width: ScreenUtil.instance
                                                    .setWidth(30),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            creatorImageUri
                                                                .toString()))),
                                              ),
                                            ),
                                            SizedBox(
                                              width: ScreenUtil.instance
                                                  .setWidth(5),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  creatorFullName == null
                                                      ? 'loading'
                                                      : creatorFullName
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil
                                                          .instance
                                                          .setSp(12),
                                                      color: eventajaGreenTeal,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                    creatorName == null
                                                        ? 'loading'
                                                        : creatorName
                                                            .toString(),
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
                                            height: ScreenUtil.instance
                                                .setWidth(10)),
                                        Container(
                                            height: ScreenUtil.instance
                                                .setWidth(35),
                                            width: ScreenUtil.instance
                                                .setWidth(180),
                                            child: Text(
                                              detailData['name'] == null
                                                  ? '-'
                                                  : detailData['name']
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                  fontSize: ScreenUtil.instance
                                                      .setSp(15),
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            )),
                                        SizedBox(
                                            height: ScreenUtil.instance
                                                .setWidth(17)),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              width: ScreenUtil.instance
                                                  .setWidth(10),
                                              height: ScreenUtil.instance
                                                  .setWidth(12),
                                              child: Image.asset(
                                                  'assets/icons/location-transparent.png'),
                                            ),
                                            SizedBox(
                                                width: ScreenUtil.instance
                                                    .setWidth(5)),
                                            detailData['address']
                                                        .toString()
                                                        .length <
                                                    50
                                                ? Text(
                                                    detailData['address'],
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil
                                                            .instance
                                                            .setSp(11)),
                                                    maxLines: 1,
                                                  )
                                                : Container(
                                                    height: ScreenUtil.instance
                                                        .setWidth(16),
                                                    width: ScreenUtil.instance
                                                        .setWidth(170),
                                                    child: MarqueeWidget(
                                                      text: detailData[
                                                                  'address'] ==
                                                              null
                                                          ? '-'
                                                          : detailData[
                                                              'address'],
                                                      scrollAxis:
                                                          Axis.horizontal,
                                                      textStyle: TextStyle(
                                                          fontSize: ScreenUtil
                                                              .instance
                                                              .setSp(11)),
                                                      ratioOfBlankToScreen: .1,
                                                    ),
                                                  )
                                          ],
                                        ),
                                        SizedBox(
                                            height: ScreenUtil.instance
                                                .setWidth(5)),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              width: ScreenUtil.instance
                                                  .setWidth(10),
                                              height: ScreenUtil.instance
                                                  .setWidth(12),
                                              child: Image.asset(
                                                  'assets/icons/btn_time_green.png'),
                                            ),
                                            SizedBox(
                                                width: ScreenUtil.instance
                                                    .setWidth(5)),
                                            Text(
                                                startTime.toString() +
                                                    ' to ' +
                                                    endTime.toString(),
                                                style: TextStyle(
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(11))),
                                          ],
                                        ),
                                        SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(15),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (ticketStat['salesStatus'] ==
                                                null) {
                                            } else if (ticketType['type'] ==
                                                'free') {
                                              showCupertinoDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          SuccessPage());
                                            } else if (ticketType['type'] ==
                                                'no_ticket') {
                                              print('no ticket');
                                              showDialog(
                                                  context: context,
                                                  child:
                                                      new CupertinoAlertDialog(
                                                    title: new Text(
                                                        "Dialog Title"),
                                                    content: new Text(
                                                        "This is my content"),
                                                    actions: <Widget>[
                                                      CupertinoDialogAction(
                                                        isDefaultAction: true,
                                                        child: Text("Yes"),
                                                      ),
                                                      CupertinoDialogAction(
                                                        child: Text("No"),
                                                      )
                                                    ],
                                                  ));
                                            } else {
                                              if (ticketStat['salesStatus'] ==
                                                      'endSales' ||
                                                  ticketStat[
                                                          'availableTicketStatus'] ==
                                                      '0') {
                                                return;
                                              } else {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            SelectTicketWidget(
                                                              eventID:
                                                                  detailData[
                                                                      'id'],
                                                              eventDate:
                                                                  detailData[
                                                                      'dateStart'],
                                                            )));
                                              }
                                            }
                                          },
                                          child: Container(
                                            height: ScreenUtil.instance
                                                .setWidth(28),
                                            width: ScreenUtil.instance
                                                .setWidth(133),
                                            decoration: BoxDecoration(
                                                boxShadow: <BoxShadow>[
                                                  BoxShadow(
                                                      color: itemColor
                                                          .withOpacity(0.4),
                                                      blurRadius: 2,
                                                      spreadRadius: 1.5)
                                                ],
                                                color: itemColor,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Center(
                                                child: Text(
                                              ticketPrice,
                                              // type == 'paid' ||
                                              //         type == 'paid_seating'
                                              //     ? isAvailable == '1'
                                              //         ? 'Rp. ' +
                                              //             itemPrice.toUpperCase() +
                                              //             ',-'
                                              //         : itemPrice.toUpperCase()
                                              //     : itemPrice.toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ScreenUtil.instance
                                                      .setSp(10),
                                                  fontWeight: FontWeight.bold),
                                            )),
                                          ),
                                        ),
                                      ])),
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
                              color: Colors.white,
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
                                loveCount: detailData['countLove'],
                              ),
                              SizedBox(
                                width: ScreenUtil.instance.setWidth(10),
                              ),
                              LoveItem(
                                  isComment: true,
                                  commentCount:
                                      detailData['total_comment'].toString()),
                              Expanded(
                                child: SizedBox(),
                              ),
                              GestureDetector(
                                onTap: phoneNumber == null || phoneNumber == ""
                                    ? () {}
                                    : () =>
                                        launch("tel:" + phoneNumber.toString()),
                                child: SizedBox(
                                  height: ScreenUtil.instance.setWidth(33),
                                  width: ScreenUtil.instance.setWidth(33),
                                  child: Image.asset(phoneNumber == null ||
                                          phoneNumber == ""
                                      ? 'assets/icons/btn_phone.png'
                                      : 'assets/icons/btn_phone_active.png'),
                                ),
                              ),
                              GestureDetector(
                                onTap: email == null || email == ""
                                    ? () {}
                                    : () =>
                                        launch("mailto:" + email.toString()),
                                child: SizedBox(
                                  height: ScreenUtil.instance.setWidth(33),
                                  width: ScreenUtil.instance.setWidth(33),
                                  child: Image.asset(
                                      email == null || email == ""
                                          ? 'assets/icons/btn_mail.png'
                                          : 'assets/icons/btn_mail_active.png'),
                                ),
                              ),
                              GestureDetector(
                                onTap: website == null || website == ""
                                    ? () {}
                                    : () => launch(website.toString()),
                                child: SizedBox(
                                  height: ScreenUtil.instance.setWidth(33),
                                  width: ScreenUtil.instance.setWidth(33),
                                  child: Image.asset(
                                    website == null || website == ""
                                        ? 'assets/icons/btn_web.png'
                                        : 'assets/icons/btn_web_active.png',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(20),
                        ),
                        isPrivate == "0"
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(left: 13),
                                child: Container(
                                  // margin: EdgeInsets.symmetric(
                                  //     horizontal: 13, vertical: 13),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Who\'s Invited',
                                        style: TextStyle(
                                            color: Color(0xff8a8a8b),
                                            fontSize:
                                                ScreenUtil.instance.setSp(11)),
                                      ),
                                      SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(10)),
                                      invitedUserList.length == 0
                                          ? Container()
                                          : Container(
                                              height: ScreenUtil.instance
                                                  .setWidth(30),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: invitedUserList ==
                                                        null
                                                    ? 0
                                                    : invitedUserList.length,
                                                itemBuilder:
                                                    (BuildContext context, i) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxHeight:
                                                                  ScreenUtil
                                                                      .instance
                                                                      .setWidth(
                                                                          30),
                                                              maxWidth:
                                                                  ScreenUtil
                                                                      .instance
                                                                      .setWidth(
                                                                          30),
                                                              minHeight:
                                                                  ScreenUtil
                                                                      .instance
                                                                      .setWidth(
                                                                          30),
                                                              minWidth:
                                                                  ScreenUtil
                                                                      .instance
                                                                      .setWidth(
                                                                          30)),
                                                      height: ScreenUtil
                                                          .instance
                                                          .setWidth(30),
                                                      width: ScreenUtil.instance
                                                          .setWidth(30),
                                                      decoration: BoxDecoration(
                                                          boxShadow: <
                                                              BoxShadow>[
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black,
                                                                blurRadius: 8,
                                                                offset: Offset(
                                                                    1.0, 1.0))
                                                          ],
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: invitedUserList[
                                                                              i]
                                                                          [
                                                                          'photo'] ==
                                                                      null
                                                                  ? AssetImage(
                                                                      'assets/grey-fade.jpg')
                                                                  : NetworkImage(
                                                                      invitedUserList[
                                                                              i]
                                                                          [
                                                                          'photo']),
                                                              fit:
                                                                  BoxFit.fill)),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                              ),
                        detailData['ticket']['salesStatus'] == 'comingSoon'
                            ? countdownTimer()
                            : Container(),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 13, vertical: 13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Who\'s Going',
                                style: TextStyle(
                                    color: Color(0xff8a8a8b),
                                    fontSize: ScreenUtil.instance.setSp(11)),
                              ),
                              SizedBox(
                                  height: ScreenUtil.instance.setWidth(10)),
                              Container(
                                height: ScreenUtil.instance.setWidth(50),
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      goingData == null ? 0 : goingData.length,
                                  itemBuilder: (BuildContext context, i) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (BuildContext
                                                        context) =>
                                                    ProfileWidget(
                                                      initialIndex: 0,
                                                      userId:
                                                          detailData['going']
                                                                  ['data'][i]
                                                              ['id']['id'],
                                                    )));
                                      },
                                      child: new Container(
                                        padding: i == 0
                                            ? EdgeInsets.only(left: 13)
                                            : EdgeInsets.only(left: 13),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              height: ScreenUtil.instance
                                                  .setWidth(30),
                                              width: ScreenUtil.instance
                                                  .setWidth(30),
                                              decoration: BoxDecoration(
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        offset:
                                                            Offset(1.0, 1.0),
                                                        blurRadius: 3)
                                                  ],
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            detailData['going']
                                                                    ['data'][i]
                                                                ['photo']),
                                                    fit: BoxFit.fill,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(20),
                        ),
                        detailData['createdByID'] != currentUserId
                            ? Container()
                            : Container(
                                width: ScreenUtil.instance.setWidth(333.7),
                                height: ScreenUtil.instance.setWidth(95.4),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                margin: EdgeInsets.symmetric(horizontal: 13),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 5,
                                        spreadRadius: 1.5,
                                        color:
                                            Color(0xff8a8a8b).withOpacity(.5))
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        saveId(detailData['id']);
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ManageTicket(
                                                          eventID:
                                                              detailData['id'],
                                                        )));
                                      },
                                      child: SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(100),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                                height: ScreenUtil.instance
                                                    .setWidth(20.9),
                                                // width: ScreenUtil.instance
                                                //     .setWidth(30),
                                                child: Image.asset(
                                                    'assets/icons/icon_apps/ticket.png',
                                                    fit: BoxFit.fill)),
                                            SizedBox(
                                              height: ScreenUtil.instance
                                                  .setWidth(15),
                                            ),
                                            Text(
                                              'MANAGE TICKET',
                                              style: TextStyle(
                                                  color: Color(0xff404041),
                                                  fontSize: ScreenUtil.instance
                                                      .setSp(10)),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setString(
                                            'NEW_EVENT_ID', detailData['id']);
                                        prefs.setString('QR_URI',
                                            detailData['qrcode']['secure_url']);
                                        prefs.setString(
                                            'EVENT_NAME', detailData['name']);
                                        print(prefs.getString('NEW_EVENT_ID'));
                                        print(prefs.getString('QR_URI'));
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ShowQr()));
                                      },
                                      child: SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(100),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                                width: ScreenUtil.instance
                                                    .setWidth(20.9),
                                                child: Image.asset(
                                                  'assets/icons/icon_apps/qr.png',
                                                  fit: BoxFit.fill,
                                                )),
                                            SizedBox(
                                              height: ScreenUtil.instance
                                                  .setWidth(15),
                                            ),
                                            Text('SHOW QR CODE',
                                                style: TextStyle(
                                                    color: Color(0xff404041),
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(10)))
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (BuildContext
                                                        context) =>
                                                    TicketSales(
                                                      eventID: detailData['id'],
                                                      eventName:
                                                          detailData['name'],
                                                    )));
                                      },
                                      child: SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(100),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                                width: ScreenUtil.instance
                                                    .setWidth(20.9),
                                                child: Image.asset(
                                                    'assets/icons/icon_apps/wallet.png',
                                                    fit: BoxFit.fill)),
                                            SizedBox(
                                              height: ScreenUtil.instance
                                                  .setWidth(12),
                                            ),
                                            Text('TICKET SALES',
                                                style: TextStyle(
                                                    color: Color(0xff404041),
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(10)))
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(5),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 13, vertical: 13),
                          height: ScreenUtil.instance.setWidth(35),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        thickness: 2,
                                        color: eventajaGreenTeal,
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
                                        'Activty',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        thickness: 2,
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
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        thickness: 2,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          color: Color(0xff8a8a8b).withOpacity(.05),
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 13),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 13),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 5,
                                          spreadRadius: 1.5,
                                          color:
                                              Color(0xff8a8a8b).withOpacity(.2))
                                    ],
                                    color: Colors.white),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      detailData['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              ScreenUtil.instance.setSp(18)),
                                    ),
                                    SizedBox(
                                      height: ScreenUtil.instance.setWidth(
                                          detailData['additional'].length == 0
                                              ? 0
                                              : 29),
                                    ),
                                    detailData['additional'].length == 0
                                        ? Container()
                                        : Container(
                                            height: ScreenUtil.instance
                                                .setWidth(206),
                                            width: ScreenUtil.instance
                                                .setWidth(206),
                                            decoration: BoxDecoration(
                                                color: Color(0xff8a8a8b),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        detailData['additional']
                                                                [0][
                                                            'posterPathThumb']),
                                                    fit: BoxFit.cover),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                    SizedBox(
                                      height: ScreenUtil.instance.setWidth(29),
                                    ),
                                    Text(detailData['description'])
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(18),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 13),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 5,
                                          spreadRadius: 1.5,
                                          color:
                                              Color(0xff8a8a8b).withOpacity(.2))
                                    ],
                                    color: Colors.white),
                                child: Column(
                                  children: <Widget>[
                                    Container(child: Text('Lokasi terdaftar')),
                                    showMap()
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )));
  }

  Widget customAppbar() {
    return Container(
        height: ScreenUtil.instance.setWidth(65),
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil.instance.setWidth(250),
                color: Colors.grey,
              ),
            ),
            Positioned(
              top: 16,
              left: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                  GestureDetector(
                      child: Icon(
                    Icons.person_add,
                    size: 30,
                    color: Colors.white,
                  )),
                  SizedBox(
                    width: ScreenUtil.instance.setWidth(20),
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil.instance.setWidth(20),
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }

  static BorderSide createBorderSide(BuildContext context,
      {Color color, double width = 0.0}) {
    assert(width != null);
    return BorderSide(
      color: color ?? Theme.of(context).dividerColor,
      width: width,
    );
  }

  Widget bannerDetails() {
    return Expanded(
      child: NotificationListener(
        onNotification: (t) {
          if (t is ScrollUpdateNotification) {
//            print(_scrollController.position.pixels);
            _scrollController.offset.clamp(0, 355);
            // if (_scrollController.position.pixels <= 355.0) {

            // }
          }
        },
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            Text(generatedLink + _data),
            Stack(children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / .5,
                padding: EdgeInsets.only(top: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        height: ScreenUtil.instance.setWidth(230),
                        width: ScreenUtil.instance.setWidth(500),
                        decoration: BoxDecoration(color: Colors.white
                            // image: DecorationImage(
                            //     image: detailData['photoFull'] == null
                            //         ? AssetImage('assets/grey-fade.jpg')
                            //         : NetworkImage(detailData['photoFull']),
                            //     fit: BoxFit.cover)
                            ),
                        child: BackdropFilter(
                          filter: new ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.0)),
                          ),
                        )),
                    SizedBox(
                      height: ScreenUtil.instance.setWidth(40),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(50),
                            width: ScreenUtil.instance.setWidth(170),
                            child: Row(
                              children: <Widget>[
                                Stack(children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isLoveClicked = true;
                                        print(isLoveClicked.toString());
                                        if (isLoveClicked == true &&
                                            loveClickedCount == 0) {
                                          loveClickedCount = 1;
                                          loveBtn =
                                              "assets/icons/btn_loved_value.png";
                                          loveCount += 1;
                                          isLoved = loveCount.toString();
                                          print(isLoved);
                                        } else if (isLoveClicked == true &&
                                            loveClickedCount == 1) {
                                          loveClickedCount = 0;
                                          loveBtn =
                                              "assets/icons/btn_love_small.png";
                                          loveCount -= 1;
                                          isLoved = loveCount.toString();
                                          print('you dislike this event ' +
                                              isLoved);
                                        }
                                      });
                                    },
                                    child: SizedBox(
                                      height: loveBtn ==
                                              'assets/icons/btn_loved_value.png'
                                          ? 50
                                          : 50,
                                      width: loveBtn ==
                                              'assets/icons/btn_loved_value.png'
                                          ? 100
                                          : 50,
                                      child: Image.asset(loveBtn),
                                    ),
                                  ),
                                  Positioned(
                                    top: 16,
                                    left: 60,
                                    child: Text(isLoved,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  )
                                ]),
                                SizedBox(
                                  height: ScreenUtil.instance.setWidth(50),
                                  width: ScreenUtil.instance.setWidth(50),
                                  child:
                                      Image.asset('assets/icons/btn_chat.png'),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: phoneNumber == null || phoneNumber == ""
                                ? () {}
                                : () => launch("tel:" + phoneNumber.toString()),
                            child: SizedBox(
                              height: ScreenUtil.instance.setWidth(50),
                              width: ScreenUtil.instance.setWidth(50),
                              child: Image.asset(
                                  phoneNumber == null || phoneNumber == ""
                                      ? 'assets/icons/btn_phone.png'
                                      : 'assets/icons/btn_phone_active.png'),
                            ),
                          ),
                          GestureDetector(
                            onTap: email == null || email == ""
                                ? () {}
                                : () => launch("mailto:" + email.toString()),
                            child: SizedBox(
                              height: ScreenUtil.instance.setWidth(50),
                              width: ScreenUtil.instance.setWidth(50),
                              child: Image.asset(email == null || email == ""
                                  ? 'assets/icons/btn_mail.png'
                                  : 'assets/icons/btn_mail_active.png'),
                            ),
                          ),
                          GestureDetector(
                            onTap: website == null || website == ""
                                ? () {}
                                : () => launch(website.toString()),
                            child: SizedBox(
                              height: ScreenUtil.instance.setWidth(50),
                              width: ScreenUtil.instance.setWidth(50),
                              child: Image.asset(
                                  website == null || website == ""
                                      ? 'assets/icons/btn_web.png'
                                      : 'assets/icons/btn_web_active.png'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil.instance.setWidth(20),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(
                        color: Colors.black,
                      ),
                    ),
                    detailData['createdByID'] != currentUserId
                        ? Container()
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: ScreenUtil.instance.setWidth(150),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    saveId(detailData['id']);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ManageTicket(
                                                  eventID: detailData['id'],
                                                )));
                                  },
                                  child: SizedBox(
                                    height: ScreenUtil.instance.setWidth(100),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                            height: ScreenUtil.instance
                                                .setWidth(30),
                                            width: ScreenUtil.instance
                                                .setWidth(30),
                                            child: Image.asset(
                                                'assets/icons/btn_manage_ticket.png',
                                                fit: BoxFit.fill)),
                                        SizedBox(
                                          width:
                                              ScreenUtil.instance.setWidth(20),
                                        ),
                                        Text(
                                          'MANAGE TICKET',
                                          style: TextStyle(
                                              fontSize: ScreenUtil.instance
                                                  .setSp(10)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(10)),
                                Container(
                                  width: 0,
                                  height: ScreenUtil.instance.setWidth(100),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: createBorderSide(context,
                                              color: Colors.black))),
                                ),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(10)),
                                GestureDetector(
                                  onTap: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setString(
                                        'NEW_EVENT_ID', detailData['id']);
                                    prefs.setString('QR_URI',
                                        detailData['qrcode']['secure_url']);
                                    prefs.setString(
                                        'EVENT_NAME', detailData['name']);
                                    print(prefs.getString('NEW_EVENT_ID'));
                                    print(prefs.getString('QR_URI'));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ShowQr()));
                                  },
                                  child: SizedBox(
                                    height: ScreenUtil.instance.setWidth(100),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                            height: ScreenUtil.instance
                                                .setWidth(30),
                                            width: ScreenUtil.instance
                                                .setWidth(30),
                                            child: Image.asset(
                                              'assets/icons/btn_show_qr.png',
                                              fit: BoxFit.fill,
                                            )),
                                        SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(20),
                                        ),
                                        Text('SHOW QR CODE',
                                            style: TextStyle(
                                                fontSize: ScreenUtil.instance
                                                    .setSp(10)))
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(10)),
                                Container(
                                  width: 0,
                                  height: ScreenUtil.instance.setWidth(100),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: createBorderSide(context,
                                              color: Colors.black))),
                                ),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(10)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                TicketSales(
                                                  eventID: detailData['id'],
                                                  eventName: detailData['name'],
                                                )));
                                  },
                                  child: SizedBox(
                                    height: ScreenUtil.instance.setWidth(100),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                            height: ScreenUtil.instance
                                                .setWidth(30),
                                            width: ScreenUtil.instance
                                                .setWidth(30),
                                            child: Image.asset(
                                                'assets/icons/btn_ticket_sales.png',
                                                fit: BoxFit.fill)),
                                        SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(20),
                                        ),
                                        Text('TICKET SALES',
                                            style: TextStyle(
                                                fontSize: ScreenUtil.instance
                                                    .setSp(10)))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                    DefaultTabController(
                      length: 3,
                      initialIndex: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TabBar(
                            unselectedLabelColor: Colors.grey,
                            tabs: <Widget>[
                              Tab(text: 'DETAILS'),
                              Tab(
                                text: 'ACTIVITY',
                              ),
                              Tab(
                                text: 'COMMENT',
                              )
                            ],
                          ),
                          Container(
                            color: Colors.grey.withOpacity(0.2),
                            padding: EdgeInsets.only(top: 10),
                            height: MediaQuery.of(context).size.height,
                            child: TabBarView(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, bottom: 13),
                                  child: ListView(
                                    children: <Widget>[
                                      Text('EVENT'),
                                      SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10),
                                      ),
                                      Text(
                                        detailData['name'] == null
                                            ? '-'
                                            : detailData['name'],
                                        style: TextStyle(
                                            color: eventajaGreenTeal,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10),
                                      ),
                                      Divider(
                                        color: Colors.black26,
                                        height:
                                            ScreenUtil.instance.setWidth(10),
                                      ),
                                      SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10),
                                      ),
                                      Text(detailData['description'] == null
                                          ? '-'
                                          : detailData['description']),
                                      SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10),
                                      ),
                                      Divider(
                                        color: Colors.black26,
                                        height:
                                            ScreenUtil.instance.setWidth(10),
                                      ),
                                      SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: ScreenUtil.instance
                                                .setWidth(20),
                                            width: ScreenUtil.instance
                                                .setWidth(20),
                                            child: Image.asset(
                                                'assets/icons/location-transparent.png'),
                                          ),
                                          Text('ADDRESS',
                                              style: TextStyle(
                                                  color: eventajaGreenTeal,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Text(address == null
                                          ? 'address'
                                          : address),
                                      showMap()
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Text('ACTIVITY'),
                                ),
                                Text('this is comment section')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                left: 26,
                child: isPrivate == '0'
                    ? Container()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(20),
                            width: ScreenUtil.instance.setWidth(10),
                            child: Image.asset('assets/icons/btn_gembok.png'),
                          ),
                          SizedBox(
                            width: ScreenUtil.instance.setWidth(5),
                          ),
                          Text('Private Event',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil.instance.setSp(12))),
                        ],
                      ),
              ),
              Positioned(
                top: 36,
                left: 26,
                child: Container(
                  width: ScreenUtil.instance.setWidth(158),
                  height: ScreenUtil.instance.setWidth(222),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                          image: detailData['photo'] == null
                              ? AssetImage('assets/grey-fade.jpg')
                              : NetworkImage(detailData['photo']),
                          fit: BoxFit.fill)),
                ),
              ),
              Positioned(
                top: 36,
                left: 206,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(30),
                          width: ScreenUtil.instance.setWidth(30),
                          child: Container(
                            height: ScreenUtil.instance.setWidth(30),
                            width: ScreenUtil.instance.setWidth(30),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: NetworkImage(
                                        creatorImageUri.toString()))),
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil.instance.setWidth(5),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              creatorFullName == null
                                  ? 'loading'
                                  : creatorFullName.toString(),
                              style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(12),
                                  color: eventajaGreenTeal,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                                creatorName == null
                                    ? 'loading'
                                    : creatorName.toString(),
                                style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil.instance.setWidth(20),
                    ),
                    Text(
                      'xx xx xx to xx xx xx',
                      style: TextStyle(color: eventajaGreenTeal),
                    ),
                    Container(
                      height: ScreenUtil.instance.setWidth(30),
                      width: ScreenUtil.instance.setWidth(200),
                      child: MarqueeWidget(
                        text: detailData['name'] == null
                            ? '-'
                            : detailData['name'].toUpperCase(),
                        textStyle: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(20),
                          fontWeight: FontWeight.bold,
                        ),
                        scrollAxis: Axis.horizontal,
                      ),
                    ),
                    SizedBox(height: ScreenUtil.instance.setWidth(5)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(10),
                          width: ScreenUtil.instance.setHeight(12),
                          child: Image.asset(
                              'assets/icons/location-transparent.png'),
                        ),
                        SizedBox(width: ScreenUtil.instance.setWidth(5)),
                        Container(
                          height: ScreenUtil.instance.setWidth(16),
                          width: ScreenUtil.instance.setWidth(200),
                          child: MarqueeWidget(
                            text: detailData['address'] == null
                                ? '-'
                                : detailData['address'],
                            scrollAxis: Axis.horizontal,
                            textStyle: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(11)),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: ScreenUtil.instance.setWidth(5)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: ScreenUtil.instance.setWidth(10),
                          height: ScreenUtil.instance.setWidth(12),
                          child: Image.asset('assets/icons/btn_time_green.png'),
                        ),
                        SizedBox(width: ScreenUtil.instance.setWidth(5)),
                        Text(startTime.toString() + ' to ' + endTime.toString(),
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(11)))
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                left: 205,
                top: 205,
                child: Container(
                  height: ScreenUtil.instance.setWidth(50),
                  width: ScreenUtil.instance.setWidth(150),
                  child: GestureDetector(
                    onTap: () {
                      if (ticketStat['salesStatus'] == null) {
                      } else if (ticketType['type'] == 'free') {
                        showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) => SuccessPage());
                      } else if (ticketType['type'] == 'no_ticket') {
                        print('no ticket');
                        showDialog(
                            context: context,
                            child: new CupertinoAlertDialog(
                              title: new Text("Dialog Title"),
                              content: new Text("This is my content"),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: Text("Yes"),
                                ),
                                CupertinoDialogAction(
                                  child: Text("No"),
                                )
                              ],
                            ));
                      } else {
                        if (ticketStat['salesStatus'] == 'endSales' ||
                            ticketStat['availableTicketStatus'] == '0') {
                          return;
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SelectTicketWidget(
                                    eventID: detailData['id'],
                                    eventDate: detailData['dateStart'],
                                  )));
                        }
                      }
                    },
                    child: Container(
                      height: ScreenUtil.instance.setWidth(26),
                      width: ScreenUtil.instance.setWidth(80),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(
                            colorFilter: isTicketUnavailable == true
                                ? new ColorFilter.mode(
                                    Colors.black.withOpacity(0.4),
                                    BlendMode.dstATop)
                                : ColorFilter.mode(
                                    Colors.white, BlendMode.dstATop),
                            image: AssetImage(ticketTypeURI),
                            fit: BoxFit.fill,
                          )),
                      child: FractionallySizedBox(
                        alignment: Alignment.center,
                        heightFactor: .4,
                        child: Text(
                          ticketPrice,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.instance.setSp(20),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ])
          ],
        ),
      ),
    );
  }

  Widget countdownTimer() {
    final salesDay = _dDay;
    final remaining = salesDay.difference(_currentTime);

    final days = remaining.inDays;
    final hours = remaining.inHours - remaining.inDays * 24;
    final minutes = remaining.inMinutes - remaining.inHours * 60;
    final seconds = remaining.inSeconds - remaining.inMinutes * 60;

    final countdownAsString = '$days : $hours : $minutes : $seconds';

    print(countdownAsString);

    return Container(
      child: Center(
          child: Column(
        children: <Widget>[
          Text(
              'Ticket sales start from ${_dDay.day} - ${_dDay.month} - ${_dDay.year}'),
          Text(countdownAsString,
              style: TextStyle(
                  fontSize: ScreenUtil.instance.setSp(18),
                  fontWeight: FontWeight.bold)),
        ],
      )),
    );
  }

  Widget showMap() {
    StaticMapsProvider mapProvider = new StaticMapsProvider(
      GOOGLE_API_KEY: 'AIzaSyDjNpeyufzT81GAhQkCe85x83kxzfA7qbI',
      height: 200,
      width: MediaQuery.of(context).size.width.round(),
      latitude: lat,
      longitude: long,
    );

    String mapURI = mapProvider.toStringDeep();

    print(mapURI);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil.instance.setWidth(200),
      child: mapProvider,
    );
  }

  testGetData() {
    print(detailData['name']);
  }

  Future getInvitedUser() async {
    final invitedDataUrl = BaseApi().apiUrl +
        '/event/invited?X-API-KEY=${API_KEY}&event_id=${widget.id}&page=all';
    final response = await http.get(invitedDataUrl, headers: {
      'Authorization': 'Basic YWRtaW46MTIzNA==',
      'cookie': session
    });

    print(response.statusCode);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        invitedData = extractedData['data'];
        invitedUserList = invitedData['invited']['data'];
      });

      print(invitedUserList);
    }
  }

  Future getEventDetailsSpecificInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      session = preferences.getString('Session');
    });

    final detailsInfoUrl = BaseApi().apiUrl +
        '/event/detail?X-API-KEY=$API_KEY&eventID=${widget.id}';
    final response = await http.get(detailsInfoUrl, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': session
    });

    print('event detail page -> ' + response.statusCode.toString());
    print('event detail page -> ' + response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
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
        // _dDay = DateTime.parse(detailData['ticket']['sales_start_date']);

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

        if (detailData['ticket_type']['type'] == 'paid' ||
            detailData['ticket_type']['type'] == 'paid_seating') {
          if (detailData['ticket']['availableTicketStatus'] == '1') {
            if (detailData['ticket']['cheapestTicket'] == '0') {
              itemColor = Color(0xFFFFAA00);
              ticketPrice = 'Free Limited';
            } else {
              itemColor = Color(0xFF34B323);
              ticketPrice = detailData['ticket']['cheapestTicket'];
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

        // setState(() {
        //   if (ticketType['type'] == 'free') {
        //     ticketPrice = 'Free';
        //   } else if (ticketType['type'] == 'no_ticket') {
        //     ticketPrice = 'No Ticket';
        //   } else if (ticketType['type'] == 'on_the_spot') {
        //     ticketPrice = 'On The Spot';
        //   }
        // });

        // if (detailData['status'] == 'active') {
        //   if (ticketType['isSetupTicket'].toString() == "1") {
        //     if (ticketStat['cheapestTicket'].toString() == "0") {
        //       setState(() {
        //         ticketPriceStringVisibility = false;
        //         itemColor = Colors.green;
        //         ticketPrice = 'Free Limited';
        //       });
        //     } else {
        //       ticketTypeURI = 'assets/btn_ticket/paid-value.png';
        //       ticketPrice = "Rp. " + ticketStat['cheapestTicket'].toString();
        //     }

        //     if (ticketStat['availableTicketStatus'].toString() == '0') {
        //       isTicketUnavailable = true;
        //     } else {
        //       isTicketUnavailable = false;
        //     }
        //   }

        //   if (isGoing == "1") {
        //     ticketPrice = 'Going';
        //   }
        // } else {
        //   if (detailData['status'] == 'canceled') {
        //     ticketPrice = "Canceled";
        //   } else if (detailData['status'] == 'ended') {
        //     ticketPrice = "Event Ended";
        //   }
        // }
      });
      preferences.setString('eventID', detailData['id']);
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
  }
}
