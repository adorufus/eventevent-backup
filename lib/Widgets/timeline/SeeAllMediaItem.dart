import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/timeline/LatestMediaItem.dart';
import 'package:eventevent/Widgets/timeline/MediaDetails.dart';
import 'package:eventevent/Widgets/timeline/popularMediaItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeeAllMediaItem extends StatefulWidget {
  final initialIndex;

  final bool isVideo;
  final likeCount;
  final commentCount;
  final isRest;

  const SeeAllMediaItem(
      {Key key,
      this.initialIndex,
      this.isVideo,
      this.likeCount,
      this.commentCount,
      @required this.isRest})
      : super(key: key);

  @override
  _SeeAllMediaItemState createState() => _SeeAllMediaItemState();
}

class _SeeAllMediaItemState extends State<SeeAllMediaItem> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  List popularEventList;
  List latestMedia;
  List popularMedia;
  int likeCount;
  List commentCount;

  String imageUrl = '';

  int currentTabIndex = 0;

  int newPagePopular = 0;
  int newPageLatest = 0;

  void onLoadingLatest() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPageLatest += 1;
    });

    getLatestMedia(newPage: newPageLatest).then((response) {
      var extractedData = json.decode(response.body);
      List updatedData = extractedData['data']['data'];

      if (response.statusCode == 200) {
        setState(() {
          if (updatedData == null) {
            refreshController.loadNoData();
          }
          print('data: ' + updatedData.toString());
          latestMedia.addAll(updatedData);
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

  void _onLoadingPopular() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      newPagePopular += 1;
    });
      getPopularMedia(newPage: newPagePopular).then((response) {
        var extractedData = json.decode(response.body);
        List updatedData = extractedData['data']['data'];

        if (response.statusCode == 200) {
          setState(() {
            if (updatedData == null) {
              refreshController.loadNoData();
            }
            print('data: ' + updatedData.toString());
            popularMedia.addAll(updatedData);
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
    setState(() {
      commentCount = widget.commentCount;
      likeCount = widget.likeCount;
    });
    getPopularMedia().then((response) {
      var extractedData = json.decode(response.body);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          popularMedia = extractedData['data']['data'];
        });
      }
    });

    getLatestMedia().then((response) {
      var extractedData = json.decode(response.body);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          latestMedia = extractedData['data']['data'];
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
                      'All Media',
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
            children: <Widget>[
              Container(
                color: Colors.white,
                child: TabBar(
                  onTap: (index) {
                    setState(() {
                      currentTabIndex = index;
                    });
                  },
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
                            'assets/icons/icon_apps/latest.png',
                            scale: 4.5,
                          ),
                          SizedBox(width: ScreenUtil.instance.setWidth(8)),
                          Text('Latest',
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
                height: MediaQuery.of(context).size.height - 123,
                child: TabBarView(
                  children: <Widget>[popularEvent(), discoverEvent()],
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
        child: popularMedia == null
            ? HomeLoadingScreen().myTicketLoading()
            : SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
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
                controller: refreshController,
                onRefresh: () {
                  setState(() {
                    newPagePopular = 0;
                  });
                  getPopularMedia(newPage: newPagePopular).then((response) {
                    var extractedData = json.decode(response.body);

                    print(response.statusCode);
                    print(response.body);

                    if (response.statusCode == 200) {
                      setState(() {
                        popularMedia = extractedData['data']['data'];
                      });
                      if (mounted) setState(() {});
                      refreshController.refreshCompleted();
                    } else {
                      if (mounted) setState(() {});
                      refreshController.refreshFailed();
                    }
                  });
                },
                onLoading: _onLoadingPopular,
                child: ListView.builder(
                  itemCount: popularMedia == null ? 0 : popularMedia.length,
                  itemBuilder: (BuildContext context, i) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => widget.isVideo == false
                                    ? MediaDetails(
                                        isRest: widget.isRest,
                                        userPicture: popularMedia[i]['creator']
                                            ['photo'],
                                        articleDetail: popularMedia[i]
                                            ['content'],
                                        imageCount: 'img' + i.toString(),
                                        username: popularMedia[i]['creator']
                                            ['username'],
                                        imageUri: popularMedia[i]['banner'],
                                        mediaTitle: popularMedia[i]['title'],
                                        autoFocus: false,
                                        mediaId: popularMedia[i]['id'],
                                        isVideo: false,
                                      )
                                    : MediaDetails(
                                        isRest: widget.isRest,
                                        isVideo: true,
                                        videoUrl: popularMedia[i]['video'],
                                        youtubeUrl: popularMedia[i]['youtube'],
                                        userPicture: popularMedia[i]['creator']
                                            ['photo'],
                                        articleDetail: popularMedia[i]
                                            ['content'],
                                        imageCount: 'img' + i.toString(),
                                        username: popularMedia[i]['creator']
                                            ['username'],
                                        imageUri: popularMedia[i]
                                            ['thumbnail_timeline'],
                                        mediaTitle: popularMedia[i]['title'],
                                        autoFocus: false,
                                        mediaId: popularMedia[i]['id'],
                                      )));
                      },
                      child: new LatestMediaItem(
                        isRest: widget.isRest,
                        isVideo: widget.isVideo,
                        isLiked: popularMedia[i]['is_loved'],
                        image: widget.isVideo == true
                            ? popularMedia[i]['thumbnail_timeline']
                            : popularMedia[i]['banner_timeline'],
                        title: popularMedia[i]['title'],
                        username: popularMedia[i]['creator']['username'],
                        userImage: popularMedia[i]['creator']['photo'],
                        likeCount: popularMedia[i]['count_loved'],
                        commentCount: popularMedia[i]['comment'],
                      ),
                    );
                  },
                )));
  }

  Widget discoverEvent() {
    return Container(
        child: popularMedia == null
            ? HomeLoadingScreen().myTicketLoading()
            : SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
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
                controller: refreshController,
                onRefresh: () {
                  setState(() {
                    newPagePopular = 0;
                  });
                  getLatestMedia(newPage: newPagePopular).then((response) {
                    var extractedData = json.decode(response.body);

                    print(response.statusCode);
                    print(response.body);

                    if (response.statusCode == 200) {
                      setState(() {
                        latestMedia = extractedData['data']['data'];
                      });
                      if (mounted) setState(() {});
                      refreshController.refreshCompleted();
                    } else {
                      if (mounted) setState(() {});
                      refreshController.refreshFailed();
                    }
                  });
                },
                onLoading: onLoadingLatest,
                child: ListView.builder(
                  itemCount: latestMedia == null ? 0 : latestMedia.length,
                  itemBuilder: (BuildContext context, i) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => widget.isVideo == false
                                    ? MediaDetails(
                                        isRest: widget.isRest,
                                        userPicture: latestMedia[i]['creator']
                                            ['photo'],
                                        articleDetail: latestMedia[i]
                                            ['content'],
                                        imageCount: 'img' + i.toString(),
                                        username: latestMedia[i]['creator']
                                            ['username'],
                                        imageUri: latestMedia[i]['banner'],
                                        mediaTitle: latestMedia[i]['title'],
                                        autoFocus: false,
                                        mediaId: latestMedia[i]['id'],
                                        isVideo: false,
                                      )
                                    : MediaDetails(
                                        isRest: widget.isRest,
                                        isVideo: true,
                                        videoUrl: latestMedia[i]['video'],
                                        youtubeUrl: latestMedia[i]['youtube'],
                                        userPicture: latestMedia[i]['creator']
                                            ['photo'],
                                        articleDetail: latestMedia[i]
                                            ['content'],
                                        imageCount: 'img' + i.toString(),
                                        username: latestMedia[i]['creator']
                                            ['username'],
                                        imageUri: latestMedia[i]
                                            ['thumbnail_timeline'],
                                        mediaTitle: latestMedia[i]['title'],
                                        autoFocus: false,
                                        mediaId: latestMedia[i]['id'],
                                      )));
                      },
                      child: new LatestMediaItem(
                        isRest: widget.isRest,
                        isVideo: widget.isVideo,
                        image: widget.isVideo == true
                            ? latestMedia[i]['thumbnail_timeline']
                            : latestMedia[i]['banner_timeline'],
                        isLiked: latestMedia[i]['is_loved'],
                        title: latestMedia[i]['title'],
                        username: latestMedia[i]['creator']['username'],
                        userImage: latestMedia[i]['creator']['photo'],
                        likeCount: latestMedia[i]['count_loved'],
                        commentCount: latestMedia[i]['comment'],
                      ),
                    );
                  },
                )));
  }

  Future<http.Response> getPopularMedia({int newPage}) async {
    int currentPage = 1;
    String type = 'photo';
    String status = 'popular';
    Map<String, String> headers;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String baseApi;

    setState(() {
      if (newPage != null) {
        currentPage += newPage;
      }
      print(currentPage);

      if (widget.isRest == true) {
        baseApi = BaseApi().restUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'signature': SIGNATURE,
        };
      } else {
        baseApi = BaseApi().apiUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session'),
        };
      }
    });

    if (widget.isVideo == true) {
      setState(() {
        type = 'video';
      });
    } else {
      setState(() {
        type = 'photo';
      });
    }

    String url = baseApi +
        '/media?X-API-KEY=$API_KEY&search=&page=$currentPage&limit=10&type=$type&status=popular';

    final response = await http.get(url, headers: headers);

    return response;
  }

  Future<http.Response> getLatestMedia({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;
    String type = 'photo';
    String status = 'popular';
    Map<String, String> headers;
    String baseApi;

    setState(() {
      if (newPage != null) {
        currentPage += newPage;
      }
      print(currentPage);

      if (widget.isRest == true) {
        baseApi = BaseApi().restUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'signature': SIGNATURE,
        };
      } else {
        baseApi = BaseApi().apiUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session'),
        };
      }
    });

    if (widget.isVideo == true) {
      setState(() {
        type = 'video';
      });
    } else {
      setState(() {
        type = 'photo';
      });
    }

    String url = baseApi +
        '/media?X-API-KEY=$API_KEY&search=&page=$currentPage&limit=10&type=$type&status=latest';

    final response = await http.get(url, headers: headers);

    return response;
  }
}
