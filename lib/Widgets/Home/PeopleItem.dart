import 'package:eventevent/Widgets/Home/MiniDate.dart';
import 'package:eventevent/helper/FollowUnfollow.dart';
import 'package:flutter/material.dart';
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
      this.followTextColor})
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
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return Container(
      margin: EdgeInsets.only(
          left: 13, right: 13, top: widget.topPadding, bottom: 13),
      padding:
          EdgeInsets.only(left: 8.87, right: 8.87, top: 8.87, bottom: 8.87),
      height: 59.21,
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
            width: 8.87,
          ),
          Container(
            width: MediaQuery.of(context).size.width - 175,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    widget.isVerified == '1'
                        ? Container(
                            height: 15,
                            width: 15,
                            child:
                                Image.asset('assets/icons/icon_apps/verif.png'))
                        : Container(),
                    SizedBox(width: 5),
                    Container(
                      width: 165,
                      child: Text(
                        widget.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 3),
                      Container(
                        width: 165,
                          child: Text(
                        '@' + widget.username,
                        style: TextStyle(color: Color(0xFF8A8A8B), fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            child: Container(
              height: 32.93,
              width: 82.31,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Color(0xFF55B9E5),
                  ),
                  borderRadius: BorderRadius.circular(30),
                  color: isFollowed == false ? Color(0xFFFFFFFF) : Color(0xFF55B9E5)),
              child: Center(
                  child: Text(isFollowed == false ? 'Follow' : 'Following',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: isFollowed == false ? Color(0xFF55B9E5) : Color(0xFFFFFFFF),
                      ))),
            ),
          )
        ],
      ),
    );
  }
}
