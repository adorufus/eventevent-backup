import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomFormActivator extends StatefulWidget {
  final eventId;

  const CustomFormActivator({Key key, this.eventId}) : super(key: key);
  @override
  _CustomFormActivatorState createState() => _CustomFormActivatorState();
}

class _CustomFormActivatorState extends State<CustomFormActivator> {
  int __curValue = 0;
  Dio dio = new Dio(BaseOptions(
      baseUrl: BaseApi().apiUrl, connectTimeout: 10000, receiveTimeout: 10000));

  Future customFormActivator() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    print('activating form');

    Map<String, dynamic> data = {
      'X-API-KEY': API_KEY,
      'eventID': widget.eventId
    };

    try {
      Response response = await dio.post(
        '/custom_form/active',
        options: Options(headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session')
        }, cookies: [
          Cookie.fromSetCookieValue(preferences.getString('Session'))
        ], responseType: ResponseType.plain),
        data: FormData.from(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(response.data);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManageCustomForm(
                      eventId: widget.eventId,
                    )));
      }
    } catch (e) {
      if (e is DioError) {
        print(e.message);
        print(e.response);
        Flushbar(
          animationDuration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
          message: e.message,
        );
      }
    }
  }

  Future customFormDeactivator() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> data = {
      'X-API-KEY': API_KEY,
      'eventID': widget.eventId
    };

    try {
      print('deactivating form...');
      Response response = await dio.post(
        '/custom_form/inactive',
        options: Options(headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session')
        }, cookies: [
          Cookie.fromSetCookieValue(preferences.getString('Session'))
        ], responseType: ResponseType.plain),
        data: FormData.from(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('form deactivated!');
        print(response.data);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManageCustomForm(
                      eventId: widget.eventId,
                    )));
      }
    } catch (e, stacktrace) {
      print(stacktrace);
      if (e is DioError) {
        Flushbar(
          animationDuration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
          message: e.message,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Edit / Add Custom Form',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          leading: GestureDetector(
            child: Icon(
              CupertinoIcons.clear,
              size: 50,
              color: eventajaGreenTeal,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (__curValue == 1) {
                      customFormActivator();
                    } else {
                      customFormDeactivator();
                    }
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
          color: Colors.white,
          padding: EdgeInsets.only(left: 15, top: 15),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Use Custom Form?',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(25),
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
                  height: ScreenUtil.instance.setWidth(10),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(150),
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 29, left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Radio(
                        groupValue: __curValue,
                        onChanged: (int i) => setState(() => __curValue = i),
                        value: 1,
                      ),
                      Text('Yes'),
                      SizedBox(
                        width: ScreenUtil.instance.setWidth(25),
                      ),
                      Radio(
                        groupValue: __curValue,
                        onChanged: (int i) => setState(() {
                          __curValue = i;
                          print(MaterialTapTargetSize.values);
                        }),
                        value: 0,
                      ),
                      Text('No')
                    ],
                  ))
            ],
          ),
        ));
  }
}

class ManageCustomForm extends StatefulWidget {
  final eventId;

  const ManageCustomForm({Key key, this.eventId}) : super(key: key);

  @override
  _ManageCustomFormState createState() => _ManageCustomFormState();
}

class _ManageCustomFormState extends State<ManageCustomForm> {
  List<Widget> customFormList = [];
  List customForms = [];

  Dio dio = new Dio(BaseOptions(
      connectTimeout: 10000, baseUrl: BaseApi().apiUrl, receiveTimeout: 10000));

  @override
  void initState() {
    getCustomForm();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Edit / Add Custom Form',
          style: TextStyle(color: eventajaGreenTeal),
        ),
        leading: GestureDetector(
          child: Icon(
            CupertinoIcons.clear,
            size: 50,
            color: eventajaGreenTeal,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            defaultForm(),
            ColumnBuilder(
              itemCount: customForms.length < 1 ? 0 : customForms.length,
              itemBuilder: (context, i) {
                return customForm(
                    customForms[i]['name'], customForms[i]['id'], i);
              },
            ),
            GestureDetector(
              onTap: () {
                
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 13),
                color: Colors.white,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Icon(
                        CupertinoIcons.add_circled_solid,
                      ),
                      Text('ADD')
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customForm(String formName, String formId, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      padding: EdgeInsets.only(bottom: 13),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    deleteCustomForm(formId, index);
                  },
                  child: Icon(
                    CupertinoIcons.clear_thick,
                    color: Colors.grey,
                  ),
                ),
                Expanded(child: SizedBox())
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 13),
            child: Text(formName),
          ),
          Divider(),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.edit,
                      color: eventajaGreenTeal,
                    ),
                    Text(
                      'Edit',
                      style: TextStyle(color: eventajaGreenTeal),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget defaultForm() {
    return Container(
      padding: EdgeInsets.all(13),
      margin: EdgeInsets.only(bottom: 25),
      height: 120,
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'First Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Last Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'E-mail',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Phone Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Additional Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            color: Colors.white.withOpacity(.8),
            child: Center(
              child: Text('DEFAULT',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }

  Future getCustomForm() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Cookie cookie = Cookie.fromSetCookieValue(preferences.getString("Session"));

    Response response = await dio.get(
      '/custom_form/get?X-API-KEY=$API_KEY&id=${widget.eventId}',
      options: Options(headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session')
      }, cookies: [
        cookie
      ], responseType: ResponseType.plain),
    );

    var extractedData = json.decode(response.data);

    if (response.statusCode == 200) {
      print(extractedData);
      setState(() {
        customForms.addAll(extractedData['data']['question']);
      });

      print(customForms);
    }
  }

  Future deleteCustomForm(String formId, int index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Cookie cookie = Cookie.fromSetCookieValue(preferences.getString("Session"));

    Response response = await dio.delete('/custom_form/delete',
        options: Options(headers: {
          'X-API-KEY': API_KEY,
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session'),
          'id': formId
        }, cookies: [
          cookie
        ], responseType: ResponseType.plain));

    var extractedData = json.decode(response.data);

    if (response.statusCode == 200) {
      setState(() {
        customForms.removeAt(index);
      });
    }
  }
}
