import 'package:eventevent/Widgets/Home/MiniDate.dart';
import 'package:flutter/material.dart';
import 'PopularEventWidget.dart';

class LatestEventItem extends StatelessWidget {
  final image;
  final title;
  final username;
  final location;
  final Color itemColor;
  final String itemPrice;
  final type;
  final isAvailable;

  const LatestEventItem(
      {Key key, this.image, this.title, this.username, this.location, this.itemColor, this.itemPrice, this.type, this.isAvailable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return Container(
      margin: EdgeInsets.only(left: 13, right:13, top: 13),
      height: 150.18,
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 1.5)
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: <Widget>[
          Container(
            width: 100.19,
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: NetworkImage(image), fit: BoxFit.fill),
              color: Color(0xFFB5B5B5),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 19.35, top: 15.66, right: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MiniDate(),
                SizedBox(height: 7),
                Container(
                  width: MediaQuery.of(context).size.width - 146,
                  height: 20,
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 10,
                        width: 10,
                        child: Image.asset('assets/icons/icon_apps/location.png'),
                      ),
                      SizedBox(width: 3),
                      Container(
                          width: 200 - 20.37,
                          child: Text(
                            location,
                            style:
                                TextStyle(color: Color(0xFF8A8A8B), fontSize: 8),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 28,
                  width: 133,
                  decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: itemColor.withOpacity(0.4),
                            blurRadius: 2,
                            spreadRadius: 1.5)
                      ],
                      color: itemColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Center(
                      child: Text(
                    type == 'paid' || type == 'paid_seating' ? isAvailable == '1' ? 'Rp. ' + itemPrice.toUpperCase() + ',-' : itemPrice.toUpperCase() : itemPrice.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
