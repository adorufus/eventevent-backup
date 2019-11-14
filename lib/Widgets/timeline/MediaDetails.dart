import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:googleapis/docs/v1.dart' as prefix0;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;

class MediaDetails extends StatefulWidget {
  final username;
  final imageUri;
  final articleDetail;
  final mediaTitle;
  final imageCount;
  final userPicture;
  final autoFocus;
  final isVideo;
  final youtubeUrl;
  final videoUrl;
  final mediaId;

  const MediaDetails(
      {Key key,
      this.username,
      this.imageUri,
      this.articleDetail,
      this.mediaTitle,
      this.imageCount,
      this.userPicture,
      this.autoFocus,
      this.isVideo,
      this.youtubeUrl: 'https://test.com/',
      this.videoUrl,
      this.mediaId})
      : super(key: key);

  @override
  _MediaDetailsState createState() => _MediaDetailsState();
}

class _MediaDetailsState extends State<MediaDetails> {
  YoutubePlayerController ytController;

  VideoPlayerController videoPlayerController;

  ChewieController chewieController;

  TextEditingController textEditingController = new TextEditingController();

  String videoId = '';

  bool isLoading = false;

  List commentList;

  @override
  void initState() {
    if (widget.videoUrl == null) {
      videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl == null
          ? 'https://www.youtube.com/watch?v=6XNN6KFzLnE'
          : widget.youtubeUrl);
      ytController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: true,
          ));
    }

    videoPlayerController = VideoPlayerController.network(
        widget.videoUrl == null ? '' : widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });

    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 3 / 2,
        autoPlay: true,
        looping: false,
        fullScreenByDefault: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 65,
          padding: EdgeInsets.symmetric(horizontal: 13),
          color: Colors.white,
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/icons/icon_apps/arrow.png',
                scale: 5.5,
                alignment: Alignment.centerLeft,
              ),
            ),
            title: Text(widget.mediaTitle),
            centerTitle: true,
            textTheme: TextTheme(
                title: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            )),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  controller: textEditingController,
                  autofocus: widget.autoFocus,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'Add a comment..',
                      suffix: GestureDetector(
                        onTap: () {
                          postComment(
                                  widget.mediaId, textEditingController.text)
                              .then((response) {
                            var extractedData = json.decode(response.body);

                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              print(response.body);
                              isLoading = false;
                              print('****Comment Posted!*****');
                              setState(() {});
                            } else {
                              isLoading = false;
                              print(response.body);
                              print('****Comment Failed****');
                              print('reason: ${extractedData['desc']}');
                            }
                          }).catchError((e) {
                            isLoading = false;
                            print('****Comment Failed****');
                            print('reason: ' + e.toString());
                          });
                        },
                        child: Container(
                            child: Text(
                          'Send',
                          style: TextStyle(
                              color: eventajaGreenTeal,
                              fontWeight: FontWeight.bold),
                        )),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          widget.isVideo == true
              ? videoType()
              : Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Color(0xff8a8a8b),
                      image: DecorationImage(
                          image: NetworkImage(widget.imageUri),
                          fit: BoxFit.fill)),
                ),
          SizedBox(
            height: 15,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                    backgroundImage: NetworkImage(widget.userPicture),
                    radius: 15),
                SizedBox(
                  width: 5,
                ),
                Container(
                    width: MediaQuery.of(context).size.width - 217.7,
                    child: Text(
                      '@' + widget.username.toString(),
                      style: TextStyle(color: Color(0xFF8A8A8B), fontSize: 14),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 13),
            child: Html(
              data: widget.articleDetail,
              onLinkTap: (url) {
                print('loading..');
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.black,
          ),
          Text(
            'Comments',
            style: TextStyle(
                color: Color(0xff8a8a8b),
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Container(
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder(
              future: getCommentList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.none &&
                    snapshot.hasData == null) {
                  //print('project snapshot data is: ${projectSnap.data}');
                  return Container();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  isLoading = true;
                } else {
                  isLoading = false;
                }
                if (snapshot.data == null) {
                  print('loading');
                } else {
                  // dataLength = snapshot.data['data'].length;
                  print(snapshot.data);
                  commentList = snapshot.data['data']['comment'];
                }

                if(snapshot.hasError){
                  print(snapshot.error.toString());
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: commentList == null ? 0 : commentList.length,
                  itemBuilder: (context, i){
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: commentList[i]['photo'],),
                      title: Text(commentList[i]['fullName'] + commentList[i]['lastName']),
                      subtitle: Text(commentList[i]['comment']),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      // Hero(
      //   tag: widget.imageCount,
      //   child: ListView(
      //     children: <Widget>[
      //       Container(
      //         height: 200,
      //         width: MediaQuery.of(context).size.width,
      //         decoration: BoxDecoration(
      //             color: Color(0xff8a8a8b),
      //             image: DecorationImage(
      //                 image: NetworkImage(widget.imageUri), fit: BoxFit.fill)),
      //       ),
      //       SizedBox(
      //         height: 15,
      //       ),
      //       Container(
      //         margin: EdgeInsets.symmetric(horizontal: 13),
      //         child: Row(
      //           children: <Widget>[
      //             CircleAvatar(
      //                 backgroundImage: NetworkImage(widget.userPicture),
      //                 radius: 15),
      //             SizedBox(
      //               width: 5,
      //             ),
      //             Container(
      //                 width: MediaQuery.of(context).size.width - 217.7,
      //                 child: Text(
      //                   '@' + widget.username.toString(),
      //                   style: TextStyle(color: Color(0xFF8A8A8B), fontSize: 14),
      //                 )),
      //           ],
      //         ),
      //       ),
      //       SizedBox(
      //         height: 15,
      //       ),
      //       Container(
      //         margin: EdgeInsets.symmetric(horizontal: 13),
      //         child: Html(
      //           data: widget.articleDetail,
      //           onLinkTap: (url) {
      //             print('loading..');
      //           },
      //         ),
      //       ),
      //       SizedBox(
      //         height: 10,
      //       ),
      //       Divider(
      //         color: Colors.black,
      //       )
      //     ],
      //   ),
      // ),
    );
  }

  Widget videoType() {
    Widget typeWidget = Container();

    if (widget.videoUrl == null) {
      typeWidget = YoutubePlayer(
        controller: ytController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: eventajaGreenTeal,
      );
    } else {
      typeWidget = Chewie(
        controller: chewieController,
      );
    }
    return typeWidget;
  }

  Future getCommentList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/media/detail?X-API-KEY=$API_KEY&id=${widget.mediaId}';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    var extractedData = json.decode(response.body);

    return extractedData;
  }

  Future<http.Response> postComment(String mediaId, String comment) async {
    setState(() {
      isLoading = true;
    });
    print('****Posting Comment...*****');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/media/comment';

    final response = await http.post(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'media_id': mediaId,
      'comment': comment,
      'comment_id': ''
    });

    return response;
  }
}
