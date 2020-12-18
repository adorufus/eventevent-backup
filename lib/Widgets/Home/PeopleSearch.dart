import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
// import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
// import 'package:eventevent/Widgets/Home/SeeAll/MyTicketItem.dart';
// import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
// import 'package:eventevent/Widgets/ProfileWidget/UseTicket.dart';
// import 'package:eventevent/Widgets/eventDetailsWidget.dart';
// import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
// import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PeopleSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PeopleSearchState();
  }
}

class PeopleSearchState extends State<PeopleSearch> {
  TextEditingController searchController = new TextEditingController();
  RefreshController peopleSearchRefreshController =
      new RefreshController(initialRefresh: false);
  final dio = new Dio();

  String _searchText = "";

  List profile = new List();
  List filteredProfile = new List();
  List invitedPeople = new List<String>();
  List tempInvitedPeople = [];

  bool notFound = false;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);

    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        _searchText = "";
        filteredProfile = profile;
      } else {
        _searchText = searchController.text;
      }
    });

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: ScreenUtil.instance.setWidth(300),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1.5)
                          ]),
                      height: ScreenUtil.instance.setWidth(50),
                      child: Material(
                        borderRadius: BorderRadius.circular(40),
                        child: TextFormField(
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.search,
                          onFieldSubmitted: (value) {
                            if (value != null) {
                              _getProfile().then((response) {
                                var extractedData = json.decode(response.body);
                                List resultData = extractedData['data'];
                                List tempList = new List();

                                if (response.statusCode == 200) {
                                  isLoading = false;
                                  notFound = false;
                                  for (int i = 0; i < resultData.length; i++) {
                                    tempList.add(resultData[i]);
                                  }

                                  profile = tempList;
                                  filteredProfile = profile;
                                  if (mounted) setState(() {});
                                } else if (response.statusCode == 400) {
                                  isLoading = false;
                                  notFound = true;
                                  if (mounted) setState(() {});
                                }
                              });
                            }
                          },
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(12)),
                          autofocus: true,
                          autocorrect: false,
                          decoration: InputDecoration(
                              prefixIcon: Image.asset(
                                'assets/icons/icon_apps/search.png',
                                scale: 4.5,
                                color: Color(0xFF81818B),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 15),
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(12)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 0))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 0)))),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).pop(tempInvitedPeople);
                      },
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(15),
                                fontWeight: FontWeight.bold,
                                color: eventajaGreenTeal),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 7)
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          child: notFound == true
              ? EmptyState(
                  imagePath: 'assets/icons/empty_state/profile.png',
                  reasonText: 'No result for: \n ${searchController.text}',
                )
              : _buildList(),
        ),
      ),
    );
  }

  int peopleNewPage = 0;

  void peopleOnLoad() async {
    setState(() {
      peopleNewPage += 1;
    });

    _getProfile(page: peopleNewPage, isLoadData: true).then((response) async {
      var extractedData = json.decode(response.body);
      List resultData = extractedData['data'];
      List tempList = new List();

      if (response.statusCode == 200) {
        isLoading = false;
        notFound = false;
        for (int i = 0; i < resultData.length; i++) {
          // tempList.removeWhere((data) => data['username'] == filteredProfile)
          tempList.add(resultData[i]);
        }

        profile = tempList;
        filteredProfile.addAll(profile);

        await Future.delayed(Duration(seconds: 3));
        if (mounted) setState(() {});
        peopleSearchRefreshController.loadComplete();
      } else if (response.statusCode == 400) {
        if (mounted) setState(() {});
        peopleSearchRefreshController.loadFailed();
      }
    });
  }

  void peopleOnRefresh() async {
    setState(() {
      peopleNewPage = 0;
    });
    _getProfile().then((response) async {
      var extractedData = json.decode(response.body);
      List resultData = extractedData['data'];
      List tempList = new List();

      if (response.statusCode == 200) {
        isLoading = false;
        notFound = false;
        for (int i = 0; i < resultData.length; i++) {
          tempList.add(resultData[i]);
        }

        profile = tempList;
        filteredProfile = profile;
        await Future.delayed(Duration(seconds: 3));
        if (mounted) setState(() {});
        peopleSearchRefreshController.refreshCompleted();
      } else if (response.statusCode == 400) {
        isLoading = false;
        notFound = true;

        if (mounted) setState(() {});
        peopleSearchRefreshController.refreshFailed();
      }
    });
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = new List();
      for (int i = 0; i < filteredProfile.length; i++) {
        if (filteredProfile[i]['username']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredProfile[i]);
        }
      }
      filteredProfile = tempList;

      return isLoading == true
          ? HomeLoadingScreen().myTicketLoading()
          : SmartRefresher(
              controller: peopleSearchRefreshController,
              onLoading: peopleOnLoad,
              onRefresh: peopleOnRefresh,
              enablePullUp: true,
              child: ListView.builder(
                itemCount: filteredProfile == null ? 0 : filteredProfile.length,
                itemBuilder: (BuildContext context, i) {
                  return ListTile(
                    onTap: () {
                      saveData(i);
                    },
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(filteredProfile[i]['photo']),
                    ),
                    title: Text(
                      filteredProfile[i]['fullName'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('@' + filteredProfile[i]['username']),
                    trailing: Icon(
                      Icons.check,
                      color: invitedPeople.contains(filteredProfile[i]['id'])
                          ? eventajaGreenTeal
                          : Colors.grey,
                    ),
                  );
                },
              ),
            );
    } else {
      return Container();
    }
  }

  saveData(int index) async {
    setState(() {
      if (invitedPeople.contains(filteredProfile[index]['id'])) {
        invitedPeople.remove(filteredProfile[index]['id']);
      } else {
        invitedPeople.add(filteredProfile[index]['id']);
        tempInvitedPeople.add({
          'id': filteredProfile[index]['id'],
          'photo': filteredProfile[index]['photo'],
          'username': filteredProfile[index]['username'],
          'fullName': filteredProfile[index]['fullName']
        });
      }
      print(invitedPeople);
      print(tempInvitedPeople);
    });
  }

  Future<http.Response> _getProfile({int page, bool isLoadData = false}) async {
    int currentPage = 1;

    setState(() {
      if (isLoadData == false) {
        isLoading = true;
      }
      if (page != null) {
        currentPage += page;
      }
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/user/search?X-API-KEY=$API_KEY&people=${searchController.text}&page=$currentPage';

    final response = await http.get(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);

    return response;
  }
}
