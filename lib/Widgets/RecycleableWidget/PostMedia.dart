import 'dart:io'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';

class PostMedia extends StatefulWidget {
  final File imagePath;
  final File thumbnailPath;
  final bool isVideo;

  const PostMedia({Key key, this.imagePath, this.thumbnailPath, this.isVideo})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PostMediaState();
  }
}

class PostMediaState extends State<PostMedia> {
  TextEditingController captionController = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
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
            'POST MEDIA',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  bool isLoading = false;

                  postMedia().then((request) {
                    request.send().then((response) async {
                      var realResponse = await http.Response.fromStream(response);
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
                                    DashboardWidget(isRest: false,)));
                      } else {
                        scaffoldKey.currentState.showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 60),
                            content: Text(
                              response.statusCode.toString() +
                                  ': ' +
                                  response.reasonPhrase +
                                  ', ' +
                                  realResponse.body +
                                  ', ' +
                                  widget.imagePath.path,
                            )));
                      }
                    });
                  }).catchError((error) {
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(error.toString()),
                    ));
                  });
                },
                child: Center(
                  child: Text(
                    'Post',
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
              height: ScreenUtil.instance.setWidth(120),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: ScreenUtil.instance.setWidth(80),
                      width: ScreenUtil.instance.setWidth(80),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              image: FileImage(widget.thumbnailPath),
                              fit: BoxFit.fill)),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(250),
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

  Future<http.MultipartRequest> postMedia() async {
    print(widget.imagePath.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String theUrl;

    if (widget.isVideo == false) {
      theUrl = '/photo/post';
    } else {
      theUrl = '/video/create';
    }

    String url = BaseApi().apiUrl + theUrl;
    var stream = new http.ByteStream(
        DelegatingStream.typed(widget.imagePath.openRead()));
    var length = await widget.imagePath.length();

    print(url);

    final request = new http.MultipartRequest("POST", Uri.parse(url));
    request.fields
        .addAll({'X-API-KEY': API_KEY, 'caption': captionController.text, 'description': captionController.text});
    request.headers.addAll({
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    if (widget.isVideo == false) {
      var multipartFile = new http.MultipartFile('photo', stream, length,
          filename: basename(widget.imagePath.path),
          contentType: MediaType('image', 'jpg'));
      request.files.add(multipartFile);
    } else {
      // var multipartFile = await http.MultipartFile.fromPath('video', widget.imagePath.path, filename: basename(widget.imagePath.path), contentType: MediaType('video', 'mp4'));
      request.files.add(await http.MultipartFile.fromPath(
          'video', widget.imagePath.path,
          filename: basename(widget.imagePath.path),
          contentType: MediaType('video', 'mp4')));
      // request.fields.addAll({
      //   'video': widget.imagePath.path
      // });
    }

    return request;
  }
}
