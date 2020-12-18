import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

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
  Dio dio = new Dio(BaseOptions(
      baseUrl: BaseApi().apiUrl, connectTimeout: 15000, receiveTimeout: 15000));

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
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
                  postMedia(context);
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
        body: Stack(
          children: <Widget>[
            ListView(
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
            isLoading == true
                ? Container(
                    child:
                        Center(child: CupertinoActivityIndicator(radius: 20)),
                    color: Colors.black.withOpacity(0.5),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Future postMedia(BuildContext context) async {
    isLoading = true;
    setState(() {});
    print(widget.imagePath.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String theUrl;

    if (widget.isVideo == false) {
      theUrl = '/photo/post';
    } else {
      theUrl = '/video/create';
    }

    Map<String, dynamic> data = {
      'X-API-KEY': API_KEY,
      'caption': captionController.text,
      'description': captionController.text,
    };

    if (widget.isVideo == true) {
      data['video'] = await MultipartFile.fromFile(widget.imagePath.path,
          filename: basename(widget.imagePath.path));
    } else {
      data['photo'] = await MultipartFile.fromFile(widget.imagePath.path,
          filename: basename(widget.imagePath.path));
    }

    try {
      Response response = await dio.post(
        theUrl,
        options: Options(headers: {
          'Authorization': AUTH_KEY,
          'cookie': prefs.getString('Session')
        }, responseType: ResponseType.plain),
        data: FormData.fromMap(data),
      );

      if (response.statusCode == null) {
        isLoading = true;
        setState(() {});
      } else if (response.statusCode == 201 || response.statusCode == 200) {
        isLoading = false;
        setState(() {});
        print('berhasil');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => DashboardWidget(
                      isRest: false,
                    )));
      }
    } on DioError catch (e) {
      isLoading = false;
      setState(() {});
      var extractedError = json.decode(e.response.data);
      Flushbar(
        message: extractedError['desc'],
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        animationDuration: Duration(milliseconds: 500),
      ).show(context);
    }
  }
}
