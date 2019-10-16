import 'dart:convert';

import 'package:eventevent/Widgets/ManageEvent/EventList.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsWidget.dart';
import 'package:eventevent/Widgets/ProfileWidget/editProfile.dart';
import 'package:eventevent/Widgets/RecycleableWidget/listviewWithAppBar.dart';
import 'package:eventevent/Widgets/timeline/ReportPost.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventevent/helper/FollowUnfollow.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(null, 75),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
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
                          scale: 3.5,
                          alignment: Alignment.centerRight,
                        ))
                    : Container(),
              ],
            ),
          ),
        ),
        body: profileDetails(context, widget, userId, isFollowed));
  }

  Widget profileDetails(BuildContext context, ProfileHeader widget,
      String userId, bool isFollowed) {
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
                    height: 110,
                    width: 110,
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
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: <Widget>[
                          widget.isVerified == '0'
                              ? Container()
                              : Image.asset(
                                  'assets/icons/icon_apps/verif.png',
                                  scale: 4,
                                ),
                          SizedBox(width: 4),
                          Text(
                            widget.username == null
                                ? 'loading'
                                : '@' + widget.username,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.fullName == null ? 'loading' : widget.bio,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(
                        height: 4,
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
                          widget.fullName == null ? 'loading' : widget.website,
                          style:
                              TextStyle(color: eventajaGreenTeal, fontSize: 12),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      widget.currentUserId == userId
                          ? GestureDetector(
                              onTap: () {
                                handleClickButtonEditProfile(context, widget);
                              },
                              child: Container(
                                height: 32.93,
                                width: 82.31,
                                decoration: BoxDecoration(
                                    // border: Border.all(
                                    //   width: 1,
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
                                      fontSize: 12),
                                )
                                    //     Text(
                                    //   isFollowing == '1' ? 'Following' : 'Follow',
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.bold,
                                    //       fontSize: 10,
                                    //       color: Color(
                                    //           isFollowing == '1' ? 0xFFFFFFFF : 0xFF55B9E5)),
                                    // )
                                    ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                if (isFollowed == false) {
                                  FollowUnfollow().follow(widget.currentUserId);
                                  setState(() {
                                    isFollowed = true;
                                  });
                                } else {
                                  FollowUnfollow()
                                      .unfollow(widget.currentUserId);
                                  setState(() {
                                    isFollowed = false;
                                  });
                                }
                              },
                              child: Container(
                                height: 32.93,
                                width: 82.31,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xFF55B9E5),
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    color: isFollowed == false
                                        ? Color(0xFFFFFFFF)
                                        : Color(0xFF55B9E5)),
                                child: Center(
                                    child: Text(
                                        isFollowed == false
                                            ? 'Follow'
                                            : 'Following',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: isFollowed == false
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
                height: 60.63,
                margin: EdgeInsets.symmetric(horizontal: 13, vertical: 28),
                padding: EdgeInsets.symmetric(horizontal: 13),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => EventList(
                                  type: 'created',
                                )));
                      },
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
                                    int.parse(widget.eventCreatedCount) > 999
                                        ? 14
                                        : 17,
                                color: widget.eventCreatedCount == "0" ||
                                        widget.eventCreatedCount == null
                                    ? Colors.grey
                                    : Colors.black),
                          ),
                          SizedBox(
                            height: 9,
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
                    SizedBox(
                      width: 16,
                    ),
                    Container(
                      width: 0,
                      height: 48,
                      decoration: BoxDecoration(
                          border: Border(
                              right: createBorderSide(context,
                                  color: Color(0xFF8A8A8B)))),
                    ),
                    SizedBox(
                      width: 18,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                EventList(type: 'going')));
                      },
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
                                      int.parse(widget.eventCreatedCount) > 999
                                          ? 14
                                          : 17,
                                  color: widget.eventGoingCount == "0" ||
                                          widget.eventGoingCount == null
                                      ? Colors.grey
                                      : Colors.black)),
                          SizedBox(
                            height: 9,
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
                    SizedBox(
                      width: 18,
                    ),
                    Container(
                      width: 0,
                      height: 48,
                      decoration: BoxDecoration(
                          border: Border(
                              right: createBorderSide(context,
                                  color: Color(0xFF8A8A8B)))),
                    ),
                    SizedBox(
                      width: 23,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ListViewWithAppBar(
                                  title: 'FOLLOWER',
                                  apiURL: BaseApi().apiUrl +
                                      '/user/follower?X-API-KEY=${API_KEY}&userID=${widget.currentUserId}&page=1',
                                )));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(widget.follower == null ? '0' : widget.follower,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      int.parse(widget.eventCreatedCount) > 999
                                          ? 14
                                          : 17,
                                  color: widget.follower == "0" ||
                                          widget.follower == null
                                      ? Colors.grey
                                      : Colors.black)),
                          SizedBox(
                            height: 9,
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
                    SizedBox(
                      width: 23,
                    ),
                    Container(
                      width: 0,
                      height: 48,
                      decoration: BoxDecoration(
                          border: Border(
                              right: createBorderSide(context,
                                  color: Color(0xFF8A8A8B)))),
                    ),
                    SizedBox(
                      width: 23,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ListViewWithAppBar(
                                  title: 'FOLLOWING',
                                  apiURL: BaseApi().apiUrl +
                                      '/user/following?X-API-KEY=${API_KEY}&userID=${widget.currentUserId}&page=1',
                                )));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              widget.following == null ? '0' : widget.following,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      int.parse(widget.eventCreatedCount) > 999
                                          ? 14
                                          : 17,
                                  color: widget.following == "0" ||
                                          widget.following == null
                                      ? Colors.grey
                                      : Colors.black)),
                          SizedBox(
                            height: 9,
                          ),
                          Text('FOLLOWING',
                              style: TextStyle(
                                  fontSize: 7,
                                  color: widget.following == "0"
                                      ? Colors.grey
                                      : Colors.black))
                        ],
                      ),
                    )
                  ],
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
        //         height: 150,
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
        //             height: 200,
        //             width: 200,
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
        //             height: 15,
        //           ),
        //           Text(
        //             widget.fullName == null ? 'loading' : widget.fullName,
        //             style:
        //                 TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        //           ),
        //           SizedBox(
        //             height: 10,
        //           ),
        //           Text(
        //             widget.username == null
        //                 ? 'loading'
        //                 : '@' + widget.username,
        //             style: TextStyle(fontSize: 15, color: Colors.grey),
        //           ),
        //           SizedBox(
        //             height: 20,
        //           ),
        //           GestureDetector(
        //             onTap: () {
        //               handleClickButtonEditProfile(context, widget);
        //             },
        //             child: Container(
        //               height: 50,
        //               width: 100,
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
                      SizedBox(width: 10),
                      Text('Timeline',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12.5)),
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
                      SizedBox(width: 10),
                      Text('My Ticket',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12.5)),
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
              children: <Widget>[timeline(), MyTicketWidget()],
            ),
          ),
        ],
      ),
    );
  }

  Widget timeline() {
    return ListView.builder(
      itemCount: userTimelineList == null ? 0 : userTimelineList.length,
      itemBuilder: (context, i) {
        List impressionList = userTimelineList[i]['impression']['data'];
        List commentList = userTimelineList[i]['comment']['data'];

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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      userTimelineList[i]['photo']),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                    width: 200.0 - 32.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            userTimelineList[i]['isVerified'] ==
                                                    '1'
                                                ? Container(
                                                    height: 18,
                                                    width: 18,
                                                    child: Image.asset(
                                                        'assets/icons/icon_apps/verif.png'))
                                                : Container(),
                                            SizedBox(width: 5),
                                            Text(
                                                userTimelineList[i]['fullName'],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            userTimelineList[i]['type'] ==
                                                    'love'
                                                ? Image.asset(
                                                    'assets/icons/icon_apps/love.png',
                                                    scale: 3,
                                                  )
                                                : Container(),
                                            SizedBox(width: 5),
                                            Text(
                                                userTimelineList[i]['type'] ==
                                                        'love'
                                                    ? 'Loved'
                                                    : userTimelineList[i]
                                                                ['type'] ==
                                                            'relationship'
                                                        ? userTimelineList[i]
                                                            ['name']
                                                        : 'Post a ' +
                                                            userTimelineList[i]
                                                                ['type'],
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    )),
                              ]),
                          Column(
                            children: <Widget>[
                              Text(
                                'a minute ago',
                                style: TextStyle(fontSize: 10),
                              ),
                              SizedBox(height: 4),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                          height: userTimelineList[i]['type'] == 'video' ||
                                  userTimelineList[i]['type'] == 'photo' ||
                                  userTimelineList[i]['type'] == 'event' ||
                                  userTimelineList[i]['type'] == 'eventgoing'
                              ? 15
                              : 0),
                      userTimelineList[i]['type'] == 'video' ||
                              userTimelineList[i]['type'] == 'photo' ||
                              userTimelineList[i]['type'] == 'event' ||
                              userTimelineList[i]['type'] == 'eventgoing'
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        userTimelineList[i]['type'] == 'video'
                                            ? userTimelineList[i]['picture']
                                            : userTimelineList[i]
                                                ['pictureFull'],
                                      ),
                                      fit: BoxFit.cover)),
                              height: 400,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: userTimelineList[i]['type'] == 'video'
                                    ? Icon(
                                        Icons.play_circle_filled,
                                        size: 80,
                                        color: Colors.white,
                                      )
                                    : Container(),
                              ),
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(userTimelineList[i]['fullName'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    SizedBox(height: 8),
                                    Row(
                                      children: <Widget>[
                                        userTimelineList[i]['type'] == 'love'
                                            ? Image.asset(
                                                'assets/icons/aset_icon/like.png',
                                                scale: 3,
                                              )
                                            : Container(),
                                        SizedBox(
                                            width: userTimelineList[i]
                                                        ['type'] ==
                                                    'love'
                                                ? 8
                                                : 0),
                                        userTimelineList[i]['type'] == 'love'
                                            ? Text('Loved')
                                            : Container(),
                                        SizedBox(
                                            width: userTimelineList[i]
                                                        ['type'] ==
                                                    'love'
                                                ? 8
                                                : 0),
                                        userTimelineList[i]['type'] ==
                                                    'video' ||
                                                userTimelineList[i]['type'] ==
                                                    'photo'
                                            ? Container(
                                                width: 360 - 70.0,
                                                child: Text(
                                                    userTimelineList[i]
                                                                ['name'] ==
                                                            null
                                                        ? ''
                                                        : userTimelineList[i]
                                                            ['name'],
                                                    maxLines: 10,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A8A8B))),
                                              )
                                            : Text(
                                                userTimelineList[i]['name'] ==
                                                        null
                                                    ? ''
                                                    : userTimelineList[i]
                                                        ['name'],
                                                maxLines: 10,
                                                style: TextStyle(
                                                    color: Color(0xFF8A8A8B))),
                                      ],
                                    )
                                  ])),
                          // Container(
                          //   child: Image.asset('assets/btn_ticket/free-limited.png', scale: 7,),)
                          userTimelineList[i]['type'] == 'event'
                              ? Container(
                                  child: Image.asset(
                                    'assets/btn_ticket/free-limited.png',
                                    scale: 7,
                                  ),
                                )
                              : userTimelineList[i]['type'] == 'eventgoing'
                                  ? Container(
                                      child: Image.asset(
                                        'assets/btn_ticket/going.png',
                                        scale: 7,
                                      ),
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
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 30,
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
                                  color: impressionList.length > 0
                                      ? Colors.red
                                      : Colors.grey,
                                  scale: 3.5,
                                ),
                                SizedBox(width: 5),
                                Text(impressionList.length.toString(),
                                    style: TextStyle(
                                        color: Color(
                                            0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                              ]),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 30,
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
                                SizedBox(width: 5),
                                Text(commentList.length.toString(),
                                    style: TextStyle(
                                        color: Color(
                                            0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                              ]),
                        ),
                        SizedBox(width: impressionList.length > 99 ? 100 : 150),
                        GestureDetector(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (userTimelineList[i]['userID'] ==
                                prefs.getString('Last User ID')) {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return showMoreOption(
                                        userTimelineList[i]['id'],
                                        userTimelineList[i]['type']);
                                  });
                            } else {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return showMoreOptionReport(
                                        userTimelineList[i]['id'],
                                        userTimelineList[i]['type']);
                                  });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 30,
                            child: Icon(Icons.more_horiz),
                          ),
                        )
                      ]),
                )
              ],
            ));
      },
    );
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
                    height: 5,
                    width: 50,
                    child: Image.asset(
                      'assets/icons/icon_line.png',
                      fit: BoxFit.fill,
                    ))),
            SizedBox(height: 35),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                        height: 30,
                        width: 30,
                        child: Image.asset('assets/icons/icon_apps/delete.png'))
                    // Container(
                    //   height: 44,
                    //   width: 50,
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
            SizedBox(height: 19),
            Divider(),
            SizedBox(height: 16),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF40D7FF)),
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/icons/icon_apps/edit.png'),
                    )
                    // Container(
                    //   height: 44,
                    //   width: 50,
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
                    height: 5,
                    width: 50,
                    child: Image.asset(
                      'assets/icons/icon_line.png',
                      fit: BoxFit.fill,
                    ))),
            SizedBox(height: 35),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ReportPost()));
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                      width: 30,
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
            height: 100,
            width: 200,
            child: Column(
              children: <Widget>[
                Text(
                  'Oops',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Delete this moment?',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
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
                      width: 50,
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

  Future<http.Response> timelineList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/timeline/user?X-API-KEY=$API_KEY&page=1&userID=${widget.currentUserId}';
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
