import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventevent/Widgets/Home/MiniDate.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progressive_image/progressive_image.dart';

class PopularEventWidget extends StatelessWidget {
  final imageUrl;
  final title;
  final String location;
  final String price;
  final Color color;
  final type;
  final isAvailable;
  final isGoing;
  final DateTime date;
  final isHybridEvent;

  const PopularEventWidget(
      {Key key,
      this.imageUrl,
      this.title,
      this.location,
      this.price,
      this.color,
      this.type,
      this.isAvailable,
      this.date,
      this.isGoing,
      this.isHybridEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);

    // print(MediaQuery.of(context).size.width);

    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 13, top: 8, bottom: 8, right: 3),
          width: ScreenUtil.instance.setWidth(172),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            // boxShadow: <BoxShadow>[
            //   BoxShadow(
            //       color: Colors.black.withOpacity(0.1),
            //       blurRadius: 2,
            //       spreadRadius: 1.5)
            // ]
          ),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                              child: Container(
                  height: ScreenUtil.instance.setWidth(259),
                  decoration: BoxDecoration(
                      color: Color(0xFFB5B5B5).withOpacity(.5),
                      // image: DecorationImage(
                      //     image: CachedNetworkImageProvider(imageUrl),
                      //     fit: BoxFit.cover),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            spreadRadius: 2)
                      ]),
                      child: ProgressiveImage.assetNetwork(placeholder: 'asse'
                          'ts/grey-fade.jpg', thumbnail: imageUrl, image:
                      imageUrl, width: 200 * 1.5, height: 259 * 1.5, fit: BoxFit
                          .cover, thumbnailScale: 2,),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 1, top: 15),
                child: Column(
                  children: <Widget>[
                    Container(
                        width: ScreenUtil.instance.setWidth(300),
                        child: Text(
                          title,
                          // overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 2,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              fontWeight: FontWeight.bold),
                        )),
                    // SizedBox(height: ScreenUtil.instance.setWidth(4)),
                    // Row(
                    //   children: <Widget>[
                    //     Image.asset(
                    //       'assets/icons/icon_apps/location.png',
                    //       scale: 7,
                    //     ),
                    //     SizedBox(width: ScreenUtil.instance.setWidth(3)),
                    //     Container(
                    //       width: ScreenUtil.instance.setWidth(112),
                    //       child: Text(
                    //           location.contains('\n\n')
                    //               ? 'location not set'
                    //               : location,
                    //           overflow: TextOverflow.ellipsis,
                    //           style: TextStyle(
                    //               fontSize: ScreenUtil.instance.setSp(13))),
                    //     )
                    //   ],
                    // ),
                  ],
                ),
              ),
              // SizedBox(height: ScreenUtil.instance.setWidth(11)),
              // Flexible(
              //   child: Align(
              //     alignment: Alignment.bottomCenter,
              //     child: Container(
              //       height: ScreenUtil.instance.setWidth(28),
              //       decoration: BoxDecoration(boxShadow: <BoxShadow>[
              //         BoxShadow(
              //             color: color.withOpacity(0.4),
              //             blurRadius: 2,
              //             spreadRadius: 1.5)
              //       ], color: color, borderRadius: BorderRadius.circular(15)),
              //       child: Center(
              //           child: Text(
              //         price.toUpperCase(),
              //         style: TextStyle(
              //             color: Colors.white,
              //             fontSize: ScreenUtil.instance.setSp(14),
              //             fontWeight: FontWeight.bold),
              //       )),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        // Positioned(
        //   top: ScreenUtil.instance.setWidth(220),
        //   left: ScreenUtil.instance.setWidth(21),
        //   child: MiniDate(
        //     date: date,
        //   ),
        // ),
        isHybridEvent == 'streamOnly' ? Positioned(
          top: ScreenUtil.instance.setWidth(24),
          left: ScreenUtil.instance.setWidth(20),
          child: Image.asset('assets/icons/icon_apps/LivestreamTagIcon.png', scale: 26)
        ): Container()
      ],
    );
  }
}
