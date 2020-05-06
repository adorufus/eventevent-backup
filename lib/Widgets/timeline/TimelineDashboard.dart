import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/Widgets/openMedia.dart';
import 'package:eventevent/Widgets/timeline/EditPost.dart';
import 'package:eventevent/Widgets/timeline/LatestMediaItem.dart';
import 'package:eventevent/Widgets/timeline/MediaDetails.dart';
import 'package:eventevent/Widgets/timeline/ReportPost.dart';
import 'package:eventevent/Widgets/timeline/SeeAllMediaItem.dart';
import 'package:eventevent/Widgets/timeline/TimelineItems.dart';
import 'package:eventevent/Widgets/timeline/popularMediaItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TimelineDashboard extends StatefulWidget {
  final isRest;

  const TimelineDashboard({Key key, this.isRest}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return TimelineDashboardState();
  }
}

class TimelineDashboardState extends State<TimelineDashboard>
    with WidgetsBindingObserver {
  List mediaData = [];
  List popularMediaVideo;
  List latestMediaPhoto = [];
  List latestMediaVideo;
  List bannerData;
  String currentUserId;
  bool isLoved;
  bool isLoading = false;
  bool isTimeoutPopularMediaPhoto = false;
  bool isTimeoutPopularMediaVideo = false;
  bool isTimeoutLatestMediaVideo = false;
  bool isTimeoutLatestMediaPhoto = false;
  bool isTimeoutBanner = false;
  String errorReason;

  int likeCount = 0;

  GlobalKey modalBottomSheetKey = new GlobalKey();

  void getDetail() {
    getPopularMediaPhoto().then((response) {
      var extractedData = json.decode(response.body);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          mediaData = extractedData['data']['data'];
        });
      }
    }).timeout(Duration(seconds: 15), onTimeout: () {
      isLoading = false;
      isTimeoutPopularMediaPhoto = true;
      errorReason = 'Connection Timeout';
      setState(() {});
    });

    getPopularMediaVideo().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          popularMediaVideo = extractedData['data']['data'];
        });
      } else if (response.statusCode == 404) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          message: '404: something not found',
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          animationDuration: Duration(milliseconds: 500),
        )..show(context);
      }
    }).catchError((e) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Error: ' + e.toString(),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }).timeout(Duration(seconds: 15), onTimeout: () {
      isLoading = false;
      isTimeoutPopularMediaVideo = true;
      errorReason = 'Connection Timeout';
      setState(() {});
    });

    getLatestMediaPhoto().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          latestMediaPhoto = extractedData['data']['data'];
        });
      } else if (response.statusCode == 404) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          message: '404: something not found',
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          animationDuration: Duration(milliseconds: 500),
        )..show(context);
      }
    }).catchError((e) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Error: ' + e.toString(),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }).timeout(Duration(seconds: 15), onTimeout: () {
      isLoading = false;
      isTimeoutLatestMediaPhoto = true;
      errorReason = 'Connection Timeout';
      setState(() {});
    });

    getLatestMediaVideo().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          latestMediaVideo = extractedData['data']['data'];
        });
      } else if (response.statusCode == 404) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          message: '404: something not found',
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          animationDuration: Duration(milliseconds: 500),
        )..show(context);
      }
    }).catchError((e) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Error: ' + e.toString(),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }).timeout(Duration(seconds: 15), onTimeout: () {
      isLoading = false;
      isTimeoutLatestMediaVideo = true;
      errorReason = 'Connection Timeout';
      setState(() {});
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
    }).timeout(Duration(seconds: 15), onTimeout: () {
      isLoading = false;
      isTimeoutBanner = true;
      errorReason = 'Connection Timeout';
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserData();
    getDetail();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  RefreshController homeRefreshController =
      RefreshController(initialRefresh: false);

  int newPage = 0;

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      currentUserId = prefs.getString('Last User ID');
    });

    print(currentUserId);
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
    mappedDataBanner = bannerData?.map((bannerData) {
          return bannerData == null
              ? Center(child: CupertinoActivityIndicator(radius: 20))
              : Builder(
                  builder: (BuildContext context) {
                    return bannerData == null
                        ? Center(child: CupertinoActivityIndicator(radius: 20))
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OpenMedia(
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
                                      bannerData["banner_avatar"],
                                    ),
                                  )),
                            ),
                          );
                  },
                );
        })?.toList() ??
        [];

    return mediaData == null
        ? Container(
            child: Center(
              child: CupertinoActivityIndicator(radius: 20),
            ),
          )
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(null, 100),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil.instance.setWidth(75),
                padding: EdgeInsets.symmetric(horizontal: 13),
                child: Container(
                  color: Colors.white,
                  child: AppBar(
                    brightness: Brightness.light,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    titleSpacing: 0,
                    centerTitle: false,
                    title: Container(
                      width: ScreenUtil.instance.setWidth(240),
                      child: Row(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            body: isTimeoutPopularMediaPhoto == true &&
                    isTimeoutBanner == true &&
                    isTimeoutLatestMediaPhoto == true &&
                    isTimeoutLatestMediaVideo == true &&
                    isTimeoutPopularMediaVideo
                ? EmptyState(
                    imagePath: 'assets/icons/empty_state/error.png',
                    isTimeout: true,
                    reasonText: errorReason,
                    refreshButtonCallback: () {
                      setState(() {
                        isTimeoutPopularMediaPhoto = false;
                        getDetail();
                      });
                    },
                  )
                : SafeArea(
                    child: DefaultTabController(
                      initialIndex: 0,
                      length: 2,
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            child: TabBar(
                              tabs: <Widget>[
                                Tab(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/icons/icon_apps/home.png',
                                        scale: 4.5,
                                      ),
                                      SizedBox(
                                          width:
                                              ScreenUtil.instance.setWidth(8)),
                                      Text('Home',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtil.instance
                                                  .setSp(12.5))),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/icons/icon_apps/public_timeline.png',
                                        scale: 4.5,
                                      ),
                                      SizedBox(
                                          width:
                                              ScreenUtil.instance.setWidth(8)),
                                      Text('Public Timeline',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtil.instance
                                                  .setSp(12.5))),
                                    ],
                                  ),
                                )
                              ],
                              unselectedLabelColor: Colors.grey,
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: ScreenUtil.instance.setHeight(
                                  MediaQuery.of(context).size.height - 50),
                              child: Stack(
                                children: <Widget>[
                                  TabBarView(
                                    children: <Widget>[
                                      emedia(),
                                      widget.isRest == true
                                          ? LoginRegisterWidget()
                                          : UserTimelineItem(
                                              currentUserId: currentUserId,
                                              timelineType: 'timeline',
                                            )
                                    ],
                                  ),
                                  Positioned(
                                      child: isLoading == true
                                          ? Container(
                                              child: Center(
                                                  child:
                                                      CupertinoActivityIndicator(
                                                          radius: 20)),
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            )
                                          : Container())
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
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
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: '404: something not found',
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 500),
            )..show(context);
          }
        }).catchError((e) {
          isLoading = false;
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            message: 'Error: ' + e.toString(),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            animationDuration: Duration(milliseconds: 500),
          )..show(context);
        }).timeout(Duration(seconds: 15), onTimeout: () {
          isLoading = false;
          isTimeoutPopularMediaPhoto = true;
          errorReason = 'Connection Timeout';
          setState(() {});
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
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: '404: something not found',
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 500),
            )..show(context);
          }
        }).catchError((e) {
          isLoading = false;
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            message: 'Error: ' + e.toString(),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            animationDuration: Duration(milliseconds: 500),
          )..show(context);
        }).timeout(Duration(seconds: 15), onTimeout: () {
          isLoading = false;
          isTimeoutPopularMediaPhoto = true;
          errorReason = 'Connection Timeout';
          setState(() {});
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
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: '404: something not found',
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 500),
            )..show(context);
          }
        }).catchError((e) {
          isLoading = false;
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            message: 'Error: ' + e.toString(),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            animationDuration: Duration(milliseconds: 500),
          )..show(context);
        }).timeout(Duration(seconds: 15), onTimeout: () {
          isLoading = false;
          isTimeoutPopularMediaPhoto = true;
          errorReason = 'Connection Timeout';
          setState(() {});
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
          SizedBox(
            height: ScreenUtil.instance.setWidth(50),
          )
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
                                isRest: widget.isRest,
                                initialIndex: 0,
                                isVideo: false,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                      color: eventajaGreenTeal,
                      fontSize: ScreenUtil.instance.setSp(12)),
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
                              videoUrl: null,
                              youtubeUrl: null,
                              isRest: widget.isRest,
                              userPicture: mediaData[i]['creator']['photo'],
                              articleDetail: mediaData[i]['content'],
                              imageCount: 'img' + i.toString(),
                              username: mediaData[i]['creator']['username'],
                              imageUri: mediaData[i]['banner_avatar'],
                              mediaTitle: mediaData[i]['title'],
                              autoFocus: false,
                              mediaId: mediaData[i]['id'],
                              isVideo: false,
                            )));
              },
              child: MediaItem(
                isRest: widget.isRest,
                isVideo: false,
                isLiked: mediaData[i]['is_loved'],
                image: mediaData[i]['banner_avatar'],
                title: mediaData[i]['title'],
                // youtube: latestMediaVideo[i]['youtube'] ?? '/',
                // videoUrl: latestMediaVideo[i]['video'] ?? '/',
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
                                isRest: widget.isRest,
                                initialIndex: 1,
                                isVideo: false,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                      color: eventajaGreenTeal,
                      fontSize: ScreenUtil.instance.setSp(12)),
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
        ? HomeLoadingScreen().mediaLoading()
        : ColumnBuilder(
            itemCount: latestMediaPhoto == null ? 0 : latestMediaPhoto.length,
            itemBuilder: (BuildContext context, i) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MediaDetails(
                                isRest: widget.isRest,
                                userPicture: latestMediaPhoto[i]['creator']
                                    ['photo'],
                                articleDetail: latestMediaPhoto[i]['content'],
                                imageCount: 'img' + i.toString(),
                                username: latestMediaPhoto[i]['creator']
                                    ['username'],
                                imageUri: latestMediaPhoto[i]['banner_avatar'],
                                mediaTitle: latestMediaPhoto[i]['title'],
                                autoFocus: false,
                                mediaId: latestMediaPhoto[i]['id'],
                                isVideo: false,
                              )));
                },
                child: LatestMediaItem(
                  isRest: widget.isRest,
                  isVideo: false,
                  isLiked: latestMediaPhoto[i]['is_loved'],
                  image: latestMediaPhoto[i]['banner_timeline'],
                  mediaId: latestMediaPhoto[i]['id'],
                  title: latestMediaPhoto[i]['title'],
                  username: latestMediaPhoto[i]['creator']['username'],
                  userImage: latestMediaPhoto[i]['creator']['photo'],
                  likeCount: latestMediaPhoto[i]['count_loved'],
                  commentCount: latestMediaPhoto[i]['comment'],
                  article: latestMediaPhoto[i]['content'],
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
                                isRest: widget.isRest,
                                initialIndex: 0,
                                isVideo: true,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                      color: eventajaGreenTeal,
                      fontSize: ScreenUtil.instance.setSp(12)),
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
          ? HomeLoadingScreen().mediaLoading()
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
                                  isRest: widget.isRest,
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
                    isRest: widget.isRest,
                    isLiked: popularMediaVideo[i]['is_loved'],
                    videoUrl: popularMediaVideo[i]['video'],
                    youtube: popularMediaVideo[i]['youtube'],
                    isVideo: true,
                    image: popularMediaVideo[i]['thumbnail_avatar'],
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
                                isRest: widget.isRest,
                                initialIndex: 1,
                                isVideo: true,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                      color: eventajaGreenTeal,
                      fontSize: ScreenUtil.instance.setSp(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget latestVideoContent() {
    return latestMediaVideo == null
        ? HomeLoadingScreen().mediaLoading()
        : ColumnBuilder(
            itemCount: latestMediaVideo == null ? 0 : latestMediaVideo.length,
            itemBuilder: (BuildContext context, i) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MediaDetails(
                                isRest: widget.isRest,
                                isVideo: true,
                                videoUrl: latestMediaVideo[i]['video'],
                                youtubeUrl: latestMediaVideo[i]['youtube'],
                                userPicture: latestMediaVideo[i]['creator']
                                    ['photo'],
                                articleDetail: latestMediaVideo[i]['content'],
                                imageCount: 'img' + i.toString(),
                                username: latestMediaVideo[i]['creator']
                                    ['username'],
                                imageUri: latestMediaVideo[i]
                                    ['thumbnail_timeline'],
                                mediaTitle: latestMediaVideo[i]['title'],
                                autoFocus: false,
                                mediaId: latestMediaVideo[i]['id'],
                              )));
                },
                child: LatestMediaItem(
                  isRest: widget.isRest,
                  isVideo: true,
                  isLiked: latestMediaVideo[i]['is_loved'],
                  youtube: latestMediaVideo[i]['youtube'] ?? '/',
                  videoUrl: latestMediaVideo[i]['video'] ?? '/',
                  mediaId: latestMediaVideo[i]['id'],
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
          ? [HomeLoadingScreen().bannerLoading(context)]
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

  Future<http.Response> unLove(String id) async {
    SharedPreferences prefences = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/photo_impression/delete';

    final response = await http.delete(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'X-API-KEY': API_KEY,
      'cookie': prefences.getString('Session'),
      'id': id
    });

    print(response.body);

    return response;
  }

  Future<http.Response> getLatestMediaPhoto() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String baseUrl = '';
    Map<String, String> headers;

    setState(() {
      if (widget.isRest == true) {
        baseUrl = BaseApi().restUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'signature': SIGNATURE,
        };
      } else if (widget.isRest == false) {
        baseUrl = BaseApi().apiUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session'),
        };
      }
    });

    String url = baseUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=5&type=photo&status=latest';

    final response = await http.get(url, headers: headers);

    print('*******GETTING RESPONSE*******');
    print('HTTP RESPONSE CODE: ' + response.statusCode.toString());
    print('HTTP RESPONSE BODY: ' + response.statusCode.toString());

    return response;
  }

  Future<http.Response> getLatestMediaVideo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String baseUrl = '';
    Map<String, String> headers;

    setState(() {
      if (widget.isRest == true) {
        baseUrl = BaseApi().restUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'signature': SIGNATURE,
        };
      } else if (widget.isRest == false) {
        baseUrl = BaseApi().apiUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session'),
        };
      }
    });

    String url = baseUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=5&type=video&status=latest';

    final response = await http.get(url, headers: headers);

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
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String baseUrl = '';
    Map<String, String> headers;

    setState(() {
      if (widget.isRest == true) {
        baseUrl = BaseApi().restUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'signature': SIGNATURE,
        };
      } else if (widget.isRest == false) {
        baseUrl = BaseApi().apiUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session'),
        };
      }
    });

    String url = baseUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=10&type=photo&status=popular';

    final response = await http.get(url, headers: headers);

    return response;
  }

  Future<http.Response> getPopularMediaVideo() async {
    String baseUrl = '';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map<String, String> headers;

    setState(() {
      if (widget.isRest == true) {
        baseUrl = BaseApi().restUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'signature': SIGNATURE,
        };
      } else if (widget.isRest == false) {
        baseUrl = BaseApi().apiUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session'),
        };
      }
    });

    String url = baseUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=10&type=video&status=popular';

    final response = await http.get(url, headers: headers);

    print('*******GETTING RESPONSE*******');
    print('HTTP RESPONSE CODE: ' + response.statusCode.toString());
    print('HTTP RESPONSE BODY: ' + response.statusCode.toString());

    return response;
  }

  Future<http.Response> getBanner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String baseUrl = '';
    Map<String, String> headers;

    setState(() {
      if (widget.isRest == true) {
        baseUrl = BaseApi().restUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'signature': SIGNATURE,
        };
      } else if (widget.isRest == false) {
        baseUrl = BaseApi().apiUrl;
        headers = {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session'),
        };
      }
    });

    String url =
        baseUrl + '/media/banner?X-API-KEY=$API_KEY&search=&page=1&limit=10';

    final response = await http.get(url, headers: headers);

    return response;
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    homeRefreshController.dispose();
  }
}
