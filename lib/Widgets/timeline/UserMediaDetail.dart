import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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



  const UserMediaDetail({Key key, this.username, this.imageUri, this.articleDetail, this.mediaTitle, this.imageCount, this.userPicture, this.autoFocus, this.postID}) : super(key: key);

  @override
  _UserMediaDetailState createState() => _UserMediaDetailState();
}

class _UserMediaDetailState extends State<UserMediaDetail> {

  TextEditingController commentController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    List commentList;

    print(widget.postID);

    @override
    void initState() {
      super.initState();
      getCommentList().then((response){
        print(response.statusCode);
        print(response.body);

        var extractedData = json.decode(response.body);

        if(response.statusCode == 200){
          setState(() {
              commentList = extractedData['data'];
          });
        }
      });
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 64,
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
                  controller: commentController,
                  autofocus: widget.autoFocus,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'Add a comment..',
                      suffix: GestureDetector(
                        onTap: () {
                          postComment(commentController.text).then((response){
                            print(response.statusCode);
                            print(response.body);
                            var extractedData = json.decode(response.body);

                            if(response.statusCode == 201){
                              print('berhasil');
                            }
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
          Container(
            height: 400,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Color(0xff8a8a8b),
                image: DecorationImage(
                    image: NetworkImage(widget.imageUri), fit: BoxFit.fill)),
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
                      widget.username.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: commentList == null ? 0 : commentList.length,
            itemBuilder: (context, i){
              return Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child:  Text('test')
              );
            },
          )
        ],
      ),
    );
  }



  Future<http.Response> getCommentList() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/photo_comment/list?X-API-KEY=$API_KEY}&id=${widget.postID}&page=1';
    
    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }

  Future<http.Response> postComment(String comment) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/photo_comment/post';

    final response = await http.post(url, body: {
      'X-API-KEY': API_KEY,
      'id': widget.postID,
      'response': comment
    }, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}
