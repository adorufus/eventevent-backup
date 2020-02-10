import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eventevent/Widgets/EventDetailComment.dart';
import 'package:eventevent/Widgets/EventDetailItems/FeedbackLogic.dart';
import 'package:eventevent/Widgets/EventDetailItems/ReviewDetails.dart';
import 'package:eventevent/Widgets/ManageEvent/ManageCustomForm.dart';
import 'package:eventevent/Widgets/ManageEvent/SeeWhosGoingInvitedWidget.dart';
import 'package:eventevent/Widgets/timeline/EventDetailTimeline.dart';
import 'package:eventevent/Widgets/timeline/TimelineItems.dart';
import 'package:eventevent/Widgets/timeline/UserTimelineItem.dart';
import 'package:eventevent/Widgets/timeline/VideoPlayer.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
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
import 'package:googleapis/people/v1.dart';
import 'dart:ui';
import 'package:marquee/marquee.dart';
//import 'package:eventevent/helper/MarqueeWidget.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';

class EventDetailsConstructView extends StatefulWidget {
  final Map<String, dynamic> eventDetailsData;
  final String id;
  final String name;
  final String image;
  final buo;
  final lp;
  final Map<String, dynamic> detailData;
  final Map<String, dynamic> ticketStat;
  final Function getEventDetailSpecificInfo;
  final ticketType;
  final itemColor;
  final ticketPrice;
  final creatorImageUri;
  final creatorFullName;
  final creatorName;
  final dateTime;
  final startTime;
  final endTime;
  final phoneNumber;
  final commentData;
  final email;
  final website;
  final isPrivate;
  final goingData;
  final lat;
  final long;
  final dDay;

  EventDetailsConstructView(
      {Key key,
      this.eventDetailsData,
      this.id,
      this.name,
      this.image,
      this.buo,
      this.lp,
      this.detailData,
      this.ticketStat,
      this.getEventDetailSpecificInfo,
      this.ticketType,
      this.itemColor,
      this.ticketPrice,
      this.creatorImageUri,
      this.creatorFullName,
      this.creatorName,
      this.dateTime,
      this.startTime,
      this.endTime,
      this.phoneNumber,
      this.commentData,
      this.email,
      this.website, this.isPrivate, this.goingData, this.lat, this.long, this.dDay})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventDetailsConstructViewState();
  }
}

class _EventDetailsConstructViewState extends State<EventDetailsConstructView>
    with AutomaticKeepAliveClientMixin<EventDetailsConstructView> {
  ScrollController _scrollController = new ScrollController();

  TextEditingController feedbackInputController = new TextEditingController();

  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerUrl = StreamController<String>();

  int loveClickedCount = 0;
  int currentTab = 0;

  bool ticketPriceStringVisibility;
  bool isTicketUnavailable;
  bool isLoveClicked = false;

  List invitedUserList = [];

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  Timer _timer;
  DateTime _currentTime;

  Color reviewColor = Colors.grey;
  Color reviewColorBad = Colors.grey;

  var session;

  String _data = '-';
  String generatedLink = '-';
  String error = '-';
  String defaultTab = '0';

  bool isGoodFeedback = false;
  bool isBadFeedback = false;

  Map<String, dynamic> invitedData = Map<String, dynamic>();

  List timelineList = [];
  String currentUserId = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // FlutterBranchSdk.validateSDKIntegration();
    generateLink();

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

    getTimelineList().then((response) {
      print(response.statusCode);
      print(response.body);
      var extractedData = json.decode(response.body);

      print('Timeline List -> ${response.body.toString()}');

      if (response.statusCode == 200) {
        setState(() {
          timelineList = extractedData['data'];
        });
      }
    });

    getInvitedUser();
    getData();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), _onTimeChange);
  }

  void setUpBranch() {
    // FlutterBranchIoPlugin.setupBranchIO();

    // FlutterBranchIoPlugin.listenToDeepLinkStream().listen((string) {
    //   print("DEEPLINK $string");
    //   setState(() {
    //     this._data = string;
    //   });
    // });

    // FlutterAndroidLifecycle.listenToOnStartStream().listen((string) {
    //   print("ONSTART");
    //   FlutterBranchIoPlugin.setupBranchIO();
    // });

    // FlutterBranchIoPlugin.listenToGeneratedLinkStream().listen((link) {
    //   print('GET LINK IN FLUTTER');
    //   print('thelink' + link);
    //   setState(() {
    //     this.generatedLink = link;

    //     print('thisgeneratedlink: ' + generatedLink);
    //   });
    // });

    // FlutterBranchIoPlugin.generateLink(
    //     FlutterBranchUniversalObject()
    //         .setCanonicalIdentifier('event_' + widget.id)
    //         .setTitle(widget.name)
    //         .setContentDescription('')
    //         .setContentImageUrl(widget.image)
    //         .setContentIndexingMode(BUO_CONTENT_INDEX_MODE.PUBLIC)
    //         .setLocalIndexMode(BUO_CONTENT_INDEX_MODE.LOCAL),
    //     lpFeature: 'sharing',
    //     lpControlParams: {
    //       '\$desktop_url': 'http://eventevent.com/event/${widget.id}'
    //     });
  }

  void generateLink() async {
    BranchResponse response = await FlutterBranchSdk.getShortUrl(
        buo: widget.buo, linkProperties: widget.lp);

    if (response.success) {
      print('generated link: ' + response.result);
      setState(() {
        generatedLink = response.result;
      });
    } else {
      controllerUrl.sink
          .add('Error: ${response.errorCode} - ${response.errorDescription}');
    }
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
      // generatedLink = extractedData['url'];
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    refreshController.dispose();
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

  bool isLoading = false;

  Future<http.Response> ungoing() async {
    print(widget.id);
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/event_goingstatus/delete';

    final response = await http.delete(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session'),
        'id': widget.id,
        'X-API-KEY': API_KEY,
      },
    );

    return response;
  }

  Future<http.Response> goingToEvent() async {
    print(widget.id);
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/event_goingstatus/post';

    final response = await http.post(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session')
      },
      body: {'X-API-KEY': API_KEY, 'eventID': widget.id},
    );

    return response;
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
    return widget.detailData == null
        ? Container(
            color: Colors.white,
            child: Center(child: CupertinoActivityIndicator(radius: 20)))
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
                            'EVENT_VIEWED', widget.detailData['countView']);
                        prefs.setString(
                            'EVENT_LOVED', widget.detailData['countLove']);
                        prefs.setString(
                            'EVENT_NAME', widget.detailData['name']);

                        print(prefs.getString('EVENT_VIEWED'));
                        print(prefs.getString('EVENT_LOVED'));
                        print(prefs.getString('EVENT_NAME'));

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                EventStatistic()));
                      },
                      child: widget.detailData['createdByID'] == null
                          ? Container(
                              child: Center(
                                  child:
                                      CupertinoActivityIndicator(radius: 20)),
                            )
                          : widget.detailData['createdByID'] != currentUserId
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
                                                widget
                                                    .detailData['category']
                                                        ['data']
                                                    .length;
                                            i++) {
                                          print(i.toString());
                                          categoryList.add(
                                              widget.detailData['category']
                                                  ['data'][i]['name']);
                                          categoryIdList.add(
                                              widget.detailData['category']
                                                  ['data'][i]['id']);
                                        }

                                        prefs.setString('NEW_EVENT_ID',
                                            widget.detailData['id']);
                                        prefs.setString('EVENT_NAME',
                                            widget.detailData['name']);
                                        prefs.setString('EVENT_TYPE',
                                            widget.detailData['isPrivate']);
                                        prefs.setStringList(
                                            'EVENT_CATEGORY', categoryList);
                                        prefs.setStringList(
                                            'EVENT_CATEGORY_ID_LIST',
                                            categoryIdList);
                                        prefs.setString('DATE_START',
                                            widget.detailData['dateStart']);
                                        prefs.setString('DATE_END',
                                            widget.detailData['dateEnd']);
                                        prefs.setString('TIME_START',
                                            widget.detailData['timeStart']);
                                        prefs.setString('TIME_END',
                                            widget.detailData['timeEnd']);
                                        prefs.setString('EVENT_DESCRIPTION',
                                            widget.detailData['description']);
                                        prefs.setString('EVENT_PHONE',
                                            widget.detailData['phone']);
                                        prefs.setString('EVENT_EMAIL',
                                            widget.detailData['email']);
                                        prefs.setString('EVENT_WEBSITE',
                                            widget.detailData['website']);
                                        prefs.setString('EVENT_LAT',
                                            widget.detailData['latitude']);
                                        prefs.setString('EVENT_LONG',
                                            widget.detailData['longitude']);
                                        prefs.setString('EVENT_ADDRESS',
                                            widget.detailData['address']);
                                        prefs.setString('EVENT_IMAGE',
                                            widget.detailData['photoFull']);

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
                                    ),
                                    RaisedButton(
                                      child: Text('Edit Custom Form'),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ManageCustomForm(
                                                      eventId: widget
                                                          .detailData['id'],
                                                    )));
                                      },
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
            bottomNavigationBar: GestureDetector(
              onTap: () {
                if (widget.ticketStat['salesStatus'] == null ||
                    widget.ticketStat['salesStatus'] == 'null') {
                  if (widget.detailData['ticket_type']['type'] == 'free' ||
                      widget.detailData['ticket_type']['type'] == 'no_ticket') {
                    print('show modal');
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return Container(
                          color: Color(0xFF737373),
                          child: Container(
                            padding: EdgeInsets.only(bottom: 30),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                      color: eventajaGreenTeal,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      )),
                                  child: Center(
                                    child: Text(
                                      'Going to this event?',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                // Padding(
                                //     padding:
                                //         EdgeInsets.symmetric(horizontal: 50),
                                //     child: SizedBox(
                                //         height: ScreenUtil.instance.setWidth(5),
                                //         width: ScreenUtil.instance.setWidth(50),
                                //         child: Image.asset(
                                //           'assets/icons/icon_line.png',
                                //           fit: BoxFit.fill,
                                //         ))),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 13),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: ScreenUtil.instance
                                            .setWidth(122.86),
                                        height: ScreenUtil.instance
                                            .setWidth(184.06),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey,
                                            image: DecorationImage(
                                                image: NetworkImage(widget
                                                    .detailData['photo']))),
                                      ),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Flexible(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: ScreenUtil.instance
                                                  .setWidth(200),
                                              child: Text(
                                                widget.detailData['name'],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 2,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                                width: 210,
                                                child: Text(
                                                  widget.detailData[
                                                      'description'],
                                                  maxLines: 8,
                                                ))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(12)),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 13),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height:
                                              ScreenUtil.instance.setWidth(30),
                                          width:
                                              ScreenUtil.instance.setWidth(100),
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Center(
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              ScreenUtil.instance.setWidth(8)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);

                                          isLoading = true;
                                          goingToEvent().then((response) {
                                            print(response.statusCode);
                                            print(response.body);

                                            if (response.statusCode == 201) {
                                              widget
                                                  .getEventDetailSpecificInfo();
                                              isLoading = false;
                                            } else {
                                              isLoading = false;
                                            }
                                          });
                                        },
                                        child: Container(
                                          height:
                                              ScreenUtil.instance.setWidth(30),
                                          width:
                                              ScreenUtil.instance.setWidth(100),
                                          decoration: BoxDecoration(
                                              color: eventajaGreenTeal,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Center(
                                            child: Text(
                                              'Yes',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                } else {
                  if (widget.ticketStat['salesStatus'] == 'endSales' ||
                      widget.ticketStat['availablewidget.ticketStatus'] ==
                          '0') {
                    return;
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => SelectTicketWidget(
                              eventID: widget.detailData['id'],
                              eventDate: widget.detailData['dateStart'],
                            )));
                  }
                }
              },
              child: Container(
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 25.7),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      offset: Offset(0, -1),
                      blurRadius: 2,
                      color: Color(0xff8a8a8b).withOpacity(.2),
                      spreadRadius: 1.5)
                ]),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Get Your Tickets now!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff231f20),
                          fontWeight: FontWeight.bold,
                        )),
                    Expanded(
                      child: SizedBox(),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.ticketStat['salesStatus'] == null) {
                        } else if (widget.ticketType['type'] == 'free') {
                          showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) => SuccessPage());
                        } else if (widget.ticketType['type'] == 'no_ticket') {
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
                          if (widget.ticketStat['salesStatus'] == 'endSales' ||
                              widget.ticketStat[
                                      'availablewidget.ticketStatus'] ==
                                  '0') {
                            return;
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SelectTicketWidget(
                                      eventID: widget.detailData['id'],
                                      eventDate: widget.detailData['dateStart'],
                                    )));
                          }
                        }
                      },
                      child: Container(
                        height: ScreenUtil.instance.setWidth(29.6),
                        width: ScreenUtil.instance.setWidth(143.7),
                        decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: widget.itemColor.withOpacity(0.4),
                                  blurRadius: 2,
                                  spreadRadius: 1.5)
                            ],
                            color: widget.itemColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                            child: Text(
                          widget.ticketPrice,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.instance.setSp(13),
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                widget.detailData == null
                    ? Container(
                        child: Center(
                            child: CupertinoActivityIndicator(radius: 20)))
                    // :
                    : Container(
                        color: Colors.white,
                        child: SmartRefresher(
                          controller: refreshController,
                          enablePullDown: true,
                          enablePullUp: false,
                          onRefresh: () {
                            setState(() {
                              widget.getEventDetailSpecificInfo();
                              getInvitedUser();
                              getData();
                              _currentTime = DateTime.now();
                              _timer = Timer.periodic(
                                  Duration(seconds: 1), _onTimeChange);
                            });
                            refreshController.refreshCompleted();
                          },
                          child: ListView(
                            shrinkWrap: true,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 13),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: ScreenUtil.instance
                                          .setWidth(122.86 * 1.3),
                                      height: ScreenUtil.instance
                                          .setWidth(184.06 * 1.3),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                              image: widget.detailData[
                                                          'photo_timeline'] ==
                                                      null
                                                  ? AssetImage(
                                                      'assets/grey-fade.jpg')
                                                  : NetworkImage(widget
                                                      .detailData['photo_timeline']),
                                              fit: BoxFit.fill)),
                                    ),
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 13),
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
                                                      height: ScreenUtil
                                                          .instance
                                                          .setWidth(30),
                                                      width: ScreenUtil.instance
                                                          .setWidth(30),
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: NetworkImage(widget
                                                                  .creatorImageUri
                                                                  .toString()))),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: ScreenUtil.instance
                                                        .setWidth(5),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        widget.creatorFullName ==
                                                                null
                                                            ? 'loading'
                                                            : widget
                                                                .creatorFullName
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontSize: ScreenUtil
                                                                .instance
                                                                .setSp(12),
                                                            color:
                                                                eventajaGreenTeal,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          widget.creatorName ==
                                                                  null
                                                              ? 'loading'
                                                              : widget
                                                                  .creatorName
                                                                  .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize:
                                                                  ScreenUtil
                                                                      .instance
                                                                      .setSp(
                                                                          11))),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                  height: ScreenUtil.instance
                                                      .setWidth(10)),
                                              Container(
                                                  width: ScreenUtil.instance
                                                      .setWidth(180),
                                                  child: Text(
                                                    widget.dateTime,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil
                                                            .instance
                                                            .setSp(12),
                                                        color: Colors.grey),
                                                  )),
                                              SizedBox(
                                                  height: ScreenUtil.instance
                                                      .setWidth(10)),
                                              Container(
                                                  height: ScreenUtil.instance
                                                      .setWidth(widget
                                                                  .detailData[
                                                                      'name']
                                                                  .length <
                                                              30
                                                          ? 15
                                                          : 35),
                                                  width: ScreenUtil.instance
                                                      .setWidth(180),
                                                  child: Text(
                                                    widget.detailData['name'] ==
                                                            null
                                                        ? '-'
                                                        : widget
                                                            .detailData['name']
                                                            .toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil
                                                            .instance
                                                            .setSp(15),
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                  widget.detailData['address']
                                                              .toString()
                                                              .length <
                                                          30
                                                      ? Text(
                                                          widget.detailData[
                                                              'address'],
                                                          style: TextStyle(
                                                              fontSize:
                                                                  ScreenUtil
                                                                      .instance
                                                                      .setSp(
                                                                          11)),
                                                          maxLines: 1,
                                                        )
                                                      : Container(
                                                          height: ScreenUtil
                                                              .instance
                                                              .setWidth(16),
                                                          width: ScreenUtil
                                                              .instance
                                                              .setWidth(170),
                                                          child: MarqueeWidget(
                                                            text: widget.detailData[
                                                                        'address'] ==
                                                                    null
                                                                ? '-'
                                                                : widget.detailData[
                                                                    'address'],
                                                            scrollAxis:
                                                                Axis.horizontal,
                                                            textStyle: TextStyle(
                                                                fontSize:
                                                                    ScreenUtil
                                                                        .instance
                                                                        .setSp(
                                                                            11)),
                                                            ratioOfBlankToScreen:
                                                                .1,
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
                                                      widget.startTime
                                                              .toString() +
                                                          ' to ' +
                                                          widget.endTime
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontSize: ScreenUtil
                                                              .instance
                                                              .setSp(11))),
                                                ],
                                              ),
                                              SizedBox(
                                                height: ScreenUtil.instance
                                                    .setWidth(15),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  if (widget.ticketStat[
                                                              'salesStatus'] ==
                                                          null ||
                                                      widget.ticketStat[
                                                              'salesStatus'] ==
                                                          'null') {
                                                    if (widget.detailData[
                                                                    'ticket_type']
                                                                ['type'] ==
                                                            'free' ||
                                                        widget.detailData[
                                                                    'ticket_type']
                                                                ['type'] ==
                                                            'no_ticket') {
                                                      print('show modal');
                                                      if (widget.detailData[
                                                              'isGoing'] ==
                                                          '1') {
                                                        ungoing()
                                                            .then((response) {
                                                          isLoading = true;
                                                          print(response
                                                              .statusCode);
                                                          print(response.body);

                                                          if (response.statusCode ==
                                                                  200 ||
                                                              response.statusCode ==
                                                                  201) {
                                                            widget
                                                                .getEventDetailSpecificInfo();
                                                            isLoading = false;
                                                          } else {
                                                            isLoading = false;
                                                          }
                                                        });
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (context) {
                                                            return Container(
                                                              color: Color(
                                                                  0xFF737373),
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            30),
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(15),
                                                                          topRight:
                                                                              Radius.circular(15),
                                                                        )),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              13),
                                                                      decoration: BoxDecoration(
                                                                          color: eventajaGreenTeal,
                                                                          borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(15),
                                                                            topRight:
                                                                                Radius.circular(15),
                                                                          )),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Going to this event?',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Padding(
                                                                    //     padding:
                                                                    //         EdgeInsets.symmetric(horizontal: 50),
                                                                    //     child: SizedBox(
                                                                    //         height: ScreenUtil.instance.setWidth(5),
                                                                    //         width: ScreenUtil.instance.setWidth(50),
                                                                    //         child: Image.asset(
                                                                    //           'assets/icons/icon_line.png',
                                                                    //           fit: BoxFit.fill,
                                                                    //         ))),
                                                                    Container(
                                                                      margin: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              13,
                                                                          vertical:
                                                                              13),
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                            width:
                                                                                ScreenUtil.instance.setWidth(146.67),
                                                                            height:
                                                                                ScreenUtil.instance.setWidth(220),
                                                                            decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                                color: Colors.grey,
                                                                                image: DecorationImage(image: NetworkImage(widget.detailData['photo']))),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          Flexible(
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Container(
                                                                                  width: ScreenUtil.instance.setWidth(200),
                                                                                  child: Text(
                                                                                    widget.detailData['name'],
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                    maxLines: 2,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 15,
                                                                                ),
                                                                                Container(
                                                                                    width: 210,
                                                                                    child: Text(
                                                                                      widget.detailData['description'],
                                                                                      maxLines: 8,
                                                                                    ))
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height: ScreenUtil
                                                                            .instance
                                                                            .setWidth(12)),
                                                                    Container(
                                                                      margin: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              13),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: <
                                                                            Widget>[
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              height: ScreenUtil.instance.setWidth(30),
                                                                              width: ScreenUtil.instance.setWidth(100),
                                                                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(30)),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  'Cancel',
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: ScreenUtil.instance.setWidth(8)),
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.pop(context);

                                                                              isLoading = true;

                                                                              goingToEvent().then((response) {
                                                                                print(response.statusCode);
                                                                                print(response.body);

                                                                                if (response.statusCode == 201) {
                                                                                  widget.getEventDetailSpecificInfo();
                                                                                  isLoading = false;
                                                                                } else {
                                                                                  isLoading = false;
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              height: ScreenUtil.instance.setWidth(30),
                                                                              width: ScreenUtil.instance.setWidth(100),
                                                                              decoration: BoxDecoration(color: eventajaGreenTeal, borderRadius: BorderRadius.circular(30)),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  'Yes',
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                  } else {
                                                    if (widget.ticketStat[
                                                                'salesStatus'] ==
                                                            'endSales' ||
                                                        widget.ticketStat[
                                                                'availablewidget.ticketStatus'] ==
                                                            '0') {
                                                      return;
                                                    } else {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  SelectTicketWidget(
                                                                    eventID: widget
                                                                            .detailData[
                                                                        'id'],
                                                                    eventDate: widget
                                                                            .detailData[
                                                                        'dateStart'],
                                                                  )));
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  height: ScreenUtil.instance
                                                      .setWidth(28 * 1.1),
                                                  width: ScreenUtil.instance
                                                      .setWidth(133 * 1.1),
                                                  decoration: BoxDecoration(
                                                      boxShadow: <BoxShadow>[
                                                        BoxShadow(
                                                            color: widget
                                                                .itemColor
                                                                .withOpacity(
                                                                    0.4),
                                                            blurRadius: 2,
                                                            spreadRadius: 1.5)
                                                      ],
                                                      color: widget.itemColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                                  child: Center(
                                                      child: Text(
                                                    widget.ticketPrice,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: ScreenUtil
                                                            .instance
                                                            .setSp(13),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                ),
                                              ),
                                            ])),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: ScreenUtil.instance.setWidth(15)),
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
                                          color:
                                              Color(0xff8a8a8b).withOpacity(.5))
                                    ]),
                                child: Row(
                                  children: <Widget>[
                                    LoveItem(
                                      isComment: false,
                                      isAlreadyLoved:
                                          widget.detailData['isLoved'] == '1'
                                              ? true
                                              : false,
                                      loveCount: widget.detailData['countLove'],
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.instance.setWidth(10),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EventDetailComment(
                                                      eventID: widget
                                                          .detailData['id'],
                                                    )));
                                      },
                                      child: LoveItem(
                                          isComment: true,
                                          isAlreadyCommented: widget
                                                      .detailData['comment']
                                                      .length <
                                                  1
                                              ? false
                                              : widget.commentData
                                                          .containsValue(
                                                              currentUserId) ==
                                                      true
                                                  ? true
                                                  : false,
                                          commentCount: widget
                                              .detailData['total_comment']
                                              .toString()),
                                    ),
                                    Expanded(
                                      child: SizedBox(),
                                    ),
                                    GestureDetector(
                                      onTap: widget.phoneNumber == null ||
                                              widget.phoneNumber == ""
                                          ? () {}
                                          : () => launch("tel:" +
                                              widget.phoneNumber.toString()),
                                      child: SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(33),
                                        width: ScreenUtil.instance.setWidth(33),
                                        child: Image.asset(widget.phoneNumber ==
                                                    null ||
                                                widget.phoneNumber == ""
                                            ? 'assets/icons/btn_phone.png'
                                            : 'assets/icons/btn_phone_active.png'),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: widget.email == null ||
                                              widget.email == ""
                                          ? () {}
                                          : () => launch("mailto:" +
                                              widget.email.toString()),
                                      child: SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(33),
                                        width: ScreenUtil.instance.setWidth(33),
                                        child: Image.asset(widget.email ==
                                                    null ||
                                                widget.email == ""
                                            ? 'assets/icons/btn_mail.png'
                                            : 'assets/icons/btn_mail_active.png'),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: widget.website == null || widget.website == ""
                                          ? () {}
                                          : () => launch(widget.website.toString()),
                                      child: SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(33),
                                        width: ScreenUtil.instance.setWidth(33),
                                        child: Image.asset(
                                          widget.website == null || widget.website == ""
                                              ? 'assets/icons/btn_web.png'
                                              : 'assets/icons/btn_web_active.png',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              widget.isPrivate == "0"
                                  ? Container()
                                  : SizedBox(
                                      height: ScreenUtil.instance.setWidth(20),
                                    ),
                              widget.isPrivate == "0"
                                  ? Container()
                                  : Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Container(
                                        // margin: EdgeInsets.symmetric(
                                        //     horizontal: 13, vertical: 13),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 13),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    'Who\'s Invited',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff8a8a8b),
                                                        fontSize: ScreenUtil
                                                            .instance
                                                            .setSp(11)),
                                                  ),
                                                  Expanded(
                                                    child: SizedBox(),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SeeWhosGoingInvitedWidget(
                                                                    eventId: widget
                                                                            .detailData[
                                                                        'id'],
                                                                    peopleType:
                                                                        'invited',
                                                                  )));
                                                    },
                                                    child: Container(
                                                      height: 30,
                                                      child: Text(
                                                        'See All >',
                                                        style: TextStyle(
                                                            color:
                                                                eventajaGreenTeal),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: ScreenUtil.instance
                                                    .setWidth(10)),
                                            Container(
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
                                                        left: 13),
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
                                                                    .black26,
                                                                offset: Offset(
                                                                    1.0, 1.0),
                                                                blurRadius: 3)
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
                              widget.detailData['ticket']['salesStatus'] ==
                                      'comingSoon'
                                  ? countdownTimer()
                                  : Container(),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 13),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 13),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Who\'s Going',
                                            style: TextStyle(
                                                color: Color(0xff8a8a8b),
                                                fontSize: ScreenUtil.instance
                                                    .setSp(11)),
                                          ),
                                          Expanded(
                                            child: SizedBox(),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SeeWhosGoingInvitedWidget(
                                                            eventId: widget
                                                                    .detailData[
                                                                'id'],
                                                            peopleType: 'going',
                                                          )));
                                            },
                                            child: Container(
                                              height: 30,
                                              child: Text(
                                                'See All >',
                                                style: TextStyle(
                                                    color: eventajaGreenTeal),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Container(
                                      height: ScreenUtil.instance.setWidth(50),
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: widget.goingData == null
                                            ? 0
                                            : widget.goingData.length,
                                        itemBuilder: (BuildContext context, i) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          ProfileWidget(
                                                            initialIndex: 0,
                                                            userId: widget
                                                                        .detailData[
                                                                    'going'][
                                                                'data'][i]['id'],
                                                          )));
                                            },
                                            child: new Container(
                                              margin: EdgeInsets.only(left: 10),
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
                                                              color: Colors
                                                                  .black26,
                                                              offset: Offset(
                                                                  1.0, 1.0),
                                                              blurRadius: 3)
                                                        ],
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: CachedNetworkImageProvider(
                                                              widget.detailData[
                                                                          'going']
                                                                      ['data']
                                                                  [i]['photo']),
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
                              widget.detailData['status'] == 'ended'
                                  ? SizedBox(
                                      height: ScreenUtil.instance.setWidth(20),
                                    )
                                  : Container(),
                              widget.detailData['status'] == 'ended'
                                  ? Container(
                                      // height: ScreenUtil.instance.setWidth(150),
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 13),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Expanded(child: SizedBox()),
                                              Text('USERS FEEDBACK',
                                                  style: TextStyle(
                                                      color:
                                                          Color(0xff8a8a8b))),
                                              Expanded(child: SizedBox()),
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ReviewDetails(
                                                                  eventId: widget
                                                                          .detailData[
                                                                      'id'],
                                                                  eventName: widget
                                                                          .detailData[
                                                                      'name'],
                                                                  goodReview: widget
                                                                              .detailData[
                                                                          'event_review']
                                                                      [
                                                                      'percent_review']['good'],
                                                                  badReview: widget
                                                                              .detailData[
                                                                          'event_review']
                                                                      [
                                                                      'percent_review']['bad'],
                                                                )));
                                                  },
                                                  child: Text('See All >',
                                                      style: TextStyle(
                                                          color:
                                                              eventajaGreenTeal)))
                                            ],
                                          ),
                                          SizedBox(
                                            height: ScreenUtil.instance
                                                .setWidth(15),
                                          ),
                                          Row(
                                            crossAxisAlignment: prefix0
                                                .CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Icon(Icons.thumb_up,
                                                  size: 15,
                                                  color: eventajaGreenTeal),
                                              Expanded(
                                                child: LinearPercentIndicator(
                                                  lineHeight: ScreenUtil
                                                      .instance
                                                      .setWidth(10),
                                                  progressColor:
                                                      eventajaGreenTeal,
                                                  percent: int.parse(widget
                                                                      .detailData[
                                                                  'event_review']
                                                              ['percent_review']
                                                          ['good']) /
                                                      100,
                                                ),
                                              ),
                                              Container(
                                                width: ScreenUtil.instance
                                                    .setWidth(40),
                                                child: Text(
                                                  (widget.detailData[
                                                                  'event_review']
                                                              ['percent_review']
                                                          ['good'] +
                                                      '%'),
                                                  style: TextStyle(
                                                      color: eventajaGreenTeal,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.end,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: ScreenUtil.instance
                                                .setWidth(15),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Icon(Icons.thumb_down,
                                                  size: 15, color: Colors.red),
                                              Expanded(
                                                child: LinearPercentIndicator(
                                                  lineHeight: ScreenUtil
                                                      .instance
                                                      .setWidth(10),
                                                  progressColor: Colors.red,
                                                  percent: int.parse(widget
                                                                      .detailData[
                                                                  'event_review']
                                                              ['percent_review']
                                                          ['bad']) /
                                                      100,
                                                ),
                                              ),
                                              Container(
                                                width: ScreenUtil.instance
                                                    .setWidth(40),
                                                child: Text(
                                                  widget.detailData[
                                                                  'event_review']
                                                              ['percent_review']
                                                          ['bad'] +
                                                      '%',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.end,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: widget.detailData[
                                                                'event_review']
                                                            ['user_review'] ==
                                                        '1' ||
                                                    widget.detailData[
                                                            'isGoing'] ==
                                                        '0'
                                                ? 0
                                                : 15,
                                          ),
                                          widget.detailData['event_review']
                                                          ['user_review'] ==
                                                      '1' ||
                                                  widget.detailData[
                                                          'isGoing'] ==
                                                      '0'
                                              ? Container()
                                              : GestureDetector(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        builder: (context) {
                                                          return StatefulBuilder(
                                                              builder: (context,
                                                                  state) {
                                                            return Container(
                                                              color: Color(
                                                                  0xFF737373),
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            30),
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(15),
                                                                          topRight:
                                                                              Radius.circular(15),
                                                                        )),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              13),
                                                                      decoration: BoxDecoration(
                                                                          color: eventajaGreenTeal,
                                                                          borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(15),
                                                                            topRight:
                                                                                Radius.circular(15),
                                                                          )),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Give feedback to this event',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      color: Colors
                                                                          .white,
                                                                      margin: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              60,
                                                                          vertical:
                                                                              15),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: <
                                                                            Widget>[
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              state(() {
                                                                                if (isGoodFeedback == true) {
                                                                                  isGoodFeedback = false;
                                                                                  reviewColor = Color(0xff8a8a8b);
                                                                                } else {
                                                                                  isGoodFeedback = true;
                                                                                  if (isBadFeedback == true) {
                                                                                    isBadFeedback = false;
                                                                                    reviewColorBad = Color(0xff8a8a8b);
                                                                                  }
                                                                                  reviewColor = eventajaGreenTeal;
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                Icon(
                                                                                  Icons.thumb_up,
                                                                                  size: 100,
                                                                                  color: reviewColor,
                                                                                ),
                                                                                Text('GOOD', style: TextStyle(color: reviewColor, fontSize: 14))
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              state(() {
                                                                                if (isBadFeedback == true) {
                                                                                  isBadFeedback = false;
                                                                                  reviewColorBad = Color(0xff8a8a8b);
                                                                                } else {
                                                                                  isBadFeedback = true;
                                                                                  if (isGoodFeedback == true) {
                                                                                    isGoodFeedback = false;
                                                                                    reviewColor = Color(0xff8a8a8b);
                                                                                  }
                                                                                  reviewColorBad = Colors.red;
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                Icon(
                                                                                  Icons.thumb_down,
                                                                                  size: 100,
                                                                                  color: reviewColorBad,
                                                                                ),
                                                                                Text('BAD', style: TextStyle(color: reviewColorBad, fontSize: 14))
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height: ScreenUtil
                                                                            .instance
                                                                            .setWidth(0)),
                                                                    prefix0
                                                                        .Container(
                                                                      margin: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              13),
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            feedbackInputController,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                          ),
                                                                          hintText:
                                                                              'Enter your feedback',
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        String
                                                                            typeId =
                                                                            '0';

                                                                        state(
                                                                            () {
                                                                          if (isGoodFeedback == true &&
                                                                              isBadFeedback == false) {
                                                                            typeId =
                                                                                '4';
                                                                          } else if (isBadFeedback == true &&
                                                                              isGoodFeedback == false) {
                                                                            typeId =
                                                                                '8';
                                                                          }

                                                                          print(
                                                                              typeId);

                                                                          isLoading =
                                                                              true;

                                                                          FeedbackLogic.postFeedback(widget.detailData['id'], typeId, feedbackInputController.text).then(
                                                                              (response) {
                                                                            if (response.statusCode == 201 ||
                                                                                response.statusCode == 200) {
                                                                              widget.getEventDetailSpecificInfo();
                                                                              isLoading = false;
                                                                            } else {
                                                                              isLoading = false;
                                                                              print(response.body);
                                                                            }
                                                                          }).timeout(
                                                                              Duration(seconds: 15),
                                                                              onTimeout:
                                                                                  () {
                                                                            isLoading =
                                                                                false;
                                                                            print('request timeout');
                                                                          }).catchError(
                                                                              (err) {
                                                                            isLoading =
                                                                                false;
                                                                            print(err);
                                                                          });
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                13),
                                                                        height: ScreenUtil
                                                                            .instance
                                                                            .setWidth(50),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                eventajaGreenTeal,
                                                                            borderRadius:
                                                                                BorderRadius.circular(10)),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Icon(
                                                                              Icons.chat,
                                                                              color: Colors.white,
                                                                              size: 18,
                                                                            ),
                                                                            SizedBox(
                                                                              width: ScreenUtil.instance.setWidth(8),
                                                                            ),
                                                                            Text('Write a review',
                                                                                style: TextStyle(color: Colors.white, fontSize: 15))
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                        padding:
                                                                            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                        });
                                                  },
                                                  child: Container(
                                                    height: ScreenUtil.instance
                                                        .setWidth(50),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            eventajaGreenTeal,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.chat,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                        SizedBox(
                                                          width: ScreenUtil
                                                              .instance
                                                              .setWidth(8),
                                                        ),
                                                        Text('Write a review',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15))
                                                      ],
                                                    ),
                                                  ),
                                                )
                                        ],
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(20),
                              ),
                              widget.detailData['createdByID'] != currentUserId
                                  ? Container()
                                  : Container(
                                      width:
                                          ScreenUtil.instance.setWidth(333.7),
                                      height:
                                          ScreenUtil.instance.setWidth(95.4),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 13),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 5,
                                              spreadRadius: 1.5,
                                              color: Color(0xff8a8a8b)
                                                  .withOpacity(.5))
                                        ],
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              saveId(widget.detailData['id']);
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          ManageTicket(
                                                            eventID: widget
                                                                    .detailData[
                                                                'id'],
                                                          )));
                                            },
                                            child: SizedBox(
                                              height: ScreenUtil.instance
                                                  .setWidth(100),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  SizedBox(
                                                      height: ScreenUtil
                                                          .instance
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
                                                        color:
                                                            Color(0xff404041),
                                                        fontSize: ScreenUtil
                                                            .instance
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
                                              prefs.setString('NEW_EVENT_ID',
                                                  widget.detailData['id']);
                                              prefs.setString(
                                                  'QR_URI',
                                                  widget.detailData['qrcode']
                                                      ['secure_url']);
                                              prefs.setString('EVENT_NAME',
                                                  widget.detailData['name']);
                                              print(prefs
                                                  .getString('NEW_EVENT_ID'));
                                              print(prefs.getString('QR_URI'));
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          ShowQr(
                                                            qrUrl: widget
                                                                        .detailData[
                                                                    'qrcode']
                                                                ['secure_url'],
                                                            eventName: widget
                                                                    .detailData[
                                                                'name'],
                                                          )));
                                            },
                                            child: SizedBox(
                                              height: ScreenUtil.instance
                                                  .setWidth(100),
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
                                                          color:
                                                              Color(0xff404041),
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
                                                            eventID: widget
                                                                    .detailData[
                                                                'id'],
                                                            eventName: widget
                                                                    .detailData[
                                                                'name'],
                                                          )));
                                            },
                                            child: SizedBox(
                                              height: ScreenUtil.instance
                                                  .setWidth(100),
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
                                                          color:
                                                              Color(0xff404041),
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
                                height: ScreenUtil.instance.setWidth(40),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () {
                                          currentTab = 0;
                                        },
                                        child: Container(
                                          height:
                                              ScreenUtil.instance.setWidth(115),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Divider(
                                                thickness: 2,
                                                color: currentTab == 0
                                                    ? eventajaGreenTeal
                                                    : Theme.of(context)
                                                        .dividerColor,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () {
                                          currentTab = 1;
                                        },
                                        child: Container(
                                          height:
                                              ScreenUtil.instance.setWidth(112),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Divider(
                                                thickness: 2,
                                                color: currentTab == 1
                                                    ? eventajaGreenTeal
                                                    : Theme.of(context)
                                                        .dividerColor,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () {
                                          currentTab = 2;
                                        },
                                        child: Container(
                                          height:
                                              ScreenUtil.instance.setWidth(112),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Divider(
                                                thickness: 2,
                                                color: currentTab == 2
                                                    ? eventajaGreenTeal
                                                    : Theme.of(context)
                                                        .dividerColor,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              tabItem()
                            ],
                          ),
                        )),
                Positioned(
                    child: isLoading == true
                        ? Container(
                            child: Center(
                                child: CupertinoActivityIndicator(radius: 20)),
                            color: Colors.black.withOpacity(0.5),
                          )
                        : Container())
              ],
            ));
  }

  Widget tabItem() {
    if (currentTab == 0) {
      return Container(
        color: Color(0xff8a8a8b).withOpacity(.05),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 5,
                        spreadRadius: 1.5,
                        color: Color(0xff8a8a8b).withOpacity(.2))
                  ],
                  color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.detailData['name'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(
                        widget.detailData['additional'].length == 0 ? 0 : 29),
                  ),
                  widget.detailData['additional'].length == 0 ? Container() : Container(
                    height: 200,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.detailData['additional'].length == 0
                            ? 0
                            : widget.detailData['additional'].length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => widget
                                                      .detailData['additional']
                                                  [i]['extension'] ==
                                              'image/jpeg' ||
                                          widget.detailData['additional'][i]
                                                  ['extension'] ==
                                              'image/png'
                                      ? PhotoView(
                                          imageProvider: NetworkImage(
                                              widget.detailData['additional'][i]
                                                  ['posterPathFull']),
                                        )
                                      : MediaPlayer(
                                          videoUri:
                                              widget.detailData['additional'][i]
                                                  ['posterPathFull']),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              height: ScreenUtil.instance.setWidth(206),
                              width: ScreenUtil.instance.setWidth(274.67),
                              decoration: BoxDecoration(
                                  color: Color(0xff8a8a8b),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          widget.detailData['additional'][i]
                                              ['posterPathThumb']),
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Center(
                                  child: widget.detailData['additional'][i]
                                                  ['extension'] ==
                                              'image/jpeg' ||
                                          widget.detailData['additional'][i]
                                                  ['extension'] ==
                                              'image/png'
                                      ? Container()
                                      : Icon(
                                          Icons.play_circle_filled,
                                          color: Colors.white,
                                          size: 50,
                                        )),
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(29),
                  ),
                  Text(widget.detailData['description'])
                ],
              ),
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(18),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 5,
                        spreadRadius: 1.5,
                        color: Color(0xff8a8a8b).withOpacity(.2))
                  ],
                  color: Colors.white),
              child: Column(
                children: <Widget>[showMap()],
              ),
            )
          ],
        ),
      );
    } else if (currentTab == 1) {
      return UserTimelineItem(
        currentUserId: currentUserId,
        eventId: widget.detailData['id'],
        timelineType: 'eventDetail',
      );
    } else if (currentTab == 2) {
      return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EventDetailComment(
                        eventID: widget.detailData['id'],
                      )));
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 13),
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xff8a8a8b).withOpacity(.2),
                        blurRadius: 2,
                        spreadRadius: 1.5)
                  ]),
              child: Center(
                child: Text('Write a Comment',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.5))),
              ),
            ),
          ),
          widget.detailData['comment'].length == 0
              ? Container(
                  height: 15,
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.detailData['comment'] == null
                      ? 0
                      : widget.detailData['comment'].length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            widget.detailData['comment'][i]['photo']),
                      ),
                      title: Text(
                        widget.detailData['comment'][i]['fullName'] + '' + ': ',
                        style: TextStyle(
                            fontSize: ScreenUtil.instance.setSp(12),
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text(widget.detailData['comment'][i]['response']),
                    );
                  },
                )
        ],
      );
    }

    return Container();
  }

  static BorderSide createBorderSide(BuildContext context,
      {Color color, double width = 0.0}) {
    assert(width != null);
    return BorderSide(
      color: color ?? Theme.of(context).dividerColor,
      width: width,
    );
  }

  Widget countdownTimer() {
    final salesDay = widget.dDay;
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
              'Ticket sales start from ${widget.dDay.day} - ${widget.dDay.month} - ${widget.dDay.year}'),
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
      latitude: widget.lat,
      longitude: widget.long,
    );

    String mapURI = mapProvider.toStringDeep();

    print(mapURI);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil.instance.setWidth(200),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: mapProvider,
    );
  }

  testGetData() {
    print(widget.detailData['name']);
  }

  Future getInvitedUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final invitedDataUrl = BaseApi().apiUrl +
        '/event/invited?X-API-KEY=$API_KEY&event_id=${widget.id}&page=all';
    final response = await http.get(invitedDataUrl, headers: {
      'Authorization': 'Basic YWRtaW46MTIzNA==',
      'cookie': preferences.getString('Session')
    });

    print(response.statusCode);
    print('invited: ' + response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        invitedData = extractedData['data'];
        invitedUserList = invitedData['invited'];
      });

      print(invitedUserList);
    }
  }

  Future<http.Response> getTimelineList({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (newPage != null) {
        currentPage += newPage;
      }

      print(currentPage);
    });

    String url = BaseApi().apiUrl +
        '/timeline/user?X-API-KEY=$API_KEY&page=1&userID=$currentUserId';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print('body: ' + response.body);

    return response;
  }
}
