import 'dart:async';
import 'dart:io';

import 'package:eventevent/Widgets/PostEvent/CreateTicketReview.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PostEventMap.dart';

class CreateTicketPicture extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateTicketPictureState();
  }
}

class CreateTicketPictureState extends State<CreateTicketPicture> {
  var thisScaffold = GlobalKey<ScaffoldState>();

  File posterFile;

  @override
  Widget build(BuildContext context) {
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
            'CREATE TICKET',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    navigateToNextStep();
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(color: eventajaGreenTeal, fontSize: 18),
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
                    'Ticket Picture',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Divider(
                  color: Colors.grey,
                  height: 5,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                'Ticket',
                style: TextStyle(
                    color: eventajaGreenTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              SizedBox(
                height: posterFile == null ? 100 : 30,
              ),
              GestureDetector(
                onTap: (){
                  _showDialog();
                },
                child: posterFile == null ? SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(
                    'assets/bottom-bar/new-something-white.png',
                    color: Colors.grey,
                  ),
                ) : Container(
                  height: 300, width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: ExactAssetImage(posterFile.path),
                      fit: BoxFit.fill
                    )
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void _showDialog(){
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context){
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
            onTap: (){
              imageCaptureCamera();
            }          
          ),
          new ListTile(
            leading: new Icon(Icons.close),
            title: new Text('Cancel'),
            onTap: (){
              Navigator.pop(context);
            },          
          ),
          ],
        );
      }
    );
  }

  imageSelectorGalery() async{
    var galleryFile = await ImagePicker.pickImage(
      source: ImageSource.gallery
    );

    print(galleryFile.path);
    cropImage(galleryFile);
  }

  imageCaptureCamera() async{
    var galleryFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );

    //cropImage(galleryFile);
  }

  Future cropImage(File image) async{
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      ratioX: 2.0,
      ratioY: 3.0,
      maxWidth: 512,
      maxHeight: 512
    );

    print(croppedImage.path);
    setState((){
      posterFile = croppedImage;
    });
  }

  void navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(posterFile == null){
      thisScaffold.currentState.showSnackBar(SnackBar(
        content: Text('Ticket picture cannot be empty!'),
        backgroundColor: Colors.red,
      ));
    }
    else{
      setState((){
        prefs.setString('SETUP_TICKET_POSTER', posterFile.path);
      });
      print(prefs.getString('SETUP_TICKET_POSTER'));
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) => CreateTicketReview()));
    }
  }
}
