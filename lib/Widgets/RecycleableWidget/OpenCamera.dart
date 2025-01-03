import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class OpenCamera {
  void imageCaputreCamera() async {
    var galleryFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );

    print(galleryFile.path);
    cropImage(galleryFile);
  }

  Future<Null> cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        // ratioX: 2.0,
        // ratioY: 3.0,
        maxHeight: ScreenUtil.instance.setWidth(512),
        maxWidth: ScreenUtil.instance.setWidth(512));

    print(croppedImage.path);
  }
}

// List<CameraDescription> cameras;

// Future<void> main() async {
//   cameras = await availableCameras();
//   runApp(CameraApp());
// }

// class CameraApp extends StatefulWidget {
//   @override
//   _CameraAppState createState() => _CameraAppState();
// }

// class _CameraAppState extends State<CameraApp> {
//   CameraController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = CameraController(cameras[0], ResolutionPreset.medium);
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
// double defaultScreenHeight = 810.0;

// ScreenUtil.instance = ScreenUtil(
//   width: defaultScreenWidth,
//   height: defaultScreenHeight,
//   allowFontScaling: true,
// )..init(context);
//     if (!controller.value.isInitialized) {
//       return Container();
//     }
//     return AspectRatio(
//         aspectRatio: controller.value.aspectRatio,
//         child: CameraPreview(controller));
//   }
// }
