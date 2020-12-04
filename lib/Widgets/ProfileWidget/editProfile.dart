import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfileWidget extends StatefulWidget {
  final String profileImage;
  final String username;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String bio;
  final String email;
  final String phone;
  final String website;

  const EditProfileWidget(
      {Key key,
      this.profileImage,
      this.username,
      this.firstName,
      this.lastName,
      this.dateOfBirth,
      this.bio,
      this.email,
      this.phone,
      this.website})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditProfileWidgetState();
  }
}

class _EditProfileWidgetState extends State<EditProfileWidget>
    with AutomaticKeepAliveClientMixin<EditProfileWidget> {
  TextEditingController usernameController = new TextEditingController();
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController shortBioController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController websiteController = new TextEditingController();
  TextEditingController birthDateController = new TextEditingController();

  String fullName;
  String firstName;
  String username;
  String pictureUri;
  String userId;
  String email;
  String phone;
  String website;
  String eventCreated;
  String eventGoing;
  String follower;
  String following;
  String lastName;
  String bio;
  File profilePictureFile;
  File croppedProfilePicture;
  Dio dio = new Dio(BaseOptions(
      baseUrl: BaseApi().apiUrl, connectTimeout: 15000, receiveTimeout: 15000));

  bool isLoading = false;

  List userData;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getUserProfileData();
    super.initState();
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
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              CupertinoIcons.back,
              color: eventajaGreenTeal,
              size: 50,
            )),
        centerTitle: true,
        title: Text(
          'EDIT PROFILE',
          style: TextStyle(color: eventajaGreenTeal),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              postUserProfileUpdate();
              if (isLoading == true) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Material(
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            color: Colors.white,
                            height: ScreenUtil.instance.setWidth(120),
                            width: ScreenUtil.instance.setWidth(120),
                            child: SizedBox(
                                height: ScreenUtil.instance.setWidth(50),
                                width: ScreenUtil.instance.setWidth(50),
                                child: CupertinoActivityIndicator(radius: 20)),
                          ),
                        ),
                      );
                    });
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: Text(
                  'SAVE',
                  style: TextStyle(
                      fontSize: ScreenUtil.instance.setSp(20),
                      color: eventajaGreenTeal),
                ),
              ),
            ),
          )
        ],
      ),
      body: buildMainView(),
    );
  }

  Widget buildMainView() {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: ScreenUtil.instance.setWidth(20),
        ),
        profilePicture(),
        SizedBox(
          height: ScreenUtil.instance.setWidth(30),
        ),
        userData == null ? HomeLoadingScreen().basicSettingsLoading(context, eventajaGreenTeal) : basicSettings(),
        SizedBox(
          height: ScreenUtil.instance.setWidth(20),
        ),
        userData == null ? HomeLoadingScreen().contactSettingsLoading(context, eventajaGreenTeal) : contactSettings(),
        SizedBox(
          height: ScreenUtil.instance.setWidth(20),
        )
      ],
    );
  }

  Widget profilePicture() {
    return GestureDetector(
      onTap: () {
        getImage();
      },
      child: Column(
        children: <Widget>[
          userData == null ? HomeLoadingScreen().EditProfilePictureLoading() : Container(
            height: ScreenUtil.instance.setWidth(200),
            width: ScreenUtil.instance.setWidth(200),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: pictureUri == null
                        ? AssetImage('assets/white.png')
                        : croppedProfilePicture == null
                            ? NetworkImage(pictureUri)
                            : FileImage(croppedProfilePicture),
                    fit: BoxFit.cover)),
          ),
          SizedBox(
            height: ScreenUtil.instance.setWidth(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  CupertinoIcons.photo_camera_solid,
                  color: eventajaGreenTeal,
                  size: 30,
                ),
                Text(
                  'Tap to change photo',
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      profilePictureFile = image;

      cropImage(profilePictureFile);
    });
  }

  Future cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 512,
      maxWidth: 512,
    );

    croppedProfilePicture = croppedImage;

    setState(() {});
  }

  Widget basicSettings() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'BASIC SETTINGS',
          style: TextStyle(
              fontSize: ScreenUtil.instance.setSp(15),
              fontWeight: FontWeight.bold,
              color: Colors.grey),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        Container(
          width: MediaQuery.of(context).size.width / 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey, offset: Offset(1, 1), blurRadius: 2)
              ]),
          child: Padding(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Username',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: TextFormField(
                        controller: usernameController,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 1),
                          hintText: 'Username',
                          hintStyle: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(15)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'First Name',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: TextFormField(
                        controller: firstNameController,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 1),
                            border: InputBorder.none,
                            hintText: 'First Name',
                            hintStyle: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(15))),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Last Name',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: TextFormField(
                        controller: lastNameController,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 1),
                            border: InputBorder.none,
                            hintText: 'Last Name',
                            hintStyle: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(15))),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Date Of Birth',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: TextFormField(
                        controller: birthDateController,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 1),
                            border: InputBorder.none,
                            hintText: 'Birthday',
                            hintStyle: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(15))),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bio',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: TextFormField(
                        controller: shortBioController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 1),
                            border: InputBorder.none,
                            hintText: 'Short Bio',
                            hintStyle: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(15))),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget contactSettings() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'CONTACT SETTINGS',
          style: TextStyle(
              fontSize: ScreenUtil.instance.setSp(15),
              fontWeight: FontWeight.bold,
              color: Colors.grey),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        Container(
          width: MediaQuery.of(context).size.width / 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey, offset: Offset(1, 1), blurRadius: 2)
              ]),
          child: Padding(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Email',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: TextFormField(
                        controller: emailController,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 1),
                          hintText: 'Email Address',
                          hintStyle: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(15)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Phone',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: TextFormField(
                        controller: phoneController,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 1),
                            border: InputBorder.none,
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(15))),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Website',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      width: ScreenUtil.instance.setWidth(150),
                      child: TextFormField(
                        controller: websiteController,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 1),
                            border: InputBorder.none,
                            hintText: 'Website',
                            hintStyle: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(15))),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future getUserProfileData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('Last User ID');
    var session = preferences.getString('Session');

    print(userId);

    final userProfileAPI =
        BaseApi().apiUrl + '/user/detail?X-API-KEY=$API_KEY&userID=$userId';
    print(userProfileAPI);
    final response = await http.get(userProfileAPI, headers: {
      'Authorization': 'Basic YWRtaW46MTIzNA==',
      'cookie': session
    });

    print(response.statusCode);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        userData = extractedData['data'];
        usernameController.text = userData[0]['username'];
        firstNameController.text = userData[0]['fullName'];
        emailController.text = userData[0]['email'];
        phoneController.text = userData[0]['phone'];
        websiteController.text = userData[0]['website'];
        lastNameController.text = userData[0]['lastName'];
        pictureUri = userData[0]['pictureFullURL'];
        eventCreated = userData[0]['countEventCreated'];
        eventGoing = userData[0]['countEventGoing'];
        following = userData[0]['countFollowing'];
        follower = userData[0]['countFollower'];
        shortBioController.text = userData[0]['shortBio'];
        birthDateController.text = userData[0]['birthDay'];
      });
    }
  }

  Future postUserProfileUpdate() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('Last User ID');
    var session = preferences.getString('Session');

    print(userId);

    final userProfileAPI = '/user/update_profile';
    print(userProfileAPI);
    print("edited email: " + emailController.text);

    try {
      Response response = await dio.post(
        userProfileAPI,
        options: Options(
          headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session},
          responseType: ResponseType.plain,
        ),
        data: FormData.fromMap(
          {
            'X-API-KEY': API_KEY,
            'fullName': firstNameController.text,
            'lastName': lastNameController.text,
            'phone': phoneController.text,
            'shortBio': shortBioController.text,
            'birthDay': birthDateController.text,
            'website': websiteController.text,
            'email': emailController.text,
            'username': usernameController.text,
            'photo': croppedProfilePicture == null
                ? ''
                : await MultipartFile.fromFile(croppedProfilePicture.path,
                    filename: "eventevent-profilepicture-${DateTime.now().toString()}.jpg",
                    contentType: MediaType('image', 'jpg'))
          },
        ),
      );

      print(response.statusCode);

      if (response.statusCode == null) {
        setState(() {
          isLoading = true;
        });
        print('loading');
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLoading = false;
          print('edit berhasil');
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {
        setState((){
          isLoading = false;
        });
        print(response.data);
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.response != null) {
        print(e.response.data);
        print(e.response.statusCode);
        print(e.response.request);
      } else {
        print(e.message);
        print(e.error);
      }
    }
  }
}
