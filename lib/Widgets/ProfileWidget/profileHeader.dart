import 'dart:convert';

import 'package:eventevent/Widgets/ManageEvent/EventList.dart';
import 'package:eventevent/Widgets/ManageEvent/PublicEventList.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsWidget.dart';
import 'package:eventevent/Widgets/ProfileWidget/editProfile.dart';
import 'package:eventevent/Widgets/RecycleableWidget/listviewWithAppBar.dart';
import 'package:eventevent/Widgets/timeline/ReportPost.dart';
import 'package:eventevent/Widgets/timeline/UserTimelineItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventevent/helper/FollowUnfollow.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'MyTicketWidget.dart';
import 'package:http/http.dart' as http;

class ProfileHeader extends StatefulWidget {
  final String currentUserId;
  final String username;
  final String fullName;
  final String firstName;
  final String email;
  final String website;
  final String phone;
  final String lastName;
  final String profilePhotoURL;
  final String eventCreatedCount;
  final String eventGoingCount;
  final String following;
  final String follower;
  final String bio;
  final String isVerified;
  final initialIndex;
  final isFollowing;

  const ProfileHeader(
      {Key key,
      this.currentUserId,
      this.username,
      this.fullName,
      this.lastName,
      this.profilePhotoURL,
      this.eventCreatedCount,
      this.eventGoingCount,
      this.following,
      this.follower,
      this.firstName,
      this.email,
      this.website,
      this.phone,
      this.bio,
      this.initialIndex,
      this.isVerified,
      this.isFollowing})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileHeaderState();
  }
}

class _ProfileHeaderState extends State<ProfileHeader>
    with AutomaticKeepAliveClientMixin<ProfileHeader> {
  @override
  bool get wantKeepAlive => true;

  String userId;
  bool isFollowed;
  List userTimelineList;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('Last User ID');
    });
  }

  @override
  void initState() {
    super.initState();

    timelineList().then((response) {
      print(response.statusCode);
      print(response.body);

      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          userTimelineList = extractedData['data'];
        });
      } else {
        print('error' + extractedData.toString());
      }
    });

    getUserProfile();
    print('isFollowing' + widget.isFollowing);
    if (widget.isFollowing == '0') {
      setState(() {
        isFollowed = false;
      });
    } else {
      setState(() {
        isFollowed = true;
      });
    }
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
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(null, 75),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil.instance.setWidth(60),
            padding: EdgeInsets.symmetric(horizontal: 13),
            color: Colors.white,
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: widget.currentUserId == userId
                  ? Container()
                  : GestureDetector(
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
                widget.currentUserId == userId
                    ? GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SettingsWidget()));
                        },
                        child: Image.asset(
                          'assets/icons/icon_apps/iconsettings.png',
                          scale: 1.5,
                          alignment: Alignment.centerRight,
                        ))
                    : Container(),
              ],
            ),
          ),
        ),
        body: SmartRefresher(
            controller: refreshController,
            enablePullUp: false,
            enablePullDown: true,
            onRefresh: () async {
              await Future.delayed(Duration(milliseconds: 5000));
              if (mounted) setState(() {});
              refreshController.refreshCompleted();
            },
            child: profileDetails(context, widget, userId, isFollowed)));
  }

  Widget profileDetails(BuildContext context, ProfileHeader widget,
      String userId, bool followed) {
    return ListView(
      children: <Widget>[
        Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 28, vertical: 3),
                    height: ScreenUtil.instance.setWidth(110),
                    width: ScreenUtil.instance.setWidth(110),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5,
                              offset: Offset(1, 1))
                        ],
                        image: DecorationImage(
                            image: widget.profilePhotoURL == null
                                ? AssetImage('assets/white.png')
                                : CachedNetworkImageProvider(
                                    widget.profilePhotoURL),
                            fit: BoxFit.cover)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.fullName == null ? 'loading' : widget.fullName,
                        style: TextStyle(
                            fontSize: ScreenUtil.instance.setSp(17),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(4),
                      ),
                      Row(
                        children: <Widget>[
                          widget.isVerified == '0'
                              ? Container()
                              : Image.asset(
                                  'assets/icons/icon_apps/verif.png',
                                  scale: 4,
                                ),
                          SizedBox(width: ScreenUtil.instance.setWidth(4)),
                          Text(
                            widget.username == null
                                ? 'loading'
                                : '@' + widget.username,
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(12),
                                color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(4),
                      ),
                      Container(
                        width: ScreenUtil.instance.setWidth(180),
                        child: Text(
                          widget.bio == null ? '-' : widget.bio,
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(12)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(4),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (widget.website == null) {
                            return;
                          } else {
                            launch('https://' + widget.website.toString());
                          }
                        },
                        child: Text(
                          widget.website == null ? '-' : widget.website,
                          style: TextStyle(
                              color: eventajaGreenTeal,
                              fontSize: ScreenUtil.instance.setSp(12)),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(20),
                      ),
                      widget.currentUserId == userId
                          ? GestureDetector(
                              onTap: () {
                                handleClickButtonEditProfile(context, widget);
                              },
                              child: Container(
                                height: ScreenUtil.instance.setWidth(32.93),
                                width: ScreenUtil.instance.setWidth(82.31),
                                decoration: BoxDecoration(
                                    // border: Border.all(
                                    //   width: ScreenUtil.instance.setWidth(1),
                                    //   color: Color(0xFF55B9E5),
                                    // ),
                                    borderRadius: BorderRadius.circular(30),
                                    color: Color(0xFFFFAA00)
                                    // color: Color(
                                    //     isFollowing == '1' ? 0xFF55B9E5 : 0xFFFFFFFF)
                                    ),
                                child: Center(
                                    child: Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil.instance.setSp(12)),
                                )
                                    //     Text(
                                    //   isFollowing == '1' ? 'Following' : 'Follow',
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.bold,
                                    //       fontSize: ScreenUtil.instance.setSp(10),
                                    //       color: Color(
                                    //           isFollowing == '1' ? 0xFFFFFFFF : 0xFF55B9E5)),
                                    // )
                                    ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                print(this.isFollowed);
                                if (this.isFollowed == false) {
                                  FollowUnfollow().follow(widget.currentUserId);
                                  setState(() {
                                    this.isFollowed = true;
                                  });
                                } else {
                                  FollowUnfollow()
                                      .unfollow(widget.currentUserId);

                                  setState(() {
                                    this.isFollowed = false;
                                  });
                                }
                              },
                              child: Container(
                                height: ScreenUtil.instance.setWidth(32.93),
                                width: ScreenUtil.instance.setWidth(82.31),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: ScreenUtil.instance.setWidth(1),
                                      color: Color(0xFF55B9E5),
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    color: this.isFollowed == false
                                        ? Color(0xFFFFFFFF)
                                        : Color(0xFF55B9E5)),
                                child: Center(
                                    child: Text(
                                        this.isFollowed == false
                                            ? 'Follow'
                                            : 'Following',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              ScreenUtil.instance.setSp(10),
                                          color: this.isFollowed == false
                                              ? Color(0xFF55B9E5)
                                              : Color(0xFFFFFFFF),
                                        ))),
                              ),
                            )
                    ],
                  )
                ],
              ),
              Container(
                height: ScreenUtil.instance.setWidth(60.63),
                margin: EdgeInsets.symmetric(horizontal: 13, vertical: 28),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1.5)
                    ]),
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.eventCreatedCount == '0'
                            ? () {}
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        EventList(
                                      userId: widget.currentUserId,
                                      type: 'created',
                                    ),
                                  ),
                                );
                              },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                widget.eventCreatedCount == null
                                    ? '0'
                                    : widget.eventCreatedCount,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        int.parse(widget.eventCreatedCount) >
                                                999
                                            ? 14
                                            : 17,
                                    color: widget.eventCreatedCount == "0" ||
                                            widget.eventCreatedCount == null
                                        ? Colors.grey
                                        : Colors.black),
                              ),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(9),
                              ),
                              Text('EVENT CREATED',
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: widget.eventCreatedCount == "0" ||
                                              widget.eventCreatedCount == null
                                          ? Colors.grey
                                          : Colors.black))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 0,
                        height: ScreenUtil.instance.setWidth(48),
                        decoration: BoxDecoration(
                            border: Border(
                                right: createBorderSide(context,
                                    color: Color(0xFF8A8A8B)))),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.eventGoingCount == '0'
                            ? () {}
                            : () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        EventList(
                                          type: 'going',
                                          userId: widget.currentUserId,
                                        )));
                              },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18, right: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                  widget.eventGoingCount == null
                                      ? '0'
                                      : widget.eventGoingCount,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          int.parse(widget.eventCreatedCount) >
                                                  999
                                              ? 14
                                              : 17,
                                      color: widget.eventGoingCount == "0" ||
                                              widget.eventGoingCount == null
                                          ? Colors.grey
                                          : Colors.black)),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(9),
                              ),
                              Text('EVENT GOING',
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: widget.eventGoingCount == "0" ||
                                              widget.eventGoingCount == null
                                          ? Colors.grey
                                          : Colors.black))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 0,
                        height: ScreenUtil.instance.setWidth(48),
                        decoration: BoxDecoration(
                            border: Border(
                                right: createBorderSide(context,
                                    color: Color(0xFF8A8A8B)))),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.follower == '0'
                            ? () {}
                            : () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ListViewWithAppBar(
                                          title: 'FOLLOWER',
                                          apiURL: BaseApi().apiUrl +
                                              '/user/follower?X-API-KEY=$API_KEY&userID=${widget.currentUserId}&page=1',
                                        )));
                              },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 23, right: 23),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                  widget.follower == null
                                      ? '0'
                                      : widget.follower,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          int.parse(widget.eventCreatedCount) >
                                                  999
                                              ? 14
                                              : 17,
                                      color: widget.follower == "0" ||
                                              widget.follower == null
                                          ? Colors.grey
                                          : Colors.black)),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(9),
                              ),
                              Text('FOLLOWER',
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: widget.follower == "0" ||
                                              widget.follower == null
                                          ? Colors.grey
                                          : Colors.black))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 0,
                        height: ScreenUtil.instance.setWidth(48),
                        decoration: BoxDecoration(
                            border: Border(
                                right: createBorderSide(context,
                                    color: Color(0xFF8A8A8B)))),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.following == '0'
                            ? () {}
                            : () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ListViewWithAppBar(
                                          title: 'FOLLOWING',
                                          apiURL: BaseApi().apiUrl +
                                              '/user/following?X-API-KEY=${API_KEY}&userID=${widget.currentUserId}&page=1',
                                        )));
                              },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 23, right: 9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                  widget.following == null
                                      ? '0'
                                      : widget.following,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          int.parse(widget.eventCreatedCount) >
                                                  999
                                              ? 14
                                              : 17,
                                      color: widget.following == "0" ||
                                              widget.following == null
                                          ? Colors.grey
                                          : Colors.black)),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(9),
                              ),
                              Text('FOLLOWING',
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: widget.following == "0"
                                          ? Colors.grey
                                          : Colors.black))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              tabNavigator(context, widget)
            ],
          ),
        )
        // Stack(
        //   fit: StackFit.passthrough,
        //   children: <Widget>[
        //     UnconstrainedBox(
        //       alignment: Alignment.topCenter,
        //       child: Container(
        //         height: ScreenUtil.instance.setWidth(150),
        //         width: MediaQuery.of(context).size.width,
        //         child: Image(
        //           image: widget.profilePhotoURL == null
        //               ? AssetImage('assets/white.png')
        //               : NetworkImage(widget.profilePhotoURL),
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     ),
        //     Center(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         children: <Widget>[
        //           Container(
        //             height: ScreenUtil.instance.setWidth(200),
        //             width: ScreenUtil.instance.setWidth(200),
        //             decoration: BoxDecoration(
        //                 shape: BoxShape.circle,
        //                 boxShadow: <BoxShadow>[
        //                   BoxShadow(
        //                       color: Colors.grey,
        //                       blurRadius: 5,
        //                       offset: Offset(1, 1))
        //                 ],
        //                 image: DecorationImage(
        //                     image: widget.profilePhotoURL == null
        //                         ? AssetImage('assets/white.png')
        //                         : CachedNetworkImageProvider(
        //                             widget.profilePhotoURL),
        //                     fit: BoxFit.cover)),
        //           ),
        //           SizedBox(
        //             height: ScreenUtil.instance.setWidth(15),
        //           ),
        //           Text(
        //             widget.fullName == null ? 'loading' : widget.fullName,
        //             style:
        //                 TextStyle(fontSize: ScreenUtil.instance.setSp(20), fontWeight: FontWeight.bold),
        //           ),
        //           SizedBox(
        //             height: ScreenUtil.instance.setWidth(10),
        //           ),
        //           Text(
        //             widget.username == null
        //                 ? 'loading'
        //                 : '@' + widget.username,
        //             style: TextStyle(fontSize: ScreenUtil.instance.setSp(15), color: Colors.grey),
        //           ),
        //           SizedBox(
        //             height: ScreenUtil.instance.setWidth(20),
        //           ),
        //           GestureDetector(
        //             onTap: () {
        //               handleClickButtonEditProfile(context, widget);
        //             },
        //             child: Container(
        //               height: ScreenUtil.instance.setWidth(50),
        //               height: ScreenUtil.instance.setWidth(100),
        //               child: Image.asset('assets/icons/btn_edit_profile.png'),
        //             ),
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.only(top: 20),
        //             child:
        //           ),
        //           tabNavigator(context, widget)
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget tabNavigator(BuildContext context, ProfileHeader widget) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialIndex,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.black,
              labelStyle: TextStyle(fontFamily: 'Proxima'),
              tabs: [
                Tab(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/icon_apps/home.png',
                        scale: 4.5,
                      ),
                      SizedBox(width: ScreenUtil.instance.setWidth(10)),
                      Text('Timeline',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil.instance.setSp(12.5))),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/icon_apps/latest.png',
                        scale: 4.5,
                      ),
                      SizedBox(width: ScreenUtil.instance.setWidth(10)),
                      Text(
                          widget.currentUserId == userId
                              ? 'My Ticket'
                              : 'Event Going',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil.instance.setSp(12.5))),
                    ],
                  ),
                ),
              ],
              unselectedLabelColor: Colors.grey,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              children: <Widget>[
                userTimelineList == null
                    ? Container(
                        padding: EdgeInsets.only(top: 80),
                        alignment: Alignment.topCenter,
                        child: CupertinoActivityIndicator(radius: 20),
                      )
                    : timeline(),
                widget.currentUserId == userId
                    ? MyTicketWidget()
                    : PublicEventList(
                        type: 'going',
                        userId: widget.currentUserId,
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }

  int newPage = 0;

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    timelineList(newPage: newPage).then((response) {
      var extractedData = json.decode(response.body);

      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
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

  Widget timeline() {
    return SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        enablePullDown: false,
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
        onLoading: _onLoading,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: userTimelineList == null ? 0 : userTimelineList.length,
          itemBuilder: (context, i) {
            List _loveCount = userTimelineList[i]['impression']['data'];
            List commentList = userTimelineList[i]['comment']['data'];

            Map impressionData;

            for (var impres in userTimelineList[i]['impression']['data']) {
              impressionData = impres;
              print(impressionData.toString());
            }

            return TimelineItem(
              id: userTimelineList[i]['id'],
              commentTotalRows: userTimelineList[i]['comment']['totalRows'],
              fullName: userTimelineList[i]['fullName'],
              description: userTimelineList[i]['description'],
              isVerified: userTimelineList[i]['isVerified'],
              name: userTimelineList[i]['name'],
              photo: userTimelineList[i]['photo'],
              dateTime: DateTime.parse(userTimelineList[i]['createdDate']),
              photoFull: userTimelineList[i]['photoFull'],
              picture: userTimelineList[i]['picture'],
              pictureFull: userTimelineList[i]['pictureFull'],
              type: userTimelineList[i]['type'],
              userId: userTimelineList[i]['userID'],
              impressionId:
                  userTimelineList[i]['impression']['data'].length == 0
                      ? ''
                      : impressionData['id'],
              loveCount: userTimelineList[i]['impression']['data'].length,
              isLoved: userTimelineList[i]['impression']['data'].length == 0
                  ? false
                  : impressionData.containsValue(widget.currentUserId) == true
                      ? true
                      : false,
            );
          },
        ));
  }

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
                          timelineList().then((response) {
                            print(response.statusCode);
                            print(response.body);
                            var extractedData = json.decode(response.body);

                            if (response.statusCode == 200) {
                              setState(() {
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
      'Authorization': AUTHORIZATION_KEY,
      'id': id,
      'cookie': prefs.getString('Session')
    });

    return response;
  }

  Future<http.Response> timelineList({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (newPage != null) {
        currentPage += newPage;
      }

      print(currentPage);
    });

    String url = BaseApi().apiUrl +
        '/timeline/user?X-API-KEY=$API_KEY&page=$currentPage&userID=${widget.currentUserId}';
    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}

handleClickButtonEditProfile(BuildContext context, ProfileHeader widget) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => EditProfileWidget(
            username: widget.username,
            firstName: widget.fullName,
            lastName: widget.lastName,
            profileImage: widget.profilePhotoURL,
            email: widget.email,
            phone: widget.phone,
            website: widget.website,
            bio: widget.bio,
          )));
}

BorderSide createBorderSide(BuildContext context,
    {Color color, double width = 0.0}) {
  assert(width != null);
  return BorderSide(
    color: color ?? Theme.of(context).dividerColor,
    width: width,
  );
}

Widget myTickets() {}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
