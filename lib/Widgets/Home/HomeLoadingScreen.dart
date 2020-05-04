import 'dart:convert';

import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_placeholder_textlines/placeholder_lines.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class HomeLoadingScreen {
  static List<dynamic> categoryCount = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
  ];

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
      })?.toList() ??
      [];

  Widget followListLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, i) {
        return Container(
          margin: EdgeInsets.only(left: 13, right: 13, top: 13),
          padding:
              EdgeInsets.only(left: 8.87, right: 8.87, top: 8.87, bottom: 8.87),
          height: ScreenUtil.instance.setWidth(59.21),
          decoration: BoxDecoration(boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                spreadRadius: 1.5)
          ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                enabled: true,
                child: CircleAvatar(
                  backgroundColor: Color(0xFFB5B5B5),
                  backgroundImage: AssetImage('assets/grey-fade.jpg'),
                  radius: 20,
                ),
              ),
              SizedBox(
                width: ScreenUtil.instance.setWidth(8.87),
              ),
              Container(
                  width: 150,
                  child: PlaceholderLines(
                    count: 2,
                    color: Colors.grey,
                    align: TextAlign.left,
                    animate: true,
                    lineHeight: 10,
                  )),
              Expanded(
                child: SizedBox(),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                enabled: true,
                child: Container(
                  height: ScreenUtil.instance.setWidth(32.93),
                  width: ScreenUtil.instance.setWidth(82.31),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey.withOpacity(.5)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget basicSettingsLoading(BuildContext context, eventajaGreenTeal) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'BASIC SETTINGS',
          style: TextStyle(
              fontSize: ScreenUtil.instance.setSp(15),
              fontWeight: FontWeight.bold,
              color: Colors.grey),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        Container(
          width: MediaQuery.of(context).size.width / 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey, offset: Offset(1, 1), blurRadius: 2)
              ]),
          child: Padding(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Username',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: PlaceholderLines(
                        count: 1,
                        color: Colors.grey,
                        align: TextAlign.left,
                        animate: true,
                        lineHeight: 10,
                      )
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'First Name',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: PlaceholderLines(
                        count: 1,
                        color: Colors.grey,
                        align: TextAlign.left,
                        animate: true,
                        lineHeight: 10,
                      )
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Last Name',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: PlaceholderLines(
                        count: 1,
                        color: Colors.grey,
                        align: TextAlign.left,
                        animate: true,
                        lineHeight: 10,
                      )
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Date Of Birth',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: PlaceholderLines(
                        count: 1,
                        color: Colors.grey,
                        align: TextAlign.left,
                        animate: true,
                        lineHeight: 10,
                      )
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bio',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: PlaceholderLines(
                        count: 1,
                        color: Colors.grey,
                        align: TextAlign.left,
                        animate: true,
                        lineHeight: 10,
                      )
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget contactSettingsLoading(BuildContext context, eventajaGreenTeal) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'CONTACT SETTINGS',
          style: TextStyle(
              fontSize: ScreenUtil.instance.setSp(15),
              fontWeight: FontWeight.bold,
              color: Colors.grey),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        Container(
          width: MediaQuery.of(context).size.width / 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey, offset: Offset(1, 1), blurRadius: 2)
              ]),
          child: Padding(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Email',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: PlaceholderLines(
                        count: 1,
                        color: Colors.grey,
                        align: TextAlign.left,
                        animate: true,
                        lineHeight: 10,
                      )
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Phone',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: PlaceholderLines(
                        count: 1,
                        color: Colors.grey,
                        align: TextAlign.left,
                        animate: true,
                        lineHeight: 10,
                      )
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Website',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: PlaceholderLines(
                        count: 1,
                        color: Colors.grey,
                        align: TextAlign.left,
                        animate: true,
                        lineHeight: 10,
                      )
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget EditProfilePictureLoading(){
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      enabled: true,
      child: Container(
        height: ScreenUtil.instance.setWidth(200),
        width: ScreenUtil.instance.setWidth(200),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image:AssetImage('assets/white.png'),
                fit: BoxFit.cover)),
      ),
    );
  }

  Widget withdrawLoading(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Center(
                  child: Text(
                    'WITHDRAW AMOUNT',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.instance.setSp(18),
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(25),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      'Requested Amount',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil.instance.setSp(18),
                          color: Colors.black26),
                    ),
                    Container(
                      width: 80,
                      child: PlaceholderLines(
                        count: 1,
                        align: TextAlign.left,
                        lineHeight: 10,
                        color: Colors.grey,
                        animate: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      'Processing Fee',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil.instance.setSp(18),
                          color: Colors.black26),
                    ),
                    Container(
                      width: 80,
                      child: PlaceholderLines(
                        count: 1,
                        align: TextAlign.left,
                        lineHeight: 10,
                        color: Colors.grey,
                        animate: true,
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey,
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(15),
                ),
                Text(
                  'Amount will be transfered to your account',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.instance.setSp(16),
                      color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Container(
                  width: 100,
                  child: PlaceholderLines(
                    count: 1,
                    align: TextAlign.left,
                    lineHeight: 10,
                    color: Colors.grey,
                    animate: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(20)),
          Center(
            child: Text(
              'TRANSFER TO',
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.instance.setSp(18)),
            ),
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(20)),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  enabled: true,
                  child: Container(
                    height: ScreenUtil.instance.setWidth(50),
                    width: ScreenUtil.instance.setWidth(50),
                    child: Image.asset(
                      'assets/grey-fade.jpg',
                      scale: 2,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: 100,
                  child: PlaceholderLines(
                    count: 1,
                    align: TextAlign.center,
                    lineHeight: 10,
                    color: Colors.grey,
                    animate: true,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: 200,
                  child: PlaceholderLines(
                    count: 1,
                    align: TextAlign.center,
                    lineHeight: 10,
                    color: Colors.grey,
                    animate: true,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: 150,
                  child: PlaceholderLines(
                    count: 1,
                    align: TextAlign.center,
                    lineHeight: 10,
                    color: Colors.grey,
                    animate: true,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget myTicketLoading() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, i) {
          return Container(
            child: Container(
              margin: EdgeInsets.only(left: 13, right: 13, top: 13),
              height: ScreenUtil.instance.setWidth(150.18),
              decoration: BoxDecoration(boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    spreadRadius: 1.5)
              ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: <Widget>[
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    enabled: true,
                    child: Container(
                      width: ScreenUtil.instance.setWidth(100.19),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/grey-fade.jpg'),
                            fit: BoxFit.fill),
                        color: Color(0xFFB5B5B5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 19.35, top: 15.66, right: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: ScreenUtil.instance.setWidth(5)),
                        Container(
                          width: 200,
                          child: PlaceholderLines(
                            count: 3,
                            align: TextAlign.left,
                            lineHeight: 10,
                            color: Colors.grey,
                            animate: true,
                          ),
                        ),
                        SizedBox(height: ScreenUtil.instance.setWidth(15)),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          enabled: true,
                          child: Container(
                            height: ScreenUtil.instance.setWidth(28),
                            width: ScreenUtil.instance.setWidth(133),
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget timelineLoading() {
    return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, i) {
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
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300],
                                    highlightColor: Colors.grey[100],
                                    enabled: true,
                                    child: CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/grey-fade.jpg'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil.instance.setWidth(8),
                                  ),
                                  Container(
                                      width:
                                          ScreenUtil.instance.setWidth(200.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: 100,
                                            child: PlaceholderLines(
                                              count: 2,
                                              align: TextAlign.left,
                                              lineHeight: 10,
                                              color: Colors.grey,
                                              animate: true,
                                            ),
                                          ),
                                        ],
                                      )),
                                ]),
                          ],
                        ),
                        SizedBox(height: 15),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          enabled: true,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                    image: AssetImage('assets/grey-fade.jpg'),
                                    fit: BoxFit.cover)),
                            height: ScreenUtil.instance.setWidth(400),
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(),
                            Container(),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 11),
                              width: 200,
                              child: PlaceholderLines(
                                count: 2,
                                align: TextAlign.left,
                                lineHeight: 10,
                                color: Colors.grey,
                                animate: true,
                              ),
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                            // Container(
                            //   child: Image.asset('assets/btn_ticket/free-limited.png', scale: 7,),)
                            Container()
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ));
          ;
        });
  }

  Widget profileLoading(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 75),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(60),
          padding: EdgeInsets.symmetric(horizontal: 13),
          color: Colors.white,
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
          ),
        ),
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      enabled: true,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 28, vertical: 3),
                        height: ScreenUtil.instance.setWidth(110),
                        width: ScreenUtil.instance.setWidth(110),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5,
                                  offset: Offset(1, 1))
                            ],
                            image: DecorationImage(
                                image: AssetImage('assets/grey-fade.jpg'),
                                fit: BoxFit.cover)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'loading',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil.instance.setSp(17),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(4),
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'loading',
                              style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(12),
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(4),
                        ),
                        Container(
                          width: ScreenUtil.instance.setWidth(180),
                          child: Text(
                            'loading',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: ScreenUtil.instance.setSp(12)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(4),
                        ),
                        Text(
                          'loading',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil.instance.setSp(12)),
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(20),
                        ),
                        Container(
                          height: ScreenUtil.instance.setWidth(32.93),
                          width: ScreenUtil.instance.setWidth(82.31),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.grey[350]),
                        ),
                      ],
                    )
                  ],
                ),
                Container(
                  height: ScreenUtil.instance.setWidth(60.63),
                  margin: EdgeInsets.symmetric(horizontal: 13, vertical: 28),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1.5)
                      ]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

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
      },
    );
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
