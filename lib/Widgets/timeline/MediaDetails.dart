import 'dart:convert';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_placeholder_textlines/placeholder_lines.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
  final isRest;

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
      this.youtubeUrl = 'https://test.com/',
      this.videoUrl,
      this.mediaId,
      this.isRest})
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
  String htmlMediaContent = "";

  bool isLoading = false;

  List commentList = [];
  Map mediaDetails = {};

  bool isError = false;
  String errorReason = '';

  void getData() {
    getMediaDetails().then((response) {
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          mediaDetails = extractedData['data'];
          commentList = mediaDetails['comment'];

          // List mediaContentList = mediaDetails['media_content'];

          // mediaContentList.map((data){

          // });

          print(commentList);
        });
      } else if (response.statusCode.toString().startsWith('4')) {
        errorReason = 'Sorry, something\'s went wrong :(';
        isError = true;
        setState(() {});
      } else if (response.statusCode.toString().startsWith('5')) {
        errorReason = 'An error occured with our server, will be fixed ASAP';
        isError = true;
        setState(() {});
      }
    }).timeout(Duration(seconds: 5), onTimeout: () {
      setState(() {
        isError = true;
        errorReason = 'Connection Timeout';
      });
    }).catchError((e) {});

    if (widget.isVideo == true) {
      setState(() {
        if (widget.videoUrl == null) {
          videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl == null
              ? 'https://www.youtube.com/watch?v=6XNN6KFzLnE'
              : widget.youtubeUrl);

          ytController = YoutubePlayerController(
              initialVideoId: videoId == null ? '' : videoId,
              flags: YoutubePlayerFlags(
                autoPlay: true,
              ));
        }
      });

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
    }
  }

  @override
  void initState() {
    getData();
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(65),
          padding: EdgeInsets.symmetric(horizontal: 13),
          color: Colors.white,
          child: AppBar(
            brightness: Brightness.light,
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
              fontSize: ScreenUtil.instance.setSp(14),
              color: Colors.black,
            )),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: widget.isRest == true
            ? GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginRegisterWidget()));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: ScreenUtil.instance.setWidth(70),
                  color: eventajaGreenTeal,
                  child: Center(
                      child: Text(
                    'Login First To Comment',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
              )
            : Container(
                height: ScreenUtil.instance.setWidth(70),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: Container(
                          decoration:
                              BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                                offset: Offset(0, -1),
                                blurRadius: 2,
                                color: Color(0xff8a8a8b).withOpacity(.2),
                                spreadRadius: 1.5)
                          ]),
                          child: TypeAheadFormField(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: textEditingController,
                              autofocus: widget.autoFocus,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(0)),
                                      borderSide: BorderSide.none),
                                  contentPadding: EdgeInsets.only(left: 10),
                                  hintText: 'Add a comment..',
                                  suffix: Padding(
                                    padding: EdgeInsets.only(right: 13),
                                    child: GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        postComment(widget.mediaId,
                                                textEditingController.text)
                                            .then((response) async {
                                          SharedPreferences preferences =
                                              await SharedPreferences
                                                  .getInstance();
                                          var extractedData =
                                              json.decode(response.body);

                                          if (response.statusCode == 200 ||
                                              response.statusCode == 201) {
                                            print(response.body);
                                            isLoading = false;
                                            print('****Comment Posted!*****');
                                            setState(() {
                                              commentList.add({
                                                'comment':
                                                    textEditingController.text,
                                                'username': preferences
                                                    .getString('UserUsername'),
                                                'fullName': preferences
                                                    .getString('UserFirstname'),
                                                'lastName': preferences
                                                    .getString('UserLastname'),
                                                'photo': preferences
                                                    .getString('UserPicture')
                                              });

                                              print(commentList);
                                            });
                                            textEditingController.text = '';
                                          } else {
                                            isLoading = false;
                                            print(response.body);
                                            print('****Comment Failed****');
                                            print(
                                                'reason: ${extractedData['desc']}');
                                          }
                                        }).catchError((e) {
                                          isLoading = false;
                                          print('****Comment Failed****');
                                          print('reason: ' + e.toString());
                                        });
                                      },
                                      child: Container(
                                          margin: EdgeInsets.only(right: 13),
                                          child: Text(
                                            'Send',
                                            style: TextStyle(
                                                color: eventajaGreenTeal,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ),
                                  )),
                            ),
                            suggestionsCallback: (text) async {
                              for (var texts in text.split(' ')) {
                                print(texts);
                                if (texts.startsWith('@')) {
                                  return await searchUser(texts);
                                }
                              }
                              return null;
                            },
                            direction: AxisDirection.up,
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(suggestion['photo']),
                                ),
                                title: Text(suggestion['username']),
                              );
                            },
                            transitionBuilder:
                                (context, suggestionBox, controller) {
                              return suggestionBox;
                            },
                            onSuggestionSelected: (suggestion) {
                              textEditingController.text += suggestion;
                            },
                          ),
                        )
                        //TextFormField(
                        //   controller: textEditingController,
                        //   autofocus: widget.autoFocus,
                        //   decoration: InputDecoration(
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.all(Radius.circular(0)),
                        //           borderSide: BorderSide(color: Colors.black)),
                        //       hintText: 'Add a comment..',
                        //       suffix: GestureDetector(
                        //         onTap: () {
                        //           FocusScope.of(context).requestFocus(FocusNode());
                        //           postComment(
                        //                   widget.mediaId, textEditingController.text)
                        //               .then((response) {
                        //             var extractedData = json.decode(response.body);

                        //             if (response.statusCode == 200 ||
                        //                 response.statusCode == 201) {
                        //               print(response.body);
                        //               isLoading = false;
                        //               print('****Comment Posted!*****');
                        //               textEditingController.text = '';
                        //               setState(() {});
                        //             } else {
                        //               isLoading = false;
                        //               print(response.body);
                        //               print('****Comment Failed****');
                        //               print('reason: ${extractedData['desc']}');
                        //             }
                        //           }).catchError((e) {
                        //             isLoading = false;
                        //             print('****Comment Failed****');
                        //             print('reason: ' + e.toString());
                        //           });
                        //         },
                        //         child: Container(
                        //             child: Text(
                        //           'Send',
                        //           style: TextStyle(
                        //               color: eventajaGreenTeal,
                        //               fontWeight: FontWeight.bold),
                        //         )),
                        //       )),
                        // ),
                        )
                  ],
                ),
              ),
      ),
      body: isError == true
          ? EmptyState(
              imagePath: 'assets/icons/empty_state/error.png',
              isTimeout: true,
              reasonText: errorReason,
              refreshButtonCallback: () {
                setState(() {
                  isError = false;
                  getData();
                });
              },
            )
          : ListView(
              children: <Widget>[
                widget.isVideo == true
                    ? videoType()
                    : Container(
                        height: ScreenUtil.instance.setWidth(300),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Color(0xff8a8a8b),
                            image: DecorationImage(
                                image: NetworkImage(widget.imageUri),
                                fit: BoxFit.cover)),
                      ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(15),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                          backgroundImage: NetworkImage(widget.userPicture),
                          radius: 15),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(5),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width - 217.7,
                          child: Text(
                            '@' + widget.username.toString(),
                            style: TextStyle(
                                color: Color(0xFF8A8A8B),
                                fontSize: ScreenUtil.instance.setSp(14)),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(15),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Container(
                      child: Text(
                    widget.mediaTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 2,
                  )),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(15),
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 13),
                    child: mediaDetails['media_content'] == null
                        ? Container(
                            // width: 200,
                            // child: PlaceholderLines(
                            //   count: 10,
                            //   align: TextAlign.left,
                            //   lineHeight: 10,
                            //   color: Colors.grey,
                            //   animate: true,
                            // ),
                            )
                        : ColumnBuilder(
                            itemCount: mediaDetails['media_content'].length,
                            itemBuilder: (context, i) {
                              if (mediaDetails['media_content'][i]
                                      ['content_type'] ==
                                  "text") {
                                return Html(
                                  defaultTextStyle:
                                      TextStyle(fontSize: 18, height: 1.5),
                                  data: mediaDetails['media_content'][i]
                                      ['content_text'],
                                  onLinkTap: (url) {},
                                );
                              } else if (mediaDetails['media_content'][i]
                                      ['content_type'] ==
                                  'media') {
                                if (mediaDetails['media_content'][i]['image'] !=
                                    null) {
                                  return Container(
                                      // height: 100,
                                      // width: 200,
                                      child: Image.network(
                                          mediaDetails['media_content'][i]
                                              ['image']));
                                }

                                if (mediaDetails['media_content'][i]
                                        ['youtube'] !=
                                    null) {
                                  String id = YoutubePlayer.convertUrlToId(
                                      mediaDetails['media_content'][i]
                                          ['youtube']);
                                  return YoutubePlayer(
                                    controller: YoutubePlayerController(
                                      initialVideoId: id,
                                      flags: YoutubePlayerFlags(
                                          autoPlay: false,
                                          loop: false,
                                          controlsVisibleAtStart: true),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            })),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(10),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 13),
                  child: Text(
                    'Comments',
                    style: TextStyle(
                        color: Color(0xff8a8a8b),
                        fontSize: ScreenUtil.instance.setSp(12),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(12)),
                Container(
                    child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: commentList == null ? 0 : commentList.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(commentList[i]['photo']),
                      ),
                      title: Text(
                        commentList[i]['fullName'] +
                            ' ' +
                            commentList[i]['lastName'] +
                            ': ',
                        style: TextStyle(
                            fontSize: ScreenUtil.instance.setSp(12),
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(commentList[i]['comment']),
                    );
                  },
                ))
              ],
            ),
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

  Future searchUser(String query) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String queryString = query.substring(1);

    print(queryString);

    String url = BaseApi().apiUrl +
        '/user/search?X-API-KEY=$API_KEY&people=$queryString&page=1';

    final response = await http.get(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': preferences.getString('Session')
    });

    var extractedData = json.decode(response.body);
    print(extractedData['data'].runtimeType);

    List dataMatch = List();
    print('debug');
    dataMatch.addAll(extractedData['data']);
    print('debug');

    print(dataMatch);

    print(response.statusCode);

    dataMatch.retainWhere(
        (s) => s.toString().toLowerCase().contains(queryString.toLowerCase()));
    return dataMatch;
  }

  Future<http.Response> getMediaDetails() async {
    String baseUrl = '';
    Map<String, String> headers;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      if (widget.isRest == true) {
        baseUrl = BaseApi().restUrl;
        headers = {'Authorization': AUTH_KEY, 'signature': SIGNATURE};
      } else if (widget.isRest == false) {
        baseUrl = BaseApi().apiUrl;
        headers = {
          'Accept': 'application/json',
          'Authorization': AUTH_KEY,
          'cookie': preferences.getString('Session')
        };
      }
    });

    String url =
        baseUrl + '/media/detail?X-API-KEY=$API_KEY&id=${widget.mediaId}';

    print(url);

    try {
      final response = await http.get(url, headers: headers);

      print(response.body);

      return response;
    } on SocketException catch (e) {
      print(e.message);
      errorReason = 'Sorry, looks like we lost the connection :(';
      isError = true;
      setState(() {});
      return null;
    } on HttpException catch (e) {
      print(e.message);
      errorReason = e.message;
      isError = true;
      setState(() {});
      return null;
    } on SignalException catch (e) {
      errorReason = e.message;
      isError = true;
      setState(() {});
      return null;
    }
  }

  Future<http.Response> postComment(String mediaId, String comment) async {
    setState(() {
      isLoading = true;
    });
    print('****Posting Comment...*****');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/media/comment';

    Map<String, String> headers;
    if (widget.isRest == true) {
      headers = {'Authorization': AUTH_KEY, 'signature': SIGNATURE};
    } else {
      headers = {
        'Authorization': AUTH_KEY,
        'cookie': prefs.getString('Session')
      };
    }

    print(headers);

    final response = await http.post(url, headers: headers, body: {
      'X-API-KEY': API_KEY,
      'media_id': mediaId,
      'comment': comment,
      'comment_id': '',
    });

    return response;
  }
}
