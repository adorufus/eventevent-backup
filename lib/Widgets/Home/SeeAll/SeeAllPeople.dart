import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/PeopleItem.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SeeAllPeople extends StatefulWidget {
  final initialIndex;
  final isRest;

  const SeeAllPeople({Key key, this.initialIndex, this.isRest})
      : super(key: key);

  @override
  _SeeAllPeopleState createState() => _SeeAllPeopleState();
}

class _SeeAllPeopleState extends State<SeeAllPeople> {
  List popularPeopleList;
  List discoverPeopleList;

  @override
  void initState() {
    super.initState();
    popularPeopleData().then((response) {
      print(response.statusCode);
      print(response.body);

      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          popularPeopleList = extractedData['data'];
        });
      }
    });

    discoverPeopleData().then((response) {
      print(response.statusCode);
      print(response.body);

      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          discoverPeopleList = extractedData['data'];
        });
      }
    });
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
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(null, 100),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil.instance.setWidth(75),
            child: Container(
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.fromLTRB(13, 15, 13, 0),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(15.49),
                            width: ScreenUtil.instance.setWidth(9.73),
                            child: Image.asset(
                              'assets/icons/icon_apps/arrow.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 2.8),
                    Text(
                      'All People',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil.instance.setSp(14)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: DefaultTabController(
          initialIndex: widget.initialIndex,
          length: 2,
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                color: Colors.white,
                child: TabBar(
                  tabs: <Widget>[
                    Tab(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/icons/icon_apps/popular.png',
                            scale: 4.5,
                          ),
                          SizedBox(width: ScreenUtil.instance.setWidth(8)),
                          Text('Popular',
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
                            'assets/icons/icon_apps/discover.png',
                            scale: 4.5,
                          ),
                          SizedBox(width: ScreenUtil.instance.setWidth(8)),
                          Text('Discover',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(12.5))),
                        ],
                      ),
                    )
                  ],
                  unselectedLabelColor: Colors.grey,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 136,
                child: TabBarView(
                  children: <Widget>[
                    Container(
                      child: popularEvent(),
                    ),
                    discoverEvent()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget popularEvent() {
    return Container(
        child: popularPeopleList == null
            ? HomeLoadingScreen().followListLoading()
            : ListView.builder(
                itemCount:
                    popularPeopleList == null ? 0 : popularPeopleList.length,
                itemBuilder: (BuildContext context, i) {
                  Color buttonColor = popularPeopleList[i]['isFollowed'] == '0'
                      ? Color(0xFFFFFFFF)
                      : Color(0xFF55B9E5);
                  String followText = popularPeopleList[i]['isFollowed'] == '0'
                      ? 'Follow'
                      : 'Following';
                  Color followTextColor =
                      popularPeopleList[i]['isFollowed'] == '0'
                          ? Color(0xFF55B9E5)
                          : Color(0xFFFFFFFF);
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileWidget(
                                initialIndex: 0,
                                userId: popularPeopleList[i]['id'],
                              )));
                    },
                    child: Container(
                      child: new PeopleItem(
                        image: popularPeopleList[i]['photo'],
                        username: popularPeopleList[i]['username'],
                        title: popularPeopleList[i]['fullName'],
                        isVerified: popularPeopleList[i]['isVerified'],
                        topPadding: i == 0 ? 13.0 : 0.0,
                        userId: popularPeopleList[i]['id'],
                        isFollowing: popularPeopleList[i]['isFollowed'],
                      ),
                    ),
                  );
                },
              ));
  }

  Widget discoverEvent() {
    return Container(
        child: discoverPeopleList == null
            ? HomeLoadingScreen().followListLoading()
            : ListView.builder(
                itemCount:
                    discoverPeopleList == null ? 0 : discoverPeopleList.length,
                itemBuilder: (BuildContext context, i) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileWidget(
                                initialIndex: 0,
                                userId: discoverPeopleList[i]['id'],
                              )));
                    },
                    child: new PeopleItem(
                      image: discoverPeopleList[i]['photo'],
                      username: discoverPeopleList[i]['username'],
                      isVerified: discoverPeopleList[i]['isVerified'],
                      title: discoverPeopleList[i]['fullName'],
                      topPadding: i == 0 ? 13.0 : 0.0,
                      userId: discoverPeopleList[i]['id'],
                      isFollowing: discoverPeopleList[i]['isFollowed'],
                    ),
                  );
                },
              ));
  }

  Future<http.Response> popularPeopleData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

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

    final catalogApiUrl = baseUrl +
        '/user/popular?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b&page=1&total=20';
    final response = await http.get(catalogApiUrl, headers: headers);

    return response;
  }

  Future<http.Response> discoverPeopleData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    final catalogApiUrl = baseUrl +
        '/user/discover?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b&page=1&total=20';
    final response = await http.get(catalogApiUrl, headers: headers);

    return response;
  }
}
