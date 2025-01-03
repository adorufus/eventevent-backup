import 'dart:async';
import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/Widgets/RecycleableWidget/PostMedia.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class CustomCamera extends StatefulWidget {
  final List<CameraDescription> cameras;

  CustomCamera(this.cameras);

  @override
  State<StatefulWidget> createState() {
    return CustomCameraState();
  }
}

class CustomCameraState extends State<CustomCamera> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  CameraController controller;

  String videoString;

  @override
  void initState() {
    super.initState();
    controller = new CameraController(
      widget.cameras[0],
      ResolutionPreset.high,
      enableAudio: true,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
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
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    if (!controller.value.isInitialized) {
      return new Container();
    }

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Stack(
          alignment: Alignment.bottomCenter,
          fit: StackFit.expand,
          children: <Widget>[
            Transform.scale(
              scale: controller.value.aspectRatio / deviceRatio,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              ),
            ),
            Positioned(
                left: 5,
                top: 5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      height: ScreenUtil.instance.setWidth(30),
                      width: ScreenUtil.instance.setWidth(30),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      )),
                )),
            Positioned(
              bottom: 70,
              left: 0,
              child: Container(
                width: ScreenUtil.instance.setWidth(50),
                height: ScreenUtil.instance.setWidth(50),
                color: Colors.grey,
                child: Image.asset('/assets/grey-fade.jpg'),
              ),
            ),
            Positioned(
              bottom: 70,
              child: SizedBox(
                width: ScreenUtil.instance.setWidth(50),
                height: ScreenUtil.instance.setWidth(50),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: ScreenUtil.instance.setWidth(50),
                    height: ScreenUtil.instance.setWidth(50),
                    child: new GestureDetector(
                      onTap: () async {
                        try {
                          final path = join(
                              (await getApplicationDocumentsDirectory()).path,
                              '${DateTime.now()}.jpg');
                          await controller.takePicture(path);

                          cropImage(File(path));
                        } catch (e) {
                          print(e);
                        }
                      },
                      onLongPress: () async {
                        try {
                          final Directory extDir =
                              await getExternalStorageDirectory();
                          final String dirPath =
                              '${extDir.path}/eventevent/Movies/eventevent-vids';
                          await Directory(dirPath).create(recursive: true);
                          final String filePath =
                              '$dirPath/${DateTime.now()}.mp4';

                          if (controller.value.isRecordingVideo) {
                            return null;
                          }

                          videoString = filePath;

                          await controller.startVideoRecording(filePath);
                          print('saving video on: ' + videoString);
                        } on CameraException catch (e) {
                          print(e);
                          return null;
                        }
                      },
                      onLongPressEnd: (_) async {
                        try {
                          await controller.stopVideoRecording();
                          print(videoString);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => PostMedia(
                                        imagePath: File(videoString),
                                        thumbnailPath: File('test'),
                                        isVideo: true,
                                      )));
                        } catch (e) {
                          Flushbar(
                            flushbarPosition: FlushbarPosition.TOP,
                            message: e.toString(),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                            animationDuration: Duration(milliseconds: 500),
                          )..show(context);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Null> cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
      maxHeight: 512,
      maxWidth: 512,
    );

    print(croppedImage.path);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => PostMedia(
                  imagePath: croppedImage,
                  thumbnailPath: croppedImage,
                  isVideo: false,
                )));
  }
}
