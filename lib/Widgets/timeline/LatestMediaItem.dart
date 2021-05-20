import 'package:eventevent/Widgets/timeline/MediaDetails.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LatestMediaItem extends StatefulWidget {
  final bool isVideo;
  final image;
  final title;
  final username;
  final userImage;
  final likeCount;
  final article;
  final commentCount;
  final youtube;
  final videoUrl;
  final mediaId;
  final isRest;
  final isLiked;

  const LatestMediaItem(
      {Key key,
      this.isVideo,
      this.image,
      this.title,
      this.username,
      this.userImage,
      this.likeCount,
      this.commentCount,
      this.youtube,
      this.videoUrl,
      this.article,
      this.mediaId,
      @required this.isRest,
      this.isLiked})
      : super(key: key);

  @override
  _LatestMediaItemState createState() => _LatestMediaItemState();
}

class _LatestMediaItemState extends State<LatestMediaItem> {
  int likeCount;
  List commentCount;
  bool isLiked;

  @override
  void initState() {
    setState(() {
      isLiked = widget.isLiked;
      commentCount = widget.commentCount;
      likeCount = widget.likeCount;
    });
    super.initState();
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
    // print(MediaQuery.of(context).size.width);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      height: ScreenUtil.instance.setWidth(110),
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 1.5)
      ], color: checkForContainerBackgroundColor(context), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil.instance.setWidth(167),
            decoration: BoxDecoration(
              image: widget.isVideo == false
                  ? null
                  : DecorationImage(
                      image: NetworkImage(widget.image), fit: BoxFit.cover),
              color: Color(0xFFB5B5B5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: widget.isVideo == false
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ProgressiveImage.assetNetwork(
                      placeholder: 'assets/grey-fade.jpg',
                      thumbnail: widget.image,
                      image: widget.image,
                      width: 223,
                      height: 259,
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white.withOpacity(.7),
                      size: 50,
                    ),
                  ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.userImage),
                      radius: 7,
                    ),
                    SizedBox(width: ScreenUtil.instance.setWidth(3)),
                    Text(
                      '@${widget.username}',
                      style: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(12),
                          color: Color(0xFF8A8A8B)),
                    ),
                  ]),
                  SizedBox(height: ScreenUtil.instance.setWidth(4)),
                  Container(
                    height: ScreenUtil.instance.setWidth(40),
                    width: ScreenUtil.instance.setWidth(150),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
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
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      spreadRadius: 1.5)
                                ]),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                      likeCount < 1 ? '' : likeCount.toString(),
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
                                        isRest: widget.isRest,
                                        username: widget.username,
                                        mediaTitle: widget.title,
                                        userPicture: widget.userImage,
                                        imageUri: widget.image,
                                        imageCount: 'img',
                                        mediaId: widget.mediaId,
                                        articleDetail: widget.article,
                                        autoFocus: true,
                                        isVideo: widget.isVideo,
                                        videoUrl: widget.videoUrl,
                                        youtubeUrl: widget.youtube)));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: commentCount.length < 1 ? 8 : 13),
                            height: ScreenUtil.instance.setWidth(30),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      spreadRadius: 1.5)
                                ]),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                      'assets/icons/icon_apps/comment.png',
                                      scale: 3.5,
                                      color: commentCount.length < 1
                                          ? Colors.grey
                                          : eventajaGreenTeal),
                                  SizedBox(
                                      width: ScreenUtil.instance.setWidth(
                                          commentCount.length < 1 ? 0 : 5)),
                                  Text(
                                      commentCount.length < 1
                                          ? ''
                                          : commentCount.length.toString(),
                                      style: TextStyle(
                                          color: Color(
                                              0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                                ]),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
          )
        ],
      ),
    );
  }

  Future<http.Response> doLove() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/media/love';

    final response = await http.post(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'id': widget.mediaId
    });

    return response;
  }
}
