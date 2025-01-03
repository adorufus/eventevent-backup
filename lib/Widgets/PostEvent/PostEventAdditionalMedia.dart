import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'PostEventReview.dart';

class PostEventAdditionalMedia extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEventAdditionalMediaState();
  }
}

class PostEventAdditionalMediaState extends State<PostEventAdditionalMedia> {
  GlobalKey<ScaffoldState> thisScaffold = new GlobalKey<ScaffoldState>();

  List<String> additionalMediaList = [];
  List<String> additionalMediaPhoto = [];

  File additional1;
  File additional2;
  File additional3;
  File additional4;
  File additional5;

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
                  onTap: () {
                    saveAndContinue();
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(
                        color: eventajaGreenTeal,
                        fontSize: ScreenUtil.instance.setSp(18)),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: Text(
                      'Additional Media',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
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
                  padding:
                      EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: additionalMediaPhoto.length < 1
                          ? newImageContainer(0)
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 1.5,
                                        color:
                                            Color(0xff8a8a8b).withOpacity(.2),
                                        blurRadius: 2)
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  File(additionalMediaPhoto[0]),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: additionalMediaPhoto.length < 2
                          ? newImageContainer(1)
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 1.5,
                                        color:
                                            Color(0xff8a8a8b).withOpacity(.2),
                                        blurRadius: 2)
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  File(additionalMediaPhoto[1]),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: additionalMediaPhoto.length < 3
                          ? newImageContainer(2)
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 1.5,
                                        color:
                                            Color(0xff8a8a8b).withOpacity(.2),
                                        blurRadius: 2)
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  File(additionalMediaPhoto[2]),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: additionalMediaPhoto.length < 4
                          ? newImageContainer(3)
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 1.5,
                                        color:
                                            Color(0xff8a8a8b).withOpacity(.2),
                                        blurRadius: 2)
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  File(additionalMediaPhoto[3]),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: additionalMediaPhoto.length < 5
                          ? newImageContainer(4)
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 1.5,
                                        color:
                                            Color(0xff8a8a8b).withOpacity(.2),
                                        blurRadius: 2)
                                  ]),
                              child: Image.file(
                                File(additionalMediaPhoto[4]),
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget newImageContainer(int index) {
    return GestureDetector(
      onTap: () {
        _showDialog(index);
      },
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/grey-fade.jpg'), fit: BoxFit.fill),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 1.5,
                  color: Color(0xff8a8a8b).withOpacity(.2),
                  blurRadius: 2)
            ]),
        height: ScreenUtil.instance.setWidth(200),
        width: ScreenUtil.instance.setWidth(150),
        child: Center(
          child: SizedBox(
            height: ScreenUtil.instance.setWidth(50),
            width: ScreenUtil.instance.setWidth(50),
            child: index == 0
                ? Icon(
                    Icons.video_call,
                    size: 50,
                    color: Colors.grey[400],
                  )
                : Icon(
                    Icons.add_a_photo,
                    size: 50,
                    color: Colors.grey[400],
                  ),
          ),
        ),
      ),
    );
  }

  void _showDialog(int index) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              index == 0
                  ? Container()
                  : ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Choose Photo from Library'),
                      onTap: () {
                        imageSelectorGalery();
                        Navigator.pop(context);
                      },
                    ),
              index != 0
                  ? Container()
                  : ListTile(
                      leading: new Icon(Icons.videocam),
                      title: new Text('Choose Video from Library'),
                      onTap: () {
                        videoSelectorGalery();
                        Navigator.pop(context);
                      },
                    ),
              index == 0
                  ? Container()
                  : ListTile(
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
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var galleryFile = await ImagePicker.pickVideo(source: ImageSource.gallery);

    print(galleryFile.path);

    var appDocDir;

    if (Platform.isAndroid) {
      appDocDir = await getApplicationDocumentsDirectory();
      // print(appDocDir.path);
    } else {
      appDocDir = await getLibraryDirectory();
    }

    String fileFolder = appDocDir.path;

    String thumbnail;

    await VideoThumbnail.thumbnailFile(
      video: galleryFile.path,
      thumbnailPath: fileFolder,
      imageFormat: ImageFormat.JPEG,
      quality: 80,
      maxWidth: 512,
    ).then((value) {
      thumbnail = value;
      print(File(value));
    });
    // await Thumbnails.getThumbnail(
    //   thumbnailFolder: fileFolder,
    //   videoFile: galleryFile.path,
    //   imageType: ThumbFormat.JPEG,
    //   quality: 50,
    // );

    print(thumbnail.hashCode);

    setState(() {
      preferences.setString('POST_EVENT_ADDITIONAL_VIDEO', galleryFile.path);
      print(preferences.getString('POST_EVENT_ADDITIONAL_VIDEO'));
    });

    cropImage(File(thumbnail));
  }

  void imageCaptureCamera() async {
    var galleryFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (!mounted) return;

    cropImage(galleryFile);
  }

  cropImage(File galleryFile) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: galleryFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio3x2
        ],
        aspectRatio: CropAspectRatio(
          ratioX: 2.0,
          ratioY: 3.0,
        ),
        maxWidth: 512,
        maxHeight: 512);

    print(croppedImage.path);
    setState(() {
      additionalMediaPhoto.add(croppedImage.path.toString());
      additionalMediaList.add(croppedImage.path.toString());
    });

    print(additionalMediaList);
    print(additionalMediaPhoto);
  }

  saveAndContinue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('POST_EVENT_ADDITIONAL_MEDIA', additionalMediaList);

    print(prefs.getStringList('POST_EVENT_ADDITIONAL_MEDIA'));

    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) => PostEventReview()));
  }
}
