import 'dart:async';
import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PostEventMap.dart';

class PostEventPoster extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEventPosterState();
  }
}

class PostEventPosterState extends State<PostEventPoster> {
  var thisScaffold = GlobalKey<ScaffoldState>();

  File posterFile;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _showDialog());
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
        key: thisScaffold,
        appBar: AppBar(
          brightness: Brightness.light,
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
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    navigateToNextStep();
                  },
                  child: Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Next',
                        style: TextStyle(
                            color: eventajaGreenTeal,
                            fontSize: ScreenUtil.instance.setSp(18)),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 15, top: 15),
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
                height: ScreenUtil.instance.setWidth(50),
              ),
              Text(
                'Post',
                style: TextStyle(
                    color: eventajaGreenTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil.instance.setSp(30)),
              ),
              SizedBox(
                height: posterFile == null ? 100 : 30,
              ),
              GestureDetector(
                onTap: () {
                  _showDialog();
                },
                child: posterFile == null
                    ? SizedBox(
                        height: ScreenUtil.instance.setWidth(100),
                        width: ScreenUtil.instance.setWidth(100),
                        child: Image.asset(
                          'assets/bottom-bar/new-something-white.png',
                          color: Colors.grey,
                        ),
                      )
                    : Container(
                        height: ScreenUtil.instance.setWidth(300),
                        width: ScreenUtil.instance.setWidth(200),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                                image: FileImage(posterFile),
                                fit: BoxFit.fill)),
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
      },
    );
  }

  imageSelectorGalery() async {
    var galleryFile = await ImagePicker().getImage(source: ImageSource.gallery);

    print(galleryFile.path);
    cropImage(File(galleryFile.path));
  }

  imageCaptureCamera() async {
    var galleryFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );

    if (!mounted) return;

    cropImage(File(galleryFile.path));
  }

  Future cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      // saveLocation:
      //     SavedDirectoryLocation(location: DirectorySaveLocation.external),
      sourcePath: image.path,
      androidUiSettings: AndroidUiSettings(),
      aspectRatio: CropAspectRatio(
        ratioX: 2.0,
        ratioY: 3.0,
      ),
      maxWidth: 512,
      maxHeight: 512,
    );

    print(croppedImage.path);
    setState(() {
      posterFile = croppedImage;
    });
  }

  Future<void> checkForLostImageData() async {
    final LostData response = await ImagePicker().getLostData();

    if (response.isEmpty) {
      print("lost data empty");
      return;
    } else {
      if (response.file != null) {
        print("lost data found");
        print(response.file.path);
        posterFile = File(response.file.path);
        if (mounted) setState(() {});
      } else {
        print(response.exception);
      }
    }
  }

  void navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (posterFile == null) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Choose poster!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      if (Platform.isAndroid) {
        checkForLostImageData().then((_) {
          setState(() {
            prefs.setString('POST_EVENT_POSTER', posterFile.path);
          });
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => PostEventMap()));
        });
      } else {
        setState(() {
          prefs.setString('POST_EVENT_POSTER', posterFile.path);
        });
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => PostEventMap()));
      }
    }
  }
}
