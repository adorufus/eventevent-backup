import 'package:eventevent/Widgets/Home/PopularEventWidget.dart';
import 'package:eventevent/Widgets/merch/MerchDetails.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redux/redux.dart';
import 'package:eventevent/Models/MerchBannerModel.dart';
import 'package:eventevent/Redux/Reducers/BannerReducers.dart';
import 'package:eventevent/Widgets/merch/Banner.dart';
import 'MerchItem.dart';
import 'MerchCollection.dart';

class MerchDashboard extends StatefulWidget {
  @override
  _MerchDashboardState createState() => _MerchDashboardState();
}

class _MerchDashboardState extends State<MerchDashboard> {
  Store<List<MerchBannerModel>> bannerStore = new Store<List<MerchBannerModel>>(
      merchBannerReducers,
      initialState: new List());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    width: ScreenUtil.instance.setWidth(95),
                    child: Hero(
                      tag: 'eventeventlogo',
                      child: Image.asset(
                        'assets/drawable/emerch-logo.png',
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
                onTap: () {},
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
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                BannerWidget(),
                titleText('Collections',
                    'Check out our hand picked collection bellow'),
                collectionImage(),
                titleText('Popular Merch', 'Lorem Ipsum Dolor'),
                merchItem(),
                titleText('Lorem Ipsum', 'Lorem Ipsum Dolor Sit Amet'),
                merchItem(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget titleText(String mainTitle, String subTitle) {
    return Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                mainTitle,
                style: TextStyle(
                    color: eventajaBlack,
                    fontSize: ScreenUtil.instance.setSp(19),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(5)),
          Text(subTitle,
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (BuildContext context, i) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MerchCollection(),
                ),
              );
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
                      child: Image.asset(
                        'assets/grey-fade.jpg',
                        fit: BoxFit.cover,
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

  Widget merchItem() {
    return Container(
        height: ScreenUtil.instance.setWidth(340),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (BuildContext context, i) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MerchDetails()));
                },
                child: MerchItem(
                  imageUrl: 'assets/grey-fade.jpg',
                  title: 'lorem ipsum',
                  color: eventajaGreenTeal,
                  price: '50000',
                  merchantName: 'john doe',
                ),
              );
            }));
  }
}
