import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/timeline/ReportPost.dart';
import 'package:eventevent/Widgets/timeline/UserTimelineItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserProfileTimeline extends StatefulWidget {
  final isRest;
  final currentUserId;

  const UserProfileTimeline(
      {Key key, @required this.isRest, this.currentUserId})
      : super(key: key);
  @override
  _UserProfileTimelineState createState() => _UserProfileTimelineState();
}

class _UserProfileTimelineState extends State<UserProfileTimeline> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  List userTimelineList;

  @override
  void initState() {
    timelineList().then((response) {
      print("timeline list: " + response.statusCode.toString());
      print("timeline list: " + response.body);

      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (mounted)
          setState(() {
            userTimelineIsLoading = false;
            userTimelineList = extractedData['data'];
          });
      } else if (response.statusCode == 400) {
        userTimelineList = [];
        userTimelineIsLoading = false;
        if (mounted) setState(() {});
      } else {
        userTimelineIsLoading = false;
        userTimelineList = [];
        setState(() {});
        print('error' + extractedData.toString());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return userTimelineIsLoading == true
        ? HomeLoadingScreen().timelineLoading()
        : userTimelineList == null || userTimelineList.isEmpty
            ? EmptyState(
                imagePath: 'assets/icons/empty_state/public_timeline.png',
                reasonText: 'Timeline is empty :(',
              )
            : SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                enablePullDown: false,
                onLoading: _onLoading,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      userTimelineList == null ? 0 : userTimelineList.length,
                  itemBuilder: (context, i) {
                    List _loveCount = userTimelineList[i]['impression']['data'];
                    List commentList = userTimelineList[i]['comment']['data'];

                    Map impressionData;

                    for (var impres in userTimelineList[i]['impression']
                        ['data']) {
                      impressionData = impres;
                      print("impression data: " + impressionData.toString());
                    }

                    return TimelineItem(
                      id: userTimelineList[i]['id'],
                      commentTotalRows: userTimelineList[i]['comment']
                          ['totalRows'],
                      fullName: userTimelineList[i]['fullName'],
                      description: userTimelineList[i]['description'],
                      isVerified: userTimelineList[i]['isVerified'],
                      name: userTimelineList[i]['name'],
                      photo: userTimelineList[i]['photo'],
                      dateTime:
                          DateTime.parse(userTimelineList[i]['createdDate']),
                      photoFull: userTimelineList[i]['photoFull'],
                      picture: userTimelineList[i]['picture'],
                      pictureFull: userTimelineList[i]['pictureFull'],
                      type: userTimelineList[i]['type'],
                      userId: userTimelineList[i]['userID'],
                      ticketType: userTimelineList[i].containsKey('ticket_type')
                          ? userTimelineList[i]['ticket_type']['type']
                          : null,
                      cheapestTicket: userTimelineList[i].containsKey('ticket')
                          ? userTimelineList[i]['ticket']['cheapestTicket']
                          : null,
                      location: userTimelineList[i]['locationName'],
                      eventId: userTimelineList[i]['type'] == 'event' ||
                              userTimelineList[i]['type'] == 'love'
                          ? userTimelineList[i]['eventID']
                          : null,
                      impressionId:
                          userTimelineList[i]['impression']['data'].length == 0
                              ? ''
                              : impressionData['id'],
                      loveCount:
                          userTimelineList[i]['impression']['data'].length,
                      isLoved:
                          userTimelineList[i]['impression']['data'].length == 0
                              ? false
                              : impressionData.containsValue(
                                          widget.currentUserId) ==
                                      true
                                  ? true
                                  : false,
                    );
                  },
                ));
  }

  int newPage = 0;

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    timelineList(newPage: newPage).then((response) {
      var extractedData = json.decode(response.body);

      print("body on loading: " + response.body);

      if (response.statusCode == 200) {
        setState(() {
          userTimelineIsLoading = false;
          List updatedData = extractedData['data'];
          if (updatedData == null) {
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          userTimelineList.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      } else {
        refreshController.loadFailed();
      }
    });
  }

  bool userTimelineIsLoading = false;

  Widget showMoreOption(String id, String postType) {
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
                ),
              ),
            ),
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
                // imageCaputreCamera();
                // Navigator.of(context).pushNamed('/CustomCamera');
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
                    ),
                  ),
                );
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
                          print("status code delete: " + response
                              .statusCode.toString());
                          print("delete body: " + response.body);

                          Navigator.pop(context);
                          if (!mounted) return;
                          timelineList().then((response) {
                            print("timeline list: " + response.statusCode.toString());
                            print("timeline list body: " + response.body);
                            var extractedData = json.decode(response.body);

                            if (response.statusCode == 200) {
                              setState(() {
                                userTimelineIsLoading = false;
                                userTimelineList = extractedData['data'];
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
      'Authorization': AUTH_KEY,
      'id': id,
      'cookie': prefs.getString('Session')
    });

    return response;
  }

  Future<http.Response> timelineList({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
        'cookie': prefs.getString('Session')
      };
    }

    setState(() {
      userTimelineIsLoading = true;
      if (newPage != null) {
        currentPage += newPage;
      }

      print("current page: " + currentPage.toString());
    });

    String url = baseUrl +
        '/timeline/user?X-API-KEY=$API_KEY&page=$currentPage&userID=${widget.currentUserId}';
    final response = await http.get(url, headers: headers);

    return response;
  }
}
