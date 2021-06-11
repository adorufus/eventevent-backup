import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/API/registerModel.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/sharedPreferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboardWidget.dart';

class AfterRegister extends StatefulWidget {
  final username;
  final email;
  final password;

  const AfterRegister({Key key, this.username, this.email, this.password})
      : super(key: key);

  @override
  _AfterRegisterState createState() => _AfterRegisterState();
}

const String MIN_DATETIME = '1685-05-12';
const String MAX_DATETIME = '2020-11-25';
const String INIT_DATETIME = '2019-05-17';

class _AfterRegisterState extends State<AfterRegister> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  File _image;
  Dio dio = new Dio(BaseOptions(
      baseUrl: BaseApi().apiUrl, connectTimeout: 15000, receiveTimeout: 15000));
  bool isLoading = false;

  var usernameController = new TextEditingController();
  var phoneController = new TextEditingController();
  var passwordController = new TextEditingController();
  var birthdateController = new TextEditingController();
  var firstNameController = new TextEditingController();
  var lastNameController = new TextEditingController();

  File profilePictureFile = File('aofkafoa');
  File croppedProfilePicture;
  String profilePictureURI = 'fa';
  int currentValue = 0;
  String birthDate;
  String gender = 'Male';

  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
  List<DateTimePickerLocale> _locales = DateTimePickerLocale.values;

  String _format = 'yyyy-MMMM-dd';

  DateTime _dateTime;

  bool isPasswordObsecure = true;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      profilePictureFile = image;

      cropImage(profilePictureFile);
    });
  }

  Future cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      cropStyle: CropStyle.rectangle,
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 512,
      maxWidth: 512,
    );

    croppedProfilePicture = croppedImage;

    setState(() {});
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
      key: _scaffoldKey,
      backgroundColor: checkForBackgroundColor(context),
      appBar: AppBar(
          brightness: Brightness.light,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              // googleSignIn.signOut();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
            ),
          ),
          centerTitle: true,
          title: Text('COMPLETE YOUR PROFILE',
              style: TextStyle(color: eventajaGreenTeal))),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: registerGoogleWidget())
            ],
          ),
          isLoading == false
              ? Container()
              : Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CupertinoActivityIndicator(
                      animating: true,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget registerGoogleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: ScreenUtil.instance.setWidth(10),
        ),
        GestureDetector(
            onTap: () {
              getImage();
            },
            child: Column(children: <Widget>[
              CircleAvatar(
                radius: 80,
                backgroundColor: eventajaGreenTeal,
                backgroundImage: croppedProfilePicture == null
                    ? AssetImage('assets/grey-fade.jpg')
                    : FileImage(croppedProfilePicture),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              Text('Tap to change / edit photo')
            ])),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: firstNameController,
          decoration: InputDecoration(
            hintText: 'First Name',
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: lastNameController,
          decoration: InputDecoration(
            hintText: 'Last Name',
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          onTap: () {
            showDatePicker();
          },
          controller: birthdateController,
          decoration: InputDecoration(
            hintText: 'Birth Date',
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '(Phone, e.g. 0818123456)',
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState(() {
                currentValue = i;
                gender = 'Male';
              }),
              value: 0,
            ),
            Text('Male'),
            SizedBox(width: ScreenUtil.instance.setWidth(30)),
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState(() {
                currentValue = i;
                gender = 'Female';
              }),
              value: 1,
            ),
            Text('Female'),
            SizedBox(width: ScreenUtil.instance.setWidth(30)),
            Radio(
              groupValue: currentValue,
              onChanged: (int i) => setState(() {
                currentValue = i;
                gender = 'Other';
              }),
              value: 2,
            ),
            Text('Other')
          ],
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        GestureDetector(
          onTap: () {
            requestRegister(
                    context,
                    widget.username,
                    widget.email,
                    widget.password,
                    firstNameController.text,
                    lastNameController.text,
                    birthdateController.text,
                    phoneController.text,
                    gender,
                    _scaffoldKey)
                .catchError((e) {
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                message: '${e.toString()}',
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
                animationDuration: Duration(milliseconds: 500),
              )..show(context);
            });
          },
          child: Container(
            height: ScreenUtil.instance.setWidth(50),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: eventajaGreenTeal,
                borderRadius: BorderRadius.circular(30)),
            child: Center(
                child: Text(
              'DONE',
              style: TextStyle(
                  fontSize: ScreenUtil.instance.setSp(18),
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )),
          ),
        )
      ],
    );
  }

  Future<Register> requestRegister(
      BuildContext context,
      String username,
      String email,
      String password,
      String fullName,
      String lastName,
      String birthDay,
      String phoneNumber,
      String genderSpec,
      GlobalKey<ScaffoldState> _scaffoldKey) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final registerApiUrl = '/signup/register';

    try {
      Response response = await dio.post(
        registerApiUrl,
        options: Options(
          headers: {'Authorization': AUTH_KEY},
          responseType: ResponseType.plain,
        ),
        data: FormData.fromMap(
          {
            'X-API-KEY': API_KEY,
            'username': username,
            'email': email,
            'password': password,
            'fullName': fullName,
            'lastName': lastName,
            'birthDay': birthDay,
            'phone': phoneNumber,
            'gender': gender,
            'register_device': Platform.isIOS ? 'iOS' : 'Android',
            'photo': croppedProfilePicture == null
                ? '$gender.jpg'
                : await MultipartFile.fromFile(croppedProfilePicture.path,
                    filename:
                        "eventevent-profilepicture-${DateTime.now().toString()}.jpg",
                    contentType: MediaType('image', 'jpg'))
          },
        ),
      );

      print(username);
      print(email);
      print(password);
      print(fullName);
      print(lastName);
      print(birthDay);
      print(phoneNumber);
      print(genderSpec);

      Map responseJson;

      setState(() {
        responseJson = jsonDecode(response.data);
      });

      if (response.statusCode == 201) {
        setState(() {
          isLoading = false;
        });
        setState(() {
          prefs.setString('Session', response.headers['set-cookie'].first);
        });

        //ClevertapHandler.pushUserProfile(responseJson['data']['fullName'], responseJson['data']['lastName'], responseJson['data']['email'], responseJson['data']['pictureNormalURL'], responseJson['data']['birthday'] == null ? '-' : responseJson['data']['birthday'], responseJson['data']['username'], responseJson['data']['gender'], responseJson['data']['phone']);

        SharedPrefs().saveCurrentSession(responseJson);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => DashboardWidget(
                      isRest: false,
                      selectedPage: 0,
                    )));
        return Register.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        setState(() {
          isLoading = false;
        });
        //Register registerModel = new Register.fromJson(responseJson);
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          message: responseJson['desc'].toString(),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          animationDuration: Duration(milliseconds: 500),
        )..show(context);
      } else if (responseJson.containsKey('username')) {
        setState(() {
          isLoading = false;
        });
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          message: 'Username already taken',
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          animationDuration: Duration(milliseconds: 500),
        )..show(context);
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

    return null;
  }

  void showDatePicker() {
    DatePicker.showDatePicker(context,
        pickerTheme: DateTimePickerTheme(
            showTitle: true,
            confirm: Text(
              'Done',
              style: TextStyle(color: eventajaGreenTeal),
            ),
            cancel: Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            )),
        minDateTime: DateTime.parse(MIN_DATETIME),
        maxDateTime: DateTime.parse(MAX_DATETIME),
        initialDateTime: _dateTime,
        dateFormat: _format,
        locale: _locale,
        onClose: () => {},
        onCancel: () => {},
        onChange: (dateTime, List<int> index) {
          setState(() {
            _dateTime = dateTime;
            birthdateController.text =
                '${_dateTime.year}/${_dateTime.month}/${_dateTime.day}';
          });
        },
        onConfirm: (dateTime, List<int> index) {
          setState(() {
            _dateTime = dateTime;
            birthdateController.text =
                '${_dateTime.year}/${_dateTime.month}/${_dateTime.day}';
          });
        });
  }
}
