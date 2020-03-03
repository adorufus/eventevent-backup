import 'dart:convert';

import 'package:eventevent/Widgets/Home/PeopleItem.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeeWhosGoingInvitedWidget extends StatefulWidget {
  final eventId;
  final peopleType;

  const SeeWhosGoingInvitedWidget({Key key, this.eventId, this.peopleType})
      : super(key: key);
  @override
  _SeeWhosGoingInvitedWidgetState createState() =>
      _SeeWhosGoingInvitedWidgetState();
}

class _SeeWhosGoingInvitedWidgetState extends State<SeeWhosGoingInvitedWidget> {
  List peopleList = [];
  int newPage;

  RefreshController refreshController = RefreshController(initialRefresh: false);

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    fetchPeopleData(page: newPage).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          var extractedData = json.decode(response.body);
          List updatedData = extractedData['data'][widget.peopleType]['data'];
          print('data: ' + updatedData.toString());
          peopleList.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      }
    });
  }

  @override
  void initState() {
    fetchPeopleData().then((response){
      print(response.statusCode);
      print(response.body);

      var extractedData = json.decode(response.body);

      if(response.statusCode == 200){
        setState((){
          if(widget.peopleType == 'invited'){
            peopleList = extractedData['data'][widget.peopleType];
          } else {
            peopleList = extractedData['data'][widget.peopleType]['data'];
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'All ${widget.peopleType} people',
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
      body: Container(
          child: peopleList == null
              ? Center(
                  child: Container(
                    width: ScreenUtil.instance.setWidth(25),
                    height: ScreenUtil.instance.setWidth(25),
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: CupertinoActivityIndicator(radius: 20),
                    ),
                  ),
                )
              : SmartRefresher(
                  controller: refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onLoading: _onLoading,
                  onRefresh: () {
                    setState(() {
                      newPage = 0;
                    });

                    fetchPeopleData().then((response) {
                      if (response.statusCode == 200) {
                        setState(() {
                          var extractedData = json.decode(response.body);
                          peopleList = extractedData['data'][widget.peopleType]['data'];
                          assert(peopleList != null);

                          print(peopleList);

                          return extractedData;
                        });
                      }
                    });

                    if (mounted) setState(() {});
                    refreshController.refreshCompleted();
                  },
                  footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
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
                        height: ScreenUtil.instance.setWidth(35),
                        child: Center(child: body));
                  }),
                  child: ListView.builder(
                    itemCount: peopleList == null ? 0 : peopleList.length,
                    itemBuilder: (BuildContext context, i) {
                      Color buttonColor = peopleList[i]['isFollowed'] == '0'
                          ? Color(0xFFFFFFFF)
                          : Color(0xFF55B9E5);
                      String followText = peopleList[i]['isFollowed'] == '0'
                          ? 'Follow'
                          : 'Following';
                      Color followTextColor = peopleList[i]['isFollowed'] == '0'
                          ? Color(0xFF55B9E5)
                          : Color(0xFFFFFFFF);
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProfileWidget(
                                    initialIndex: 0,
                                    userId: peopleList[i]['id'],
                                  )));
                        },
                        child: Container(
                          child: new PeopleItem(
                            image: peopleList[i]['photo'],
                            username: peopleList[i]['username'],
                            title: peopleList[i]['fullName'],
                            isVerified: peopleList[i]['isVerified'],
                            topPadding: i == 0 ? 13.0 : 0.0,
                            userId: peopleList[i]['id'],
                            isFollowing: peopleList[i]['isFollowed'],
                          ),
                        ),
                      );
                    },
                  ),
                )),
    );
  }

  Future<http.Response> fetchPeopleData({int page}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    int currentPage = 1;
    String eventIdType = 'eventID';

    setState(() {
      if (page != null) {
        currentPage += page;
      }

      if(widget.peopleType == "invited") {
        eventIdType = 'event_id';
      } else {
        eventIdType = 'eventID';
      }
    });

    String url = BaseApi().apiUrl +
        '/event/${widget.peopleType}?X-API-KEY=$API_KEY&page=$currentPage&$eventIdType=${widget.eventId}';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    });

    return response;
  }
}
