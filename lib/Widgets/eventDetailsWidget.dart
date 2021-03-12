import 'dart:async';
import 'dart:convert';
import 'package:eventevent/Widgets/EventDetailComment.dart';
import 'package:eventevent/Widgets/EventDetailItems/FeedbackLogic.dart';
import 'package:eventevent/Widgets/EventDetailItems/ReviewDetails.dart';
import 'package:eventevent/Widgets/ManageEvent/LivestreamBroadcastWidget.dart';
// import 'package:eventevent/Widgets/ManageEvent/LivestreamBroadcastWidgetAndroid.dart';
import 'package:eventevent/Widgets/ManageEvent/ManageCustomForm.dart';
import 'package:eventevent/Widgets/ManageEvent/SeeWhosGoingInvitedWidget.dart';
import 'package:eventevent/Widgets/PostEvent/PostEventInvitePeople.dart';
import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/Widgets/timeline/ReportPost.dart';
import 'package:eventevent/Widgets/timeline/TimelineItems.dart';
import 'package:eventevent/Widgets/timeline/VideoPlayer.dart';
import 'package:eventevent/helper/API/apiHelper.dart';
import 'package:eventevent/helper/ClevertapHandler.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart' as prefix0;
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
import 'package:eventevent/helper/static_map_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventevent/helper/API/baseApi.dart';
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
  final eventStartDate;
  final isRest;

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
      this.website,
      this.isPrivate,
      this.goingData,
      this.lat,
      this.long,
      this.dDay,
      this.eventStartDate,
      this.isRest})
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
  var detailData;

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
  String streamingState = '';

  bool isGoing = false;

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
    if (widget.detailData.containsKey("livestream") &&
        widget.detailData['livestream'].isNotEmpty &&
        widget.isRest == false) {
      getWowzaLivestreamState(
              widget.detailData['livestream'][0]['streaming_id'])
          .then((response) {
        var extractedResponse = json.decode(response.body);

        streamingState = extractedResponse['live_stream']['state'];
        // streamingState = 'started';
        if (!mounted) return;
        setState(() {});
      });
    }

    setState(() {
      detailData = widget.detailData;
      // ClevertapHandler.handleEventDetail(
      //     detailData['name'],
      //     detailData['creatorName'],
      //     detailData['dateStart'],
      //     detailData['dateEnd'],
      //     detailData['isPrivate'],
      //     detailData['category']['data']);
    });

    if (detailData["isGoing"] == '1') {
      setState(() {
        isGoing = true;
      });
    } else {
      isGoing = false;
    }

    print('isGoing' + isGoing.toString());

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

  void setUpBranch() {}

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
    if (!mounted) return;
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
        'Authorization': AUTH_KEY,
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
        'Authorization': AUTH_KEY,
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
    return detailData == null
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

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => EventStatistic(
                              eventId: widget.id,
                            ),
                          ),
                        );
                      },
                      child: detailData['createdByID'] == null
                          ? Container(
                              child: Center(
                                  child:
                                      CupertinoActivityIndicator(radius: 20)),
                            )
                          : detailData['createdByID'] != currentUserId
                              ? Container()
                              : Icon(
                                  Icons.insert_chart,
                                  color: eventajaGreenTeal,
                                  size: 30,
                                ),
                    ),
                    SizedBox(width: ScreenUtil.instance.setWidth(15)),
                    GestureDetector(
                      onTap: () {
                        if (widget.isRest) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LoginRegisterWidget(
                                  previousWidget: 'EventDetailsWidgetRest',
                                  eventId: widget.id),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PostEventInvitePeople(
                                    calledFrom: "other event",
                                    eventId: widget.id,
                                  )));
                        }
                      },
                      child: Icon(
                        Icons.person_add,
                        color: eventajaGreenTeal,
                        size: 25,
                      ),
                    ),
                    SizedBox(width: ScreenUtil.instance.setWidth(15)),
                    GestureDetector(
                      onTap: () {
                        ShareExtend.share(generatedLink, 'text');
                      },
                      child: Icon(
                        Icons.share,
                        color: eventajaGreenTeal,
                        size: 25,
                      ),
                    ),
                    SizedBox(width: ScreenUtil.instance.setWidth(15)),
                    GestureDetector(
                      onTap: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (thisContext) {
                              return detailData['createdByID'] != currentUserId
                                  ? CupertinoActionSheet(
                                      actions: <Widget>[
                                        CupertinoActionSheetAction(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReportPost(
                                                            postId: widget.id,
                                                            postType: 'event',
                                                          )));
                                            },
                                            child: Text('Report This Event'))
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                          onPressed: () {
                                            Navigator.pop(thisContext);
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(color: Colors.red),
                                          )),
                                    )
                                  : CupertinoActionSheet(
                                      actions: <Widget>[
                                          CupertinoActionSheetAction(
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
                                                            .detailData[
                                                                'category']
                                                                ['data']
                                                            .length;
                                                    i++) {
                                                  print(i.toString());
                                                  categoryList.add(
                                                      detailData['category']
                                                          ['data'][i]['name']);
                                                  categoryIdList.add(
                                                      detailData['category']
                                                          ['data'][i]['id']);
                                                }

                                                prefs.setString('NEW_EVENT_ID',
                                                    detailData['id']);
                                                prefs.setString('EVENT_NAME',
                                                    detailData['name']);
                                                prefs.setString('EVENT_TYPE',
                                                    detailData['isPrivate']);
                                                prefs.setStringList(
                                                    'EVENT_CATEGORY',
                                                    categoryList);
                                                prefs.setStringList(
                                                    'EVENT_CATEGORY_ID_LIST',
                                                    categoryIdList);
                                                prefs.setString('DATE_START',
                                                    detailData['dateStart']);
                                                prefs.setString(
                                                    'DATE_END',
                                                    widget
                                                        .detailData['dateEnd']);
                                                prefs.setString('TIME_START',
                                                    detailData['timeStart']);
                                                prefs.setString(
                                                    'TIME_END',
                                                    widget
                                                        .detailData['timeEnd']);
                                                prefs.setString(
                                                    'EVENT_DESCRIPTION',
                                                    detailData['description']);
                                                prefs.setString('EVENT_PHONE',
                                                    detailData['phone']);
                                                prefs.setString('EVENT_EMAIL',
                                                    detailData['email']);
                                                prefs.setString(
                                                    'EVENT_WEBSITE',
                                                    widget
                                                        .detailData['website']);
                                                prefs.setString('EVENT_LAT',
                                                    detailData['latitude']);
                                                prefs.setString('EVENT_LONG',
                                                    detailData['longitude']);
                                                prefs.setString(
                                                    'EVENT_ADDRESS',
                                                    widget
                                                        .detailData['address']);
                                                prefs.setString('EVENT_IMAGE',
                                                    detailData['photoFull']);
                                                print('additional: ' +
                                                    detailData['additional']
                                                        .toString());

                                                print(prefs
                                                    .getStringList(
                                                        'EVENT_CATEGORY')
                                                    .toString());
                                                Navigator.of(thisContext).pop();

                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            EditEvent(
                                                                additional:
                                                                    detailData[
                                                                        'additional'])))
                                                    .then((value) {
                                                  if (value == true) {
                                                    getEventDetailsSpecificInfo()
                                                        .then((response) {
                                                      print(
                                                          response.statusCode);
                                                      var extractedData =
                                                          json.decode(
                                                              response.body);
                                                      if (response.statusCode ==
                                                          200) {
                                                        setState(() {
                                                          detailData =
                                                              extractedData[
                                                                  'data'];
                                                          isLoading = false;
                                                        });
                                                      }
                                                    });
                                                    isLoading = false;
                                                  }
                                                });
                                              },
                                              child: Text('Edit Event')),
                                          CupertinoActionSheetAction(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CustomFormActivator(
                                                              eventId:
                                                                  widget.id,
                                                                  from: 'EventDetails'
                                                            ),),);
                                              },
                                              child: Text('Edit Custom Form')),
                                        ],
                                      cancelButton: CupertinoActionSheetAction(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.red))));
                            });
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: eventajaGreenTeal,
                        size: 25,
                      ),
                    ),
                    SizedBox(width: 15),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (widget.ticketStat['salesStatus'] == null ||
                    widget.ticketStat['salesStatus'] == 'null') {
                  if (detailData['ticket_type']['type'] == 'free' ||
                      detailData['ticket_type']['type'] == 'no_ticket') {
                    print('show modal');
                    showGoingOption();
                  }
                } else {
                  if (widget.ticketStat['salesStatus'] == 'endSales' ||
                      widget.ticketStat['salesStatus'] == 'comingSoon' ||
                      widget.ticketPrice.toLowerCase() == 'canceled' ||
                      widget.ticketStat['availablewidget.ticketStatus'] ==
                          '0') {
                    return;
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => SelectTicketWidget(
                              eventID: detailData['id'],
                              eventDate: detailData['dateStart'],
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
                          fontSize: 16,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        )),
                    Expanded(
                      child: SizedBox(),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.isRest == true) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginRegisterWidget(
                                  previousWidget: 'EventDetailsWidgetRest',
                                  eventId: widget.id)));
                        } else {
                          if (widget.ticketStat['salesStatus'] == null) {
                          } else if (widget.ticketType['type'] == 'free') {
                            showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    SuccessPage());
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
                            if (widget.ticketStat['salesStatus'] ==
                                    'endSales' ||
                                widget
                                        .ticketStat['salesStatus'] ==
                                    'comingSoon' ||
                                widget.ticketPrice.toLowerCase() ==
                                    'canceled' ||
                                widget.ticketStat[
                                        'availablewidget.ticketStatus'] ==
                                    '0') {
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
                        }
                      },
                      child: Container(
                        height: ScreenUtil.instance.setWidth(32 * 1.1),
                        width: ScreenUtil.instance.setWidth(
                            widget.ticketStat['salesStatus'] == "comingSoon"
                                ? 135
                                : 110 * 1.1),
                        decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: widget.ticketStat['salesStatus'] ==
                                          'comingSoon'
                                      ? Color(0xFF34B323).withOpacity(.2)
                                      : isGoing == true
                                          ? Colors.blue.withOpacity(0.4)
                                          : widget.itemColor.withOpacity(0.4),
                                  blurRadius: 2,
                                  spreadRadius: 1.5)
                            ],
                            color:
                                widget.ticketStat['salesStatus'] == 'comingSoon'
                                    ? Color(0xFF34B323).withOpacity(.5)
                                    : isGoing == true
                                        ? Colors.blue
                                        : widget.itemColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: Text(
                          isGoing == true ? 'Going!' : widget.ticketPrice,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.instance.setSp(16),
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
                detailData == null
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
                              getEventDetailsSpecificInfo();
                              getInvitedUser();
                              getData();
                              _currentTime = DateTime.now();
                              _timer = Timer.periodic(
                                  Duration(seconds: 1), _onTimeChange);
                            });
                            refreshController.refreshCompleted();
                          },
                          child: ListView(
                            padding: EdgeInsets.symmetric(horizontal: 11),
                            shrinkWrap: true,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 13),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: ScreenUtil.instance
                                          .setWidth(122.86 * 1.6),
                                      height: ScreenUtil.instance
                                          .setWidth(184.06 * 1.6),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 10,
                                                color: Color(0xff8a8a8b)
                                                    .withOpacity(.5),
                                                spreadRadius: 1.5)
                                          ],
                                          image: DecorationImage(
                                              image: detailData['photo'] == null
                                                  ? AssetImage(
                                                      'assets/grey-fade.jpg')
                                                  : NetworkImage(widget
                                                      .detailData['photo']),
                                              fit: BoxFit.fill)),
                                    ),
                                    // Expanded(child: SizedBox()),
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
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
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ProfileWidget(
                                                                    isRest: widget
                                                                        .isRest,
                                                                    userId: widget
                                                                            .detailData[
                                                                        'createdByID'],
                                                                    initialIndex:
                                                                        0,
                                                                  )));
                                                    },
                                                    child: SizedBox(
                                                      height: ScreenUtil
                                                          .instance
                                                          .setWidth(30),
                                                      width: ScreenUtil.instance
                                                          .setWidth(30),
                                                      child: Container(
                                                        height: ScreenUtil
                                                            .instance
                                                            .setWidth(30),
                                                        width: ScreenUtil
                                                            .instance
                                                            .setWidth(30),
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image: DecorationImage(
                                                                image: NetworkImage(widget
                                                                    .creatorImageUri
                                                                    .toString()),
                                                                fit: BoxFit
                                                                    .cover)),
                                                      ),
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
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ProfileWidget(
                                                                            userId:
                                                                                detailData['createdByID'],
                                                                            initialIndex:
                                                                                0,
                                                                          )));
                                                        },
                                                        child: Text(
                                                          widget.creatorFullName ==
                                                                  null
                                                              ? 'loading'
                                                              : widget
                                                                  .creatorFullName
                                                                  .toString(),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  ScreenUtil
                                                                      .instance
                                                                      .setSp(
                                                                          12),
                                                              color:
                                                                  eventajaGreenTeal,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Text(
                                                          widget.creatorName ==
                                                                  null
                                                              ? ''
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
                                                    .setWidth(150),
                                                child: Text(
                                                  widget.dateTime,
                                                  style: TextStyle(
                                                    fontSize: ScreenUtil
                                                        .instance
                                                        .setSp(12),
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: ScreenUtil.instance
                                                    .setWidth(5),
                                              ),
                                              detailData['isHybridEvent'] ==
                                                      'streamOnly'
                                                  ? Row(
                                                      children: <Widget>[
                                                        Image.asset(
                                                            'assets/online-event.png',
                                                            scale: 25),
                                                      ],
                                                    )
                                                  : Container(),
                                              detailData['isHybridEvent'] ==
                                                      'streamOnly'
                                                  ? SizedBox(
                                                      height: ScreenUtil
                                                          .instance
                                                          .setWidth(10),
                                                    )
                                                  : Container(),
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
                                                    .setWidth(170),
                                                child: MarqueeWidget(
                                                  text: detailData['name'] ==
                                                          null
                                                      ? '-'
                                                      : widget
                                                          .detailData['name']
                                                          .toUpperCase(),
                                                  scrollAxis: Axis.horizontal,
                                                  textStyle: TextStyle(
                                                      fontSize: ScreenUtil
                                                          .instance
                                                          .setSp(15),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  ratioOfBlankToScreen: .05,
                                                ),
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
                                                        'assets/icons/location-transparent.png'),
                                                  ),
                                                  SizedBox(
                                                      width: ScreenUtil.instance
                                                          .setWidth(5)),
                                                  detailData['address']
                                                              .toString()
                                                              .length <
                                                          30
                                                      ? Text(
                                                          detailData['address'],
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
                                                              .setWidth(150),
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
                                                                fontSize:
                                                                    ScreenUtil
                                                                        .instance
                                                                        .setSp(
                                                                            11)),
                                                            ratioOfBlankToScreen:
                                                                .05,
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
                                                    .setWidth(30),
                                              ),
                                              StatefulBuilder(
                                                builder: (context, setState) =>
                                                    GestureDetector(
                                                  onTap: () {
                                                    if (widget.isRest == true) {
                                                      Navigator.of(context).push(MaterialPageRoute(
                                                          builder: (context) =>
                                                              LoginRegisterWidget(
                                                                  previousWidget:
                                                                      'EventDetailsWidgetRest',
                                                                  eventId: widget
                                                                      .id)));
                                                    } else {
                                                      if (widget.ticketStat[
                                                                  'salesStatus'] ==
                                                              null ||
                                                          widget.ticketStat[
                                                                  'salesStatus'] ==
                                                              'null') {
                                                        if (detailData['ticket_type']
                                                                    ['type'] ==
                                                                'free' ||
                                                            detailData['ticket_type']
                                                                    ['type'] ==
                                                                'no_ticket') {
                                                          print('show modal');
                                                          if (isGoing == true) {
                                                            ungoing().then(
                                                                (response) {
                                                              isLoading = true;
                                                              print(response
                                                                  .statusCode);
                                                              print(response
                                                                  .body);

                                                              if (response.statusCode ==
                                                                      200 ||
                                                                  response.statusCode ==
                                                                      201) {
                                                                setState(() {
                                                                  isGoing =
                                                                      false;
                                                                });
                                                                isLoading =
                                                                    false;
                                                              } else {
                                                                isLoading =
                                                                    false;
                                                              }
                                                            });
                                                          } else {
                                                            showGoingOption();
                                                          }
                                                        }
                                                      } else {
                                                        if (widget.ticketStat[
                                                                    'salesStatus'] ==
                                                                'endSales' ||
                                                            widget.ticketStat[
                                                                    'salesStatus'] ==
                                                                'comingSoon' ||
                                                            widget.ticketPrice
                                                                    .toLowerCase() ==
                                                                'canceled' ||
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
                                                                        eventID:
                                                                            widget.detailData['id'],
                                                                        eventDate:
                                                                            widget.detailData['dateStart'],
                                                                      )));
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    height: ScreenUtil.instance
                                                        .setWidth(32 * 1.1),
                                                    width: ScreenUtil.instance
                                                        .setWidth(widget.ticketStat[
                                                                    'salesStatus'] ==
                                                                "comingSoon"
                                                            ? 135
                                                            : 110 * 1.1),
                                                    decoration: BoxDecoration(
                                                        boxShadow: <BoxShadow>[
                                                          BoxShadow(
                                                              color: widget.ticketStat[
                                                                          'salesStatus'] ==
                                                                      'comingSoon'
                                                                  ? Color(0xFF34B323)
                                                                      .withOpacity(
                                                                          .2)
                                                                  : isGoing ==
                                                                          true
                                                                      ? Colors
                                                                          .blue
                                                                          .withOpacity(
                                                                              0.4)
                                                                      : widget
                                                                          .itemColor
                                                                          .withOpacity(
                                                                              0.4),
                                                              blurRadius: 2,
                                                              spreadRadius: 1.5)
                                                        ],
                                                        color: widget.ticketStat[
                                                                    'salesStatus'] ==
                                                                'comingSoon'
                                                            ? Color(0xFF34B323)
                                                                .withOpacity(.5)
                                                            : isGoing == true
                                                                ? Colors.blue
                                                                : widget
                                                                    .itemColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30)),
                                                    child: Center(
                                                        child: Text(
                                                      isGoing == true
                                                          ? 'Going!'
                                                          : widget.ticketPrice,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: ScreenUtil
                                                              .instance
                                                              .setSp(16),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                  ),
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
                                      eventId: widget.id,
                                      isAlreadyLoved:
                                          detailData['isLoved'] == '1'
                                              ? true
                                              : false,
                                      loveCount:
                                          int.parse(detailData['countLove']),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.instance.setWidth(10),
                                    ),
                                    LoveItem(
                                          isComment: true,
                                          eventId: widget.id,
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
                                        child: Image.asset(
                                          widget.phoneNumber == null ||
                                                  widget.phoneNumber == ""
                                              ? 'assets/icons/btn_phone.png'
                                              : 'assets/icons/btn_phone_active.png',
                                        ),
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
                                      onTap: widget.website == null ||
                                              widget.website == ""
                                          ? () {}
                                          : () =>
                                              launch(widget.website.toString()),
                                      child: SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(33),
                                        width: ScreenUtil.instance.setWidth(33),
                                        child: Image.asset(
                                          widget.website == null ||
                                                  widget.website == ""
                                              ? 'assets/icons/btn_web.png'
                                              : 'assets/icons/btn_web_active.png',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              widget.isPrivate == "0" || invitedUserList == null
                                  ? Container()
                                  : SizedBox(
                                      height: ScreenUtil.instance.setWidth(20),
                                    ),
                              widget.isPrivate == "0" || invitedUserList == null
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
                                                                    isRest: widget
                                                                        .isRest,
                                                                    eventId: widget
                                                                            .detailData[
                                                                        'id'],
                                                                    peopleType:
                                                                        'invited',
                                                                  )));
                                                    },
                                                    child: Container(
                                                      height: 10,
                                                      child: Text(
                                                        'See All >',
                                                        style: TextStyle(
                                                            fontSize: 11,
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
                                                    .setWidth(2)),
                                            Container(
                                              height: ScreenUtil.instance
                                                  .setWidth(50),
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
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              ProfileWidget(
                                                            initialIndex: 0,
                                                            isRest:
                                                                widget.isRest,
                                                            userId: widget
                                                                        .detailData[
                                                                    'invited'][
                                                                'data'][i]['id'],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Container(
                                                            height: ScreenUtil
                                                                .instance
                                                                .setWidth(35),
                                                            width: ScreenUtil
                                                                .instance
                                                                .setWidth(35),
                                                            decoration:
                                                                BoxDecoration(
                                                                    boxShadow: <
                                                                        BoxShadow>[
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black26,
                                                                      offset: Offset(
                                                                          1.0,
                                                                          1.0),
                                                                      blurRadius:
                                                                          3)
                                                                ],
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image:
                                                                        DecorationImage(
                                                                      image: CachedNetworkImageProvider(
                                                                          invitedUserList[i]
                                                                              [
                                                                              'photo']),
                                                                      fit: BoxFit
                                                                          .cover,
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
                                    ),
                              SizedBox(
                                height: 0,
                              ),
                              detailData['ticket']['salesStatus'] ==
                                      'comingSoon'
                                  ? countdownTimer()
                                  : Container(),
                              widget.goingData == null ||
                                      widget.goingData.length < 1
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                                  isRest: widget
                                                                      .isRest,
                                                                  eventId: widget
                                                                          .detailData[
                                                                      'id'],
                                                                  peopleType:
                                                                      'going',
                                                                )));
                                                  },
                                                  child: Container(
                                                    height: 10,
                                                    child: Text(
                                                      'See All >',
                                                      style: TextStyle(
                                                          fontSize: 11,
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
                                                  .setWidth(2)),
                                          Container(
                                            height: ScreenUtil.instance
                                                .setWidth(50),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  widget.goingData == null
                                                      ? 0
                                                      : widget.goingData.length,
                                              itemBuilder:
                                                  (BuildContext context, i) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                ProfileWidget(
                                                                  isRest: widget
                                                                      .isRest,
                                                                  initialIndex:
                                                                      0,
                                                                  userId: detailData[
                                                                              'going']
                                                                          [
                                                                          'data'][i]
                                                                      [
                                                                      'userID'],
                                                                )));
                                                  },
                                                  child: new Container(
                                                    margin: EdgeInsets.only(
                                                        left: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                          height: ScreenUtil
                                                              .instance
                                                              .setWidth(35),
                                                          width: ScreenUtil
                                                              .instance
                                                              .setWidth(35),
                                                          decoration:
                                                              BoxDecoration(
                                                                  boxShadow: <
                                                                      BoxShadow>[
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .black26,
                                                                    offset:
                                                                        Offset(
                                                                            1.0,
                                                                            1.0),
                                                                    blurRadius:
                                                                        3)
                                                              ],
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image:
                                                                      DecorationImage(
                                                                    image: CachedNetworkImageProvider(detailData['going']
                                                                            [
                                                                            'data'][i]
                                                                        [
                                                                        'photo']),
                                                                    fit: BoxFit
                                                                        .cover,
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
                              detailData['status'] == 'ended' &&
                                      widget.isRest == false
                                  ? SizedBox(
                                      height: ScreenUtil.instance.setWidth(20),
                                    )
                                  : Container(),
                              detailData['status'] == 'ended' &&
                                      widget.isRest == false
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
                                                                  eventId: detailData !=
                                                                              null ||
                                                                          !detailData
                                                                              .isEmpty
                                                                      ? detailData[
                                                                          'id']
                                                                      : widget.detailData[
                                                                          'id'],
                                                                  eventName: detailData !=
                                                                              null ||
                                                                          !detailData
                                                                              .isEmpty
                                                                      ? detailData[
                                                                          'name']
                                                                      : widget.detailData[
                                                                          'name'],
                                                                  goodReview: detailData !=
                                                                              null ||
                                                                          !detailData
                                                                              .isEmpty
                                                                      ? detailData['event_review']
                                                                              [
                                                                              'percent_review']
                                                                          [
                                                                          'good']
                                                                      : widget.detailData['event_review']
                                                                              [
                                                                              'percent_review']
                                                                          [
                                                                          'good'],
                                                                  badReview: detailData !=
                                                                              null ||
                                                                          !detailData
                                                                              .isEmpty
                                                                      ? detailData['event_review']
                                                                              [
                                                                              'percent_review']
                                                                          [
                                                                          'bad']
                                                                      : widget.detailData['event_review']
                                                                              [
                                                                              'percent_review']
                                                                          [
                                                                          'bad'],
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
                                                  percent: int.parse(detailData !=
                                                                  null ||
                                                              !detailData
                                                                  .isEmpty
                                                          ? detailData[
                                                                      'event_review']
                                                                  [
                                                                  'percent_review']
                                                              ['good']
                                                          : widget.detailData[
                                                                      'event_review']
                                                                  [
                                                                  'percent_review']
                                                              ['good']) /
                                                      100,
                                                ),
                                              ),
                                              Container(
                                                width: ScreenUtil.instance
                                                    .setWidth(40),
                                                child: Text(
                                                  (detailData != null ||
                                                          !detailData.isEmpty
                                                      ? detailData['event_review']
                                                              ['percent_review']
                                                          ['good']
                                                      : detailData['event_review']
                                                                  [
                                                                  'percent_review']
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
                                                  percent: int.parse(detailData !=
                                                                  null ||
                                                              !detailData
                                                                  .isEmpty
                                                          ? detailData[
                                                                      'event_review']
                                                                  [
                                                                  'percent_review']
                                                              ['bad']
                                                          : widget.detailData[
                                                                      'event_review']
                                                                  [
                                                                  'percent_review']
                                                              ['bad']) /
                                                      100,
                                                ),
                                              ),
                                              Container(
                                                width: ScreenUtil.instance
                                                    .setWidth(40),
                                                child: Text(
                                                  detailData != null ||
                                                          !detailData.isEmpty
                                                      ? detailData[
                                                                  'event_review']
                                                              ['percent_review']
                                                          ['bad']
                                                      : widget.detailData[
                                                                      'event_review']
                                                                  [
                                                                  'percent_review']
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
                                            height: detailData['event_review']
                                                            ['user_review'] ==
                                                        '1' ||
                                                    detailData['isGoing'] == '0'
                                                ? 0
                                                : 15,
                                          ),
                                          detailData['event_review']
                                                          ['user_review'] ==
                                                      '1' ||
                                                  detailData['isGoing'] == '0'
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

                                                                          FeedbackLogic.postFeedback(detailData['id'], typeId, feedbackInputController.text).then(
                                                                              (response) {
                                                                            if (response.statusCode == 201 ||
                                                                                response.statusCode == 200) {
                                                                              getEventDetailsSpecificInfo().then((response) {
                                                                                print(response.statusCode);
                                                                                var extractedData = json.decode(response.body);
                                                                                if (response.statusCode == 200) {
                                                                                  setState(() {
                                                                                    detailData = extractedData['data'];
                                                                                    isLoading = false;
                                                                                  });
                                                                                }
                                                                              });
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
                              detailData['createdByID'] != currentUserId
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
                                              saveId(detailData['id']);
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder:
                                                          (BuildContext
                                                                  context) =>
                                                              ManageTicket(
                                                                isLivestream:
                                                                    detailData['isHybridEvent'] ==
                                                                            'streamOnly'
                                                                        ? true
                                                                        : false,
                                                                eventID:
                                                                    widget.id,
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
                                              if (widget.detailData[
                                                              'ticket_type']
                                                          ['type'] ==
                                                      'free_live_stream' ||
                                                  widget.detailData[
                                                              'ticket_type']
                                                          ['type'] ==
                                                      'paid_live_stream') {
                                                print('isLivestream');

                                                if (widget.detailData[
                                                            'livestream'][0]
                                                        ['on_demand_link'] !=
                                                    null) {
                                                  showCupertinoDialog(
                                                    context: context,
                                                    builder: (thisContext) {
                                                      return CupertinoAlertDialog(
                                                        title: Text('Notice'),
                                                        content: Text(
                                                          'You uploaded on demand video',
                                                          textScaleFactor: 1.2,
                                                          textWidthBasis:
                                                              TextWidthBasis
                                                                  .longestLine,
                                                        ),
                                                        actions: <Widget>[
                                                          CupertinoDialogAction(
                                                            child:
                                                                Text('Close'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      thisContext)
                                                                  .pop();
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else if (widget.detailData[
                                                            'livestream'][0]
                                                        ['zoom_id'] !=
                                                    null) {
                                                  showCupertinoDialog(
                                                    context: context,
                                                    builder: (thisContext) {
                                                      return CupertinoAlertDialog(
                                                        title: Text('Notice'),
                                                        content: Text(
                                                          'please start broadcast using zoom link you provide to your attendees',
                                                          textScaleFactor: 1.2,
                                                          textWidthBasis:
                                                              TextWidthBasis
                                                                  .longestLine,
                                                        ),
                                                        actions: <Widget>[
                                                          CupertinoDialogAction(
                                                            child:
                                                                Text('Close'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      thisContext)
                                                                  .pop();
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  if (streamingState ==
                                                      'stopped') {
                                                    showCupertinoDialog(
                                                        context: context,
                                                        builder: (thisContext) {
                                                          return CupertinoAlertDialog(
                                                            title:
                                                                Text('Notice'),
                                                            content: Text(
                                                              'Please broadcast 5 minutes before the event start',
                                                              textScaleFactor:
                                                                  1.2,
                                                              textWidthBasis:
                                                                  TextWidthBasis
                                                                      .longestLine,
                                                            ),
                                                            actions: <Widget>[
                                                              CupertinoDialogAction(
                                                                child: Text(
                                                                    'Close'),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          thisContext)
                                                                      .pop();
                                                                },
                                                              )
                                                            ],
                                                          );
                                                        });
                                                  } else {
                                                    showCupertinoModalPopup(
                                                        context: context,
                                                        builder: (thisContext) {
                                                          return CupertinoActionSheet(
                                                            title: Text(
                                                                'Set Broadcast Bitrate'),
                                                            actions: <Widget>[
                                                              CupertinoActionSheetAction(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => LivestreamBroadcast(
                                                                          bitrate:
                                                                              1000,
                                                                          eventDetail:
                                                                              widget.detailData),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Text(
                                                                    '1000 Kbps ( Medium Quality )'),
                                                              ),
                                                              CupertinoActionSheetAction(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => LivestreamBroadcast(
                                                                          bitrate:
                                                                              2500,
                                                                          eventDetail:
                                                                              widget.detailData),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Text(
                                                                    '2500 Kbps ( High Quality )'),
                                                              ),
                                                            ],
                                                            cancelButton:
                                                                CupertinoActionSheetAction(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    thisContext);
                                                              },
                                                              child: Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  }
                                                }
                                              } else {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.setString('NEW_EVENT_ID',
                                                    detailData['id']);
                                                prefs.setString(
                                                    'QR_URI',
                                                    detailData['qrcode']
                                                        ['secure_url']);
                                                prefs.setString('EVENT_NAME',
                                                    detailData['name']);
                                                print(prefs
                                                    .getString('NEW_EVENT_ID'));
                                                print(
                                                    prefs.getString('QR_URI'));
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        ShowQr(
                                                      qrUrl: prefs
                                                          .getString('QR_URI'),
                                                      eventName: widget
                                                          .detailData['name'],
                                                    ),
                                                  ),
                                                );
                                              }
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
                                                      width: ScreenUtil.instance.setWidth(
                                                          widget.detailData['ticket_type']['type'] == 'free_live_stream' ||
                                                                  widget.detailData['ticket_type']['type'] ==
                                                                      'paid_live_stream'
                                                              ? widget.detailData['livestream'].isNotEmpty &&
                                                                      widget.detailData['livestream'][0]['zoom_id'] !=
                                                                          null
                                                                  ? 80
                                                                  : 50
                                                              : 20.9),
                                                      child:
                                                          widget.detailData
                                                                      .containsKey(
                                                                          'livestream') &&
                                                                  widget
                                                                      .detailData[
                                                                          'livestream']
                                                                      .isNotEmpty &&
                                                                  widget.detailData['livestream']
                                                                              [0]
                                                                          ['on_demand_link'] !=
                                                                      null
                                                              ? Text(
                                                                  'On Demand Video',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                )
                                                              : Image.asset(
                                                                  widget.detailData['ticket_type']['type'] ==
                                                                              'free_live_stream' ||
                                                                          widget.detailData['ticket_type']['type'] ==
                                                                              'paid_live_stream'
                                                                      ? widget.detailData['livestream'].isNotEmpty &&
                                                                              widget.detailData['livestream'][0]['zoom_id'] != null
                                                                          ? 'assets/icons/aset_icon/zoom_livestream.png'
                                                                          : 'assets/btn_ticket/live.png'
                                                                      : 'assets/icons/icon_apps/qr.png',
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  colorBlendMode:
                                                                      BlendMode
                                                                          .srcATop,
                                                                  color: widget.detailData['ticket_type']['type'] ==
                                                                              'free_live_stream' ||
                                                                          widget.detailData['ticket_type']['type'] ==
                                                                              'paid_live_stream'
                                                                      ? streamingState ==
                                                                              'stopped'
                                                                          ? Colors.white.withOpacity(
                                                                              .9)
                                                                          : Colors
                                                                              .transparent
                                                                      : Colors
                                                                          .transparent,
                                                                )),
                                                  widget.detailData.containsKey(
                                                              'livestream') &&
                                                          widget
                                                              .detailData[
                                                                  'livestream']
                                                              .isNotEmpty &&
                                                          widget.detailData[
                                                                      'livestream'][0]
                                                                  [
                                                                  'on_demand_link'] !=
                                                              null
                                                      ? Container()
                                                      : SizedBox(
                                                          height: ScreenUtil
                                                              .instance
                                                              .setWidth(15),
                                                        ),
                                                  Text(
                                                      widget.detailData['ticket_type']['type'] ==
                                                                  'free_live_stream' ||
                                                              widget.detailData['ticket_type']
                                                                      [
                                                                      'type'] ==
                                                                  'paid_live_stream'
                                                          ? widget
                                                                      .detailData[
                                                                          'livestream']
                                                                      .isNotEmpty &&
                                                                  widget.detailData['livestream'][0]['on_demand_link'] !=
                                                                      null
                                                              ? ''
                                                              : 'NOW !'
                                                          : 'SHOW QR CODE',
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
                                        behavior:
                                            prefix0.HitTestBehavior.opaque,
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
                                        behavior:
                                            prefix0.HitTestBehavior.opaque,
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
                                        behavior:
                                            prefix0.HitTestBehavior.opaque,
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
                    detailData['name'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(
                        detailData['additional'].length == 0 ? 0 : 29),
                  ),
                  detailData['additional'].length == 0
                      ? Container()
                      : Container(
                          child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: detailData['additional']
                                .map<Widget>((additional) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => additional[
                                                      'extension'] ==
                                                  'image/jpeg' ||
                                              additional['extension'] ==
                                                  'image/png' ||
                                              additional['file_name']
                                                  .toString()
                                                  .contains(".jpg") ||
                                              additional['file_name']
                                                  .toString()
                                                  .contains(".png")
                                          ? PhotoView(
                                            
                                              imageProvider: NetworkImage(
                                                  additional['posterPathFull']),
                                            )
                                          : MediaPlayer(
                                              videoHeight:
                                                  additional['pictureHeight'],
                                              videoWidth:
                                                  additional['pictureWidth'],
                                              videoUri:
                                                  additional['posterPathFull']),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  height: ScreenUtil.instance.setWidth(
                                      additional['pictureHeight'] == ""
                                          ? 184.06 * 1.3
                                          : double.parse(additional[
                                                      'pictureHeight']) >
                                                  double.parse(additional[
                                                      'pictureWidth'])
                                              ? 250 * 1.3
                                              : double.parse(additional[
                                                      'pictureHeight']) /
                                                  1.5),
                                  width: ScreenUtil.instance.setWidth(
                                      additional['pictureWidth'] == ""
                                          ? 122.86 * 1.3
                                          : double.parse(additional[
                                                      'pictureWidth']) <
                                                  double.parse(additional[
                                                      'pictureHeight'])
                                              ? 165 * 1.3
                                              : double.parse(additional[
                                                      'pictureWidth']) /
                                                  1.5),
                                  decoration: BoxDecoration(
                                      color: Color(0xff8a8a8b),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            additional['posterPathThumb'],
                                          ),
                                          fit: BoxFit.fill),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Center(
                                      child:
                                          additional['extension'] ==
                                                      'image/jpeg' ||
                                                  additional['extension'] ==
                                                      'image/png' ||
                                                  additional['file_name']
                                                      .toString()
                                                      .contains(".jpg") ||
                                                  additional['file_name']
                                                      .toString()
                                                      .contains(".png")
                                              ? Container()
                                              : Icon(
                                                  Icons.play_circle_filled,
                                                  color: Colors.white,
                                                  size: 50,
                                                )),
                                ),
                              );
                            }).toList(),
                          ),
                        )),
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
            detailData['isHybridEvent'] == 'streamOnly'
                ? Container()
                : Container(
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
        eventId: detailData['id'],
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
                        eventID: detailData['id'],
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
          SizedBox(
            height: 30,
          ),
          detailData['comment'].length == 0
              ? Container(
                  height: 15,
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: detailData['comment'] == null
                      ? 0
                      : detailData['comment'].length,
                  itemBuilder: (context, i) {
                    List commentList = detailData['comment'];
                    return Container(
                      margin: EdgeInsets.only(bottom: 25, left: 13, right: 13),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                NetworkImage(detailData['comment'][i]['photo']),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                detailData['comment'][i]['fullName'] +
                                    '' +
                                    ': ',
                                style: TextStyle(
                                    fontSize: ScreenUtil.instance.setSp(14),
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                  width: 210,
                                  child: Text(
                                      detailData['comment'][i]['response'])),
                            ],
                          ),
                          Expanded(child: Container()),
                          detailData['comment'][i]['userID'] == currentUserId
                              ? Container(
                                  height: 50,
                                  width: 50,
                                  child: GestureDetector(
                                    onTap: () {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (thisContext) {
                                          return CupertinoAlertDialog(
                                            title: Text('Notice'),
                                            content: Text(
                                              'Do you want to delete this comment?',
                                              textScaleFactor: 1.2,
                                              textWidthBasis:
                                                  TextWidthBasis.longestLine,
                                            ),
                                            actions: <Widget>[
                                              CupertinoDialogAction(
                                                child: Text('No'),
                                                onPressed: () {
                                                  Navigator.of(
                                                    thisContext,
                                                  ).pop();
                                                },
                                              ),
                                              CupertinoDialogAction(
                                                child: Text('Yes'),
                                                onPressed: () {
                                                  Navigator.of(
                                                    thisContext,
                                                  ).pop();
                                                  deleteComment(
                                                    detailData['comment'][i]
                                                        ['id'],
                                                  ).then(
                                                    (response) {
                                                      if (response.statusCode ==
                                                              200 ||
                                                          response.statusCode ==
                                                              201) {
                                                        print(response.body);
                                                        isLoading = false;
                                                        detailData['comment']
                                                            .removeAt(i);
                                                      } else {
                                                        print(response.body);
                                                        isLoading = false;
                                                        Flushbar(
                                                          backgroundColor:
                                                              Colors.red,
                                                          flushbarPosition:
                                                              FlushbarPosition
                                                                  .TOP,
                                                          animationDuration:
                                                              Duration(
                                                                  milliseconds:
                                                                      500),
                                                          duration: Duration(
                                                              seconds: 3),
                                                          message:
                                                              response.body,
                                                        ).show(context);
                                                      }
                                                    },
                                                  ).catchError((err) {
                                                    isLoading = false;
                                                    Flushbar(
                                                            backgroundColor:
                                                                Colors.red,
                                                            flushbarPosition:
                                                                FlushbarPosition
                                                                    .TOP,
                                                            animationDuration:
                                                                Duration(
                                                                    milliseconds:
                                                                        500),
                                                            duration: Duration(
                                                                seconds: 3),
                                                            message:
                                                                err.toString())
                                                        .show(context);
                                                  });
                                                },
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(Icons.close,
                                        color: Colors.grey.withOpacity(.5)),
                                  ),
                                )
                              : Container(width: 100),
                        ],
                      ),
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

  Future<http.Response> deleteComment(String commentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoading = true;
    if (mounted) {
      setState(() {});
    }

    String url = BaseApi().apiUrl + '/eventdetail_comment/delete';

    final response = await http.delete(url, headers: {
      'cookie': prefs.getString('Session'),
      'Authorization': AUTH_KEY,
      'X-API-KEY': API_KEY,
      'id': commentId
    });

    return response;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Ticket sales start from '),
              Text(
                  '${widget.dDay.day} - ${widget.dDay.month} - ${widget.dDay.year}',
                  style: TextStyle(color: eventajaGreenTeal))
            ],
          ),
          Text(countdownAsString,
              style: TextStyle(
                  color: eventajaGreenTeal,
                  fontSize: ScreenUtil.instance.setSp(32),
                  fontWeight: FontWeight.bold)),
        ],
      )),
    );
  }

  Widget showMap() {
    StaticMapsProvider mapProvider = new StaticMapsProvider(
      GOOGLE_API_KEY: 'AIzaSyA2s9iDKooQ9Cwgr6HiDVQkG9p3fvsVmEI',
      height: 215,
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
    print(detailData['name']);
  }

  showGoingOption() {
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
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: ScreenUtil.instance.setWidth(122.86),
                        height: ScreenUtil.instance.setWidth(184.06),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey,
                            image: DecorationImage(
                                image:
                                    NetworkImage(widget.detailData['photo']))),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: ScreenUtil.instance.setWidth(200),
                              child: Text(
                                detailData['name'],
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
                                  detailData['description'],
                                  maxLines: 8,
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(12)),
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
                          height: ScreenUtil.instance.setWidth(30),
                          width: ScreenUtil.instance.setWidth(100),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30)),
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
                      SizedBox(width: ScreenUtil.instance.setWidth(8)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            isLoading = true;
                          });
                          goingToEvent().then((response) {
                            print(response.statusCode);
                            print(response.body);

                            if (response.statusCode == 201) {
                              getEventDetailsSpecificInfo().then((response) {
                                print(response.statusCode);
                                var extractedData = json.decode(response.body);
                                if (response.statusCode == 200) {
                                  setState(() {
                                    detailData = extractedData['data'];
                                    isLoading = false;
                                    isGoing = true;
                                  });
                                }
                              });
                              isLoading = false;
                            } else {
                              isLoading = false;
                              setState(() {});
                            }
                          });
                        },
                        child: Container(
                          height: ScreenUtil.instance.setWidth(30),
                          width: ScreenUtil.instance.setWidth(100),
                          decoration: BoxDecoration(
                              color: eventajaGreenTeal,
                              borderRadius: BorderRadius.circular(30)),
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

  Future getInvitedUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String baseUrl = BaseApi().apiUrl;
    Map<String, String> headers;

    setState(() {
      if (widget.isRest == false) {
        headers = {
          'Authorization': AUTH_KEY,
          'cookie': preferences.getString('Session')
        };
        baseUrl = BaseApi().apiUrl;
      } else {
        headers = {'Authorization': AUTH_KEY, 'signature': SIGNATURE};
        baseUrl = BaseApi().restUrl;
      }
    });

    final invitedDataUrl = baseUrl +
        '/event/invited?X-API-KEY=$API_KEY&event_id=${widget.id}&page=all';
    final response = await http.get(invitedDataUrl, headers: headers);

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
    String baseUrl = BaseApi().apiUrl;
    Map<String, String> headers;

    setState(() {
      if (newPage != null) {
        currentPage += newPage;
      }

      if (widget.isRest == false) {
        headers = {
          'Authorization': AUTH_KEY,
          'cookie': prefs.getString('Session')
        };
        baseUrl = BaseApi().apiUrl;
      } else {
        headers = {'Authorization': AUTH_KEY, 'signature': SIGNATURE};
        baseUrl = BaseApi().restUrl;
      }

      print(currentPage);
    });

    String url = baseUrl +
        '/timeline/user?X-API-KEY=$API_KEY&page=1&userID=$currentUserId';

    final response = await http.get(url, headers: headers);

    print('body: ' + response.body);

    return response;
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
        baseUrl + '/event/detail?X-API-KEY=$API_KEY&eventID=${widget.id}';

    print(detailsInfoUrl);
    final response = await http.get(detailsInfoUrl, headers: headers);

    print('event detail page -> ' + response.statusCode.toString());
    print('event detail page -> ' + response.body);

    return response;
  }
}
