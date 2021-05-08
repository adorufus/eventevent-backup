import 'dart:async';
import 'dart:convert';
import 'package:eventevent/Models/BannerModels.dart';
import 'package:eventevent/Widgets/CollectionPage.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/MyTicket.dart';
import 'package:eventevent/Widgets/Home/PopularEventWidget.dart';
import 'package:eventevent/Widgets/Home/SeeAll/SeeAllItem.dart';
import 'package:eventevent/Widgets/Home/SeeAll/SeeAllPeople.dart';
import 'package:eventevent/Widgets/LatestEventWidget.dart';
import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/RecycleableWidget/SearchWidget.dart';
import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/Widgets/timeline/LatestMediaItem.dart';
import 'package:eventevent/Widgets/timeline/MediaDetails.dart';
import 'package:eventevent/Widgets/timeline/SeeAllMediaItem.dart';
import 'package:eventevent/Widgets/timeline/popularMediaItem.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/API/catalogModel.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'nearbyEventWidget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'categoryEventWidget.dart';
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
    with
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin<EventCatalog>,
        TickerProviderStateMixin {
  TimelineDashboardState timelineState = new TimelineDashboardState();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  // ContainerTransitionType _transitionType = ContainerTransitionType.fade;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ///Variable untuk insialisasi Value awal
  List data;
  List bannerData = [];
  List discoverData;
  List popularPeopleData;
  List discoverPeopleData;
  List collectionData;
  List child;
  List latestMediaVideo;
  ListenPage geoPage = new ListenPage();
  List mediaData;
  Widget errReasonWidget = Container();

  String ticketPriceImageURI = 'assets/btn_ticket/paid-value.png';
  String urlType = '';

  final StreamController<int> _bannerCount = StreamController<int>();
  Stream<int> get bannerCount => _bannerCount.stream;

  int _current = 0;

  ScrollController _scrollController = new ScrollController();
  List<Widget> mappedDataBanner;
  var session;
  TabController tabController;
  int currentTabIndex = 0;

  List<bool> hasInit = [true, false, false];
  List<Widget> pages = [];

  ///Inisialisasi semua fungsi untuk fetching dan hal hal lain yang dibutuhkan
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    //ClevertapHandler.logPageView("Home");

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
      getLatestMediaData().then((response) {
        var extractedData = json.decode(response.body);

        print(response.statusCode);
        print(response.body);

        if (response.statusCode == 200) {
          setState(() {
            latestMediaVideo = extractedData['data']['data'];
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
  }

  bool isOnlyContainer = false;

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
  bool get wantKeepAlive => true;

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
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                  onTap: () {
                    if (bannerData['type'] == 'event' &&
                        bannerData['eventID'] != "") {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EventDetailLoadingScreen(
                            isRest: widget.isRest,
                            eventId: bannerData['eventID']);
                        // EventDetailsConstructView(
                        //     id: bannerData['eventID'],
                        //     name: bannerData['name'],
                        //     image: bannerData['photoFull']);
                      }));
                    } else if (bannerData['type'] == 'nolink') {
                      return;
                    } else if (bannerData['type'] == 'category') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return EventDetailLoadingScreen(
                                isRest: widget.isRest,
                                eventId: bannerData['categoryID']);
                            //  EventDetailsConstructView(
                            //     id: bannerData['categoryID'],
                            //     name: bannerData['name'],
                            //     image: bannerData['photoFull']);
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).devicePixelRatio * 2645.0,
                    margin: EdgeInsets.only(
                        left: 13, right: 13, bottom: 15, top: 13),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/grey-fade.jpg'),
                          fit: BoxFit.cover),
                      shape: BoxShape.rectangle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 0),
                            blurRadius: 2,
                            spreadRadius: 1.5)
                      ],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ProgressiveImage.assetNetwork(
                          placeholder: 'assets/grey-fade.jpg',
                          thumbnail: bannerData["image"],
                          image: bannerData["image"],
                          width: 350,
                          height: 180),
                      // CachedNetworkImage(
                      //     imageUrl: bannerData["image"]
                      //         .toString()
                      //         .replaceAll("\n", ""),
                      //     fit: BoxFit.cover,
                      //     placeholder: (context, url) => Container()),
                    ),
                  ));
            },
          );
        })?.toList() ??
        [];

    return SafeArea(
      bottom: false,
      child: RefreshConfiguration(
        enableLoadingWhenFailed: true,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size(null, 100),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: ScreenUtil.instance.setWidth(75),
              padding: EdgeInsets.symmetric(horizontal: 13),
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
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(23),
                        width: ScreenUtil.instance.setWidth(140),
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
                  fontSize: ScreenUtil.instance.setSp(14),
                  color: Colors.black,
                )),
                actions: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (BuildContext context) => Search(
                                    isRest: widget.isRest,
                                  )));
                    },
                    child: Container(
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
                          'assets/icons/icon_apps/search.png',
                          scale: 4.5,
                        )),
                  ),
                  SizedBox(width: ScreenUtil.instance.setWidth(8)),
                  widget.isRest == true
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => MyTicket()));
                          },
                          child: Container(
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
                              )),
                        ),
                  SizedBox(width: ScreenUtil.instance.setWidth(2)),
                ],
              ),
            ),
          ),
          body: DefaultTabController(
            length: 3,
            initialIndex: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: TabBar(
                    onTap: (val) {
                      setState(() {
                        if (val == 2 || val == 0) {
                          isOnlyContainer = true;
                        } else {
                          isOnlyContainer = false;
                        }
                      });

                      print(isOnlyContainer);
                    },
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
                            SizedBox(width: ScreenUtil.instance.setWidth(10)),
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
                              'assets/icons/icon_apps/nearby.png',
                              scale: 4.5,
                            ),
                            SizedBox(width: ScreenUtil.instance.setWidth(10)),
                            Text('Nearby',
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
                            SizedBox(width: ScreenUtil.instance.setWidth(10)),
                            Text('Latest',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil.instance.setSp(12.5))),
                          ],
                        ),
                      ),
                    ],
                    unselectedLabelColor: Colors.grey,
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.topCenter,
                    height: MediaQuery.of(context).size.height - 191,
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        home(),
                        isOnlyContainer == true
                            ? Container()
                            : Container(
                                child: Center(
                                  child: ListenPage(
                                    isRest: widget.isRest,
                                  ),
                                ),
                              ),
                        LatestEventWidget(
                          isRest: widget.isRest,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        shrinkWrap: true,
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
                      bannerData == null
                          ? HomeLoadingScreen().bannerLoading(context)
                          : banner(),
                    ],
                  ),
                ),
                popularEventTitle(),
                Container(
                    height: ScreenUtil.instance.setWidth(340),
                    child: data == null
                        ? HomeLoadingScreen().eventLoading()
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: data == null ? 0 : data.length,
                            itemBuilder: (BuildContext context, i) {
                              Color itemColor;
                              String itemPriceText;
                              if (data[i]['isGoing'] == '1') {
                                itemColor = Colors.blue;
                                itemPriceText = 'Going!';
                              } else {
                                if (data[i]['ticket_type']['type'] == 'paid' ||
                                    data[i]['ticket_type']['type'] ==
                                        'paid_seating') {
                                  if (data[i]['ticket']
                                          ['availableTicketStatus'] ==
                                      '1') {
                                    if (data[i]['ticket']['cheapestTicket'] ==
                                        '0') {
                                      itemColor = Color(0xFFFFAA00);
                                      itemPriceText = 'Free Limited';
                                    } else {
                                      itemColor = Color(0xFF34B323);
                                      itemPriceText = 'Rp' +
                                          data[i]['ticket']['cheapestTicket'] +
                                          ',-';
                                    }
                                  } else {
                                    if (data[i]['ticket']['salesStatus'] ==
                                        'comingSoon') {
                                      itemColor =
                                          Color(0xFF34B323).withOpacity(0.3);
                                      itemPriceText = 'COMING SOON';
                                    } else if (data[i]['ticket']
                                            ['salesStatus'] ==
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
                                  itemColor = Color(0xFF652D90);
                                  itemPriceText = 'NO TICKET';
                                } else if (data[i]['ticket_type']['type'] ==
                                    'on_the_spot') {
                                  itemColor = Color(0xFF652D90);
                                  itemPriceText =
                                      data[i]['ticket_type']['name'];
                                } else if (data[i]['ticket_type']['type'] ==
                                    'free') {
                                  itemColor = Color(0xFFFFAA00);
                                  itemPriceText =
                                      data[i]['ticket_type']['name'];
                                } else if (data[i]['ticket_type']['type'] ==
                                    'free') {
                                  itemColor = Color(0xFFFFAA00);
                                  itemPriceText =
                                      data[i]['ticket_type']['name'];
                                } else if (data[i]['ticket_type']['type'] ==
                                    'paid_live_stream') {
                                  itemColor = eventajaGreenTeal;
                                  itemPriceText = 'Rp' +
                                      data[i]['ticket']['cheapestTicket'] +
                                      ',-';
                                } else if (data[i]['ticket_type']['type'] ==
                                    'free_live_stream') {
                                  itemColor = Color(0xFFFFAA00);
                                  itemPriceText =
                                      data[i]['ticket_type']['name'];
                                } else if (data[i]['ticket_type']['type'] ==
                                    'free_limited') {
                                  if (data[i]['ticket']
                                          ['availableTicketStatus'] ==
                                      '1') {
                                    itemColor = Color(0xFFFFAA00);
                                    itemPriceText =
                                        data[i]['ticket_type']['name'];
                                  } else {
                                    if (data[i]['ticket']['salesStatus'] ==
                                        'comingSoon') {
                                      itemColor =
                                          Color(0xFF34B323).withOpacity(0.3);
                                      itemPriceText = 'COMING SOON';
                                    } else if (data[i]['ticket']
                                            ['salesStatus'] ==
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
                              }

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              EventDetailLoadingScreen(
                                                  isRest: widget.isRest,
                                                  eventId: data[i]['id'])));
                                },
                                child: PopularEventWidget(
                                  imageUrl: data[i]['picture'],
                                  title: data[i]["name"],
                                  isHybridEvent: data[i]['isHybridEvent'],
                                  location: data[i]["address"],
                                  color: itemColor,
                                  price: itemPriceText,
                                  type: data[i]['ticket_type']['type'],
                                  date: DateTime.parse(data[i]['dateStart']),
                                  isAvailable: data[i]['ticket']
                                      ['availableTicketStatus'],
                                ),
                              );
                            })),
                SizedBox(height: ScreenUtil.instance.setWidth(20)),
                mediaHeader(),
                Container(
                  height: ScreenUtil.instance.setWidth(247),
                  child: data == null
                      ? HomeLoadingScreen().mediaLoading()
                      : ListView.builder(
                          itemCount: mediaData == null ? 0 : mediaData.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, i) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MediaDetails(
                                              isRest: widget.isRest,
                                              videoUrl: mediaData[i]['video'],
                                              youtubeUrl: mediaData[i]
                                                  ['youtube'],
                                              userPicture: mediaData[i]
                                                  ['creator']['photo'],
                                              articleDetail: mediaData[i]
                                                  ['content'],
                                              imageCount: 'img' + i.toString(),
                                              username: mediaData[i]['creator']
                                                  ['username'],
                                              imageUri: mediaData[i]
                                                  ['banner_timeline'],
                                              mediaTitle: mediaData[i]['title'],
                                              isVideo: true,
                                              mediaId: mediaData[i]['id'],
                                              autoFocus: false,
                                            )));
                              },
                              child: MediaItem(
                                isRest: widget.isRest,
                                isVideo: true,
                                isLiked: mediaData[i]['is_loved'],
                                image: mediaData[i]['thumbnail_timeline'],
                                title: mediaData[i]['title'],
                                username: mediaData[i]['creator']['username'],
                                userPicture: mediaData[i]['creator']['photo'],
                                articleDetail: mediaData[i]['description'],
                                imageIndex: i,
                                commentCount: mediaData[i]['comment'],
                                likeCount: mediaData[i]['count_loved'],
                                mediaId: mediaData[i]['id'],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(20)),
          latestVideoHeader(),
          latestVideoContent(),
          SizedBox(height: ScreenUtil.instance.setWidth(20)),
          categoryTitle(),
          Container(
            height: ScreenUtil.instance.setWidth(180),
            padding: EdgeInsets.only(top: 5, left: 6.5),
            // decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(15),
            //     boxShadow: <BoxShadow>[
            //       BoxShadow(
            //           blurRadius: 2,
            //           color: Colors.black.withOpacity(0.1),
            //           spreadRadius: 1.5)
            //     ]),
            margin: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
            child: Center(
              child: CategoryEventWidget(isRest: widget.isRest),
            ),
          ),
          collection(),
          collectionImage(),
          popularPeople(),
          popularPeopleImage(),
          SizedBox(height: ScreenUtil.instance.setWidth(15)),
          discoverEvent(),
          discoverData == null
              ? HomeLoadingScreen().eventLoading()
              : Container(
                  height: ScreenUtil.instance.setWidth(340),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: discoverData == null ? 0 : discoverData.length,
                      itemBuilder: (BuildContext context, i) {
                        Color itemColor;
                        String itemPriceText;
                        if (discoverData[i]['isGoing'] == '1') {
                          itemColor = Colors.blue;
                          itemPriceText = 'Going!';
                        } else {
                          if (discoverData[i]['ticket_type']['type'] ==
                                  'paid' ||
                              discoverData[i]['ticket_type']['type'] ==
                                  'paid_seating') {
                            if (discoverData[i]['ticket']
                                    ['availableTicketStatus'] ==
                                '1') {
                              itemColor = Color(0xFF34B323);
                              itemPriceText = 'Rp' +
                                  discoverData[i]['ticket']['cheapestTicket'] +
                                  ',-';
                            } else {
                              if (discoverData[i]['ticket']['salesStatus'] ==
                                  'comingSoon') {
                                itemColor = Color(0xFF34B323).withOpacity(0.3);
                                itemPriceText = 'COMING SOON';
                              } else if (discoverData[i]['ticket']
                                      ['salesStatus'] ==
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
                            itemColor = Color(0xFF652D90);
                            itemPriceText = 'NO TICKET';
                          } else if (discoverData[i]['ticket_type']['type'] ==
                              'on_the_spot') {
                            itemColor = Color(0xFF652D90);
                            itemPriceText =
                                discoverData[i]['ticket_type']['name'];
                          } else if (discoverData[i]['ticket_type']['type'] ==
                              'free') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText =
                                discoverData[i]['ticket_type']['name'];
                          } else if (discoverData[i]['ticket_type']['type'] ==
                              'free') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText =
                                discoverData[i]['ticket_type']['name'];
                          } else if (discoverData[i]['ticket_type']['type'] ==
                              'paid_live_stream') {
                            itemColor = eventajaGreenTeal;
                            itemPriceText = 'Rp' +
                                discoverData[i]['ticket']['cheapestTicket'] +
                                ',-';
                          } else if (discoverData[i]['ticket_type']['type'] ==
                              'free_live_stream') {
                            itemColor = Color(0xFFFFAA00);
                            itemPriceText =
                                discoverData[i]['ticket_type']['name'];
                          } else if (discoverData[i]['ticket_type']['type'] ==
                                  'free_limited' ||
                              discoverData[i]['ticket_type']['type'] ==
                                  'free_limited_seating') {
                            if (discoverData[i]['ticket']
                                    ['availableTicketStatus'] ==
                                '1') {
                              itemColor = Color(0xFFFFAA00);
                              itemPriceText =
                                  discoverData[i]['ticket_type']['name'];
                            } else {
                              if (discoverData[i]['ticket']['salesStatus'] ==
                                  'comingSoon') {
                                itemColor = Color(0xFFFFAA00).withOpacity(0.3);
                                itemPriceText = 'COMING SOON';
                              } else if (discoverData[i]['ticket']
                                      ['salesStatus'] ==
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
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EventDetailLoadingScreen(
                                  isRest: widget.isRest,
                                  eventId: discoverData[i]['id'],
                                ),
                              ),
                            );
                          },
                          child: PopularEventWidget(
                            imageUrl: discoverData[i]['picture'],
                            title: discoverData[i]["name"],
                            location: discoverData[i]["address"],
                            price: itemPriceText,
                            color: itemColor,
                            isGoing: discoverData[i]['isGoing'] == '1'
                                ? true
                                : false,
                            date: DateTime.parse(discoverData[i]['dateStart']),
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
                      fontSize: ScreenUtil.instance.setSp(26),
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
                      fontSize: ScreenUtil.instance.setSp(26),
                      fontWeight: FontWeight.bold)),
              Expanded(
                child: SizedBox(),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SeeAllItem(
                                isRest: widget.isRest,
                                initialIndex: 0,
                              )));
                },
                child: Container(
                  height: 20,
                  child: Center(
                    child: Text(
                      'See All  >',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(5)),
          Text('Find the most popular event',
              style: TextStyle(
                  color: Color(0xFF868686),
                  fontSize: ScreenUtil.instance.setSp(14))),
        ],
      ),
    );
  }

  Widget popularEventContent() {
    return Container(
        height: ScreenUtil.instance.setWidth(269),
        child: data == null
            ? CupertinoActivityIndicator(radius: 13.5)
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
                                        EventDetailLoadingScreen(
                                      isRest: widget.isRest,
                                      eventId: data[i]['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: ScreenUtil.instance.setWidth(250),
                                width: ScreenUtil.instance.setWidth(190),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 3,
                                          spreadRadius: 1.5)
                                    ],
                                    image: DecorationImage(
                                        image:
                                            NetworkImage(data[i]['picture'])),
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
                                  fontSize: ScreenUtil.instance.setSp(20),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              data[i]["address"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Container(
                              height: ScreenUtil.instance.setWidth(40),
                              width: ScreenUtil.instance.setWidth(150),
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
                      fontSize: ScreenUtil.instance.setSp(26),
                      fontWeight: FontWeight.bold)),
              Expanded(child: SizedBox()),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SeeAllItem(
                                isRest: widget.isRest,
                                initialIndex: 1,
                              )));
                },
                child: Container(
                  height: 20,
                  child: Center(
                    child: Text(
                      'See All  >',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(5)),
          Text('Discover the undiscovered',
              style: TextStyle(
                  fontSize: ScreenUtil.instance.setSp(14),
                  color: Color(0xFF868686))),
        ],
      ),
    );
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
              Text('Popular Profile',
                  style: TextStyle(
                      color: eventajaBlack,
                      fontSize: ScreenUtil.instance.setSp(26),
                      fontWeight: FontWeight.bold)),
              Expanded(child: SizedBox()),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SeeAllPeople(
                                isRest: widget.isRest,
                                initialIndex: 0,
                              )));
                },
                child: Container(
                  height: 20,
                  child: Center(
                    child: Text(
                      'See All  >',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(5)),
          Text('Find the most popular profile',
              style: TextStyle(
                  color: Color(0xFF868686),
                  fontSize: ScreenUtil.instance.setSp(14))),
        ],
      ),
    );
  }

  Widget popularPeopleImage() {
    return Container(
      height: ScreenUtil.instance.setWidth(80),
      child: popularPeopleData == null
          ? HomeLoadingScreen().peopleLoading()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  popularPeopleData == null ? 0 : popularPeopleData.length,
              itemBuilder: (BuildContext context, i) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ProfileWidget(
                              isRest: widget.isRest,
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
                          height: ScreenUtil.instance.setWidth(40.50),
                          width: ScreenUtil.instance.setWidth(41.50),
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
                    fontSize: ScreenUtil.instance.setSp(26),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(5)),
          Text('Check out our hand-picked collectoins bellow',
              style: TextStyle(
                  color: Color(0xFF868686),
                  fontSize: ScreenUtil.instance.setSp(14))),
        ],
      ),
    );
  }

  Widget collectionImage() {
    return Container(
      height: ScreenUtil.instance.setWidth(90),
      child: collectionData == null
          ? HomeLoadingScreen().collectionLoading()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: collectionData == null ? 0 : collectionData.length,
              itemBuilder: (BuildContext context, i) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CollectionPage(
                              isRest: widget.isRest,
                              headerImage: collectionData[i]['image'],
                              categoryId: collectionData[i]['id'],
                              collectionName: collectionData[i]['name'],
                            )));
                  },
                  child: new Container(
                    width: ScreenUtil.instance.setWidth(150),
                    margin: i == 0
                        ? EdgeInsets.only(left: 13)
                        : EdgeInsets.only(left: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.instance.setWidth(70),
                          width: ScreenUtil.instance.setWidth(150),
                          decoration: BoxDecoration(
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
                              imageUrl: collectionData[i]['image_medium'],
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
              Text('Discover Profile',
                  style: TextStyle(
                      color: eventajaBlack,
                      fontSize: ScreenUtil.instance.setSp(26),
                      fontWeight: FontWeight.bold)),
              Expanded(child: SizedBox()),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SeeAllPeople(
                                initialIndex: 1,
                                isRest: widget.isRest,
                              )));
                },
                child: Container(
                  height: 20,
                  child: Center(
                    child: Text(
                      'See All  >',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(5)),
          Text('Find more profile to follow',
              style: TextStyle(
                  color: Color(0xFF868686),
                  fontSize: ScreenUtil.instance.setSp(14))),
        ],
      ),
    );
  }

  Widget discoverPeopleImage() {
    return Container(
      height: ScreenUtil.instance.setWidth(80),
      child: discoverPeopleData == null
          ? HomeLoadingScreen().peopleLoading()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  discoverPeopleData == null ? 0 : discoverPeopleData.length,
              itemBuilder: (BuildContext context, i) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ProfileWidget(
                              isRest: widget.isRest,
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
                          height: ScreenUtil.instance.setWidth(40.50),
                          width: ScreenUtil.instance.setWidth(41.50),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
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
    return bannerData == null
        ? HomeLoadingScreen().bannerLoading(context)
        : bannerData.length < 1
            ? HomeLoadingScreen().bannerLoading(context)
            : CarouselSlider(
                height: ScreenUtil.instance.setWidth(200),
                items: bannerData.length < 1
                    ? [HomeLoadingScreen().bannerLoading(context)]
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
          height: ScreenUtil.instance.setWidth(180),
          width: ScreenUtil.instance.setWidth(350),
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
                      fontSize: ScreenUtil.instance.setSp(26),
                      fontWeight: FontWeight.bold)),
              Expanded(child: SizedBox()),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => SeeAllMediaItem(
                          isRest: widget.isRest,
                          initialIndex: 0,
                          isVideo: true)));
                },
                child: Container(
                  height: 20,
                  child: Center(
                    child: Text(
                      'See All  >',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=10&type=video&status=popular';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTH_KEY,
      'signature': SIGNATURE
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }

  Future<http.Response> getLatestMediaData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = urlType +
        '/media?X-API-KEY=$API_KEY&search=&page=1&limit=5&type=video&status=latest';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTH_KEY,
      'signature': SIGNATURE
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }

//  Future getAllBanner() async{
//    final db = await DBProvider.db.database;
//    var res = await db.query('event_banner');
//
//
//
//    bannerData = res.isNotEmpty ? res : [];
//    print('banner_data: ' + bannerData.toString());
//    return bannerData;
//  }

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
      'Authorization': AUTH_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTH_KEY,
      'signature': SIGNATURE
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
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginRegisterWidget()));
      // Flushbar(
      //   flushbarPosition: FlushbarPosition.TOP,
      //   message: response.reasonPhrase,
      //   backgroundColor: Colors.red,
      //   duration: Duration(seconds: 3),
      //   animationDuration: Duration(milliseconds: 500),
      // )..show(context).then((val) {

      //   });
    }
  }

  Stream<List<BannerModel>> get BannerList async* {
    yield await fetchBanner();
  }

  BannerManager() {
    BannerList.listen((list) => _bannerCount.add(list.length));
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
      'Authorization': AUTH_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTH_KEY,
      'signature': SIGNATURE
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
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginRegisterWidget()));
    } else if (extractedData['desc'] == 'Event Not Found') {
      setState(() {
        isLoading = false;
        errReasonWidget = Container(
          child: Center(child: Text('No event found')),
        );
      });
    }
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
                      fontSize: ScreenUtil.instance.setSp(26),
                      fontWeight: FontWeight.bold)),
              Expanded(child: SizedBox()),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
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
                child: Container(
                  height: 20,
                  child: Center(
                    child: Text(
                      'See All  >',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(12)),
                    ),
                  ),
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
                                        ['thumbnail_timeline']
                                    .toString()
                                    .replaceAll("\n", ""),
                                mediaTitle: latestMediaVideo[i]['title'],
                                autoFocus: false,
                                mediaId: latestMediaVideo[i]['id'],
                              )));
                },
                child: LatestMediaItem(
                  isRest: widget.isRest,
                  isVideo: true,
                  isLiked: latestMediaVideo[i]['is_loved'],
                  image: latestMediaVideo[i]['thumbnail_timeline']
                      .toString()
                      .replaceAll("\n", ""),
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
      'Authorization': AUTH_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTH_KEY,
      'signature': SIGNATURE
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

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginRegisterWidget()));
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
      'Authorization': AUTH_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTH_KEY,
      'signature': SIGNATURE
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
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginRegisterWidget()));
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
      'Authorization': AUTH_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTH_KEY,
      'signature': SIGNATURE
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
        discoverData.removeWhere((item) =>
            item['ticket_type']['type'] == 'free_limited_seating' ||
            item['ticket_type']['type'] == 'paid_seating' ||
            item['ticket_type']['type'] == 'paid_seating');

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginRegisterWidget()));
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
      'Authorization': AUTH_KEY,
      'cookie': preferences.getString('Session')
    };

    print(headerProd);

    Map<String, String> headerRest = {
      'Authorization': AUTH_KEY,
      'signature': SIGNATURE
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
        data.removeWhere((item) =>
            item['ticket_type']['type'] == 'free_limited_seating' ||
            item['ticket_type']['type'] == 'paid_seating' ||
            item['ticket_type']['type'] == 'paid_seating');

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginRegisterWidget()));
    }
  }
}
