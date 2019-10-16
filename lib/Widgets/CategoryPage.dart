import 'dart:convert';

import 'package:eventevent/Widgets/Home/LatestEventItem.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CategoryPage extends StatefulWidget {
  final categoryId;

  const CategoryPage({Key key, this.categoryId}) : super(key: key);
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List eventByCategoryList;

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
              title: Text('Category'),
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
        body: Container(
          child: eventByCategoryList == null
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
              : ListView.builder(
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
                        itemPriceText =
                            eventByCategoryList[i]['ticket']['cheapestTicket'];
                      } else {
                        if (eventByCategoryList[i]['ticket']['salesStatus'] ==
                            'comingSoon') {
                          itemColor = Color(0xFF34B323).withOpacity(0.3);
                          itemPriceText = 'COMING SOON';
                        } else if (eventByCategoryList[i]['ticket']['salesStatus'] ==
                          'endSales') {
                        itemColor = Color(0xFF8E1E2D);
                        if(eventByCategoryList[i]['status'] == 'ended'){
                          itemPriceText = 'EVENT HAS ENDED';
                        }
                        itemPriceText = 'SALES ENDED';
                      }else {
                          itemColor = Color(0xFF8E1E2D);
                          itemPriceText = 'SOLD OUT';
                        }
                      }
                    } else if (eventByCategoryList[i]['ticket_type']['type'] ==
                        'no_ticket') {
                      itemColor = Color(0xFFA6A8AB);
                      itemPriceText = 'NO TICKET';
                    } else if (eventByCategoryList[i]['ticket_type']['type'] ==
                        'on_the_spot') {
                      itemColor = Color(0xFF652D90);
                      itemPriceText =
                          eventByCategoryList[i]['ticket_type']['name'];
                    } else if (eventByCategoryList[i]['ticket_type']['type'] ==
                        'free') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText =
                          eventByCategoryList[i]['ticket_type']['name'];
                    } else if (eventByCategoryList[i]['ticket_type']['type'] ==
                        'free') {
                      itemColor = Color(0xFFFFAA00);
                      itemPriceText =
                          eventByCategoryList[i]['ticket_type']['name'];
                    } else if (eventByCategoryList[i]['ticket_type']['type'] ==
                        'free_limited') {
                      if (eventByCategoryList[i]['ticket']
                              ['availableTicketStatus'] ==
                          '1') {
                        itemColor = Color(0xFFFFAA00);
                        itemPriceText =
                            eventByCategoryList[i]['ticket_type']['name'];
                      } else if (eventByCategoryList[i]['ticket']['salesStatus'] ==
                          'endSales') {
                        itemColor = Color(0xFF8E1E2D);
                        if(eventByCategoryList[i]['status'] == 'ended'){
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
                                builder: (BuildContext context) =>
                                    EventDetailsConstructView(
                                        id: eventByCategoryList[i]['id'])));
                      },
                      child: new LatestEventItem(
                        image: eventByCategoryList[i]['picture_timeline'],
                        title: eventByCategoryList[i]['name'],
                        location: eventByCategoryList[i]['address'],
                        itemColor: itemColor,
                        itemPrice: itemPriceText,
                        type: eventByCategoryList[i]['ticket_type']['type'],
                        isAvailable: eventByCategoryList[i]['ticket']
                            ['availableTicketStatus'],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future fetchCategoryById() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final latestEventApi = BaseApi().apiUrl +
        '/event/category?X-API-KEY=$API_KEY&category=${widget.categoryId}&page=1';

    print(latestEventApi);

    final response = await http.get(latestEventApi, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': preferences.getString('Session')
    });

    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        eventByCategoryList = extractedData['data'];
      });
    }
  }
}
