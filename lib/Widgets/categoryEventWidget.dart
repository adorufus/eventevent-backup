import 'dart:convert';

import 'package:eventevent/Widgets/CategoryPage.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventevent/helper/ClevertapHandler.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryEventWidget extends StatefulWidget {
  final isRest;

  const CategoryEventWidget({Key key, this.isRest}) : super(key: key);
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
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    mappedCategoryData = categoryEventData?.map((categoryData) {
          return categoryData == null
              ? HomeLoadingScreen().categoryLoading()
              : Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: (){
                        ClevertapHandler.logCategoryView(categoryData['name']);
                        Navigator.push(context, MaterialPageRoute(settings: RouteSettings(name: 'CategoryList'), builder: (context) => CategoryPage(categoryId: categoryData['id'],)));
                      },
                        child: SizedBox(
                            height: ScreenUtil.instance.setWidth(85),
                            width: ScreenUtil.instance.setWidth(80),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(bottom: 20),
                                    width: ScreenUtil.instance.setWidth(41.50),
                                    height: ScreenUtil.instance.setWidth(40.50),
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
                                            image: CachedNetworkImageProvider(
                                          categoryData['logo'],
                                        ))),
                                  ),
                                  SizedBox(height: ScreenUtil.instance.setWidth(9)),
                                  Text(
                                    categoryData['name'],
                                    style: TextStyle(
                                        fontSize: ScreenUtil.instance.setSp(10), color: Color(0xFF8A8A8B)),
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
      height: ScreenUtil.instance.setWidth(220),
      padding: EdgeInsets.symmetric(horizontal: 0),
      width: MediaQuery.of(context).size.width,
      child: categoryEventData == null ? HomeLoadingScreen().categoryLoading() : ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Container(
                  width: ScreenUtil.instance.setWidth(800),
                  height: ScreenUtil.instance.setWidth(220),
                  child: Wrap(
                      direction: Axis.horizontal, children: mappedCategoryData),
                )
              ],
            ),
    );
  }

  Future fetchCategoryEvent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    

    String baseUrl = '';
    Map<String, String> headers;

    if (widget.isRest) {
      baseUrl = BaseApi().restUrl;
      headers = {
        'Authorization': AUTHORIZATION_KEY,
        'signature': SIGNATURE,
      };
    } else {
      baseUrl = BaseApi().apiUrl;
      headers = {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session')
      };
    }

    final categoryApi =
        baseUrl + '/category/list?X-API-KEY=${API_KEY}&page=1';
    final response = await http.get(categoryApi, headers: headers);

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
