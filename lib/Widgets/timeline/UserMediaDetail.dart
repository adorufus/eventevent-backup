import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:googleapis/plusdomains/v1.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserMediaDetail extends StatefulWidget {
  final username;
  final imageUri;
  final articleDetail;
  final mediaTitle;
  final imageCount;
  final userPicture;
  final autoFocus;
  final postID;

  const UserMediaDetail(
      {Key key,
      this.username,
      this.imageUri,
      this.articleDetail,
      this.mediaTitle,
      this.imageCount,
      this.userPicture,
      this.autoFocus,
      this.postID})
      : super(key: key);

  @override
  _UserMediaDetailState createState() => _UserMediaDetailState();
}

class _UserMediaDetailState extends State<UserMediaDetail> {
  TextEditingController commentController = new TextEditingController();
  List commentList;
  List mentionList=[];
  @override
  void initState() {
    super.initState();
    getCommentList();
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

    print(widget.postID);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(64),
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
              fontSize: ScreenUtil.instance.setSp(14),
              color: Colors.black,
            )),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: ScreenUtil.instance.setWidth(70),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: commentController,
                      autofocus: widget.autoFocus,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0)),
                              borderSide: BorderSide(color: Colors.black)),
                          hintText: 'Add a comment..',
                          suffix: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              postComment(commentController.text)
                                  .then((response) {
                                var extractedData = json.decode(response.body);

                                if (response.statusCode == 200 ||
                                    response.statusCode == 201) {
                                  print(response.body);
                                  
                                  print('****Comment Posted!*****');
                                  commentController.text = '';
                                  setState(() {});
                                } else {
                                  
                                  print(response.body);
                                  print('****Comment Failed****');
                                  print('reason: ${extractedData['desc']}');
                                }
                              }).catchError((e, s) {
                                print(s.toString());
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
                          backgroundImage: NetworkImage(suggestion['photo']),
                        ),
                        title: Text(suggestion['username']),
                      );
                    },
                    transitionBuilder: (context, suggestionBox, controller) {
                      return suggestionBox;
                    },
                    onSuggestionSelected: (suggestion) {
                      mentionList.add(suggestion);
                      commentController.text += suggestion;
                    },
                  )
                  // TextFormField(
                  //   controller: commentController,
                  //   autofocus: widget.autoFocus,
                  //   decoration: InputDecoration(
                  //       border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.all(Radius.circular(0)),
                  //           borderSide: BorderSide(color: Colors.black)),
                  //       hintText: 'Add a comment..',
                  //       suffix: GestureDetector(
                  //         onTap: () {
                  //           postComment(commentController.text).then((response){
                  //             print(response.statusCode);
                  //             print(response.body);
                  //             var extractedData = json.decode(response.body);

                  //             if(response.statusCode == 201){
                  //               print('berhasil');
                  //             }
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
      body: ListView(
        children: <Widget>[
          Container(
            height: ScreenUtil.instance.setWidth(400),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Color(0xff8a8a8b),
                image: DecorationImage(
                    image: NetworkImage(widget.imageUri), fit: BoxFit.fill)),
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
                      widget.username.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenUtil.instance.setSp(14),
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil.instance.setWidth(15),
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
            height: ScreenUtil.instance.setWidth(10),
          ),
          Divider(
            color: Colors.black,
          ),
          Text('Comments'),
          Container(
            child: FutureBuilder(
              future: getCommentList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.none &&
                    snapshot.hasData == null) {
                  //print('project snapshot data is: ${projectSnap.data}');
                  return Container();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } 
                if (snapshot.data == null) {
                  print('loading');
                } else {
                  // dataLength = snapshot.data['data'].length;
                  print(snapshot.data);
                  commentList = snapshot.data['data']['comment']['data'];
                }

                if (snapshot.hasError) {
                  print(snapshot.error.toString());
                }

                return ListView.builder(
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
                            ': ',
                        style: TextStyle(
                            fontSize: ScreenUtil.instance.setSp(12), fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(commentList[i]['response']),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future getCommentList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/timeline/detail?X-API-KEY=$API_KEY&type=photo&id=${widget.postID}';
//        '/photo_comment/list?X-API-KEY=$API_KEY&id=${widget.postID}&page=1';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    var extractedData = json.decode(response.body);

    return extractedData;
  }

  Future searchUser(String query) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String queryString = query.substring(1);

    print(queryString);

    String url = BaseApi().apiUrl +
        '/user/search?X-API-KEY=$API_KEY&people=$queryString&page=1';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
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

  Future<http.Response> postComment(String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/photo_comment/post';

    Map<String, dynamic> body = {
      'X-API-KEY': API_KEY,
      'id': widget.postID,
      'response': comment, 
    };

    if(mentionList.isNotEmpty){
      for(int i = 0; i < mentionList.length; i++){
        var mention = mentionList[i];
        print(mention);
        body.addAll({'mention[$i]': mention['username']});
      }
    }


    final response = await http.post(url, body: body, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}
