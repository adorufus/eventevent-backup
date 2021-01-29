import 'package:eventevent/Widgets/Home/MiniDate.dart';
import 'package:eventevent/helper/FollowUnfollow.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'PopularEventWidget.dart';

class PeopleItem extends StatefulWidget {
  final image;
  final title;
  final username;
  final isVerified;
  final topPadding;
  final location;
  final isFollowing;
  final userId;
  final bool isInvite;
  final Color color;
  final followText;
  final Color followTextColor;
  final VoidCallback pressAction;

  const PeopleItem(
      {Key key,
      this.image,
      this.title,
      this.username,
      this.location,
      this.isVerified,
      this.topPadding,
      this.isFollowing,
      this.userId,
      this.pressAction,
      this.color,
      this.followText,
      this.followTextColor, this.isInvite = false})
      : super(key: key);

  @override
  _PeopleItemState createState() => _PeopleItemState();
}

class _PeopleItemState extends State<PeopleItem> {

  bool isFollowed;

  @override
  void initState() {
    super.initState();
    if(widget.isFollowing == '0'){
      setState((){
        isFollowed = false;
      });
    }else{
      setState((){
        isFollowed = true;
      });
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
    // print(MediaQuery.of(context).size.width);
    return Container(
      margin: EdgeInsets.only(
          left: 13, right: 13, top: widget.topPadding, bottom: 13),
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
          CircleAvatar(
            backgroundColor: Color(0xFFB5B5B5),
            backgroundImage: NetworkImage(widget.image),
            radius: 20,
          ),
          SizedBox(
            width: ScreenUtil.instance.setWidth(8.87),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    widget.isVerified == '1'
                        ? Container(
                            height: ScreenUtil.instance.setWidth(15),
                            width: ScreenUtil.instance.setWidth(15),
                            child:
                                Image.asset('assets/icons/icon_apps/verif.png'))
                        : Container(),
                    SizedBox(width: ScreenUtil.instance.setWidth(5)),
                    Container(
                      width: ScreenUtil.instance.setWidth(160),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(12)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(5)),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: ScreenUtil.instance.setWidth(3)),
                      Container(
                        width: ScreenUtil.instance.setWidth(160),
                          child: Text(
                        '@' + widget.username,
                        style: TextStyle(color: Color(0xFF8A8A8B), fontSize: ScreenUtil.instance.setSp(9)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: SizedBox(),),
          GestureDetector(
            onTap: () {

              if (isFollowed == false) {
                FollowUnfollow().follow(widget.userId);
                setState(() {
                  isFollowed = true;
                });
              } else {
                FollowUnfollow().unfollow(widget.userId);
                setState(() {
                  isFollowed = false;
                });
              }
            },
            child: widget.isInvite == true ? Icon(Icons.check, color: widget.color) : Container(
              height: ScreenUtil.instance.setWidth(32.93),
              width: ScreenUtil.instance.setWidth(82.31),
              decoration: BoxDecoration(
                  border: Border.all(
                    width: ScreenUtil.instance.setWidth(1),
                    color: Color(0xFF55B9E5),
                  ),
                  borderRadius: BorderRadius.circular(30),
                  color: isFollowed == false ? Color(0xFFFFFFFF) : Color(0xFF55B9E5)),
              child: Center(
                  child: Text(isFollowed == false ? 'Follow' : 'Following',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(10),
                        color: isFollowed == false ? Color(0xFF55B9E5) : Color(0xFFFFFFFF),
                      ))),
            ),
          )
        ],
      ),
    );
  }
}
