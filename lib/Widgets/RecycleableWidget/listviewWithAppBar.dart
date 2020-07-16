import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/PeopleItem.dart';
import 'package:eventevent/Widgets/RecycleableWidget/EmptyState.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/FollowUnfollow.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ListViewWithAppBar extends StatefulWidget {
  final String title;
  final String apiURL;
  final isRest;

  const ListViewWithAppBar({Key key, @required this.title, this.apiURL, this.isRest})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ListViewWithAppBar();
  }
}

class _ListViewWithAppBar extends State<ListViewWithAppBar> {
  var session;
  String profileImageUrl;
  String isFollowed;
  String username;
  String isVerified;
  String fullName;
  String isApproved;
  String imageURI;
  bool isEmpty = false;

  List profileData;

  @override
  void initState() {
    super.initState();
    getItemFromAPI();
  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            CupertinoIcons.back,
            size: 50,
            color: eventajaGreenTeal,
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      body: profileData == null
          ? HomeLoadingScreen().followListLoading()
          : isEmpty == true
              ? EmptyState(
                  emptyImage: 'assets/drawable/profile_empty_state.png',
                  reasonText: 'You Have No Friends Yet',
                )
              : ListView.builder(
                  itemCount: profileData == null ? 0 : profileData.length,
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ProfileWidget(
                              initialIndex: 0,
                              userId: profileData[i]['id'],
                            )));
                      },
                      child: PeopleItem(
                        image: profileData[i]['photo'],
                        username: profileData[i]['username'],
                        isVerified: profileData[i]['isVerified'],
                        title: profileData[i]['fullName'],
                        topPadding: i == 0 ? 13.0 : 0.0,
                        userId: profileData[i]['id'],
                        isFollowing: profileData[i]['isFollowed'],
                      ),
                    );
                    // return Container(
                    //   height: ScreenUtil.instance.setWidth(100),
                    //   width: MediaQuery.of(context).size.width,
                    //   color: Colors.white,
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: <Widget>[
                    //         Container(
                    //           height: ScreenUtil.instance.setWidth(200),
                    //           width: ScreenUtil.instance.setWidth(60),
                    //           decoration: BoxDecoration(
                    //               color: Colors.white,
                    //               boxShadow: <BoxShadow>[
                    //                 BoxShadow(
                    //                     offset: Offset(1, 1),
                    //                     color: Colors.grey,
                    //                     blurRadius: 2)
                    //               ],
                    //               shape: BoxShape.circle,
                    //               image: DecorationImage(
                    //                   image: NetworkImage(profileData[i]['photo']),
                    //                   fit: BoxFit.fill)),
                    //         ),
                    //         SizedBox(
                    //           width: ScreenUtil.instance.setWidth(15),
                    //         ),
                    //         Column(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: <Widget>[
                    //             Text(
                    //               profileData[i]['fullName'] == null
                    //                   ? 'loading'
                    //                   : profileData[i]['fullName'],
                    //               style: TextStyle(
                    //                   fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(20)),
                    //             ),
                    //             SizedBox(
                    //               height: ScreenUtil.instance.setWidth(10),
                    //             ),
                    //             Text(
                    //               profileData[i]['username'] == null
                    //                   ? 'loading'
                    //                   : '@' + profileData[i]['username'],
                    //               style: TextStyle(fontSize: ScreenUtil.instance.setSp(20), color: Colors.grey),
                    //             )
                    //           ],
                    //         ),
                    //         SizedBox(
                    //           width: MediaQuery.of(context).size.width / 5,
                    //         ),
                    //         GestureDetector(
                    //           onTap: profileData[i]['isFollowed'] == '0' ? (){
                    //             FollowUnfollow().follow(profileData[i]['id']);
                    //           } : (){
                    //             FollowUnfollow().unfollow(profileData[i]['id']);
                    //           } ,
                    //           child: Container(
                    //             height: ScreenUtil.instance.setWidth(50),
                    //             height: ScreenUtil.instance.setWidth(100),
                    //             child: Image.asset(profileData[i]['isFollowed'] == '0'
                    //                 ? 'assets/icons/btn_follow.png'
                    //                 : 'assets/icons/btn_following.png'),
                    //           ),
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // );
                  },
                ),
    );
  }

  Future getItemFromAPI() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    session = preferences.getString('Session');

    Map<String, String> headers;

    if (widget.isRest) {
      
      headers = {
        'Authorization': AUTHORIZATION_KEY,
        'signature': SIGNATURE,
      };
    } else {
      
      headers = {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session')
      };
    }

    final urlApi = widget.apiURL;
    final response = await http.get(urlApi, headers: headers);

    var extractedData = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        if (extractedData['data'].length == 0) {
          isEmpty = true;
        } else {
          isEmpty = false;
          profileData = extractedData['data'];
        }
      });
    }
  }
}
