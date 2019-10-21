import 'dart:convert';

import 'package:eventevent/Widgets/openMedia.dart';
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
import 'package:flutter/material.dart';
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

class TimelineDashboardState extends State<TimelineDashboard> {
  List timelineList = [];
  List mediaData = [];
  List bannerData;
  String currentUserId;

  GlobalKey modalBottomSheetKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    getUserData();
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
  Widget build(BuildContext context) {
    mappedDataBanner = bannerData?.map((bannerData) {
          return bannerData == null
              ? Center(child: CircularProgressIndicator())
              : Builder(
                  builder: (BuildContext context) {
                    return bannerData == null
                        ? Center(child: CircularProgressIndicator())
                        : GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => OpenMedia(articleID: bannerData['id'],)));
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 23,
                          width: 93,
                          child: Image.asset(
                            'assets/icons/aset_icon/emedia.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                    Container(
                        height: 35,
                        width: 35,
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
                            'assets/icons/icon_apps/home.png',
                            scale: 4.5,
                          ),
                          SizedBox(width: 8),
                          Text('Home',
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
                            'assets/icons/icon_apps/public_timeline.png',
                            scale: 4.5,
                          ),
                          SizedBox(width: 8),
                          Text('Public Timeline',
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
                height: MediaQuery.of(context).size.height - 191,
                child: TabBarView(
                  children: <Widget>[emedia(), userMedia()],
                ),
              )
            ],
          ),
        ));
  }

  getSize() {}

  Widget tabView() {
    // print(preferedSize.size.height.toString());
    // return ;
  }

  Widget emedia() {
    return ListView(
      children: <Widget>[
        banner(),
        mediaHeader(),
        mediaContent(),
        latestMediaHeader(),
        latestMediaContent(),
        popularVideoHeader(),
        popularVideoContent(),
        latestVideoHeader(),
        latestVideoContent()
      ],
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
                      fontSize: 19,
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
                  style: TextStyle(color: eventajaGreenTeal, fontSize: 12),
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
      height: 247,
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
                              articleDetail: mediaData[i]['description'],
                              imageCount: 'img' + i.toString(),
                              username: mediaData[i]['creator']['username'],
                              imageUri: mediaData[i]['banner'],
                              mediaTitle: mediaData[i]['title'],
                              autoFocus: false,
                            )));
              },
              child: MediaItem(
                isVideo: false,
                image: mediaData[i]['banner'],
                title: mediaData[i]['title'],
                username: mediaData[i]['creator']['username'],
                userPicture: mediaData[i]['creator']['photo'],
                articleDetail: mediaData[i]['description'],
                imageIndex: i,
              ),
            ),
          );
        },
      ),
    );
    // return Container(
    //   padding: EdgeInsets.symmetric(vertical: 8),
    //     height: 247 + 9.0,
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
    //                           height: 146,
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
    //                         height: 110,
    //                         decoration: BoxDecoration(
    //                           color: Colors.white,
    //                           borderRadius: BorderRadius.only(
    //                               topLeft: Radius.circular(15),
    //                               topRight: Radius.circular(15)),
    //                         ),
    //                         child: Column(children: <Widget>[
    //                           SizedBox(height: 9),
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
    //                                   width: 220,
    //                                   child: Text(
    //                                     'Masuk Universitas Favorit \n Penting, Tapi...',
    //                                     // mediaData['data'][i]["title"],
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: TextStyle(
    //                                         fontSize: 20,
    //                                         fontWeight: FontWeight.bold),
    //                                     textAlign: TextAlign.start,
    //                                     maxLines: 2,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           SizedBox(height: 9),
    //                           Padding(
    //                             padding: const EdgeInsets.only(left: 10),
    //                             child: Row(
    //                               mainAxisAlignment: MainAxisAlignment.start,
    //                               crossAxisAlignment: CrossAxisAlignment.center,
    //                               children: <Widget>[
    //                                 Container(
    //                                     height: 30,
    //                                     width: 30,
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
    //                                   width: 10,
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
                      fontSize: 19,
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
                  style: TextStyle(color: eventajaGreenTeal, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget latestMediaContent() {
    return ColumnBuilder(
      itemCount: 3,
      itemBuilder: (BuildContext context, i) {
        return LatestMediaItem(
          isVideo: false,
          image: mediaData[i]['banner'],
          title: mediaData[i]['title'],
          username: mediaData[i]['creator']['username'],
          userImage: mediaData[i]['creator']['photo'],
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
                      fontSize: 19,
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
                  style: TextStyle(color: eventajaGreenTeal, fontSize: 12),
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
      height: 247,
      child: ListView.builder(
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, i) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MediaDetails(
                            userPicture: mediaData[i]['creator']['photo'],
                            articleDetail: mediaData[i]['description'],
                            imageCount: 'img' + i.toString(),
                            username: mediaData[i]['creator']['username'],
                            imageUri: mediaData[i]['banner'],
                            mediaTitle: mediaData[i]['title'],
                            autoFocus: false,
                          )));
            },
            child: MediaItem(
              isVideo: true,
              image: mediaData[i]['banner'],
              title: mediaData[i]['title'],
              username: mediaData[i]['creator']['username'],
              userPicture: mediaData[i]['creator']['photo'],
              articleDetail: mediaData[i]['description'],
              imageIndex: i,
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
                      fontSize: 19,
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
                  style: TextStyle(color: eventajaGreenTeal, fontSize: 12),
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
      itemCount: 3,
      itemBuilder: (BuildContext context, i) {
        return LatestMediaItem(
          isVideo: true,
          image: mediaData[i]['banner'],
          title: mediaData[i]['title'],
          username: mediaData[i]['creator']['username'],
          userImage: mediaData[i]['creator']['photo'],
        );
      },
    );
  }

  List<Widget> mappedDataBanner;

  Widget banner() {
    int _current = 0;
    return CarouselSlider(
      height: 200,
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

        return Container(height: 35, child: Center(child: body));
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


            for(int i = 0; i < impressionList.length; i++ ){
              List impression = impressionList;

              print(impression);

              if(impression != null){
                if(impression[i]['userID'].contains(currentUserId)){
                  isLiked = false;
                  print('not yet liked');
                }
                else{
                  isLiked = true;
                  print('you already liked');
                }
              }
              else{
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
                                              timelineList[i]['isVerified'] ==
                                                      '1'
                                                  ? Container(
                                                      height: 18,
                                                      width: 18,
                                                      child: Image.asset(
                                                          'assets/icons/icon_apps/verif.png'))
                                                  : Container(),
                                              SizedBox(width: 5),
                                              Text(timelineList[i]['fullName'],
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
                                              timelineList[i]['type'] == 'love'
                                                  ? Image.asset(
                                                      'assets/icons/icon_apps/love.png',
                                                      scale: 3,
                                                    )
                                                  : Container(),
                                              SizedBox(width: 5),
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
                            height: timelineList[i]['type'] == 'video' ||
                                    timelineList[i]['type'] == 'photo' ||
                                    timelineList[i]['type'] == 'event' ||
                                    timelineList[i]['type'] == 'eventgoing'
                                ? 15
                                : 0),
                        timelineList[i]['type'] == 'video' ||
                                timelineList[i]['type'] == 'photo' ||
                                timelineList[i]['type'] == 'event' ||
                                timelineList[i]['type'] == 'eventgoing'
                            ? GestureDetector(
                              onTap: (){
                                if(timelineList[i]['type'] == 'photo'){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserMediaDetail(postID: timelineList[i]['id'], imageUri: timelineList[i]['pictureFull'], articleDetail: timelineList[i]['description'], mediaTitle: timelineList[i]['description'], autoFocus: false, username: timelineList[i]['fullName'], userPicture: timelineList[i]['photo'], imageCount: 1,)));
                                }
                                else{
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPlayer(videoUri: timelineList[i]['pictureFull'])));
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          timelineList[i]['type'] == 'video'
                                              ? timelineList[i]['picture']
                                              : timelineList[i]['pictureFull'],
                                        ),
                                        fit: BoxFit.cover)),
                                height: 400,
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
                                              fontSize: 15)),
                                      SizedBox(height: 8),
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
                                                  width: 360 - 70.0,
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
                                              : Text(
                                                  timelineList[i]['name'] ==
                                                          null
                                                      ? ''
                                                      : timelineList[i]['name'],
                                                  maxLines: 10,
                                                  style: TextStyle(
                                                      color:
                                                          Color(0xFF8A8A8B))),
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
                            onTap: (){
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

                              if(timelineList[i]['impression']['data'] == null){
                                isLiked = false;
                                for(int i = 0; i < impressionList.length; i++ ){
                                  List impression = impressionList;

                                  if(impression[i]['userID'].contains(currentUserId)){
                                    isLiked = false;
                                    print('not yet liked');
                                  }
                                  else{
                                    isLiked = true;
                                    print('you already liked');
                                  }
                                }
                              }
                              else{
                                for(int i = 0; i < impressionList.length; i++ ){
                                  List impression = impressionList;

                                  if(impression[i]['userID'].contains(currentUserId)){
                                    isLiked = false;
                                    print('not yet liked');
                                  }
                                  else{
                                    isLiked = true;
                                    print('you already liked');
                                  }
                                }
                              }

                              if(isLiked == false){
                                isLiked = !isLiked;
                                print('liked');
                              }
                              else{
                                isLiked = !isLiked;
                                print('disliked');
                              }
                            },
                                                      child: Container(
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
                                          timelineList[i]['type']);
                                    });
                              } else {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return showMoreOptionReport(
                                          timelineList[i]['id'],
                                          timelineList[i]['type']);
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
      ),
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

  Future<http.Response> doLove(var postId, var impressionID) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/photo_impression/post';

    final response = await http.post(
      url,
      body: {
        'X-API-KEY': API_KEY,
        'id': postId,
        'impressionID': impressionID
      },
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': prefs.getString('Session'),
      }
    );

    return response;
  }

  Future<http.Response> getTimelineList({int newPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState((){
      if(newPage != null){
        currentPage += newPage;
      }

      print(currentPage);
    });

    String url = BaseApi().apiUrl + '/timeline/list?X-API-KEY=$API_KEY&page=$currentPage';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print('body: ' + response.body);

    return response;
  }

  Future<http.Response> getMedia() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=10&type=photo&status=popular';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

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
}
