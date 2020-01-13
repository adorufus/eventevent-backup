import 'dart:io'; import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PostEventReview.dart';

class PostEventAdditionalMedia extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEventAdditionalMediaState();
  }
}

class PostEventAdditionalMediaState extends State<PostEventAdditionalMedia> {
  GlobalKey<ScaffoldState> thisScaffold = new GlobalKey<ScaffoldState>();

  List<String> additionalMediaList = <String>['', '', '', '', ''];

  File additional1;
  File additional2;
  File additional3;
  File additional4;
  File additional5;

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
        key: thisScaffold,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
            ),
          ),
          centerTitle: true,
          title: Text(
            'CREATE EVENT',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    saveAndContinue();
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                ),
              ),
            )
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 0, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Event Poster',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(20),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Divider(
                  color: Colors.grey,
                  height: ScreenUtil.instance.setWidth(5),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(40),
              ),
              Text(
                'Video & Picture',
                style: TextStyle(
                    color: eventajaGreenTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil.instance.setSp(20)),
              ),
              Text(
                'Add your event\'s video and picture',
                style: TextStyle(fontSize: ScreenUtil.instance.setSp(18)),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(20),
              ),
              Container(
                height: ScreenUtil.instance.setWidth(200),
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: additionalMediaList[0] == ''
                          ? Container()
                          : Container(
                              child: Image.file(
                                File(additionalMediaList[0]),
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: additionalMediaList[1] == ''
                          ? Container()
                          : Container(
                              child: Image.file(
                                File(additionalMediaList[1]),
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: additionalMediaList[2] == ''
                          ? Container()
                          : Container(
                              child: Image.file(
                                File(additionalMediaList[2]),
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: additionalMediaList[3] == ''
                          ? Container()
                          : Container(
                              child: Image.file(
                                File(additionalMediaList[3]),
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: additionalMediaList[4] == ''
                          ? Container()
                          : Container(
                              child: Image.file(
                                File(additionalMediaList[4]),
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                    additionalMediaList[4] == ''
                        ? GestureDetector(
                            onTap: () {
                              _showDialog();
                            },
                            child: Container(
                              color: Colors.grey,
                              height: ScreenUtil.instance.setWidth(200),
                              width: ScreenUtil.instance.setWidth(150),
                              child: Center(
                                child: SizedBox(
                                  height: ScreenUtil.instance.setWidth(50),
                                  width: ScreenUtil.instance.setWidth(50),
                                  child: Image.asset(
                                      'assets/bottom-bar/new-something-white.png'),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  void _showDialog() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.photo_library),
                title: new Text('Choose Photo from Library'),
                onTap: () {
                  imageSelectorGalery();
                  Navigator.pop(context);
                },
              ),
              new ListTile(
                leading: new Icon(Icons.videocam),
                title: new Text('Choose Video from Library'),
                onTap: () {
                  videoSelectorGalery();
                  Navigator.pop(context);
                },
              ),
              new ListTile(
                  leading: new Icon(Icons.camera_alt),
                  title: new Text('Take Photo from Camera'),
                  onTap: () {
                    imageCaptureCamera();
                  }),
              new ListTile(
                leading: new Icon(Icons.close),
                title: new Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  imageSelectorGalery() async {
    var galleryFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    print(galleryFile.path);
    cropImage(galleryFile);
  }

  videoSelectorGalery() async {
    var galleryFile = await ImagePicker.pickVideo(source: ImageSource.gallery);

    print(galleryFile.path);
    setState(() {
      additionalMediaList.add(galleryFile.path);
    });
  }

  void imageCaptureCamera() async {
    var galleryFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (!mounted) return;
  }

  cropImage(File galleryFile) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: galleryFile.path,
        aspectRatio: CropAspectRatio(
          ratioX: 2.0,
          ratioY: 3.0,
        ),
        maxWidth: 512,
        maxHeight: 512);

    print(croppedImage.path);
    setState(() {
      if (additionalMediaList[0] == '') {
        additionalMediaList[0] = croppedImage.path;
      } else {
        if (additionalMediaList[1] == '') {
          additionalMediaList[1] = croppedImage.path;
        } else {
          if (additionalMediaList[2] == '') {
            additionalMediaList[2] = croppedImage.path;
          } else {
            if (additionalMediaList[3] == '') {
              additionalMediaList[3] = croppedImage.path;
            } else {
              if (additionalMediaList[4] == '') {
                additionalMediaList[4] = croppedImage.path;
              }
            }
          }
        }
      }
    });

    print(additionalMediaList);
  }

  saveAndContinue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_1', additionalMediaList[0]);
    prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_2', additionalMediaList[1]);
    prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_3', additionalMediaList[2]);
    prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_4', additionalMediaList[3]);
    prefs.setString('POST_EVENT_ADDITIONAL_MEDIA_5', additionalMediaList[4]);

    print(prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_1') +
        ' ' +
        prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_2') +
        ' ' +
        prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_3') +
        ' ' +
        prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_4') +
        ' ' +
        prefs.getString('POST_EVENT_ADDITIONAL_MEDIA_5'));

    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) => PostEventReview()));
  }
}
