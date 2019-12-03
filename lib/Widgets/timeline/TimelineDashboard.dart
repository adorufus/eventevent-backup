import 'dart:convert';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/Widgets/openMedia.dart';
import 'package:eventevent/Widgets/timeline/EditPost.dart';
import 'package:eventevent/Widgets/timeline/LatestMediaItem.dart';
import 'package:eventevent/Widgets/timeline/MediaDetails.dart';
import 'package:eventevent/Widgets/timeline/ReportPost.dart';
import 'package:eventevent/Widgets/timeline/SeeAllMediaItem.dart';
import 'package:eventevent/Widgets/timeline/UserMediaDetail.dart';
import 'package:eventevent/Widgets/timeline/VideoPlayer.dart';
import 'package:eventevent/Widgets/timeline/popularMediaItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TimelineDashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TimelineDashboardState();
  }
}

class TimelineDashboardState extends State<TimelineDashboard>
    with WidgetsBindingObserver {
  List timelineList = [];
  List mediaData = [];
  List popularMediaVideo = [];
  List latestMediaPhoto = [];
  List latestMediaVideo = [];
  List bannerData;
  String currentUserId;
  bool isLoading = false;

  GlobalKey modalBottomSheetKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserData();
    getPopularMediaPhoto().then((response) {
      var extractedData = json.decode(response.body);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          mediaData = extractedData['data']['data'];
        });
      }
    });

    getPopularMediaVideo().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          popularMediaVideo = extractedData['data']['data'];
        });
      } else if (response.statusCode == 404) {
        scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
          content: Text(
            '404: something not found',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
      }
    }).catchError((e) {
      scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Error Occured: ' + e.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ));
    }).timeout(Duration(seconds: 10), onTimeout: () {
      scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Request Timeout',
          style: TextStyle(color: Colors.white),
        ),
      ));
    });

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
      if (state == AppLifecycleState.resumed) {
        setState(() {});
      }
    }

    getLatestMediaPhoto().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          latestMediaPhoto = extractedData['data']['data'];
        });
      } else if (response.statusCode == 404) {
        scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
          content: Text(
            '404: something not found',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
      }
    }).catchError((e) {
      scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Error Occured: ' + e.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ));
    }).timeout(Duration(seconds: 10), onTimeout: () {
      scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Request Timeout',
          style: TextStyle(color: Colors.white),
        ),
      ));
    });

    getLatestMediaVideo().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          latestMediaVideo = extractedData['data']['data'];
        });
      } else if (response.statusCode == 404) {
        scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
          content: Text(
            '404: something not found',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
      }
    }).catchError((e) {
      scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Error Occured: ' + e.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ));
    }).timeout(Duration(seconds: 10), onTimeout: () {
      scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Request Timeout',
          style: TextStyle(color: Colors.white),
        ),
      ));
    });

    getBanner().then((response) {
      var extractedData = json.decode(response.body);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          bannerData = extractedData['data']['data'];
        });
      }
    });
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
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  RefreshController homeRefreshController =
      RefreshController(initialRefresh: false);

  int newPage = 0;

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

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      currentUserId = prefs.getString('Last User ID');
    });

    print(currentUserId);
  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    mappedDataBanner = bannerData?.map((bannerData) {
          return bannerData == null
              ? Center(child: CircularProgressIndicator())
              : Builder(
                  builder: (BuildContext context) {
                    return bannerData == null
                        ? Center(child: CircularProgressIndicator())
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OpenMedia(
                                            articleID: bannerData['id'],
                                            url: bannerData['link'],
                                          )));
                            },
                            child: Container(
                              width: MediaQuery.of(context).devicePixelRatio *
                                  2645.0,
                              margin: EdgeInsets.only(
                                  left: 13, right: 13, bottom: 15, top: 13),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: Offset(0, 0),
                                        blurRadius: 2,
                                        spreadRadius: 1.5)
                                  ],
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                      bannerData["banner"],
                                    ),
                                  )),
                            ),
                          );
                  },
                );
        })?.toList() ??
        [];

    return SafeArea(
      child: mediaData == null
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Scaffold(
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
                          Row(
                            children: <Widget>[
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(23),
                                width: ScreenUtil.instance.setWidth(93),
                                child: Image.asset(
                                  'assets/icons/aset_icon/emedia.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                          Container(
                              height: ScreenUtil.instance.setWidth(35),
                              width: ScreenUtil.instance.setWidth(35),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: Offset(0, 0),
                                        spreadRadius: 1.5,
                                        blurRadius: 2)
                                  ]),
                              child: Image.asset(
                                'assets/icons/ticket.png',
                                scale: 3,
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.5),
              body: DefaultTabController(
                initialIndex: 0,
                length: 2,
                child: ListView(
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
                                  'assets/icons/icon_apps/home.png',
                                  scale: 4.5,
                                ),
                                SizedBox(width: ScreenUtil.instance.setWidth(8)),
                                Text('Home',
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
                                  'assets/icons/icon_apps/public_timeline.png',
                                  scale: 4.5,
                                ),
                                SizedBox(width: ScreenUtil.instance.setWidth(8)),
                                Text('Public Timeline',
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
                      height: MediaQuery.of(context).size.height - 197,
                      child: Stack(
                        children: <Widget>[
                          TabBarView(
                            children: <Widget>[emedia(), userMedia()],
                          ),
                          Positioned(
                              child: isLoading == true
                                  ? Container(
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                      color: Colors.black.withOpacity(0.5),
                                    )
                                  : Container())
                        ],
                      ),
                    )
                  ],
                ),
              )),
    );
  }

  getSize() {}

  Widget tabView() {
    // print(preferedSize.size.height.toString());
    // return ;
  }

  Future doRefresh() async {
    await Future.delayed(Duration(seconds: 5), () {
      setState(() {
        getPopularMediaVideo().then((response) {
          var extractedData = json.decode(response.body);

          if (response.statusCode == 200) {
            isLoading = false;
            setState(() {
              popularMediaVideo = extractedData['data']['data'];
            });
          } else if (response.statusCode == 404) {
            isLoading = false;
            scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
              content: Text(
                '404: something not found',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ));
          }
        }).catchError((e) {
          isLoading = false;
          scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error Occured: ' + e.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ));
        }).timeout(Duration(seconds: 10), onTimeout: () {
          isLoading = false;
          scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Request Timeout',
              style: TextStyle(color: Colors.white),
            ),
          ));
        });

        getLatestMediaPhoto().then((response) {
          var extractedData = json.decode(response.body);

          if (response.statusCode == 200) {
            isLoading = false;
            setState(() {
              latestMediaPhoto = extractedData['data']['data'];
            });
          } else if (response.statusCode == 404) {
            isLoading = false;
            scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
              content: Text(
                '404: something not found',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ));
          }
        }).catchError((e) {
          isLoading = false;
          scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error Occured: ' + e.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ));
        }).timeout(Duration(seconds: 10), onTimeout: () {
          isLoading = false;
          scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Request Timeout',
              style: TextStyle(color: Colors.white),
            ),
          ));
        });

        getLatestMediaVideo().then((response) {
          var extractedData = json.decode(response.body);

          if (response.statusCode == 200) {
            isLoading = false;
            setState(() {
              latestMediaVideo = extractedData['data']['data'];
            });
          } else if (response.statusCode == 404) {
            isLoading = false;
            scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
              content: Text(
                '404: something not found',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ));
          }
        }).catchError((e) {
          isLoading = false;
          scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error Occured: ' + e.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ));
        }).timeout(Duration(seconds: 10), onTimeout: () {
          isLoading = false;
          scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Request Timeout',
              style: TextStyle(color: Colors.white),
            ),
          ));
        });
        isLoading = false;
        getUserData();
        getPopularMediaPhoto().then((response) {
          var extractedData = json.decode(response.body);

          print(response.statusCode);
          print(response.body);

          if (response.statusCode == 200) {
            isLoading = false;
            setState(() {
              mediaData = extractedData['data']['data'];
            });
          }
        });

        getBanner().then((response) {
          var extractedData = json.decode(response.body);

          print(response.statusCode);
          print(response.body);

          if (response.statusCode == 200) {
            isLoading = false;
            setState(() {
              bannerData = extractedData['data']['data'];
            });
          }
        });
        getTimelineList().then((response) {
          print(response.statusCode);
          print(response.body);
          var extractedData = json.decode(response.body);

          print('Timeline List -> ${response.body.toString()}');

          if (response.statusCode == 200) {
            isLoading = false;
            setState(() {
              timelineList = extractedData['data'];
            });
          }
        });
      });
      if (mounted == true) setState(() {});
      homeRefreshController.refreshCompleted();
    });
  }

  Widget emedia() {
    return SmartRefresher(
      controller: homeRefreshController,
      enablePullDown: true,
      enablePullUp: false,
      onRefresh: () {
        doRefresh();
      },
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          banner(),
          popularVideoHeader(),
          popularVideoContent(),
          latestVideoHeader(),
          latestVideoContent(),
          mediaHeader(),
          mediaContent(),
          latestMediaHeader(),
          latestMediaContent(),
        ],
      ),
    );
  }

  Widget mediaHeader() {
    return new Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 25, bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Popular Media',
                  style: TextStyle(
                      color: eventajaBlack,
                      fontSize: ScreenUtil.instance.setSp(19),
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 4.5,
              )),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SeeAllMediaItem(
                                initialIndex: 0,
                                isVideo: false,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget mediaContent() {
    return Container(
      height: ScreenUtil.instance.setWidth(247),
      child: ListView.builder(
        itemCount: mediaData == null ? 0 : mediaData.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, i) {
          return Hero(
            tag: 'img' + i.toString(),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MediaDetails(
                              userPicture: mediaData[i]['creator']['photo'],
                              articleDetail: mediaData[i]['content'],
                              imageCount: 'img' + i.toString(),
                              username: mediaData[i]['creator']['username'],
                              imageUri: mediaData[i]['banner'],
                              mediaTitle: mediaData[i]['title'],
                              autoFocus: false,
                              mediaId: mediaData[i]['id'],
                              isVideo: false,
                            )));
              },
              child: MediaItem(
                isVideo: false,
                image: mediaData[i]['banner_timeline'],
                title: mediaData[i]['title'],
                username: mediaData[i]['creator']['username'],
                userPicture: mediaData[i]['creator']['photo'],
                articleDetail: mediaData[i]['description'],
                imageIndex: i,
                likeCount: mediaData[i]['count_loved'],
                commentCount: mediaData[i]['comment'],
                mediaId: mediaData[i]['id'],
              ),
            ),
          );
        },
      ),
    );
    // return Container(
    //   padding: EdgeInsets.symmetric(vertical: 8),
    //     height: ScreenUtil.instance.setWidth(247 + 9.0),
    //     alignment: Alignment.centerLeft,
    //     child: new ListView.builder(
    //         scrollDirection: Axis.horizontal,
    //         itemCount: 20,
    //         itemBuilder: (BuildContext context, i) {
    //           return Padding(
    //             padding: const EdgeInsets.only(right: 2.5, left: 13),
    //             child: new Container(
    //                 alignment: Alignment.center,
    //                 decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.circular(15),
    //                     boxShadow: <BoxShadow>[
    //                       BoxShadow(
    //                           color: Colors.grey,
    //                           offset: Offset(1, 1),
    //                           spreadRadius: 1,
    //                           blurRadius: 5),
    //                     ]),
    //                 width: i == 0 ? 223 : 223,
    //                 child: Padding(
    //                   padding: i == 0
    //                       ? EdgeInsets.only(left: 0)
    //                       : EdgeInsets.only(left: 0),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     mainAxisAlignment: MainAxisAlignment.start,
    //                     mainAxisSize: MainAxisSize.max,
    //                     children: <Widget>[
    //                       GestureDetector(
    //                         onTap: () {
    //                           // launch(
    //                           //     'https://media.eventevent.com/medias/${mediaData['data'][i]['id']}',
    //                           //     enableJavaScript: true,
    //                           //     forceWebView: true,
    //                           //     forceSafariVC: true);
    //                         },
    //                         child: Container(
    //                           height: ScreenUtil.instance.setWidth(146),
    //                           width: i == 0 ? 223 : 223,
    //                           decoration: BoxDecoration(
    //                             color: Color(0xFFFEC97C),
    //                             borderRadius: BorderRadius.only(
    //                                 topLeft: Radius.circular(15),
    //                                 topRight: Radius.circular(15)),
    //                             // image: DecorationImage(
    //                             //     image: NetworkImage(
    //                             //       mediaData['data'][i]['banner'],
    //                             //     ),
    //                             //     fit: BoxFit.fill)
    //                           ),
    //                         ),
    //                       ),
    //                       Container(
    //                         height: ScreenUtil.instance.setWidth(110),
    //                         decoration: BoxDecoration(
    //                           color: Colors.white,
    //                           borderRadius: BorderRadius.only(
    //                               topLeft: Radius.circular(15),
    //                               topRight: Radius.circular(15)),
    //                         ),
    //                         child: Column(children: <Widget>[
    //                           SizedBox(height: ScreenUtil.instance.setWidth(9)),
    //                           // Text(data[i]["dateStart"],
    //                           //     style: TextStyle(color: eventajaGreenTeal),
    //                           //     textAlign: TextAlign.start),
    //                           Padding(
    //                             padding: const EdgeInsets.only(left: 15),
    //                             child: Column(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               mainAxisAlignment: MainAxisAlignment.start,
    //                               children: <Widget>[
    //                                 Container(
    //                                   width: ScreenUtil.instance.setWidth(220),
    //                                   child: Text(
    //                                     'Masuk Universitas Favorit \n Penting, Tapi...',
    //                                     // mediaData['data'][i]["title"],
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: TextStyle(
    //                                         fontSize: ScreenUtil.instance.setSp(20),
    //                                         fontWeight: FontWeight.bold),
    //                                     textAlign: TextAlign.start,
    //                                     maxLines: 2,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           SizedBox(height: ScreenUtil.instance.setWidth(9)),
    //                           Padding(
    //                             padding: const EdgeInsets.only(left: 10),
    //                             child: Row(
    //                               mainAxisAlignment: MainAxisAlignment.start,
    //                               crossAxisAlignment: CrossAxisAlignment.center,
    //                               children: <Widget>[
    //                                 Container(
    //                                     height: ScreenUtil.instance.setWidth(30),
    //                                     width: ScreenUtil.instance.setWidth(30),
    //                                     decoration: BoxDecoration(
    //                                       color: Colors.lightBlueAccent,
    //                                       shape: BoxShape.circle,
    //                                       // image: DecorationImage(
    //                                       //     image: NetworkImage(
    //                                       //         mediaData['data'][i]
    //                                       //             ['creator']['photo']),
    //                                       //     fit: BoxFit.fill),
    //                                     )),
    //                                 SizedBox(
    //                                   height: ScreenUtil.instance.setWidth(10),
    //                                 ),
    //                                 Text('Eventevent'
    //                                     // mediaData['data'][i]['creator']
    //                                     //           ['fullName'] ==
    //                                     //       null
    //                                     //   ? '-'
    //                                     //   : mediaData['data'][i]['creator']
    //                                     //       ['fullName']
    //                                     )
    //                               ],
    //                             ),
    //                           ),
    //                         ]),
    //                       )
    //                     ],
    //                   ),
    //                 )),
    //           );
    //         }));
  }

  Widget latestMediaHeader() {
    return new Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 25, bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Latest Media',
                  style: TextStyle(
                      color: eventajaBlack,
                      fontSize: ScreenUtil.instance.setSp(19),
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 4.5,
              )),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SeeAllMediaItem(
                                initialIndex: 1,
                                isVideo: false,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget latestMediaContent() {
    return mediaData == null
        ? Container(
            child: Center(
            child: CircularProgressIndicator(),
          ))
        : ColumnBuilder(
            itemCount: latestMediaPhoto == null ? 0 : latestMediaPhoto.length,
            itemBuilder: (BuildContext context, i) {
              return GestureDetector(
                onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MediaDetails(
                              userPicture: latestMediaPhoto[i]['creator']['photo'],
                              articleDetail: latestMediaPhoto[i]['content'],
                              imageCount: 'img' + i.toString(),
                              username: latestMediaPhoto[i]['creator']['username'],
                              imageUri: latestMediaPhoto[i]['banner'],
                              mediaTitle: latestMediaPhoto[i]['title'],
                              autoFocus: false,
                              mediaId: latestMediaPhoto[i]['id'],
                              isVideo: false,
                            )));
                },
                child: LatestMediaItem(
                  isVideo: false,
                  image: latestMediaPhoto[i]['banner_timeline'],
                  title: latestMediaPhoto[i]['title'],
                  username: latestMediaPhoto[i]['creator']['username'],
                  userImage: latestMediaPhoto[i]['creator']['photo'],
                  likeCount: latestMediaPhoto[i]['count_loved'],
                  commentCount: latestMediaPhoto[i]['comment'],
                ),
              );
            },
          );
  }

  Widget popularVideoHeader() {
    return new Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 25, bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Popular Video',
                  style: TextStyle(
                      color: eventajaBlack,
                      fontSize: ScreenUtil.instance.setSp(19),
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 4.5,
              )),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SeeAllMediaItem(
                                initialIndex: 0,
                                isVideo: true,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget popularVideoContent() {
    return Container(
      height: ScreenUtil.instance.setWidth(247),
      child: popularMediaVideo == null
          ? Container(
              child: Center(
              child: CircularProgressIndicator(),
            ))
          : ListView.builder(
              itemCount:
                  popularMediaVideo == null ? 0 : popularMediaVideo.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, i) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MediaDetails(
                                  isVideo: true,
                                  videoUrl: popularMediaVideo[i]['video'],
                                  youtubeUrl: popularMediaVideo[i]['youtube'],
                                  userPicture: popularMediaVideo[i]['creator']
                                      ['photo'],
                                  articleDetail: popularMediaVideo[i]
                                      ['content'],
                                  imageCount: 'img' + i.toString(),
                                  username: popularMediaVideo[i]['creator']
                                      ['username'],
                                  imageUri: popularMediaVideo[i]
                                      ['thumbnail_timeline'],
                                  mediaTitle: popularMediaVideo[i]['title'],
                                  autoFocus: false,
                                  mediaId: popularMediaVideo[i]['id'],
                                )));
                  },
                  child: MediaItem(
                    isVideo: true,
                    image: popularMediaVideo[i]['thumbnail_timeline'],
                    title: popularMediaVideo[i]['title'],
                    username: popularMediaVideo[i]['creator']['username'],
                    userPicture: popularMediaVideo[i]['creator']['photo'],
                    articleDetail: popularMediaVideo[i]['description'],
                    likeCount: popularMediaVideo[i]['count_loved'],
                    commentCount: popularMediaVideo[i]['comment'],
                    imageIndex: i,
                    mediaId: popularMediaVideo[i]['id'],
                  ),
                );
              },
            ),
    );
  }

  Widget latestVideoHeader() {
    return new Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 25, bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Latest Video',
                  style: TextStyle(
                      color: eventajaBlack,
                      fontSize: ScreenUtil.instance.setSp(19),
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 4.5,
              )),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SeeAllMediaItem(
                                initialIndex: 1,
                                isVideo: true,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget latestVideoContent() {
    return ColumnBuilder(
      itemCount: latestMediaVideo == null ? 0 : latestMediaVideo.length,
      itemBuilder: (BuildContext context, i) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MediaDetails(
                          isVideo: true,
                          videoUrl: latestMediaVideo[i]['video'],
                          youtubeUrl: latestMediaVideo[i]['youtube'],
                          userPicture: latestMediaVideo[i]['creator']['photo'],
                          articleDetail: latestMediaVideo[i]['content'],
                          imageCount: 'img' + i.toString(),
                          username: latestMediaVideo[i]['creator']['username'],
                          imageUri: latestMediaVideo[i]['thumbnail_timeline'],
                          mediaTitle: latestMediaVideo[i]['title'],
                          autoFocus: false,
                          mediaId: latestMediaVideo[i]['id'],
                        )));
          },
          child: LatestMediaItem(
            isVideo: true,
            image: latestMediaVideo[i]['thumbnail_timeline'],
            title: latestMediaVideo[i]['title'],
            username: latestMediaVideo[i]['creator']['username'],
            userImage: latestMediaVideo[i]['creator']['photo'],
            likeCount: latestMediaVideo[i]['count_loved'],
            commentCount: latestMediaVideo[i]['comment'],
          ),
        );
      },
    );
  }

  List<Widget> mappedDataBanner;

  Widget banner() {
    int _current = 0;
    return CarouselSlider(
      height: ScreenUtil.instance.setWidth(200),
      items: bannerData == null
          ? [
              Center(
                child: CircularProgressIndicator(),
              )
            ]
          : mappedDataBanner,
      autoPlayInterval: Duration(seconds: 3),
      enlargeCenterPage: false,
      initialPage: 0,
      autoPlay: true,
      aspectRatio: 2.0,
      viewportFraction: 1.0,
      onPageChanged: (index) {
        setState(() {
          _current = index;
        });
      },
    );
  }

  Widget userMedia() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      footer: CustomFooter(builder: (BuildContext context, LoadStatus mode) {
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
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: timelineList == null ? 0 : timelineList.length,
        itemBuilder: (BuildContext context, i) {
          List impressionList = timelineList[i]['impression']['data'];
          List commentList = timelineList[i]['comment']['data'];
          List impressions = new List();
          bool isLiked;

//          for(i = 0; i < impressionList.length; i++){
//            if(impressionList != null){
//              impressions = impressionList;
//              print('impressions: ' + impressions.toString());
//              if(impressions.contains({'userID': currentUserId})){
//                isLiked = true;
//              }else{
//                isLiked = false;
//              }
//            }
//          }
//          print(timelineList);
//          print(impressionList);

//          Map impressionLists = Map.fromIterable(impressionList);
//          print('impression map: ' + impressionLists.toString());
//          print('userID map: ' + impressionLists['data'].toString());

          for (int i = 0; i < impressionList.length; i++) {
            List impression = impressionList;

            print(impression);

            if (impression != null) {
              if (impression[i]['userID'].contains(currentUserId)) {
                isLiked = false;
                print('not yet liked');
              } else {
                isLiked = true;
                print('you already liked');
              }
            } else {
              isLiked = false;
            }
          }

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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(timelineList[i]['photo']),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil.instance.setWidth(8),
                                  ),
                                  Container(
                                      width: ScreenUtil.instance.setWidth(200.0 - 32.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              timelineList[i]['isVerified'] ==
                                                      '1'
                                                  ? Container(
                                                      height: ScreenUtil.instance.setWidth(18),
                                                      width: ScreenUtil.instance.setWidth(18),
                                                      child: Image.asset(
                                                          'assets/icons/icon_apps/verif.png'))
                                                  : Container(),
                                              SizedBox(width: ScreenUtil.instance.setWidth(5)),
                                              Text(timelineList[i]['fullName'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          SizedBox(
                                            height: ScreenUtil.instance.setWidth(5),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              timelineList[i]['type'] == 'love'
                                                  ? Image.asset(
                                                      'assets/icons/icon_apps/love.png',
                                                      scale: 3,
                                                    )
                                                  : Container(),
                                              SizedBox(width: ScreenUtil.instance.setWidth(5)),
                                              Text(
                                                  timelineList[i]['type'] ==
                                                          'love'
                                                      ? 'Loved'
                                                      : timelineList[i]
                                                                  ['type'] ==
                                                              'relationship'
                                                          ? timelineList[i]
                                                              ['name']
                                                          : 'Post a ' +
                                                              timelineList[i]
                                                                  ['type'],
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: ScreenUtil.instance.setSp(10))),
                                            ],
                                          ),
                                        ],
                                      )),
                                ]),
                            Column(
                              children: <Widget>[
                                Text(
                                  'a minute ago',
                                  style: TextStyle(fontSize: ScreenUtil.instance.setSp(10)),
                                ),
                                SizedBox(height: ScreenUtil.instance.setWidth(4)),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                            height: timelineList[i]['type'] == 'video' ||
                                    timelineList[i]['type'] == 'photo' ||
                                    timelineList[i]['type'] == 'event' ||
                                    timelineList[i]['type'] == 'eventgoing' ||
                                    timelineList[i]['eventID'] != null &&
                                        timelineList[i]['type'] == 'love'
                                ? 15
                                : 0),
                        timelineList[i]['type'] == 'video' ||
                                timelineList[i]['type'] == 'photo' ||
                                timelineList[i]['type'] == 'event' ||
                                timelineList[i]['type'] == 'eventgoing' ||
                                timelineList[i]['eventID'] != null &&
                                    timelineList[i]['type'] == 'love'
                            ? GestureDetector(
                                onTap: () {
                                  if (timelineList[i]['type'] == 'photo') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UserMediaDetail(
                                                  postID: timelineList[i]['id'],
                                                  imageUri: timelineList[i]
                                                      ['pictureFull'],
                                                  articleDetail: timelineList[i]
                                                      ['description'],
                                                  mediaTitle: timelineList[i]
                                                      ['description'],
                                                  autoFocus: false,
                                                  username: timelineList[i]
                                                      ['fullName'],
                                                  userPicture: timelineList[i]
                                                      ['photo'],
                                                  imageCount: 1,
                                                )));
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MediaPlayer(
                                                videoUri: timelineList[i]
                                                    ['pictureFull'])));
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            timelineList[i]['type'] == 'video'
                                                ? timelineList[i]['picture']
                                                : timelineList[i]
                                                    ['pictureFull'],
                                          ),
                                          fit: BoxFit.cover)),
                                  height: ScreenUtil.instance.setWidth(400),
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: timelineList[i]['type'] == 'video'
                                        ? Icon(
                                            Icons.play_circle_filled,
                                            size: 80,
                                            color: Colors.white,
                                          )
                                        : Container(),
                                  ),
                                ))
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(timelineList[i]['fullName'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtil.instance.setSp(15))),
                                      SizedBox(height: ScreenUtil.instance.setWidth(8)),
                                      Row(
                                        children: <Widget>[
                                          timelineList[i]['type'] == 'love'
                                              ? Image.asset(
                                                  'assets/icons/aset_icon/like.png',
                                                  scale: 3,
                                                )
                                              : Container(),
                                          SizedBox(
                                              width: timelineList[i]['type'] ==
                                                      'love'
                                                  ? 8
                                                  : 0),
                                          timelineList[i]['type'] == 'love'
                                              ? Text('Loved')
                                              : Container(),
                                          SizedBox(
                                              width: timelineList[i]['type'] ==
                                                      'love'
                                                  ? 8
                                                  : 0),
                                          timelineList[i]['type'] == 'video' ||
                                                  timelineList[i]['type'] ==
                                                      'photo'
                                              ? Container(
                                                  width: ScreenUtil.instance.setWidth(360 - 70.0),
                                                  child: Text(
                                                      timelineList[i]['name'] ==
                                                              null
                                                          ? ''
                                                          : timelineList[i]
                                                              ['name'],
                                                      maxLines: 10,
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xFF8A8A8B))),
                                                )
                                              : Container(
                                                  width: ScreenUtil.instance.setWidth(150),
                                                  child: Text(
                                                    timelineList[i]['name'] ==
                                                            null
                                                        ? ''
                                                        : timelineList[i]
                                                            ['name'],
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8A8A8B)),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                        ],
                                      )
                                    ])),
                            // Container(
                            //   child: Image.asset('assets/btn_ticket/free-limited.png', scale: 7,),)
                            timelineList[i]['type'] == 'event'
                                ? Container(
                                    child: Image.asset(
                                      'assets/btn_ticket/free-limited.png',
                                      scale: 7,
                                    ),
                                  )
                                : timelineList[i]['type'] == 'eventgoing'
                                    ? Container(
                                        child: Image.asset(
                                          'assets/btn_ticket/going.png',
                                          scale: 7,
                                        ),
                                      )
                                    : timelineList[i]['type'] == 'relationship'
                                        ? CircleAvatar(
                                            backgroundColor: Color(0xff8a8a8b),
                                            backgroundImage: NetworkImage(
                                                timelineList[i]['picture']),
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
                          GestureDetector(
                            onTap: () {
//                              for(int i = 0; i < impressionList.length; i++ ){
//                                List impression = impressionList;
//
//                                if(impression[i]['userID'].contains(currentUserId)){
//                                  isLiked = false;
//                                  print('not yet liked');
//                                }
//                                else{
//                                  isLiked = true;
//                                  print('you already liked');
//                                }
//                              }

                              if (timelineList[i]['impression']['data'] ==
                                  null) {
                                isLiked = false;
                                for (int i = 0;
                                    i < impressionList.length;
                                    i++) {
                                  List impression = impressionList;

                                  if (impression[i]['userID']
                                      .contains(currentUserId)) {
                                    isLiked = false;
                                    print('not yet liked');
                                  } else {
                                    isLiked = true;
                                    print('you already liked');
                                  }
                                }
                              } else {
                                for (int i = 0;
                                    i < impressionList.length;
                                    i++) {
                                  List impression = impressionList;

                                  if (impression[i]['userID']
                                      .contains(currentUserId)) {
                                    isLiked = false;
                                    print('not yet liked');
                                  } else {
                                    isLiked = true;
                                    print('you already liked');
                                  }
                                }
                              }

                              if (isLiked == false) {
                                isLiked = !isLiked;
                                print('liked');
                              } else {
                                isLiked = !isLiked;
                                print('disliked');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: ScreenUtil.instance.setWidth(30),
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
                                    SizedBox(width: ScreenUtil.instance.setWidth(5)),
                                    Text(impressionList.length.toString(),
                                        style: TextStyle(
                                            color: Color(
                                                0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                                  ]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: ScreenUtil.instance.setWidth(30),
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
                                  SizedBox(width: ScreenUtil.instance.setWidth(5)),
                                  Text(timelineList[i]['comment']['totalRows'],
                                      style: TextStyle(
                                          color: Color(
                                              0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                                ]),
                          ),
                          SizedBox(
                              width: impressionList.length > 99 ? 100 : 150),
                          GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              if (timelineList[i]['userID'] ==
                                  prefs.getString('Last User ID')) {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return showMoreOption(
                                          timelineList[i]['id'],
                                          timelineList[i]['type'],
                                          imageUrl: timelineList[i]['picture']);
                                    });
                              } else {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return showMoreOptionReport(
                                        timelineList[i]['id'],
                                        timelineList[i]['type'],
                                      );
                                    });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: ScreenUtil.instance.setWidth(30),
                              child: Icon(Icons.more_horiz),
                            ),
                          )
                        ]),
                  )
                ],
              ));
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

  Future<http.Response> doLove(var postId, var impressionID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/photo_impression/post';

    final response = await http.post(url, body: {
      'X-API-KEY': API_KEY,
      'id': postId,
      'impressionID': impressionID
    }, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session'),
    });

    return response;
  }

  Future<http.Response> getLatestMediaPhoto() async {
    String url = BaseApi().restUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=5&type=photo&status=latest';

    final response = await http.get(url,
        headers: {'Authorization': AUTHORIZATION_KEY, 'signature': signature});

    print('*******GETTING RESPONSE*******');
    print('HTTP RESPONSE CODE: ' + response.statusCode.toString());
    print('HTTP RESPONSE BODY: ' + response.statusCode.toString());

    return response;
  }

  Future<http.Response> getLatestMediaVideo() async {
    String url = BaseApi().restUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=5&type=video&status=latest';

    final response = await http.get(url,
        headers: {'Authorization': AUTHORIZATION_KEY, 'signature': signature});

    print('*******GETTING RESPONSE*******');
    print('HTTP RESPONSE CODE: ' + response.statusCode.toString());
    print('HTTP RESPONSE BODY: ' + response.statusCode.toString());

    return response;
  }

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

  Future<http.Response> getPopularMediaPhoto() async {
    String url = BaseApi().restUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=10&type=photo&status=popular';

    final response = await http.get(url,
        headers: {'Authorization': AUTHORIZATION_KEY, 'signature': signature});

    return response;
  }

  Future<http.Response> getPopularMediaVideo() async {
    String url = BaseApi().restUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=10&type=video&status=popular';

    final response = await http.get(url,
        headers: {'Authorization': AUTHORIZATION_KEY, 'signature': signature});

    print('*******GETTING RESPONSE*******');
    print('HTTP RESPONSE CODE: ' + response.statusCode.toString());
    print('HTTP RESPONSE BODY: ' + response.statusCode.toString());

    return response;
  }

  Future<http.Response> getBanner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/media/banner?X-API-KEY=$API_KEY&search=&page=1&limit=10';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
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

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    homeRefreshController.dispose();
    refreshController.dispose();
  }
}
