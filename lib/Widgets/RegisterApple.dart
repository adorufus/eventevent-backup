import 'dart:convert';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/API/registerModel.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/sharedPreferences.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show File, Platform;

class RegisterApple extends StatefulWidget {
  final Map<String, dynamic> appleData;
  final bool isRest;

  const RegisterApple({Key key, this.appleData, this.isRest}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return RegisterAppleState();
  }
}

class RegisterAppleState extends State<RegisterApple> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var usernameController = new TextEditingController();
  var phoneController = new TextEditingController();
  var passwordController = new TextEditingController();
  var birthdateController = new TextEditingController();

  String MIN_DATETIME = '1685-05-12';
  String MAX_DATETIME = '2020-11-25';
  String INIT_DATETIME =
      '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';

  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
  List<DateTimePickerLocale> _locales = DateTimePickerLocale.values;

  String _format = 'yyyy-MMMM-dd';

  DateTime _dateTime;

  File profilePictureURI;
  File croppedProfilePicture;
  String birthDate;
  String gender;

  int currentValue = 0;

  bool isPasswordObsecure = true;

  @override
  void initState() {
    super.initState();
    // getFbUserProfile();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      profilePictureURI = image;

      cropImage(profilePictureURI);
    });
  }

  Future cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      cropStyle: CropStyle.circle,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
          brightness: Brightness.light,
          elevation: 0,
          backgroundColor: Colors.white,
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
          title: Text('COMPLETE YOUR PROFILE',
              style: TextStyle(color: eventajaGreenTeal))),
      body: ListView(
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: registerFbWidget())
        ],
      ),
    );
  }

  Widget registerFbWidget() {
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
                backgroundImage: profilePictureURI == null
                    ? AssetImage(currentValue == 1
                        ? 'assets/drawable/avatar-female.png'
                        : 'assets/drawable/avatar-male.png')
                    : FileImage(profilePictureURI),
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
          controller: usernameController,
          decoration: InputDecoration(
            hintText: 'Username',
            icon: Image.asset(
              'assets/drawable/username.png',
              scale: 2,
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: birthdateController,
          onTap: () {
            showDatePicker();
          },
          decoration: InputDecoration(
              hintText: 'Birth Date (Optional)',
              icon: Image.asset(
                'assets/drawable/cake.png',
                scale: 5,
              )),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     Radio(
        //       groupValue: currentValue,
        //       onChanged: (int i) => setState(() => currentValue = i),
        //       value: 0,
        //     ),
        //     Text('Male'),
        //     SizedBox(width: ScreenUtil.instance.setWidth(30)),
        //     Radio(
        //       groupValue: currentValue,
        //       onChanged: (int i) => setState(() => currentValue = i),
        //       value: 1,
        //     ),
        //     Text('Female'),
        //     SizedBox(width: ScreenUtil.instance.setWidth(30)),
        //     Radio(
        //       groupValue: currentValue,
        //       onChanged: (int i) => setState(() => currentValue = i),
        //       value: 2,
        //     ),
        //     Text('Other')
        //   ],
        // ),
        // SizedBox(
        //   height: ScreenUtil.instance.setWidth(15),
        // ),
        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(
            hintText: 'Phone, e.g. 0818123456 (Optional)',
            icon: Icon(
              CupertinoIcons.phone_solid,
              color: Colors.grey,
              size: 25,
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        TextFormField(
          controller: passwordController,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          obscureText: isPasswordObsecure,
          decoration: InputDecoration(
              hintText: 'Password',
              icon: Image.asset(
                'assets/drawable/password.png',
                scale: 2.5,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    isPasswordObsecure = !isPasswordObsecure;
                  });
                  print(isPasswordObsecure.toString());
                },
                child: Image.asset(
                  'assets/drawable/show-password.png',
                  scale: 3,
                ),
              )),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(15),
        ),
        GestureDetector(
          onTap: () {
            postRegister();
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

  Future<Register> postRegister() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/signup/register';
    print(widget.appleData);
    print(passwordController.text);
    print(gender);
    print(usernameController.text);
    print(phoneController.text);
    // print()

    if (currentValue == 0) {
      gender = 'Male';
    } else {
      gender = 'Female';
    }

    final response = await http.post(url, headers: {
      'Authorization': AUTH_KEY
    }, body: {
      'X-API-KEY': API_KEY,
      'email': widget.appleData['email'],
      'password': passwordController.text,
      'fullName':
          widget.appleData['first_name'] + ' ' + widget.appleData['last_name'],
      'gender': 'other',
      'username': usernameController.text,
      'birthDay': birthdateController.text,
      'phone': phoneController.text,
      'isLoginFacebook': '0',
      'photo': profilePictureURI == null
          ? gender == 'Male'
              ? 'assets/drawable/avatar-male.png'
              : 'assets/drawable/avatar-female.png'
          : profilePictureURI,
      'lastName': widget.appleData['last_name'],
      'register_device': Platform.isIOS ? 'IOS' : 'android'
    });

    if (response.statusCode == 201) {
      final responseJson = json.decode(response.body);
      // ClevertapHandler.pushUserProfile(
      //     responseJson['data']['fullName'],
      //     responseJson['data']['lastName'],
      //     responseJson['data']['email'],
      //     responseJson['data']['pictureNormalURL'],
      //     responseJson['data']['birthday'] == null
      //         ? '-'
      //         : responseJson['data']['birthday'],
      //     responseJson['data']['username'],
      //     responseJson['data']['gender'],
      //     responseJson['data']['phone']);
      preferences.setString('Session', response.headers['set-cookie']);
      SharedPrefs().saveCurrentSession(responseJson);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DashboardWidget(
                    isRest: false,
                  )));
      return Register.fromJson(responseJson);
    } else {
      final responseJson = json.decode(response.body);
      print(responseJson['desc']);
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: responseJson['desc'],
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }
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
                '${_dateTime.day}/${_dateTime.month}/${_dateTime.year}';
          });
        },
        onConfirm: (dateTime, List<int> index) {
          setState(() {
            _dateTime = dateTime;
            birthdateController.text =
                '${_dateTime.day}/${_dateTime.month}/${_dateTime.year}';
          });
        });
  }
}
