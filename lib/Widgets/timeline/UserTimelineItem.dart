import 'dart:convert';

import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/timeline/EditPost.dart';
import 'package:eventevent/Widgets/timeline/ReportPost.dart';
import 'package:eventevent/Widgets/timeline/UserMediaDetail.dart';
import 'package:eventevent/Widgets/timeline/VideoPlayer.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimelineItem extends StatefulWidget {
  final eventId;
  final id;
  final String userId;
  final String photo;
  final String isVerified;
  final String fullName;
  final String type;
  final String name;
  final DateTime dateTime;
  final String photoFull;
  final String description;
  final String picture;
  final String pictureFull;
  final int loveCount;
  final bool isLoved;
  final commentTotalRows;
  final String impressionId;
  final String location;
  final ticketType;
  final cheapestTicket;

  const TimelineItem(
      {Key key,
      this.id,
      this.photo,
      this.isVerified,
      this.fullName,
      this.type,
      this.name,
      this.photoFull,
      this.description,
      this.picture,
      this.pictureFull,
      this.userId,
      this.commentTotalRows,
      this.loveCount,
      this.isLoved,
      this.impressionId,
      this.dateTime,
      this.location,
      this.eventId,
      this.ticketType,
      this.cheapestTicket})
      : super(key: key);

  @override
  _TimelineItemState createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem>
    with WidgetsBindingObserver {
  List timelineList = [];
  bool isLoading = false;
  bool _isLoved;
  bool isLivestream = false;
  String dateUploaded = 'now';
  String ticketPrice = '';
  Color ticketColor = eventajaGreenTeal;

  int _loveCount = 0;

  RefreshController homeRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    setState(() {
      if (widget.ticketType == 'free_live_stream') {
        ticketPrice = 'Free Live Stream';
        ticketColor = Color(0xFFFFAA00);
        isLivestream = true;
      } else if (widget.ticketType == 'paid_live_stream') {
        ticketPrice = 'Rp. ${widget.cheapestTicket}';
        ticketColor = eventajaGreenTeal;
        isLivestream = true;
      } else if (widget.ticketType == 'paid' ||
          widget.ticketType == 'paid_seating') {
        ticketPrice = 'Rp. ${widget.cheapestTicket}';
        ticketColor = eventajaGreenTeal;
      } else if (widget.ticketType == 'free_limited') {
        ticketPrice = 'Free Limited';
        ticketColor = Color(0xFFFFAA00);
      } else if (widget.ticketType == 'free') {
        ticketPrice = 'Free';
        ticketColor = Color(0xFFFFAA00);
      } else if (widget.ticketType == 'no_ticket') {
        ticketPrice = 'No Ticket';
        ticketColor = Color(0xFF652D90);
      } else if (widget.ticketType == 'on_the_spot') {
        ticketPrice = 'On The Spot';
        ticketColor = Color(0xFF652D90);
      }

      print(widget.dateTime.toString());
      var diff = DateTime.now().difference(widget.dateTime);
      if (diff.inSeconds < 59) {
        dateUploaded = 'Now';
      } else if (diff.inDays > 0 && diff.inDays < 2) {
        dateUploaded = 'a day ago';
      } else {
        dateUploaded = widget.dateTime.day.toString() +
            ' - ' +
            widget.dateTime.month.toString() +
            ' - ' +
            widget.dateTime.year.toString();
      }
      _isLoved = widget.isLoved;
      print('isLoved: ' + _isLoved.toString());
      _loveCount = widget.loveCount;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 1.5)
        ], color: Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: NetworkImage(widget.photo),
                            ),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(8),
                            ),
                            Container(
                                width: ScreenUtil.instance.setWidth(200.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        widget.isVerified == '1'
                                            ? Container(
                                                height: ScreenUtil.instance
                                                    .setWidth(18),
                                                width: ScreenUtil.instance
                                                    .setWidth(18),
                                                child: Image.asset(
                                                    'assets/icons/icon_apps/verif.png'))
                                            : Container(),
                                        SizedBox(
                                            width: ScreenUtil.instance
                                                .setWidth(5)),
                                        Text(widget.fullName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    SizedBox(
                                      height: ScreenUtil.instance.setWidth(5),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        widget.type == 'love'
                                            ? Image.asset(
                                                'assets/icons/icon_apps/love.png',
                                                scale: 3,
                                              )
                                            : Container(),
                                        SizedBox(
                                            width: ScreenUtil.instance
                                                .setWidth(5)),
                                        Text(
                                            widget.type == 'love'
                                                ? 'Loved'
                                                : widget.type == 'relationship'
                                                    ? widget.name
                                                    : 'Post a ' + widget.type,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: ScreenUtil.instance
                                                    .setSp(10))),
                                      ],
                                    ),
                                  ],
                                )),
                          ]),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            dateUploaded,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: ScreenUtil.instance.setSp(10)),
                          ),
                          SizedBox(height: ScreenUtil.instance.setWidth(4)),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                      height: widget.type == 'video' ||
                              widget.type == 'photo' ||
                              widget.type == 'event' ||
                              widget.type == 'eventgoing' ||
                              widget.id != null && widget.type == 'love'
                          ? 15
                          : 0),
                  widget.type == 'video' ||
                          widget.type == 'photo' ||
                          widget.type == 'eventgoing' ||
                          widget.id != null &&
                              widget.type != 'love' &&
                              widget.type != 'event' &&
                              widget.type != 'relationship' &&
                              widget.type != 'combined_relationship'
                      ? GestureDetector(
                          onTap: () {
                            if (widget.type == 'photo') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserMediaDetail(
                                            postID: widget.id,
                                            type: widget.type,
                                            imageUri: widget.photoFull,
                                            articleDetail: widget.description,
                                            mediaTitle: widget.description,
                                            autoFocus: false,
                                            username: widget.fullName,
                                            userPicture: widget.photo,
                                            imageCount: 1,
                                          )));
                            } else if (widget.type == 'event' ||
                                widget.type == 'eventgoing') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EventDetailLoadingScreen(
                                            eventId: widget.eventId,
                                          )));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MediaPlayer(
                                          videoUri: widget.photoFull)));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                    image: NetworkImage(
                                      widget.type == 'video'
                                          ? widget.picture
                                          : widget.pictureFull,
                                    ),
                                    fit: BoxFit.cover)),
                            height: ScreenUtil.instance.setWidth(400),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: widget.type == 'video'
                                  ? Icon(
                                      Icons.play_circle_filled,
                                      size: 80,
                                      color: Colors.white,
                                    )
                                  : Container(),
                            ),
                          ))
                      : Container(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      widget.type == 'love' || widget.type == 'event'
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailLoadingScreen(
                                      isRest: false,
                                      eventId: widget.eventId,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 3,
                                          blurRadius: 5,
                                          color:
                                              Color(0xff8a8a8b).withOpacity(.5))
                                    ],
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          widget.type == 'video'
                                              ? widget.picture
                                              : widget.pictureFull,
                                        ),
                                        fit: BoxFit.cover)),
                                height: ScreenUtil.instance.setWidth(100),
                                width: ScreenUtil.instance.setWidth(66),
                                child: Center(
                                  child: widget.type == 'video'
                                      ? Icon(
                                          Icons.play_circle_filled,
                                          size: 80,
                                          color: Colors.white,
                                        )
                                      : Container(),
                                ),
                              ),
                            )
                          : Container(),
                      widget.type == 'love' || widget.type == 'event'
                          ? Expanded(
                              child: SizedBox(),
                            )
                          : Container(),
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            isLivestream == true
                                ? Image.asset('assets/icons/icon_apps/LivestreamTagIcon.png', scale: 25)
                                : Container(),
                            Container(
                              width: 200,
                              child: Text(
                                widget.type == 'love' || widget.type == 'event'
                                    ? widget.name
                                    : widget.fullName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil.instance.setSp(15)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: ScreenUtil.instance.setWidth(8)),
                            Row(
                              children: <Widget>[
                                widget.type == 'video' || widget.type == 'photo'
                                    ? Container(
                                        width: ScreenUtil.instance
                                            .setWidth(360 - 70.0),
                                        child: Text(
                                            widget.name == null
                                                ? ''
                                                : widget.name,
                                            maxLines: 10,
                                            style: TextStyle(
                                                color: Color(0xFF8A8A8B))),
                                      )
                                    : Container(
                                        width: ScreenUtil.instance.setWidth(
                                            widget.type != 'love' ||
                                                    widget.type != 'event'
                                                ? 150
                                                : 250),
                                        child: Text(
                                          widget.location == null
                                              ? ''
                                              : widget.location == null
                                                  ? widget.name
                                                  : widget.location,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Color(0xFF8A8A8B)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                              ],
                            ),
                            SizedBox(height: 15),
                            widget.type == 'event'
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EventDetailLoadingScreen(
                                            isRest: false,
                                            eventId: widget.eventId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      height: ScreenUtil.instance.setWidth(28),
                                      width: ScreenUtil.instance.setWidth(133),
                                      decoration: BoxDecoration(
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: ticketColor
                                                    .withOpacity(0.4),
                                                blurRadius: 2,
                                                spreadRadius: 1.5)
                                          ],
                                          color: ticketColor,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Center(
                                          child: Text(
                                        ticketPrice.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                ScreenUtil.instance.setSp(14),
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      // Container(
                      //   child: Image.asset('assets/btn_ticket/free-limited.png', scale: 7,),)
                      widget.type == 'eventgoing'
                          ? Container(
                              child: Image.asset(
                                'assets/btn_ticket/going.png',
                                scale: 7,
                              ),
                            )
                          : widget.type == 'relationship'
                              ? CircleAvatar(
                                  backgroundColor: Color(0xff8a8a8b),
                                  backgroundImage: NetworkImage(widget.picture),
                                )
                              : Container()
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 13, top: 13, bottom: 13),
              child: Row(children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isLoved == false) {
                        _loveCount += 1;
                        _isLoved = true;
                        doLove(widget.id, '6').then((response) {
                          print(response.body);
                          print(response.statusCode);
                        });
                        doRefresh();
                      } else {
                        _loveCount -= 1;
                        _isLoved = false;
                        unLove(widget.id);
                        doRefresh();
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: _loveCount < 1 ? 7 : 10),
                    height: ScreenUtil.instance.setWidth(30),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              spreadRadius: 1.5)
                        ]),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/icons/icon_apps/love.png',
                            color: _loveCount > 0 ? Colors.red : Colors.grey,
                            scale: 3.5,
                          ),
                          SizedBox(
                              width: ScreenUtil.instance
                                  .setWidth(_loveCount < 1 ? 0 : 5)),
                          Text(_loveCount < 1 ? '' : _loveCount.toString(),
                              style: TextStyle(
                                  color: Color(
                                      0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                        ]),
                  ),
                ),
                SizedBox(width: ScreenUtil.instance.setWidth(10)),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            int.parse(widget.commentTotalRows) < 1 ? 8 : 10),
                    height: ScreenUtil.instance.setWidth(30),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              spreadRadius: 1.5)
                        ]),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/icons/icon_apps/comment.png',
                            scale: 3.5,
                            color: int.parse(widget.commentTotalRows) < 1
                                ? Colors.grey
                                : eventajaGreenTeal,
                          ),
                          SizedBox(
                              width: ScreenUtil.instance.setWidth(
                                  int.parse(widget.commentTotalRows) < 1
                                      ? 0
                                      : 5)),
                          Text(
                              int.parse(widget.commentTotalRows) < 1
                                  ? ''
                                  : widget.commentTotalRows,
                              style: TextStyle(
                                  color: Color(
                                      0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                        ]),
                  ),
                ),
                Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    if (widget.userId == prefs.getString('Last User ID')) {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return showMoreOption(widget.id, widget.type,
                                imageUrl: widget.picture);
                          });
                    } else {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return showMoreOptionReport(
                              widget.id,
                              widget.type,
                            );
                          });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: ScreenUtil.instance.setWidth(30),
                    child: Icon(Icons.more_horiz),
                  ),
                )
              ]),
            )
          ],
        ));
  }

  Widget showMoreOption(String id, String postType, {String imageUrl}) {
    return Container(
      color: Color(0xFF737373),
      child: Container(
        padding: EdgeInsets.only(top: 13, left: 25, right: 25, bottom: 30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: SizedBox(
                    height: ScreenUtil.instance.setWidth(5),
                    width: ScreenUtil.instance.setWidth(50),
                    child: Image.asset(
                      'assets/icons/icon_line.png',
                      fit: BoxFit.fill,
                    ))),
            SizedBox(height: ScreenUtil.instance.setWidth(35)),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) {
                      return deletePrompt(id, postType);
                    });
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (BuildContext context) =>
                //             PostEvent()));
              },
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Delete',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: ScreenUtil.instance.setSp(16),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                        height: ScreenUtil.instance.setWidth(30),
                        width: ScreenUtil.instance.setWidth(30),
                        child: Image.asset('assets/icons/icon_apps/delete.png'))
                    // Container(
                    //   height: ScreenUtil.instance.setWidth(44),
                    //   width: ScreenUtil.instance.setWidth(50),
                    //   decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //           image: AssetImage(
                    //               'assets/icons/page_post_event.png'),
                    //           fit: BoxFit.fill),
                    //       borderRadius: BorderRadius.circular(11),
                    //       boxShadow: <BoxShadow>[
                    //         BoxShadow(
                    //             blurRadius: 10,
                    //             color: Colors.grey
                    //                 .withOpacity(0.3),
                    //             spreadRadius: .5)
                    //       ]),
                    // )
                  ],
                ),
              ),
            ),
            SizedBox(height: ScreenUtil.instance.setWidth(19)),
            Divider(),
            SizedBox(height: ScreenUtil.instance.setWidth(16)),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditPost(
                              isVideo: postType == 'video' ? true : false,
                              postId: id,
                              thumbnailPath: imageUrl,
                            ))).then((value) {
                  setState(() {
                    isLoading = true;
                    doRefresh();
                  });
                });
              },
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Edit',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(16),
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF40D7FF)),
                        ),
                      ],
                    ),
                    Container(
                      height: ScreenUtil.instance.setWidth(30),
                      width: ScreenUtil.instance.setWidth(30),
                      child: Image.asset('assets/icons/icon_apps/edit.png'),
                    )
                    // Container(
                    //   height: ScreenUtil.instance.setWidth(44),
                    //   width: ScreenUtil.instance.setWidth(50),
                    //   decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //           image: AssetImage(
                    //               'assets/icons/page_post_media.png'),
                    //           fit: BoxFit.fill),
                    //       borderRadius: BorderRadius.circular(11),
                    //       boxShadow: <BoxShadow>[
                    //         BoxShadow(
                    //             blurRadius: 10,
                    //             color: Colors.grey
                    //                 .withOpacity(0.3),
                    //             spreadRadius: .5)
                    //       ]),
                    // )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future doRefresh() async {
    await Future.delayed(Duration(seconds: 5), () {
      setState(() {
        getTimelineList().then((response) {
          print(response.statusCode);
          print(response.body);
          var extractedData = json.decode(response.body);

          print('Timeline List -> ${response.body.toString()}');

          if (response.statusCode == 200) {
            isLoading = false;
            setState(() {
              timelineList = extractedData['data'];
            });
          }
        });
      });
      if (mounted == true) setState(() {});
      homeRefreshController.refreshCompleted();
    });
  }

  Widget showMoreOptionReport(String id, String postType) {
    return Container(
      color: Color(0xFF737373),
      child: Container(
        padding: EdgeInsets.only(top: 13, left: 25, right: 25, bottom: 30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: SizedBox(
                    height: ScreenUtil.instance.setWidth(5),
                    width: ScreenUtil.instance.setWidth(50),
                    child: Image.asset(
                      'assets/icons/icon_line.png',
                      fit: BoxFit.fill,
                    ))),
            SizedBox(height: ScreenUtil.instance.setWidth(35)),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ReportPost(
                              postId: id,
                              postType: postType,
                            )));
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (BuildContext context) =>
                //             PostEvent()));
              },
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Report',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: ScreenUtil.instance.setSp(16),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      height: ScreenUtil.instance.setWidth(30),
                      width: ScreenUtil.instance.setWidth(30),
                      child: Image.asset('assets/icons/icon_apps/report.png'),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget deletePrompt(String id, String postType) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            height: ScreenUtil.instance.setWidth(100),
            width: ScreenUtil.instance.setWidth(200),
            child: Column(
              children: <Widget>[
                Text(
                  'Oops',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.instance.setSp(18),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(10),
                ),
                Text(
                  'Delete this moment?',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Keep',
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: ScreenUtil.instance.setWidth(50),
                    ),
                    GestureDetector(
                      onTap: () {
                        deletePost(id, postType).then((response) {
                          print('calling delete api');
                          print(response.statusCode);
                          print(response.body);

                          Navigator.pop(context);
                          if (!mounted) return;
                          getTimelineList().then((response) {
                            print(response.statusCode);
                            print(response.body);
                            var extractedData = json.decode(response.body);

                            if (response.statusCode == 200) {
                              setState(() {
                                timelineList = extractedData['data'];
                              });
                            }
                          });
                        });
                      },
                      child: Text('Delete',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<http.Response> deletePost(String id, String postType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String deletePostType = '/photo/delete';

    if (postType == 'photo') {
      deletePostType = '/photo/delete';
    } else if (postType == 'video') {
      deletePostType = '/video/remove';
    }

    String url = BaseApi().apiUrl + deletePostType;

    final response = await http.delete(url, headers: {
      'X-API-KEY': API_KEY,
      'Authorization': AUTHORIZATION_KEY,
      'id': id,
      'cookie': prefs.getString('Session')
    });

    return response;
  }

  Future<http.Response> doLove(var postId, var impressionID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = '';

    if (widget.type == 'video') {
      url = BaseApi().apiUrl + '/video/impression';
    } else if (widget.type == 'photo') {
      url = BaseApi().apiUrl + '/photo_impression/post';
    } else if (widget.type == 'event') {
      url = BaseApi().apiUrl + '/event_impression/post';
    } else if (widget.type == 'eventgoing') {
      url = BaseApi().apiUrl + '/usergoing_impression/post';
    } else if (widget.type == 'love') {
      url = BaseApi().apiUrl + '/love_impression/post';
    } else if (widget.type == 'relationship') {
      url = BaseApi().apiUrl + '/relationship_impression/post';
    } else if (widget.type == 'thought') {
      url = BaseApi().apiUrl + '/thought_impression/post';
    } else if (widget.type == 'eventcheckin') {
      url = BaseApi().apiUrl + '/eventcheckin_impression/post';
    } else if (widget.type == 'checkin') {
      url = BaseApi().apiUrl + '/photo_impression/post';
    } else if (widget.type == 'combined_relationship') {
      url = BaseApi().apiUrl + '/combined_relationship_impression/post';
    }

    final response = await http.post(url, body: {
      'X-API-KEY': API_KEY,
      'id': postId,
      'impressionID': impressionID
    }, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session'),
    });

    return response;
  }

  Future<http.Response> unLove(String id) async {
    SharedPreferences prefences = await SharedPreferences.getInstance();

    String url = '';

    if (widget.type == 'video') {
      print(widget.id);
      url = BaseApi().apiUrl + '/video/delete_impression';
    } else if (widget.type == 'photo') {
      url = BaseApi().apiUrl + '/photo_impression/delete';
    } else if (widget.type == 'event') {
      url = BaseApi().apiUrl + '/event_impression/delete';
    } else if (widget.type == 'eventgoing') {
      url = BaseApi().apiUrl + '/usergoing_impression/delete';
    } else if (widget.type == 'love') {
      url = BaseApi().apiUrl + '/love_impression/delete';
    } else if (widget.type == 'relationship') {
      url = BaseApi().apiUrl + '/relationship_impression/delete';
    } else if (widget.type == 'thought') {
      url = BaseApi().apiUrl + '/thought_impression/delete';
    } else if (widget.type == 'eventcheckin') {
      url = BaseApi().apiUrl + '/eventcheckin_impression/delete';
    } else if (widget.type == 'checkin') {
      url = BaseApi().apiUrl + '/photo_impression/delete';
    } else if (widget.type == 'combined_relationship') {
      url = BaseApi().apiUrl + '/combined_relationship_impression/delete';
    }

    final response = await http.delete(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'X-API-KEY': API_KEY,
      'cookie': prefences.getString('Session'),
      'id': widget.impressionId
    });

    print('unlove: ' + response.body);

    return response;
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
        '/timeline/user?X-API-KEY=$API_KEY&page=$currentPage&userID=1';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print('body: ' + response.body);

    return response;
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    homeRefreshController.dispose();
  }
}
