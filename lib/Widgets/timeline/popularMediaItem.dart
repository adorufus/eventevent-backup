import 'package:eventevent/Widgets/timeline/MediaDetails.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MediaItem extends StatefulWidget {
  final bool isVideo;
  final image;
  final title;
  final username;
  final userPicture;
  final int imageIndex;
  final articleDetail;
  final mediaId;
  final likeCount;
  final commentCount;

  const MediaItem(
      {Key key,
      this.isVideo,
      this.image,
      this.title,
      this.username,
      this.userPicture,
      this.imageIndex,
      this.articleDetail,
      this.mediaId,
      this.likeCount,
      this.commentCount})
      : super(key: key);

  @override
  _MediaItemState createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  int likeCount;
  bool isLiked;
  List commentCount;

  @override
  void initState() {
    super.initState();

    setState(() {
      commentCount = widget.commentCount;
      likeCount = widget.likeCount;
      isLiked = false;
    });
  }

  @override
  Widget build(BuildContext context) { 
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    print(MediaQuery.of(context).size.width);
    
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
            Container(
              height: ScreenUtil.instance.setWidth(146),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(widget.image), fit: BoxFit.cover),
                  color: Color(0xFFB5B5B5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )),
              child: widget.isVideo == false
                  ? Container()
                  : Center(
                      child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white.withOpacity(.7),
                      size: 50,
                    )),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                  height: ScreenUtil.instance.setWidth(110),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                                backgroundImage:
                                    NetworkImage(widget.userPicture),
                                radius: 7),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(2.68),
                            ),
                            Container(
                                width: ScreenUtil.instance.setWidth(125),
                                child: Text(
                                  '@' + widget.username.toString(),
                                  style: TextStyle(
                                      color: Color(0xFF8A8A8B), fontSize: ScreenUtil.instance.setSp(12)),
                                )),
                            Text(
                              '19 - 08 - 2019',
                              style: TextStyle(
                                  fontSize: 8, color: Color(0xFF8A8A8B)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(4),
                        ),
                        Container(
                            height: ScreenUtil.instance.setWidth(40),
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(15), fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(3),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isLiked == false) {
                                      likeCount += 1;
                                      isLiked = true;
                                      doLove().then((response) {
                                        print(response.statusCode);
                                        print(response.body);
                                        if (response.statusCode == 200) {}
                                      });
                                    } else {
                                      likeCount -= 1;
                                      isLiked = false;
                                      doLove().then((response) {
                                        if (response.statusCode == 200) {}
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: likeCount < 1 ? 8 : 13),
                                  height: ScreenUtil.instance.setWidth(30),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 2,
                                            spreadRadius: 1.5)
                                      ]),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/icons/icon_apps/love.png',
                                          color: likeCount < 1
                                              ? Colors.grey
                                              : isLiked == false
                                                  ? Colors.grey
                                                  : Colors.red,
                                          scale: 3.5,
                                        ),
                                        SizedBox(width: likeCount < 1 ? 0 : 5),
                                        Text(
                                            likeCount < 1
                                                ? ''
                                                : likeCount.toString(),
                                            style: TextStyle(
                                                color: Color(
                                                    0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                                      ]),
                                ),
                              ),
                              SizedBox(width: ScreenUtil.instance.setWidth(12)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MediaDetails(
                                                username: widget.username,
                                                mediaTitle: widget.title,
                                                userPicture: widget.userPicture,
                                                imageUri: widget.image,
                                                imageCount: 'img' +
                                                    widget.imageIndex
                                                        .toString(),
                                                articleDetail:
                                                    widget.articleDetail,
                                                autoFocus: true,
                                              )));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 13),
                                  height: ScreenUtil.instance.setWidth(30),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 2,
                                            spreadRadius: 1.5)
                                      ]),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/icons/icon_apps/comment.png',
                                          scale: 3.5,
                                        ),
                                        SizedBox(width: ScreenUtil.instance.setWidth(5)),
                                        Text(commentCount.length.toString(),
                                            style: TextStyle(
                                                color: Color(
                                                    0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          ],
        ));
  }

  Future<http.Response> doLove() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/media/love';

    final response = await http.post(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'id': widget.mediaId
    });

    return response;
  }
}
