import 'dart:convert';

import 'package:eventevent/Widgets/timeline/EditPost.dart';
import 'package:eventevent/Widgets/timeline/ReportPost.dart';
import 'package:eventevent/Widgets/timeline/UserMediaDetail.dart';
import 'package:eventevent/Widgets/timeline/VideoPlayer.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetailTimeline extends StatefulWidget {
  final id;

  const EventDetailTimeline({Key key, this.id}) : super(key: key);

  @override
  _EventDetailTimelineState createState() => _EventDetailTimelineState();
}

class _EventDetailTimelineState extends State<EventDetailTimeline>
    with WidgetsBindingObserver {
  List timelineList = [];
  bool isLoading = false;
  bool _isLoved;
  int _loveCount = 0;
  RefreshController homeRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
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

    getUserData();

    super.initState();
  }

  var currentUserId;

  getUserData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = preferences.getString('Last User ID');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: timelineList == null ? 0 : timelineList.length,
        itemBuilder: (context, i) {
          List commentList = timelineList[i]['comment']['data'];
          List impressions = new List();
          bool isLiked;

          Map impressionData;

          for (var impres in timelineList[i]['impression']['data']) {
            impressionData = impres;
            print(impressionData.toString());
          }

          _isLoved = timelineList[i]['impression']['data'].length == 0
              ? false
              : impressionData.containsValue(currentUserId) == true
                  ? true
                  : false;
                  
          print('isLoved: ' + _isLoved.toString());
          _loveCount = timelineList[i]['impression']['data'].length;

          return Container(
              margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        spreadRadius: 1.5)
                  ],
                  color: Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(timelineList[i]['photo']),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil.instance.setWidth(8),
                                  ),
                                  Container(
                                      width:
                                          ScreenUtil.instance.setWidth(200.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              timelineList[i]['isVerified'] ==
                                                      '1'
                                                  ? Container(
                                                      height: ScreenUtil
                                                          .instance
                                                          .setWidth(18),
                                                      width: ScreenUtil.instance
                                                          .setWidth(18),
                                                      child: Image.asset(
                                                          'assets/icons/icon_apps/verif.png'))
                                                  : Container(),
                                              SizedBox(
                                                  width: ScreenUtil.instance
                                                      .setWidth(5)),
                                              Text(timelineList[i]['fullName'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                ScreenUtil.instance.setWidth(5),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              timelineList[i]['type'] == 'love'
                                                  ? Image.asset(
                                                      'assets/icons/icon_apps/love.png',
                                                      scale: 3,
                                                    )
                                                  : Container(),
                                              SizedBox(
                                                  width: ScreenUtil.instance
                                                      .setWidth(5)),
                                              Text(
                                                  timelineList[i]['type'] ==
                                                          'love'
                                                      ? 'Loved'
                                                      : timelineList[i]
                                                                  ['type'] ==
                                                              'relationship'
                                                          ? timelineList[i]
                                                              ['name']
                                                          : 'Post a ' +
                                                              timelineList[i]
                                                                  ['type'],
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: ScreenUtil
                                                          .instance
                                                          .setSp(10))),
                                            ],
                                          ),
                                        ],
                                      )),
                                ]),
                            Column(
                              children: <Widget>[
                                Text(
                                  'a minute ago',
                                  style: TextStyle(
                                      fontSize: ScreenUtil.instance.setSp(10)),
                                ),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(4)),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                            height: timelineList[i]['type'] == 'video' ||
                                    timelineList[i]['type'] == 'photo' ||
                                    timelineList[i]['type'] == 'event' ||
                                    timelineList[i]['type'] == 'eventgoing' ||
                                    timelineList[i]['eventID'] != null &&
                                        timelineList[i]['type'] == 'love'
                                ? 15
                                : 0),
                        timelineList[i]['type'] == 'video' ||
                                timelineList[i]['type'] == 'photo' ||
                                timelineList[i]['type'] == 'event' ||
                                timelineList[i]['type'] == 'eventgoing' ||
                                timelineList[i]['eventID'] != null &&
                                    timelineList[i]['type'] != 'love'
                            ? GestureDetector(
                                onTap: () {
                                  if (timelineList[i]['type'] == 'photo') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UserMediaDetail(
                                                  postID: timelineList[i]['id'],
                                                  imageUri: timelineList[i]
                                                      ['pictureFull'],
                                                  articleDetail: timelineList[i]
                                                      ['description'],
                                                  mediaTitle: timelineList[i]
                                                      ['description'],
                                                  autoFocus: false,
                                                  username: timelineList[i]
                                                      ['fullName'],
                                                  userPicture: timelineList[i]
                                                      ['photo'],
                                                  imageCount: 1,
                                                )));
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MediaPlayer(
                                                videoUri: timelineList[i]
                                                    ['pictureFull'])));
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            timelineList[i]['type'] == 'video'
                                                ? timelineList[i]['picture']
                                                : timelineList[i]
                                                    ['pictureFull'],
                                          ),
                                          fit: BoxFit.cover)),
                                  height: ScreenUtil.instance.setWidth(400),
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: timelineList[i]['type'] == 'video'
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            timelineList[i]['type'] == 'love'
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              timelineList[i]['type'] == 'video'
                                                  ? timelineList[i]['picture']
                                                  : timelineList[i]
                                                      ['pictureFull'],
                                            ),
                                            fit: BoxFit.cover)),
                                    height: ScreenUtil.instance.setWidth(100),
                                    width: ScreenUtil.instance.setWidth(66),
                                    child: Center(
                                      child: timelineList[i]['type'] == 'video'
                                          ? Icon(
                                              Icons.play_circle_filled,
                                              size: 80,
                                              color: Colors.white,
                                            )
                                          : Container(),
                                    ),
                                  )
                                : Container(),
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(timelineList[i]['name'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtil.instance
                                                  .setSp(15))),
                                      SizedBox(
                                          height:
                                              ScreenUtil.instance.setWidth(8)),
                                      Row(
                                        children: <Widget>[
                                          timelineList[i]['type'] == 'video' ||
                                                  timelineList[i]['type'] ==
                                                      'photo'
                                              ? Container(
                                                  width: ScreenUtil.instance
                                                      .setWidth(360 - 70.0),
                                                  child: Text(
                                                      timelineList[i]['name'] ==
                                                              null
                                                          ? ''
                                                          : timelineList[i]
                                                              ['name'],
                                                      maxLines: 10,
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xFF8A8A8B))),
                                                )
                                              : Container(
                                                  width: ScreenUtil.instance
                                                      .setWidth(250),
                                                  child: Text(
                                                    timelineList[i]['name'] ==
                                                            null
                                                        ? ''
                                                        : timelineList[i]
                                                                    ['type'] ==
                                                                'love'
                                                            ? timelineList[i]
                                                                ['locationName']
                                                            : timelineList[i]
                                                                ['name'],
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A8A8B)),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                        ],
                                      )
                                    ])),
                            // Container(
                            //   child: Image.asset('assets/btn_ticket/free-limited.png', scale: 7,),)
                            timelineList[i]['type'] == 'event'
                                ? Container(
                                    child: Image.asset(
                                      'assets/btn_ticket/free-limited.png',
                                      scale: 7,
                                    ),
                                  )
                                : timelineList[i]['type'] == 'eventgoing'
                                    ? Container(
                                        child: Image.asset(
                                          'assets/btn_ticket/going.png',
                                          scale: 7,
                                        ),
                                      )
                                    : timelineList[i]['type'] == 'relationship'
                                        ? CircleAvatar(
                                            backgroundColor: Color(0xff8a8a8b),
                                            backgroundImage: NetworkImage(
                                                timelineList[i]['picture']),
                                          )
                                        : Container()
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 13, top: 13, bottom: 13),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_isLoved == false) {
                                  _loveCount += 1;
                                  _isLoved = true;
                                  doLove(widget.id, '6', timelineList[i]['type']).then((response) {
                                    print(response.body);
                                    print(response.statusCode);
                                  });
                                  doRefresh();
                                } else {
                                  _loveCount -= 1;
                                  _isLoved = false;
                                  unLove(timelineList[i]['impression']['data'].length == 0 ? '' : impressionData['id'], timelineList[i]['type']);
                                  doRefresh();
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
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
                                      color: _loveCount > 0
                                          ? Colors.red
                                          : Colors.grey,
                                      scale: 3.5,
                                    ),
                                    SizedBox(
                                        width: ScreenUtil.instance.setWidth(_loveCount < 1 ? 0 : 5)),
                                    Text(_loveCount < 1 ? '' : _loveCount.toString(),
                                        style: TextStyle(
                                            color: Color(
                                                0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                                  ]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
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
                                  ),
                                  SizedBox(
                                      width: ScreenUtil.instance.setWidth(5)),
                                  Text(timelineList[i]['comment']['totalRows'],
                                      style: TextStyle(
                                          color: Color(
                                              0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                                ]),
                          ),
                          SizedBox(
                              width: _loveCount > 99 ? 100 : 150),
                          GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              if (timelineList[i]['userID'] ==
                                  prefs.getString('Last User ID')) {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return showMoreOption(
                                          timelineList[i]['id'],
                                          timelineList[i]['type'],
                                          imageUrl: timelineList[i]['picture']);
                                    });
                              } else {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return showMoreOptionReport(
                                        timelineList[i]['id'],
                                        timelineList[i]['type'],
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
        });
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

  Future<http.Response> doLove(var postId, var impressionID, var type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = '';

    if (type == 'video') {
      url = BaseApi().apiUrl + '/video/impression';
    } else if (type == 'photo') {
      url = BaseApi().apiUrl + '/photo_impression/post';
    } else if (type == 'event') {
      url = BaseApi().apiUrl + '/event_impression/post';
    } else if (type == 'eventgoing') {
      url = BaseApi().apiUrl + '/usergoing_impression/post';
    } else if (type == 'love') {
      url = BaseApi().apiUrl + '/love_impression/post';
    } else if (type == 'relationship') {
      url = BaseApi().apiUrl + '/relationship_impression/post';
    } else if (type == 'thought') {
      url = BaseApi().apiUrl + '/thought_impression/post';
    } else if (type == 'eventcheckin') {
      url = BaseApi().apiUrl + '/eventcheckin_impression/post';
    } else if (type == 'checkin') {
      url = BaseApi().apiUrl + '/photo_impression/post';
    } else if (type == 'combined_relationship') {
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

  Future<http.Response> unLove(String id, String type) async {
    SharedPreferences prefences = await SharedPreferences.getInstance();

    String url = '';

    if (type == 'video') {
      print(widget.id);
      url = BaseApi().apiUrl + '/video/delete_impression';
    } else if (type == 'photo') {
      url = BaseApi().apiUrl + '/photo_impression/delete';
    } else if (type == 'event') {
      url = BaseApi().apiUrl + '/event_impression/delete';
    } else if (type == 'eventgoing') {
      url = BaseApi().apiUrl + '/usergoing_impression/delete';
    } else if (type == 'love') {
      url = BaseApi().apiUrl + '/love_impression/delete';
    } else if (type == 'relationship') {
      url = BaseApi().apiUrl + '/relationship_impression/delete';
    } else if (type == 'thought') {
      url = BaseApi().apiUrl + '/thought_impression/delete';
    } else if (type == 'eventcheckin') {
      url = BaseApi().apiUrl + '/eventcheckin_impression/delete';
    } else if (type == 'checkin') {
      url = BaseApi().apiUrl + '/photo_impression/delete';
    } else if (type == 'combined_relationship') {
      url = BaseApi().apiUrl + '/combined_relationship_impression/delete';
    }

    final response = await http.delete(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'X-API-KEY': API_KEY,
      'cookie': prefences.getString('Session'),
      'id': id
    });

    print('unlove: ' + response.body);

    return response;
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
        '/event_activity/list?X-API-KEY=$API_KEY&page=$currentPage&eventID=${widget.id}';

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
