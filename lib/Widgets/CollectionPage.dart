import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/RecycleableWidget/EmptyState.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CollectionPage extends StatefulWidget {
  final categoryId;
  final String collectionName;
  final headerImage;

  const CollectionPage(
      {Key key, this.categoryId, this.collectionName, this.headerImage})
      : super(key: key);
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List eventByCategoryList;
  List userByCollectionList;

  bool isLoading;
  Widget errReasonWidget = Container();

  @override
  void initState() {
    fetchCategoryById().catchError((e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          e.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ));
    });

    fetchUserByCollectionId().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          userByCollectionList = extractedData['data'];
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size(null, 100),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 13),
            color: Colors.white,
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/icons/icon_apps/arrow.png',
                  scale: 5.5,
                  alignment: Alignment.centerLeft,
                ),
              ),
              title: Text('Events Happening in ' +
                  widget.collectionName[0].toUpperCase() +
                  widget.collectionName.substring(1)),
              centerTitle: true,
              textTheme: TextTheme(
                  title: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              )),
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Color(0xff8a8a8b),
                  image: DecorationImage(
                      image: NetworkImage(
                        widget.headerImage,
                      ),
                      fit: BoxFit.fill)),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    child: Text('Organizers in this collections'),
                  ),
                  SizedBox(height: 10,),
                  Container(
                      height: 50,
                      color: Colors.white,
                      child: userByCollectionList == null ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 25),
                        child: Text('No Event Organizers Found', style: TextStyle(color: Color(0xff8a8a8b), fontWeight: FontWeight.bold),),
                      ) :
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: userByCollectionList == null
                            ? 0
                            : userByCollectionList.length,
                        itemBuilder: (context, i) {
                          return Container(
                            padding: i == 0
                                ? EdgeInsets.only(left: 25, right: i == userByCollectionList.last ? 15 : 0)
                                : EdgeInsets.only(left: i == 1 ? 15 : 0 , right: 15, ),
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
                                            userByCollectionList[i]["photo"]),
                                        fit: BoxFit.fill,
                                      )),
                                ),
                              ],
                            ),
                          );
                        },
                      )),
                ],
              ),
            ),
            Container(
              child: isLoading == true
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
                  : eventByCategoryList == null
                      ? errReasonWidget
                      : ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: eventByCategoryList == null
                              ? 0
                              : eventByCategoryList.length,
                          itemBuilder: (BuildContext context, i) {
                            Color itemColor;
                            String itemPriceText;

                            if (eventByCategoryList[i]['ticket_type']['type'] ==
                                    'paid' ||
                                eventByCategoryList[i]['ticket_type']['type'] ==
                                    'paid_seating') {
                              if (eventByCategoryList[i]['ticket']
                                      ['availableTicketStatus'] ==
                                  '1') {
                                itemColor = Color(0xFF34B323);
                                itemPriceText = eventByCategoryList[i]['ticket']
                                    ['cheapestTicket'];
                              } else {
                                if (eventByCategoryList[i]['ticket']
                                        ['salesStatus'] ==
                                    'comingSoon') {
                                  itemColor =
                                      Color(0xFF34B323).withOpacity(0.3);
                                  itemPriceText = 'COMING SOON';
                                } else if (eventByCategoryList[i]['ticket']
                                        ['salesStatus'] ==
                                    'endSales') {
                                  itemColor = Color(0xFF8E1E2D);
                                  if (eventByCategoryList[i]['status'] ==
                                      'ended') {
                                    itemPriceText = 'EVENT HAS ENDED';
                                  }
                                  itemPriceText = 'SALES ENDED';
                                } else {
                                  itemColor = Color(0xFF8E1E2D);
                                  itemPriceText = 'SOLD OUT';
                                }
                              }
                            } else if (eventByCategoryList[i]['ticket_type']
                                    ['type'] ==
                                'no_ticket') {
                              itemColor = Color(0xFFA6A8AB);
                              itemPriceText = 'NO TICKET';
                            } else if (eventByCategoryList[i]['ticket_type']
                                    ['type'] ==
                                'on_the_spot') {
                              itemColor = Color(0xFF652D90);
                              itemPriceText =
                                  eventByCategoryList[i]['ticket_type']['name'];
                            } else if (eventByCategoryList[i]['ticket_type']
                                    ['type'] ==
                                'free') {
                              itemColor = Color(0xFFFFAA00);
                              itemPriceText =
                                  eventByCategoryList[i]['ticket_type']['name'];
                            } else if (eventByCategoryList[i]['ticket_type']
                                    ['type'] ==
                                'free') {
                              itemColor = Color(0xFFFFAA00);
                              itemPriceText =
                                  eventByCategoryList[i]['ticket_type']['name'];
                            } else if (eventByCategoryList[i]['ticket_type']
                                    ['type'] ==
                                'free_limited') {
                              if (eventByCategoryList[i]['ticket']
                                      ['availableTicketStatus'] ==
                                  '1') {
                                itemColor = Color(0xFFFFAA00);
                                itemPriceText = eventByCategoryList[i]
                                    ['ticket_type']['name'];
                              } else if (eventByCategoryList[i]['ticket']
                                      ['salesStatus'] ==
                                  'endSales') {
                                itemColor = Color(0xFF8E1E2D);
                                if (eventByCategoryList[i]['status'] ==
                                    'ended') {
                                  itemPriceText = 'EVENT HAS ENDED';
                                }
                                itemPriceText = 'SALES ENDED';
                              } else {
                                itemColor = Color(0xFF8E1E2D);
                                itemPriceText = 'SOLD OUT';
                              }
                            }
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: RouteSettings(name: 'EventDetails'),
                                        builder: (BuildContext context) =>
                                            EventDetailsConstructView(
                                                id: eventByCategoryList[i]
                                                    ['id'])));
                              },
                              child: new LatestEventItem(
                                image: eventByCategoryList[i]['picture'],
                                title: eventByCategoryList[i]['name'],
                                location: eventByCategoryList[i]['address'],
                                itemColor: itemColor,
                                itemPrice: itemPriceText,
                                type: eventByCategoryList[i]['ticket_type']
                                    ['type'],
                                isAvailable: eventByCategoryList[i]['ticket']
                                    ['availableTicketStatus'],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> fetchUserByCollectionId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final latestEventApi = BaseApi().apiUrl +
        '/collections/user?X-API-KEY=$API_KEY&id=${widget.categoryId}';

    print(latestEventApi);

    setState(() {
      isLoading = true;
    });

    final response = await http.get(latestEventApi, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': preferences.getString('Session')
    });

    print(response.body);

    return response;
  }

  Future fetchCategoryById() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final latestEventApi = BaseApi().apiUrl +
        '/collections/event?X-API-KEY=$API_KEY&id=${widget.categoryId}&page=1';

    print(latestEventApi);

    setState(() {
      isLoading = true;
    });

    final response = await http.get(latestEventApi, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': preferences.getString('Session')
    });

    print(response.body);
    var extractedData = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        eventByCategoryList = extractedData['data'];
      });
    } else {
      if (extractedData['desc'] == 'Event Not Found') {
        setState(() {
          isLoading = false;
          errReasonWidget = EmptyState(
            emptyImage: 'assets/drawable/event_empty_state.png',
            reasonText: 'No Event Found',
          );
        });
      }
    }
  }
}
