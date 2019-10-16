import 'dart:convert';

import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/timeline/LatestMediaItem.dart';
import 'package:eventevent/Widgets/timeline/MediaDetails.dart';
import 'package:eventevent/Widgets/timeline/popularMediaItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeeAllMediaItem extends StatefulWidget {
  final initialIndex;
  final bool isVideo;

  const SeeAllMediaItem({Key key, this.initialIndex, this.isVideo})
      : super(key: key);

  @override
  _SeeAllMediaItemState createState() => _SeeAllMediaItemState();
}

class _SeeAllMediaItemState extends State<SeeAllMediaItem> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  List popularEventList;
  List discoverEventList;
  List mediaData;

  int newPage = 0;

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPage += 1;
    });

    getMedia(newPage: newPage).then((response) {
      var extractedData = json.decode(response.body);
      List updatedData = extractedData['data'];

      if (response.statusCode == 200) {
        setState(() {
          if (updatedData == null) {
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          mediaData.addAll(updatedData);
        });
        if (mounted) setState(() {});
        refreshController.loadComplete();
      } else if (extractedData['desc'] == 'Media Posts list is not found' ||
          updatedData == null) {
        refreshController.loadNoData();
      } else {
        refreshController.loadFailed();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getMedia().then((response) {
      var extractedData = json.decode(response.body);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          mediaData = extractedData['data']['data'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 75,
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
                          height: 15.49,
                          width: 9.73,
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
                    'All Media',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
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
                        SizedBox(width: 8),
                        Text('Popular',
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
                        SizedBox(width: 8),
                        Text('Latest',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12.5)),
                      ],
                    ),
                  )
                ],
                unselectedLabelColor: Colors.grey,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 123,
              child: TabBarView(
                children: <Widget>[popularEvent(), discoverEvent()],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget popularEvent() {
    return Container(
        child: mediaData == null
            ? Center(
                child: Container(
                  width: 25,
                  height: 25,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("Load data");
                  } else if (mode == LoadStatus.loading) {
                    body = CircularProgressIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text("Load Failed!");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text('More');
                  } else {
                    body = Container();
                  }

                  return Container(height: 35, child: Center(child: body));
                }),
                controller: refreshController,
                onRefresh: () {
                  setState(() {
                    newPage = 0;
                  });
                  getMedia(newPage: newPage).then((response) {
                    var extractedData = json.decode(response.body);

                    print(response.statusCode);
                    print(response.body);

                    if (response.statusCode == 200) {
                      setState(() {
                        mediaData = extractedData['data']['data'];
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
                child: ListView.builder(
                  itemCount: mediaData == null ? 0 : mediaData.length,
                  itemBuilder: (BuildContext context, i) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MediaDetails(
                                      userPicture: mediaData[i]['creator']
                                          ['photo'],
                                      articleDetail: mediaData[i]
                                          ['description'],
                                      imageCount: 'img' + i.toString(),
                                      username: mediaData[i]['creator']
                                          ['username'],
                                      imageUri: mediaData[i]['banner'],
                                      mediaTitle: mediaData[i]['title'],
                                      autoFocus: false,
                                    )));
                      },
                      child: new LatestMediaItem(
                        isVideo: widget.isVideo,
                        image: mediaData[i]['banner_avatar'],
                        title: mediaData[i]['title'],
                        username: mediaData[i]['creator']['username'],
                        userImage: mediaData[i]['creator']['photo'],
                      ),
                    );
                  },
                )));
  }

  Widget discoverEvent() {
    return Container(
        child: mediaData == null
            ? Center(
                child: Container(
                  width: 25,
                  height: 25,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("Load data");
                  } else if (mode == LoadStatus.loading) {
                    body = CircularProgressIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text("Load Failed!");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text('More');
                  } else {
                    body = Container();
                  }

                  return Container(height: 35, child: Center(child: body));
                }),
                controller: refreshController,
                onRefresh: () {
                  setState(() {
                    newPage = 0;
                  });
                  getMedia(newPage: newPage).then((response) {
                    var extractedData = json.decode(response.body);

                    print(response.statusCode);
                    print(response.body);

                    if (response.statusCode == 200) {
                      setState(() {
                        mediaData = extractedData['data']['data'];
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
                child: ListView.builder(
                  itemCount: mediaData == null ? 0 : mediaData.length,
                  itemBuilder: (BuildContext context, i) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MediaDetails(
                                      userPicture: mediaData[i]['creator']
                                          ['photo'],
                                      articleDetail: mediaData[i]
                                          ['description'],
                                      imageCount: 'img' + i.toString(),
                                      username: mediaData[i]['creator']
                                          ['username'],
                                      imageUri: mediaData[i]['banner'],
                                      mediaTitle: mediaData[i]['title'],
                                      autoFocus: false,
                                    )));
                      },
                      child: new LatestMediaItem(
                        isVideo: widget.isVideo,
                        image: mediaData[i]['banner_timeline'],
                        title: mediaData[i]['title'],
                        username: mediaData[i]['creator']['username'],
                        userImage: mediaData[i]['creator']['photo'],
                      ),
                    );
                  },
                )));
  }

  Future<http.Response> getMedia({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (newPage != null) {
        currentPage += newPage;
      }
      print(currentPage);
    });

    String url = BaseApi().apiUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=$currentPage&limit=10&type=photo&status=popular';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}
