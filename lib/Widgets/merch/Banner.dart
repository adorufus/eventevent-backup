import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eventevent/Models/MerchBannerModel.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_indicator/page_indicator.dart';

class BannerWidget extends StatefulWidget {
  final bool loading;
  final List<MerchBannerModel> data;

  const BannerWidget({Key key, this.loading, this.data}) : super(key: key);
  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
            height: ScreenUtil.instance.setWidth(250),
            width: MediaQuery.of(context).size.width,
            child: CarouselSlider(
              height: ScreenUtil.instance.setWidth(250),
              items: widget.loading == false && widget.data.isNotEmpty
                  ? widget.data.map((data) {
                      return Container(
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
                          child: Image.network(
                            data.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList()
                  : [HomeLoadingScreen().bannerLoading(context)],
              enlargeCenterPage: false,
              initialPage: 0,
              autoPlay: true,
              aspectRatio: 2.0,
              viewportFraction: 1.0,
              onPageChanged: (index) {},
            )),
      ],
    );
  }
}
