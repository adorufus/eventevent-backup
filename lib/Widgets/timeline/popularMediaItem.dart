import 'package:eventevent/Widgets/timeline/MediaDetails.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
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

  const MediaItem(
      {Key key,
      this.isVideo,
      this.image,
      this.title,
      this.username,
      this.userPicture, this.imageIndex, this.articleDetail})
      : super(key: key);

  @override
  _MediaItemState createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  int likeCount;
  bool isLiked;

  @override
  void initState() {
    super.initState();
    setState(() {
      likeCount = 0;
      isLiked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return Container(
        margin: EdgeInsets.only(left: 13, top: 8, bottom: 8, right: 0),
        height: 247,
        width: 223,
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
              height: 146,
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
                      child: Image.asset(
                      'assets/icons/icon_apps/play.png',
                      scale: 3,
                    )),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.97),
                  height: 110,
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
                              width: 2.68,
                            ),
                            Container(
                                width:
                                    MediaQuery.of(context).size.width - 217.7,
                                child: Text(
                                  '@' + widget.username.toString(),
                                  style: TextStyle(
                                      color: Color(0xFF8A8A8B), fontSize: 12),
                                )),
                            Text(
                              '19 - 08 - 2019',
                              style: TextStyle(
                                  fontSize: 8, color: Color(0xFF8A8A8B)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Container(
                            height: 40,
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: 3,
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  if (isLiked == false) {
                                    likeCount += 1;
                                    isLiked = true;
                                  } else {
                                    likeCount -= 1;
                                    isLiked = false;
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: likeCount < 1 ? 8 : 13),
                                  height: 30,
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
                              SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MediaDetails(
                                    username: widget.username,
                                    mediaTitle: widget.title,
                                    userPicture: widget.userPicture,
                                    imageUri: widget.image,
                                    imageCount: 'img' + widget.imageIndex.toString(),
                                    articleDetail: widget.articleDetail,
                                    autoFocus: true,
                                  )));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 13),
                                  height: 30,
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
                                        SizedBox(width: 5),
                                        Text('0',
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
}
