import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CollectionItem extends StatefulWidget {
  final image;
  final profileImage;
  final title;
  final username;
  final Color itemColor;
  final String itemPrice;
  final isAvailable;

  const CollectionItem(
      {Key key,
      this.image,
      this.title,
      this.username,
      this.itemColor,
      this.itemPrice,
      this.isAvailable, this.profileImage})
      : super(key: key);
  @override
  _CollectionItemState createState() => _CollectionItemState();
}

class _CollectionItemState extends State<CollectionItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 13),
      height: ScreenUtil.instance.setWidth(130.6),
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 1.5)
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil.instance.setWidth(130.6),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(widget.image), fit: BoxFit.fill),
              color: Color(0xFFB5B5B5),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 14, top: 15.66, right: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 8,
                      backgroundImage: NetworkImage(widget.profileImage),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 146,
                      height: ScreenUtil.instance.setWidth(20),
                      child: Text(
                        widget.username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil.instance.setSp(12)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 146,
                  height: ScreenUtil.instance.setWidth(20),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(16)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                  ),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  height: ScreenUtil.instance.setWidth(28),
                  width: ScreenUtil.instance.setWidth(130),
                  decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: widget.itemColor.withOpacity(0.4),
                            blurRadius: 2,
                            spreadRadius: 1.5)
                      ],
                      color: widget.itemColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Center(
                      child: Text(
                    widget.itemPrice.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.instance.setSp(14),
                        fontWeight: FontWeight.bold),
                  )),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
