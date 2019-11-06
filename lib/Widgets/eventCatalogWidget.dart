import 'dart:convert';

import 'package:eventevent/Widgets/CollectionPage.dart';
import 'package:eventevent/Widgets/Home/MyTicket.dart';
import 'package:eventevent/Widgets/Home/PopularEventWidget.dart';
import 'package:eventevent/Widgets/Home/See%20All/SeeAllItem.dart';
import 'package:eventevent/Widgets/Home/See%20All/SeeAllPeople.dart';
import 'package:eventevent/Widgets/LatestEventWidget.dart';
import 'package:eventevent/Widgets/RecycleableWidget/SearchWidget.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/Widgets/openMedia.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/Widgets/timeline/MediaDetails.dart';
import 'package:eventevent/Widgets/timeline/SeeAllMediaItem.dart';
import 'package:eventevent/Widgets/timeline/popularMediaItem.dart';
import 'package:eventevent/helper/Models/PopularEventModels.dart';
import 'package:eventevent/helper/WebView.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/API/catalogModel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'nearbyEventWidget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'categoryEventWidget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'timeline/TimelineDashboard.dart';

//List<T> map<T>(List list, Function handler){
//  List<T> result = [];
//
//  for (var i = 0; i < list.length; i++){
//    result.add(handler(i, list[i]));
//  }
//
//  return result;
//}

class EventCatalog extends StatefulWidget {
  final isRest;

  const EventCatalog({Key key, this.isRest: true}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _EventCatalogState();
  }
}

class _EventCatalogState extends State<EventCatalog>
    with WidgetsBindingObserver {
  TimelineDashboardState timelineState = new TimelineDashboardState();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  ///Variable untuk insialisasi Value awal
  List data;
  List bannerData;
  List discoverData;
  List popularPeopleData;
  List discoverPeopleData;
  List collectionData;
  List child;
  ListenPage geoPage = new ListenPage();
  List mediaData = [];
  Widget errReasonWidget = Container();

  String ticketPriceImageURI = 'assets/btn_ticket/paid-value.png';
  String urlType = '';

  int _current = 0;

  ScrollController _scrollController = new ScrollController();
  List<Widget> mappedDataBanner;
  var session;

  ///Inisialisasi semua fungsi untuk fetching dan hal hal lain yang dibutuhkan
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    if (!mounted) {
      return;
    } else {
      fetchCatalog();
      fetchBanner();
      fetchDiscoverCatalog();
      fetchPopularPeople();
      fetchDiscoverPeople();
      fetchCollection();
      getMediaData().then((response) {
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

    setState(() {
      if (widget.isRest == true) {
        urlType = BaseApi().restUrl;
      } else {
        urlType = BaseApi().apiUrl;
      }
    });

    // timelineState.getMedia().then((response){
    //   var extractedData = json.decode(response.body);

    //   print(response.statusCode);
    //   print(response.body);

    //   if (response.statusCode == 200) {
    //     setState(() {
    //       mediaData = extractedData['data']['data'];
    //     });
    //   }
    // });
    //WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    super.didChangeAppLifecycleState(state);
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
                            onTap: () {
                              if (bannerData['type'] == 'event') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EventDetailsConstructView(
                                              id: bannerData['eventID'],
                                              name: bannerData['name'],
                                              image: bannerData['photoFull']
                                            )));
                              } else if (bannerData['type'] == 'nolink') {
                                return;
                              } else if (bannerData['type'] == 'category') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EventDetailsConstructView(
                                              id: bannerData['categoryID'],
                                              name: bannerData['name'],
                                              image: bannerData['photoFull']
                                            )));
                              }
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
                                      bannerData["image"],
                                    ),
                                  )),
                            ));
                  },
                );
        })?.toList() ??
        [];

//    child = map<Widget>(
//        bannerData ?? [],
//        (index, i){
//          return Container(
//            width: MediaQuery.of(context).size.width,
//            margin: EdgeInsets.only(left: 6, right: 6, bottom: 15, top: 10),
//            decoration: BoxDecoration(
//                shape: BoxShape.rectangle,
//                boxShadow: <BoxShadow>[
//                  BoxShadow(
//                    color: Colors.black26,
//                    offset: Offset(1.0, 1.0),
//                    blurRadius: 5,
//                  )
//                ],
//                borderRadius: BorderRadius.circular(15),
//                image: DecorationImage(
//                  fit: BoxFit.cover,
//                  image: CachedNetworkImageProvider(
//                    i['image'],
//                  ),
//                )),
//          );
//        }
//    )?.toList() ?? [];

    return RefreshConfiguration(
      enableLoadingWhenFailed: true,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size(null, 100),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 75,
            padding: EdgeInsets.symmetric(horizontal: 13),
            color: Colors.white,
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.white,
              titleSpacing: 0,
              title: Container(
                width: 240,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      height: 23,
                      width: 140,
                      child: Hero(
                        tag: 'eventeventlogo',
                        child: Image.asset(
                          'assets/icons/logo_company.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              textTheme: TextTheme(
                  title: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              )),
              actions: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (BuildContext context) => Search()));
                  },
                  child: Container(
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
                        'assets/icons/icon_apps/search.png',
                        scale: 4.5,
                      )),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => MyTicket()));
                  },
                  child: Container(
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
                      )),
                ),
                SizedBox(width: 2),
              ],
            ),
          ),
        ),
        // PreferredSize(
        //   preferredSize: Size(null, 100),
        //   child: Container(
        //     width: MediaQuery.of(context).size.width,
        //     height: 75,
        //     child: Container(
        //       color: Colors.white,
        //       child: Container(
        //         margin: EdgeInsets.fromLTRB(13, 13, 13, 13),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           children: <Widget>[
        //             Container(
        //               width: 240,
        //               child: Row(
        //                 children: <Widget>[
        //                   SizedBox(
        //                     height: 23,
        //                     width: 140,
        //                     child: Image.asset(
        //                       'assets/icons/logo_company.png',
        //                       fit: BoxFit.fill,
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //             GestureDetector(
        //               onTap: () {
        //                 Navigator.push(
        //                     context,
        //                     CupertinoPageRoute(
        //                         builder: (BuildContext context) => Search()));
        //               },
        //               child: Container(
        //                   height: 35,
        //                   width: 35,
        //                   decoration: BoxDecoration(
        //                       color: Colors.white,
        //                       shape: BoxShape.circle,
        //                       boxShadow: <BoxShadow>[
        //                         BoxShadow(
        //                             color: Colors.black.withOpacity(0.1),
        //                             offset: Offset(0, 0),
        //                             spreadRadius: 1.5,
        //                             blurRadius: 2)
        //                       ]),
        //                   child: Image.asset(
        //                     'assets/icons/icon_apps/search.png',
        //                     scale: 4.5,
        //                   )),
        //             ),
        //             GestureDetector(
        //               onTap: () {
        //                 Navigator.of(context).push(MaterialPageRoute(
        //                     builder: (BuildContext context) => MyTicket()));
        //               },
        //               child: Container(
        //                   height: 35,
        //                   width: 35,
        //                   decoration: BoxDecoration(
        //                       color: Colors.white,
        //                       shape: BoxShape.circle,
        //                       boxShadow: <BoxShadow>[
        //                         BoxShadow(
        //                             color: Colors.black.withOpacity(0.1),
        //                             offset: Offset(0, 0),
        //                             spreadRadius: 1.5,
        //                             blurRadius: 2)
        //                       ]),
        //                   child: Image.asset(
        //                     'assets/icons/ticket.png',
        //                     scale: 3,
        //                   )),
        //             )
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        body: Column(
          children: <Widget>[
            DefaultTabController(
              length: 3,
              initialIndex: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                              Text('Home',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5)),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/icons/icon_apps/nearby.png',
                                scale: 4.5,
                              ),
                              SizedBox(width: 10),
                              Text('Nearby',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5)),
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
                              Text('Latest',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                      unselectedLabelColor: Colors.grey,
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    height: MediaQuery.of(context).size.height - 191,
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        home(),
                        Container(
                          child: Center(
                            child: ListenPage(),
                          ),
                        ),
                        LatestEventWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget home() {
    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      enablePullUp: false,
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
      onRefresh: () {
        fetchCatalog();
        fetchBanner();
        fetchDiscoverCatalog();
        fetchPopularPeople();
        fetchDiscoverPeople();
        fetchCollection();
        getMediaData().then((response) {
          var extractedData = json.decode(response.body);

          print(response.statusCode);
          print(response.body);

          if (response.statusCode == 200) {
            setState(() {
              mediaData = extractedData['data']['data'];
            });
          }
        });

        refreshController.refreshCompleted();
      },
      child: ListView(
        cacheExtent: 0,
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Stack(
                    children: <Widget>[
                      mappedDataBanner == null
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : banner(),
                    ],
                  ),
                ),
                popularEventTitle(),
                Container(
                    height: 310,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data == null ? 0 : data.length,
                        itemBuilder: (BuildContext context, i) {
                          Color itemColor;
                          String itemPriceText;

                          if (data[i]['ticket_type']['type'] == 'paid' ||
                              data[i]['ticket_type']['type'] ==
                                  'paid_seating') {
                            if (data[i]['ticket']['availableTicketStatus'] ==
                                '1') {
                              itemColor = Color(0xFF34B323);
                              itemPriceText =
                                  data[i]['ticket']['cheapestTicket'];
                            } else {
                              if (data[i]['ticket']['salesStatus'] ==
                                  'comingSoon') {
                                itemColor = Color(0xFF34B323).withOpacity(0.3);
                                itemPriceText = 'COMING SOON';
                              } else if (data[i]['ticket']['salesStatus'] ==
                                  'endSales') {
                                itemColor = Color(0xFF8E1E2D);
                                if (data[i]['status'] == 'ended') {
                                  itemPriceText = 'EVENT HAS ENDED';
                                }
                                itemPriceText = 'SALES ENDED';
                              } else {
                                itemColor = Color(0xFF8E1E2D);
                                itemPriceText = 'SOLD OUT';
                              }
                            }
                          } else if (data[i]['ticket_type']['type'] ==
                              'no_ticket') {
                            itemColor = Color(0xFFA6A8AB);
                            itemPriceText = 'NO TICKET';
                          } else if (data[i]['ticket_type']['type'] ==
                              'on_the_spot') {
                            itemColor = Color(0xFF652D90);
                            itemPriceText = data[i]['ticket_type']['name'];
                          } else if (data[i]['ticket_type']['type'] == 'free') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText = data[i]['ticket_type']['name'];
                          } else if (data[i]['ticket_type']['type'] == 'free') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText = data[i]['ticket_type']['name'];
                          } else if (data[i]['ticket_type']['type'] ==
                              'free_limited') {
                            if (data[i]['ticket']['availableTicketStatus'] ==
                                '1') {
                              itemColor = Color(0xFFFFAA00);
                              itemPriceText = data[i]['ticket_type']['name'];
                            } else {
                              if (data[i]['ticket']['salesStatus'] ==
                                  'comingSoon') {
                                itemColor = Color(0xFF34B323).withOpacity(0.3);
                                itemPriceText = 'COMING SOON';
                              } else if (data[i]['ticket']['salesStatus'] ==
                                  'endSales') {
                                itemColor = Color(0xFF8E1E2D);
                                if (data[i]['status'] == 'ended') {
                                  itemPriceText = 'EVENT HAS ENDED';
                                }
                                itemPriceText = 'SALES ENDED';
                              } else {
                                itemColor = Color(0xFFFFAA00);
                                itemPriceText = 'SOLD OUT';
                              }
                            }
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          EventDetailsConstructView(
                                            id: data[i]['id'],
                                            name: data[i]['name'],
                                            image: data[i]['photoFull']
                                          )));
                            },
                            child: PopularEventWidget(
                              imageUrl: data[i]['picture'],
                              title: data[i]["name"],
                              location: data[i]["address"],
                              color: itemColor,
                              price: itemPriceText,
                              type: data[i]['ticket_type']['type'],
                              isAvailable: data[i]['ticket']
                                  ['availableTicketStatus'],
                            ),
                          );
                        })),
                SizedBox(height: 20),
                mediaHeader(),
                Container(
                  height: 247,
                  child: ListView.builder(
                    itemCount: mediaData == null ? 0 : mediaData.length,
                    scrollDirection: Axis.horizontal,
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
                        child: MediaItem(
                          isVideo: false,
                          image: mediaData[i]['banner_avatar'],
                          title: mediaData[i]['title'],
                          username: mediaData[i]['creator']['username'],
                          userPicture: mediaData[i]['creator']['photo'],
                          articleDetail: mediaData[i]['description'],
                          imageIndex: i,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          categoryTitle(),
          Container(
              height: 180,
              padding: EdgeInsets.only(top: 5, left: 6.5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1.5)
                  ]),
              margin: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
              child: Center(child: CategoryEventWidget())),
          collection(),
          collectionImage(),
          popularPeople(),
          popularPeopleImage(),
          SizedBox(height: 15),
          discoverEvent(),
          Container(
              height: 310,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (BuildContext context, i) {
                    Color itemColor;
                    String itemPriceText;

                    if (discoverData[i]['ticket_type']['type'] == 'paid' ||
                        discoverData[i]['ticket_type']['type'] ==
                            'paid_seating') {
                      if (discoverData[i]['ticket']['availableTicketStatus'] ==
                          '1') {
                        itemColor = Color(0xFF34B323);
                        itemPriceText =
                            discoverData[i]['ticket']['cheapestTicket'];
                      } else {
                        if (discoverData[i]['ticket']['salesStatus'] ==
                            'comingSoon') {
                          itemColor = Color(0xFF34B323).withOpacity(0.3);
                          itemPriceText = 'COMING SOON';
                        } else if (discoverData[i]['ticket']['salesStatus'] ==
                            'endSales') {
                          itemColor = Color(0xFF8E1E2D);
                          if (discoverData[i]['status'] == 'ended') {
                            itemPriceText = 'EVENT HAS ENDED';
                          }
                          itemPriceText = 'SALES ENDED';
                        } else {
                          itemColor = Color(0xFF8E1E2D);
                          itemPriceText = 'SOLD OUT';
                        }
                      }
                    } else if (discoverData[i]['ticket_type']['type'] ==
                        'no_ticket') {
                      itemColor = Color(0xFFA6A8AB);
                      itemPriceText = 'NO TICKET';
                    } else if (discoverData[i]['ticket_type']['type'] ==
                        'on_the_spot') {
                      itemColor = Color(0xFF652D90);
                      itemPriceText = discoverData[i]['ticket_type']['name'];
                    } else if (discoverData[i]['ticket_type']['type'] ==
                        'free') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText = discoverData[i]['ticket_type']['name'];
                    } else if (discoverData[i]['ticket_type']['type'] ==
                        'free') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText = discoverData[i]['ticket_type']['name'];
                    } else if (discoverData[i]['ticket_type']['type'] ==
                        'free_limited') {
                      if (discoverData[i]['ticket']['availableTicketStatus'] ==
                          '1') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText = discoverData[i]['ticket_type']['name'];
                      } else {
                        if (discoverData[i]['ticket']['salesStatus'] ==
                            'comingSoon') {
                          itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                          itemPriceText = 'COMING SOON';
                        } else if (discoverData[i]['ticket']['salesStatus'] ==
                            'endSales') {
                          itemColor = Color(0xFF8E1E2D);
                          if (discoverData[i]['status'] == 'ended') {
                            itemPriceText = 'EVENT HAS ENDED';
                          }
                          itemPriceText = 'SALES ENDED';
                        } else {
                          itemColor = Color(0xFF8E1E2D);
                          itemPriceText = 'SOLD OUT';
                        }
                      }
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EventDetailsConstructView(
                                      id: discoverData[i]['id'],
                                      name: discoverData[i]['name'],
                                      image: discoverData[i]['photoFull']
                                    )));
                      },
                      child: PopularEventWidget(
                        imageUrl: discoverData[i]['picture'],
                        title: discoverData[i]["name"],
                        location: discoverData[i]["address"],
                        price: itemPriceText,
                        color: itemColor,
                        type: discoverData[i]['ticket_type']['type'],
                        isAvailable: discoverData[i]['ticket']
                            ['availableTicketStatus'],
                      ),
                    );
                  })),
          discoverPeople(),
          discoverPeopleImage()
        ],
      ),
    );
  }

  Future<Null> _refresh() {
    fetchCollection();
    fetchPopularPeople();
    fetchBanner();
    fetchCatalog();
    fetchDiscoverCatalog();
    fetchDiscoverPeople();
  }

  Widget categoryTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 13, right: 13, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Categories',
                  style: TextStyle(
                      color: eventajaBlack,
                      fontSize: 19,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget popularEventTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Popular Event',
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
                          builder: (BuildContext context) => SeeAllItem(
                                initialIndex: 0,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: eventajaGreenTeal, fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text('Find the most popular event',
              style: TextStyle(color: Color(0xFF868686), fontSize: 14)),
        ],
      ),
    );
  }

  Widget popularEventContent() {
    return Container(
        height: 269,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : new ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (BuildContext context, i) {
                  return new Container(
                      width: i == 0 ? 200 : 190,
                      child: Padding(
                        padding: i == 0
                            ? EdgeInsets.only(
                                left: 34,
                              )
                            : EdgeInsets.only(left: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EventDetailsConstructView(
                                              eventDetailsData: data[i],
                                              id: data[i]['id'],
                                              name: data[i]['name'],
                                              image: data[i]['photoFull']
                                            )));
                              },
                              child: Container(
                                height: 250,
                                width: 190,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 3,
                                          spreadRadius: 1.5)
                                    ],
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            data[i]['picture_timeline'])),
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                            Text(data[i]["dateStart"],
                                style: TextStyle(color: eventajaGreenTeal),
                                textAlign: TextAlign.start),
                            Text(
                              data[i]["name"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(data[i]["address"],
                                overflow: TextOverflow.ellipsis),
                            Container(
                              height: 40,
                              width: 150,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(ticketPriceImageURI),
                                      fit: BoxFit.fill)),
                              child: Center(child: Text('harga')),
                            )
                          ],
                        ),
                      ));
                }));
  }

  ///Construct DiscoverEvent Widget

  Widget discoverEvent() {
    return new Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Discover Event',
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
                          builder: (BuildContext context) => SeeAllItem(
                                initialIndex: 1,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: eventajaGreenTeal, fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text('Discover the undiscovered',
              style: TextStyle(fontSize: 14, color: Color(0xFF868686))),
        ],
      ),
    );
  }

  Widget discoverEventContent() {
    return Container(
        height: 310,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : new ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: discoverData == null ? 0 : discoverData.length,
                itemBuilder: (BuildContext context, i) {
                  return new Container(
                      width: i == 0 ? 200 : 190,
                      child: Padding(
                        padding: i == 0
                            ? EdgeInsets.only(left: 25)
                            : EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 250,
                              width: 190,
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: discoverData[i]["picture"],
                                placeholder: (context, url) => new Container(
                                  child: Image.asset(
                                    'assets/grey-fade.jpg',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Text(discoverData[i]["dateStart"],
                                style: TextStyle(color: eventajaGreenTeal)),
                            Text(discoverData[i]["name"],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis),
                            Text(discoverData[i]["address"],
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ));
                }));
  }

  ///Construct PopularPeople Widget

  Widget popularPeople() {
    return Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Popular People',
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
                          builder: (BuildContext context) => SeeAllPeople(
                                initialIndex: 0,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: eventajaGreenTeal, fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text('Find the most popular people',
              style: TextStyle(color: Color(0xFF868686), fontSize: 14)),
        ],
      ),
    );
  }

  Widget popularPeopleImage() {
    return Container(
      height: 80,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  popularPeopleData == null ? 0 : popularPeopleData.length,
              itemBuilder: (BuildContext context, i) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ProfileWidget(
                              initialIndex: 0,
                              userId: popularPeopleData[i]['id'],
                            )));
                  },
                  child: new Container(
                    padding: i == 0
                        ? EdgeInsets.only(left: 13)
                        : EdgeInsets.only(left: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 41.50,
                          width: 41.50,
                          decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3)
                              ],
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    popularPeopleData[i]["photo"]),
                                fit: BoxFit.fill,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget collection() {
    return Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Collection',
                style: TextStyle(
                    color: eventajaBlack,
                    fontSize: 19,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text('Check out our hand-picked collectoins bellow',
              style: TextStyle(color: Color(0xFF868686), fontSize: 8.63)),
        ],
      ),
    );
  }

  Widget collectionImage() {
    return Container(
      height: 90,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : collectionData == null
              ? errReasonWidget
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: collectionData == null ? 0 : collectionData.length,
                  itemBuilder: (BuildContext context, i) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CollectionPage(
                                  headerImage: collectionData[i]['image'],
                                  categoryId: collectionData[i]['id'],
                                  collectionName: collectionData[i]['name'],
                                )));
                      },
                      child: new Container(
                        width: 150,
                        margin: i == 0
                            ? EdgeInsets.only(left: 13)
                            : EdgeInsets.only(left: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 70,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Color(0xff8a8a8b),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1.5)
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: collectionData[i]['image'],
                                  placeholder: (context, url) => Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.asset(
                                        'assets/grey-fade.jpg',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  ///Construct DiscoverPeople Widget

  Widget discoverPeople() {
    return Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Discover People',
                  style: TextStyle(
                      color: eventajaBlack,
                      fontSize: 19,
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 4.5 - 5,
              )),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SeeAllPeople(
                                initialIndex: 1,
                              )));
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: eventajaGreenTeal, fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text('Find more people to follow',
              style: TextStyle(color: Color(0xFF868686), fontSize: 14)),
        ],
      ),
    );
  }

  Widget discoverPeopleImage() {
    return Container(
      height: 80,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  discoverPeopleData == null ? 0 : discoverPeopleData.length,
              itemBuilder: (BuildContext context, i) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ProfileWidget(
                              initialIndex: 0,
                              userId: discoverPeopleData[i]['id'],
                            )));
                  },
                  child: new Container(
                    padding: i == 0
                        ? EdgeInsets.only(left: 13)
                        : EdgeInsets.only(left: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 41.50,
                          width: 41.50,
                          decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3)
                              ],
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    discoverPeopleData[i]["photo"]),
                                fit: BoxFit.fill,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  ///Construct BannerCarousel Widget
  ///
  Widget banner() {
    return CarouselSlider(
      height: 200,
      items: bannerData == null
          ? [
              Center(
                child: CircularProgressIndicator(),
              )
            ]
          : mappedDataBanner,
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

  Widget bannerCarousel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          height: 180,
          width: 350,
          child: new Carousel(
            boxFit: BoxFit.cover,
            images: mappedDataBanner,
            dotSize: 10,
            dotSpacing: 15.0,
            dotColor: Colors.white,
            dotBgColor: Color.fromRGBO(0, 0, 0, 0),
            borderRadius: true,
            radius: Radius.circular(15),
          ),
        ),
      ],
    );
  }

  Widget mediaHeader() {
    return new Padding(
      padding: EdgeInsets.only(left: 13, right: 13, bottom: 6),
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          SeeAllMediaItem(initialIndex: 0, isVideo: false)));
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

  // Widget mediaContent() {
  //   return Container(
  //       height: 250,
  //       alignment: Alignment.centerLeft,
  //       child: isLoading
  //           ? Center(
  //               child: CircularProgressIndicator(
  //               backgroundColor: Colors.white,
  //             ))
  //           : new ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount:
  //                   mediaData['data'] == null ? 0 : mediaData['data'].length,
  //               itemBuilder: (BuildContext context, i) {
  //                 return Padding(
  //                   padding: const EdgeInsets.only(right: 10, left: 10),
  //                   child: new Container(
  //                       alignment: Alignment.center,
  //                       decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(15),
  //                           boxShadow: <BoxShadow>[
  //                             BoxShadow(
  //                                 color: Colors.grey,
  //                                 offset: Offset(1, 1),
  //                                 spreadRadius: 1,
  //                                 blurRadius: 5),
  //                           ]),
  //                       width: i == 0 ? 250 : 250,
  //                       child: Padding(
  //                         padding: i == 0
  //                             ? EdgeInsets.only(left: 0)
  //                             : EdgeInsets.only(left: 0),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           mainAxisSize: MainAxisSize.max,
  //                           children: <Widget>[
  //                             GestureDetector(
  //                               onTap: () {
  //                                 launch(
  //                                     'https://media.eventevent.com/medias/${mediaData['data'][i]['id']}',
  //                                     enableJavaScript: true,
  //                                     forceWebView: true,
  //                                     forceSafariVC: true);
  //                               },
  //                               child: Container(
  //                                 height: 120,
  //                                 width: i == 0 ? 250 : 250,
  //                                 decoration: BoxDecoration(
  //                                     borderRadius: BorderRadius.only(
  //                                         topLeft: Radius.circular(15),
  //                                         topRight: Radius.circular(15)),
  //                                     image: DecorationImage(
  //                                         image: NetworkImage(
  //                                           mediaData['data'][i]['banner'],
  //                                         ),
  //                                         fit: BoxFit.fill)),
  //                               ),
  //                             ),
  //                             Container(
  //                               height: 120,
  //                               decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 borderRadius: BorderRadius.only(
  //                                     topLeft: Radius.circular(15),
  //                                     topRight: Radius.circular(15)),
  //                               ),
  //                               child: Column(children: <Widget>[
  //                                 SizedBox(height: 9),
  //                                 // Text(data[i]["dateStart"],
  //                                 //     style: TextStyle(color: eventajaGreenTeal),
  //                                 //     textAlign: TextAlign.start),
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(left: 15),
  //                                   child: Column(
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.start,
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.start,
  //                                     children: <Widget>[
  //                                       Container(
  //                                         width: 220,
  //                                         child: Text(
  //                                           //'asdfghhtij aijitaj sjakj \n ofkoakf ffffa gggdssef ffwf',
  //                                           mediaData['data'][i]["title"],
  //                                           overflow: TextOverflow.ellipsis,
  //                                           style: TextStyle(
  //                                               fontSize: 20,
  //                                               fontWeight: FontWeight.bold),
  //                                           textAlign: TextAlign.start,
  //                                           maxLines: 2,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 9),
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(left: 10),
  //                                   child: Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.start,
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.center,
  //                                     children: <Widget>[
  //                                       Container(
  //                                         height: 30,
  //                                         width: 30,
  //                                         decoration: BoxDecoration(
  //                                             shape: BoxShape.circle,
  //                                             image: DecorationImage(
  //                                                 image: NetworkImage(
  //                                                     mediaData['data'][i]
  //                                                         ['creator']['photo']),
  //                                                 fit: BoxFit.fill)),
  //                                       ),
  //                                       SizedBox(
  //                                         width: 10,
  //                                       ),
  //                                       Text(mediaData['data'][i]['creator']
  //                                                   ['fullName'] ==
  //                                               null
  //                                           ? '-'
  //                                           : mediaData['data'][i]['creator']
  //                                               ['fullName'])
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ]),
  //                             )
  //                           ],
  //                         ),
  //                       )),
  //                 );
  //               }));
  // }

  List<Catalog> _list = [];
  var isLoading = false;

  Future<void> doRefresh() async {
    await Future.delayed(Duration(milliseconds: 2000), () {
      fetchCatalog();
      fetchBanner();
      fetchDiscoverCatalog();
      fetchPopularPeople();
      fetchDiscoverPeople();
      fetchCollection();
      getMediaData().then((response) {
        var extractedData = json.decode(response.body);

        print(response.statusCode);
        print(response.body);

        if (response.statusCode == 200) {
          setState(() {
            mediaData = extractedData['data']['data'];
          });
        }
      });
    });
  }

  Future<http.Response> getMediaData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = urlType +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=10&type=photo&status=popular';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTHORIZATION_KEY,
      'signature': signature
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }

  ///Untuk Fetching Gambar banner
  Future fetchBanner() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      session = preferences.getString('Session');
    });

    final bannerApiUrl = urlType +
        '/banner/timeline?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTHORIZATION_KEY,
      'signature': signature
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(bannerApiUrl, headers: headerType);

    print(
        'event catalog widget - fetchBanner' + response.statusCode.toString());

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        bannerData = extractedData['data'];

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });

      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content:
            Text(response.reasonPhrase, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future fetchCollection() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      session = preferences.getString('Session');
    });

    final collectionUrl = urlType +
        '/collections/list?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b&page=1';
    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTHORIZATION_KEY,
      'signature': signature
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(collectionUrl, headers: headerType);

    print('eventCatalogWidget - fetch collection ' +
        response.statusCode.toString());
    var extractedData = json.decode(response.body);

    if (response.statusCode == 200) {
      print('fetched collection data');
      setState(() {
        collectionData = extractedData['data'];

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content:
            Text(response.reasonPhrase, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    } else if (extractedData['desc'] == 'Event Not Found') {
      setState(() {
        isLoading = false;
        errReasonWidget = Container(
          child: Center(child: Text('No event found')),
        );
      });
    }
  }

  ///Untuk Fetching gambar PopularPeople
  Future fetchPopularPeople() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      session = preferences.getString('Session');
    });

    final popularPeopleUrl =
        urlType + '/user/popular?X-API-KEY=$API_KEY&page=1&total=20';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTHORIZATION_KEY,
      'signature': signature
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(popularPeopleUrl, headers: headerType);

    print('eventCatalogWidget - fetch pop people' +
        response.statusCode.toString());

    if (response.statusCode == 200) {
      print('fetched data');
      if (!mounted) return;
      setState(() {
        var extractedData = json.decode(response.body);
        popularPeopleData = extractedData['data'];

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content:
            Text(response.reasonPhrase, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  ///Untuk fetching gambar DiscoverPeople
  Future fetchDiscoverPeople() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      session = preferences.getString('Session');
    });

    final popularPeopleUrl = urlType +
        '/user/discover?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b&page=1&total=20';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTHORIZATION_KEY,
      'signature': signature
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(popularPeopleUrl, headers: headerType);

    print('eventCatalogWidget - fetch discover people ' +
        response.statusCode.toString());

    if (response.statusCode == 200) {
      print('fetched data discoverPeople');
      if (!mounted) return;
      setState(() {
        var extractedData = json.decode(response.body);
        discoverPeopleData = extractedData['data'];

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content:
            Text(response.reasonPhrase, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  ///Untuk fetching segala macem yang ada di DiscoverCatalog

  Future fetchDiscoverCatalog() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      session = preferences.getString('Session');
    });

    final discoverApiUrl = urlType +
        '/event/discover?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b&page=1&total=20';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTHORIZATION_KEY,
      'signature': signature
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(discoverApiUrl, headers: headerType);

    print('eventCatalogWidget - discover widget ' +
        response.statusCode.toString());

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        discoverData = extractedData['data'];

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content:
            Text(response.reasonPhrase, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  ///Untuk fetching segala macem yang ada di PopularEvent / Catalog
  Future fetchCatalog() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      session = preferences.getString('Session');
    });

    final catalogApiUrl = urlType +
        '/event/popular?X-API-KEY=47d32cb10889cbde94e5f5f28ab461e52890034b&page=1&total=20';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTHORIZATION_KEY,
      'signature': signature
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(catalogApiUrl, headers: headerType);

    print('eventCatalogWidget' + response.statusCode.toString());

    if (response.statusCode == 200) {
      if (!mounted) return;
      setState(() {
        var extractedData = json.decode(response.body);
        data = extractedData['data'];

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content:
            Text(response.reasonPhrase, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }
}
