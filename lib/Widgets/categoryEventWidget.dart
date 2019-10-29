import 'dart:convert';

import 'package:eventevent/Widgets/CategoryPage.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryEventWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CategoryEventWidget();
  }
}

class _CategoryEventWidget extends State<CategoryEventWidget> {
  var session;
  List categoryEventData;
  List<Widget> mappedCategoryData;

  @override
  void initState() {
    super.initState();
    if (!mounted) {
      return;
    } else {
      fetchCategoryEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    mappedCategoryData = categoryEventData?.map((categoryData) {
          return categoryData == null
              ? CircularProgressIndicator()
              : Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(settings: RouteSettings(name: 'CategoryList'), builder: (context) => CategoryPage(categoryId: categoryData['id'],)));
                      },
                        child: SizedBox(
                            height: 85,
                            width: 80,
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(bottom: 20),
                                    width: 41.50,
                                    height: 41.50,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 2,
                                              spreadRadius: 1.5,
                                              offset: Offset(0.0, 0.0))
                                        ],
                                        image: DecorationImage(
                                            image: NetworkImage(
                                          categoryData['logo'],
                                        ))),
                                  ),
                                  SizedBox(height: 9),
                                  Text(
                                    categoryData['name'],
                                    style: TextStyle(
                                        fontSize: 10, color: Color(0xFF8A8A8B)),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            )));
                  },
                );
        })?.toList() ??
        [];

    return Container(
      height: 220,
      padding: EdgeInsets.symmetric(horizontal: 0),
      width: MediaQuery.of(context).size.width,
      child: categoryEventData == null
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
          : ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Container(
                  width: 800,
                  height: 220,
                  child: Wrap(
                      direction: Axis.horizontal, children: mappedCategoryData),
                )
              ],
            ),
    );
  }

  Future fetchCategoryEvent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      session = preferences.getString('Session');
    });

    final categoryApi =
        BaseApi().apiUrl + '/category/list?X-API-KEY=${API_KEY}&page=1';
    final response = await http.get(categoryApi, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': session
    });

    print(response.body);

    if (response.statusCode == 200) {
      var extractedData = json.decode(response.body);
      if (!mounted) return;
      setState(() {
        categoryEventData = extractedData['data'];
        print(categoryEventData.length);
      });
    }
  }
}
