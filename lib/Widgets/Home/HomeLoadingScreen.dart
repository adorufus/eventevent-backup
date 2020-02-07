import 'dart:convert';

import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class HomeLoadingScreen {
  static List<dynamic> categoryCount = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 1, 1, 1, 1, 1, 1, 1, 1];

  List<Widget> mappedCategoryData = categoryCount?.map((categoryData) {
      return SizedBox(
        height: ScreenUtil.instance.setWidth(85),
        width: ScreenUtil.instance.setWidth(80),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                enabled: true,
                child: Container(
                  padding: EdgeInsets.only(bottom: 20),
                  width: ScreenUtil.instance.setWidth(41.50),
                  height: ScreenUtil.instance.setWidth(40.50),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            spreadRadius: 1.5,
                            offset: Offset(0.0, 0.0))
                      ],
                      image: DecorationImage(
                          image: AssetImage(
                        'assets/grey-fade.jpg',
                      ))),
                ),
              ),
              SizedBox(height: ScreenUtil.instance.setWidth(9)),
              Text(
                '',
                style: TextStyle(
                    fontSize: ScreenUtil.instance.setSp(10),
                    color: Color(0xFF8A8A8B)),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      );
    })?.toList() ?? [];

  Widget collectionLoading() {

    return Container(
      height: ScreenUtil.instance.setWidth(90),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (BuildContext context, i) {
          return new Container(
            width: ScreenUtil.instance.setWidth(150),
            margin:
                i == 0 ? EdgeInsets.only(left: 13) : EdgeInsets.only(left: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: ScreenUtil.instance.setWidth(70),
                  width: ScreenUtil.instance.setWidth(150),
                  decoration: BoxDecoration(
                      color: Color(0xff8a8a8b),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1.5)
                      ]),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    enabled: true,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        'assets/grey-fade.jpg',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget categoryLoading() {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 25,
        itemBuilder: (context, i) {
          return Container(
            width: ScreenUtil.instance.setWidth(800),
            height: ScreenUtil.instance.setWidth(220),
            child: Wrap(
              children: mappedCategoryData,
            ),
          );
        });
  }

  Widget eventLoading() {
    return Container(
      height: ScreenUtil.instance.setWidth(300),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (BuildContext context, i) {
          return Container(
            margin: EdgeInsets.only(left: 13, top: 8, bottom: 8, right: 3),
            width: ScreenUtil.instance.setWidth(150),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      spreadRadius: 1.5)
                ]),
            child: Column(
              children: <Widget>[
                Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  enabled: true,
                  child: Container(
                    height: ScreenUtil.instance.setWidth(225),
                    decoration: BoxDecoration(
                        color: Color(0xFFB5B5B5),
                        image: DecorationImage(
                            image: AssetImage('assets/grey-fade.jpg'),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        )),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 7, top: 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                          width: ScreenUtil.instance.setWidth(133),
                          child: Text(
                            '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(15),
                                fontWeight: FontWeight.bold),
                          )),
                      SizedBox(height: ScreenUtil.instance.setWidth(4)),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(11)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget peopleLoading() {
    return Container(
      height: ScreenUtil.instance.setWidth(80),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (BuildContext context, i) {
          return Container(
            padding:
                i == 0 ? EdgeInsets.only(left: 13) : EdgeInsets.only(left: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  enabled: true,
                  child: Container(
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
                          image: AssetImage('assets/grey-fade.jpg'),
                          fit: BoxFit.fill,
                        )),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget bannerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      enabled: true,
      child: Container(
        width: MediaQuery.of(context).devicePixelRatio * 2645.0,
        height: ScreenUtil.instance.setWidth(200),
        margin: EdgeInsets.only(left: 13, right: 13, bottom: 15, top: 13),
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
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            'assets/grey-fade.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget mediaLoading() {
    return Container(
      height: ScreenUtil.instance.setWidth(247),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, i) {
          return Container(
              margin: EdgeInsets.only(left: 13, top: 8, bottom: 8, right: 0),
              height: ScreenUtil.instance.setWidth(247),
              width: ScreenUtil.instance.setWidth(223),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        spreadRadius: 1.5)
                  ]),
              child: Stack(
                children: <Widget>[
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    enabled: true,
                    child: Container(
                      height: ScreenUtil.instance.setWidth(146),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/grey-fade.jpg'),
                              fit: BoxFit.cover),
                          color: Color(0xFFB5B5B5),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                        height: ScreenUtil.instance.setWidth(110),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(4),
                              ),
                              Container(
                                  height: ScreenUtil.instance.setWidth(40),
                                  child: Text(
                                    '',
                                    style: TextStyle(
                                        fontSize: ScreenUtil.instance.setSp(15),
                                        fontWeight: FontWeight.bold),
                                  )),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(3),
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[],
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                ],
              ));
        },
      ),
    );
  }
}
