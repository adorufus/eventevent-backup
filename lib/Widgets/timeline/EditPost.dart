import 'dart:io';
import 'dart:async';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/Widgets/timeline/TimelineDashboard.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';

class EditPost extends StatefulWidget {
  final File imagePath;
  final File thumbnailPath;
  final bool isVideo;
  final postId;

  const EditPost({Key key, this.imagePath, this.thumbnailPath, this.isVideo, this.postId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return EditPostState();
  }
}

class EditPostState extends State<EditPost> {
  TextEditingController captionController = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal),
          ),
          centerTitle: true,
          title: Text(
            'Edit Post',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  bool isLoading = false;
                  postMedia().then((response) async {
                      print(response.statusCode);
                      if (response.statusCode == null) {
                        isLoading = true;
                      } else if (response.statusCode == 201 ||
                          response.statusCode == 200) {
                        isLoading = false;
                        print('berhasil');
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    TimelineDashboard()));
                      } else {
                        scaffoldKey.currentState.showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 60),
                            content: Text(
                              response.statusCode.toString() +
                                  ': ' +
                                  response.reasonPhrase +
                                  ', ' +
                                  response.body +
                                  ', ' +
                                  widget.imagePath.path,
                            )));
                      }
                    })..catchError((error) {
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(error.toString()),
                    ));
                  });
                },
                child: Center(
                  child: Text(
                    'Update',
                    style: TextStyle(color: eventajaGreenTeal),
                  ),
                ),
              ),
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: 120,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              image: FileImage(widget.thumbnailPath),
                              fit: BoxFit.fill)),
                    ),
                    Container(
                      width: 250,
                      child: TextFormField(
                        controller: captionController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: 5,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Write a Caption...'),
                      ),
                    )
                  ]),
            )
          ],
        ),
      ),
    );
  }

  Future<http.Response> postMedia() async {
    print(widget.imagePath.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String theUrl;

    if (widget.isVideo == false) {
      theUrl = '/photo/update';
    } else {
      theUrl = '/video/create';
    }

    String url = BaseApi().apiUrl + theUrl;
    final response = await http.post(
      url,
      body: {
        'X-API-KEY': API_KEY,
        'id': widget.postId,
        'caption': captionController.text
      },
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': prefs.getString('Session')
      }
    );

    return response;
  }
}
