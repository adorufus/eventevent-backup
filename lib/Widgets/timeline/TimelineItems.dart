import 'dart:convert';

import 'package:eventevent/Widgets/timeline/EditPost.dart';
import 'package:eventevent/Widgets/timeline/ReportPost.dart';
import 'package:eventevent/Widgets/timeline/UserMediaDetail.dart';
import 'package:eventevent/Widgets/timeline/UserTimelineItem.dart' as prefix0;
import 'package:eventevent/Widgets/timeline/UserTimelineItem.dart';
import 'package:eventevent/Widgets/timeline/VideoPlayer.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class UserTimelineItem extends StatefulWidget {
  final currentUserId;

  const UserTimelineItem({Key key, this.currentUserId}) : super(key: key);

  @override
  _UserTimelineItemState createState() => _UserTimelineItemState();
}

class _UserTimelineItemState extends State<UserTimelineItem> {

  RefreshController refreshController =
  RefreshController(initialRefresh: false);

  int newPage = 0;

  List timelineList = [];

  bool isLoading = false;

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
        '/timeline/list?X-API-KEY=$API_KEY&page=$currentPage';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print('body: ' + response.body);

    return response;
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    getTimelineList(newPage: newPage).then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          List updatedData = extractedData['data'];
          if (updatedData == null) {
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          timelineList.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      } else {
        refreshController.loadFailed();
      }
    });
  }

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      footer: CustomFooter(builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("Load data");
        } else if (mode == LoadStatus.loading) {
          body = CupertinoActivityIndicator(radius: 20);
        } else if (mode == LoadStatus.failed) {
          body = Text("Load Failed!");
        } else if (mode == LoadStatus.canLoading) {
          body = Text('More');
        } else {
          body = Container();
        }

        return Container(
            margin: EdgeInsets.only(bottom: 25),
            height: ScreenUtil.instance.setWidth(35),
            child: Center(child: body));
      }),
      controller: refreshController,
      onRefresh: () {
        setState(() {
          newPage = 0;
        });
        getTimelineList(newPage: newPage).then((response) {
          var extractedData = json.decode(response.body);

          print(response.statusCode);
          print(response.body);

          if (response.statusCode == 200) {
            setState(() {
              timelineList = extractedData['data'];
            });
            if (mounted) setState(() {});
            refreshController.refreshCompleted();
          } else {
            if (mounted) setState(() {});
            refreshController.refreshFailed();
          }
        });
      },
      onLoading: _onLoading,
      child: timelineList == null ? Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/icons/empty_state/public_timeline.png', scale: 1.5,),
          Text('Your timeline is empty :(', style: TextStyle(fontWeight: FontWeight.bold),)
        ],
      ),) : ListView.builder(
        shrinkWrap: true,
        itemCount: timelineList == null ? 0 : timelineList.length,
        itemBuilder: (BuildContext context, i) {
          List _loveCount = timelineList[i]['impression']['data'];
          List commentList = timelineList[i]['comment']['data'];
          List impressions = new List();
          bool isLiked = false;
          String likeCount = '';

          if(timelineList[i]['impression']['data'].length == 0){
            isLiked = false;

            print('is liked data = 0 ' + isLiked.toString());
          }
          else{
            timelineList[i]['impression']['data'].map((impressions) {
              if(impressions.containsValue(widget.currentUserId)){
                isLiked = true;
                print('is liked data > 0 ' + isLiked.toString());
              }
              else{
                isLiked = false;
                print('is we already likeit? ' + isLiked.toString());
              }
            });
          }

          Map impressionData;

          for(var impres in timelineList[i]['impression']['data']){
            impressionData = impres;
            print(impressionData.toString());
          }

          print('is have current user id: ' + timelineList[2]['impression']['data'].contains('userID: ${widget.currentUserId}').toString());

          return TimelineItem(
            id: timelineList[i]['id'],
            commentTotalRows: timelineList[i]['comment']['totalRows'],
            fullName: timelineList[i]['fullName'],
            description: timelineList[i]['description'],
            isVerified: timelineList[i]['isVerified'],
            name: timelineList[i]['name'],
            photo: timelineList[i]['photo'],
            dateTime: DateTime.parse(timelineList[i]['createdDate']),
            photoFull: timelineList[i]['photoFull'],
            picture: timelineList[i]['picture'],
            pictureFull: timelineList[i]['pictureFull'],
            type: timelineList[i]['type'],
            userId: timelineList[i]['userID'],
            impressionId: timelineList[i]['impression']['data'].length == 0 ? '' : impressionData['id'],
            loveCount: timelineList[i]['impression']['data'].length,
            isLoved: timelineList[i]['impression']['data'].length == 0 ? false : impressionData.containsValue(widget.currentUserId) == true ? true : false,
          );
        },
      ),
    );
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

  doRefresh() {
    setState(() {
      newPage = 0;
    });
    getTimelineList(newPage: newPage).then((response) {
      var extractedData = json.decode(response.body);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          timelineList = extractedData['data'];
        });
        if (mounted) setState(() {});
        refreshController.refreshCompleted();
      } else {
        if (mounted) setState(() {});
        refreshController.refreshFailed();
      }
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

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }
}
