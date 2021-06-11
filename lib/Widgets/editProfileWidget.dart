import 'dart:convert';

import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _EditProfileWidgetState();
  }
}

class _EditProfileWidgetState extends State<EditProfileWidget>{

 

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
      final TextEditingController fullNameController = TextEditingController();
      final TextEditingController lastNameController =TextEditingController();
      final TextEditingController emailController = TextEditingController();
      final TextEditingController usernameController =TextEditingController();
      final TextEditingController phoneController = TextEditingController();
      final TextEditingController dateBirthController =TextEditingController();
      final TextEditingController bioController = TextEditingController();
      final TextEditingController websiteController =TextEditingController();

    return Scaffold(
      backgroundColor: checkForBackgroundColor(context),
      body: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 25)),
          Flexible(
            flex: 1,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Last Name',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: 'Phone',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                TextFormField(
                  controller: dateBirthController,
                  decoration: InputDecoration(
                    hintText: 'birth date',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                TextFormField(
                  controller: bioController,
                  decoration: InputDecoration(
                    hintText: 'Bio',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                TextFormField(
                  controller: websiteController,
                  decoration: InputDecoration(
                    hintText: 'Website',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                MaterialButton(
                  color: eventajaGreenTeal,
                  child: Text('Ubah'),
                  onPressed: (){
                    requestEdit(context, fullNameController.text, lastNameController.text, usernameController.text, emailController.text, phoneController.text, dateBirthController.text, bioController.text, websiteController.text);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future requestEdit(BuildContext context, String fullName, String lastName, String username, String email, String phone, String dateBirth, String bio, String website) async{
    final editProfileApi = "http://staging.eventeventapp.com/api/user/update_profile";

    Map<String, dynamic> body = {
      'username':username,
      'fullName':fullName,
      'lastName':lastName,
      'email': email,
      'phone': phone,
      'birthDay':dateBirth,
      'shortBio':bio,
      'website':website,
      'X-API-KEY': '47d32cb10889cbde94e5f5f28ab461e52890034b'
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      editProfileApi,
      body:body,
      headers: {'Authorization': 'Basic YWRtaW46MTIzNA==', 'cookie': prefs.getString('Session')}
    );
    print(response.statusCode);

    if(response.statusCode == 200){
      final responseJson = json.decode(response.body);
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> ProfileWidget()));
    }
  }
}