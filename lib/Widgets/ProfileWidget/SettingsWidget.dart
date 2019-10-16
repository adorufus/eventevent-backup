import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/BankAccountList.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/ChangePassword.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/Feedback.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/PrivacyPolicy.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/Terms.dart';
import 'package:eventevent/Widgets/ProfileWidget/editProfile.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WithdrawBank.dart';
import 'package:eventevent/helper/API/apiHelper.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:launch_review/launch_review.dart';

class SettingsWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SettingsWidgetState();
  }
}

class _SettingsWidgetState extends State<SettingsWidget>{

  String appVersion = 'Current version v';

  Future setSharedPreferencesToEmpty() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getKeys());
  }

  getInfo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      appVersion = appVersion + prefs.getString('app_version');
    });

    print(appVersion);
  }

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back_ios,
            color: eventajaGreenTeal,
          ),
        ),
        title: Text('SETTINGS', style: TextStyle(color: eventajaGreenTeal),),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text('REVIEW', style: TextStyle(fontSize: 20, color: Colors.grey[600]),),
          ),
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    LaunchReview.launch(androidAppId: 'com.eventevent.android');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
                    child: Text(
                      'Rate EventEvent on App Store / Google Play',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text('BANK ACCOUNT & WITHDRAW', style: TextStyle(fontSize: 20, color: Colors.grey[600]),),
          ),
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BankAccountList()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 30, top: 15),
                    child: Text(
                      'Bank Account',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(color:  Colors.grey,),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => WithdrawBank()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
                    child: Text(
                      'Withdraw',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text('ACCOUNT SETTINGS', style: TextStyle(fontSize: 20, color: Colors.grey[600]),),
          ),
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => EditProfileWidget()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 30, top: 15),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(color:  Colors.grey,),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChangePassword()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
                    child: Text(
                      'Change Password',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text('FEEDBACK', style: TextStyle(fontSize: 20, color: Colors.grey[600]),),
          ),
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GiveFeedback()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
                    child: Text(
                      'Give us feedback',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25,),
          GestureDetector(
            onTap: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            height: 100,
                            width: 200,
                            child: Column(
                              children: <Widget>[
                                Text('Oops', style: TextStyle(color: Colors.black54,fontSize: 18, fontWeight: FontWeight.bold),),
                                SizedBox(height: 10,),
                                Text('Do you want to log out?', textAlign: TextAlign.center,),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel', style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),),
                                    ),
                                    SizedBox(
                                      width: 50,
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setSharedPreferencesToEmpty();
                                        requestLogout(context);
                                      },
                                      child: Text('Ok', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    )

                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
              );
            },
                  child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              padding: EdgeInsets.only(left: 30, bottom: 10, top: 10),
              child: Text('Log Out', style: TextStyle(color: Colors.red, fontSize: 20),),
            ),
          ),
          SizedBox(height: 25,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text('Terms and Condition', style: TextStyle(fontSize: 20, color: Colors.grey[600]),),
          ),
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Terms()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 30, top: 15),
                    child: Text(
                      'Terms',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(color:  Colors.grey,),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PrivacyPolicy()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 30, top: 5, bottom: 10),
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25,),
          GestureDetector(
            onTap: (){
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              color: Colors.white,
              child: Center(child: Text(appVersion, style: TextStyle(color: Colors.grey[700], fontSize: 18),))
            ),
          ),
        ],
      ),
    );
  }
}