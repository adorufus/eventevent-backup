import 'dart:collection';
import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Transaction/PaymentMethod.dart';
import 'package:eventevent/Widgets/Transaction/Xendit/TicketReview.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/utils.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionForm extends StatefulWidget {
  final eventID;
  final ticketType;

  const TransactionForm({Key key, this.eventID, this.ticketType})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TransactionFormState();
  }
}

class _TransactionFormState extends State<TransactionForm> {
  Map<String, dynamic> formData;
  Map<String, dynamic> customFormData;
  List customFormList;

  String firstname;
  String lastname;
  String email;
  String phone;
  Widget validationEmailIcon;
  FocusNode emailValidationNode = new FocusNode();

  bool isRequired;
  bool isRequiredEmpty = false;
  bool isEmailMatch = false;

  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController _emailValidationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController aditionalNotesController = TextEditingController();

  Future getFormData() async {
    var cookie;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      cookie = preferences.getString('Session');
    });

    var formDataAPI =
        BaseApi().apiUrl + '/form_filling/user?X-API-KEY=' + API_KEY;
    final response = await http.get(formDataAPI,
        headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': cookie});

    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        formData = extractedData['data'];
        preferences.setString('firstname', formData['firstname']);
        preferences.setString('lastname', formData['lastname']);
        preferences.setString('email', formData['email']);
        preferences.setString('phone', formData['phone']);
        firstname = preferences.getString('firstname');
        lastname = preferences.getString('lastname');
        email = preferences.getString('email');
        phone = preferences.getString('phone');
        firstnameController.text = firstname;
        lastnameController.text = lastname;
        emailController.text = email;
        phoneController.text = phone;
//        print(firstname + lastname + email + phone);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    
    getFormData();
    getCustomForm();

    emailValidationNode.addListener(() {
      if (emailValidationNode.hasFocus == false) {
        if (_emailValidationController.text == emailController.text) {
          validationEmailIcon = Icon(
            Icons.check,
            color: Colors.green,
          );
          isEmailMatch = true;
          if (mounted) setState(() {});
        } else {
          validationEmailIcon = Icon(
            Icons.close,
            color: Colors.red,
          );
          isEmailMatch = false;
          if (mounted) setState(() {});
        }
      }
    });
  }

  List<TextEditingController> customFormControllers = [];

  List answer = [];
  List questionId = [];

  List<Map<String, dynamic>> formIds;
  List formAnswer;

  void addFormToList() {}

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
      backgroundColor: Colors.white,
      bottomNavigationBar: GestureDetector(
        onTap: () {
          saveInput();
          // for (var i = 0; i < questionId.length; i++) {
          //   formIds['id'] = questionId[i];
          // }

          // for (var i = 0; i < answer.length; i++) {
          //   formAnswer['answer'] = answer[i];
          // }
          if (customFormList != null) {
            for (var customForm in customFormList) {
              questionId.add(customForm['id']);
            }

            for (int i = 0; i < customFormList.length; i++) {
              if (customFormList[i]['isRequired'] == '1' &&
                  customFormControllers[i].text.isEmpty) {
                isRequiredEmpty = true;
                setState(() {});
              } else {
                isRequiredEmpty = false;
                setState(() {});
              }
            }
          }

          print(questionId);

          print(isRequiredEmpty);

          if (firstnameController.text == null ||
              firstnameController.text == '' ||
              lastnameController.text == null ||
              lastnameController.text == '' ||
              emailController.text == null ||
              emailController.text == '' ||
              phoneController.text == null ||
              phoneController.text == '' ||
              isRequiredEmpty == true && isEmailMatch == true) {
            Flushbar(
              animationDuration: Duration(milliseconds: 500),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
              message: 'Please check again your input',
              flushbarPosition: FlushbarPosition.TOP,
            ).show(context);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return widget.ticketType == 'free_limited' ||
                          widget.ticketType == 'free_live_stream'
                      ? customFormList == null
                          ? TicketReview(
                              ticketType: widget.ticketType,
                              isCustomForm: false,
                            )
                          : TicketReview(
                              ticketType: widget.ticketType,
                              customFormList: answer,
                              customFormId: questionId,
                              isCustomForm: true,
                            )
                      : customFormList == null
                          ? PaymentMethod(isCustomForm: false)
                          : PaymentMethod(
                              isCustomForm: true,
                              answerList: answer,
                              customFormId: questionId,
                            );
                },
              ),
            ).then((val) {
              answer.clear();
              questionId.clear();
            });
          }

          // print(formIds);
        },
        child: Container(
            height: ScreenUtil.instance.setWidth(50),
            color: Colors.orange,
            child: Center(
              child: Text(
                'OK',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtil.instance.setSp(20)),
              ),
            )),
      ),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: eventajaGreenTeal,
            size: 30,
          ),
        ),
        centerTitle: true,
        title: Text(
          'ABOUT YOU',
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      body: formData == null
          ? HomeLoadingScreen().myTicketLoading()
          : Container(
              color: Colors.grey.withOpacity(0.05),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(15),
                    child: Text(
                      'Tell us about yourself, these information will be useful for connecting event organisers and attendees.',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(15)),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'First Name',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(16),
                                fontWeight: FontWeight.bold),
                          ),
                          TextFormField(
                            controller: firstnameController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Put your first name...'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(30),
                  ),
                  Container(
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Last Name',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(16),
                                fontWeight: FontWeight.bold),
                          ),
                          TextFormField(
                            controller: lastnameController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Put your last name...'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(30),
                  ),
                  Container(
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'E-mail',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(16),
                                fontWeight: FontWeight.bold),
                          ),
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Put your e-mail'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(30),
                  ),
                  TextFormField(
                    controller: _emailValidationController,
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    onFieldSubmitted: (i) async {
                      if (i == emailController.text) {
                        validationEmailIcon = Icon(
                          Icons.check,
                          color: Colors.green,
                        );
                        isEmailMatch = true;
                        if (mounted) setState(() {});
                      } else {
                        validationEmailIcon = Icon(
                          Icons.close,
                          color: Colors.red,
                        );
                        isEmailMatch = false;
                        if (mounted) setState(() {});
                      }
                    },
                    focusNode: emailValidationNode,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Re-enter Your Email',
                        border: InputBorder.none,
                        suffixIcon: validationEmailIcon),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(30),
                  ),
                  Container(
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Phone Number',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(16),
                                fontWeight: FontWeight.bold),
                          ),
                          TextFormField(
                            controller: phoneController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '(e.g. 0818123456)'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(30),
                  ),
                  Container(
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Aditional Notes',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(16),
                                fontWeight: FontWeight.bold),
                          ),
                          TextFormField(
                            controller: aditionalNotesController,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintMaxLines: 100,
                                hintText:
                                    'Additional notes for event organizer... Example: Please find the best seat for me.'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil.instance.setWidth(30)),
                  customFormList == null ? Container() : customForm()
                ],
              ),
            ),
    );
  }

  Widget customForm() {
    if (customFormData['status'] == 'OK' &&
        customFormData['data']['isCustomForm'] == '1') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: mapIndexed(customFormList, (index, item) {
          if (item['isRequired'] == "1") {
            isRequired = true;
          } else {
            isRequired = false;
          }

          return Container(
            margin: EdgeInsets.only(bottom: 30),
            padding: EdgeInsets.all(15),
            alignment: Alignment.centerLeft,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    isRequired == false
                        ? Container()
                        : Text('*',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: ScreenUtil.instance.setSp(20))),
                    SizedBox(width: ScreenUtil.instance.setWidth(5)),
                    Text(item['name'] == null ? '' : item['name'],
                        style: TextStyle(
                            fontSize: ScreenUtil.instance.setSp(16),
                            fontWeight: FontWeight.bold))
                  ],
                ),
                formType(index)
              ],
            ),
          );
        }).toList(),
      );
      // return ColumnBuilder(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   itemCount: customFormList == null ? 0 : customFormList.length,
      //   itemBuilder: (BuildContext context, i) {
      //     if (customFormList[i]['isRequired'] == "1") {
      //       isRequired = true;
      //     } else {
      //       isRequired = false;
      //     }

      //     // setState(() {
      //     //   // formIds.add(customFormData[i]['id']);
      //     //   print(formIds);
      //     // });

      //     return customFormList == null
      //         ? Container()
      //         : Container(
      //             margin: EdgeInsets.only(bottom: 30),
      //             padding: EdgeInsets.all(15),
      //             alignment: Alignment.centerLeft,
      //             color: Colors.white,
      //             child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: <Widget>[
      //                   Row(children: <Widget>[
      //                     isRequired == false
      //                         ? Container()
      //                         : Text('*',
      //                             style: TextStyle(
      //                                 color: Colors.red,
      //                                 fontSize: ScreenUtil.instance.setSp(20))),
      //                     SizedBox(width: ScreenUtil.instance.setWidth(5)),
      //                     Text(
      //                         customFormList[i]['name'] == null
      //                             ? ''
      //                             : customFormList[i]['name'],
      //                         style: TextStyle(
      //                             fontSize: ScreenUtil.instance.setSp(16),
      //                             fontWeight: FontWeight.bold))
      //                   ]),
      //                   formType(i)
      //                 ]),
      //           );
      //   },
      // );
    }
    // else if(customFormData['status'] == ['NOK']){
    //   return Container();
    // }

    return Container();
  }

  int _radioValue = 0;

  Widget formType(int index) {
    if (customFormList[index]['type'] == '2') {
      return ColumnBuilder(
          crossAxisAlignment: CrossAxisAlignment.start,
          itemCount: customFormList[index]['option'] == null
              ? 0
              : customFormList[index]['option'].length,
          itemBuilder: (BuildContext context, i) {
            return Row(children: <Widget>[
              Radio(
                  value: int.parse(customFormList[index]['option'][i]['order']),
                  groupValue: _radioValue,
                  onChanged: (int i) {
                    setState(() {
                      _radioValue = i;
                      answer.add(i.toString());
                      print(answer);
                    });
                  }),
              Text(customFormList[index]['option'][i]['name'])
            ]);
          });
    } else if (customFormList[index]['type'] == '1') {
      return TextFormField(
        controller: customFormControllers[index],
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintMaxLines: 100,
            hintText: 'Put your answers....'),
      );
    }

    setState(() {});
  }

  Future saveInput() async {
    for (int i = 0; i < customFormControllers.length; i++) {
      answer.add(customFormControllers[i].text);
    }
    print('answer list: ' + answer.toString());

    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (firstnameController.text == null ||
        firstnameController.text == '' ||
        lastnameController.text == null ||
        lastnameController.text == '' ||
        emailController.text == null ||
        emailController.text == '' ||
        phoneController.text == null ||
        phoneController.text == '') {
    } else {
      preferences.setString('ticket_about_firstname', firstnameController.text);
      preferences.setString('ticket_about_lastname', lastnameController.text);
      preferences.setString('ticket_about_email', emailController.text);
      preferences.setString('ticket_about_phone', phoneController.text);
    }
    preferences.setString(
        'ticket_about_aditional', aditionalNotesController.text);
    // preferences.setStringList('ticket_custom_form_list', answer);

    print(preferences.getString('ticket_about_firstname'));
    print(preferences.getString('ticket_about_lastname'));
    print(preferences.getString('ticket_about_email'));
    print(preferences.getString('ticket_about_phone'));
    print(preferences.getString('ticket_about_aditional'));
    print(preferences.getStringList('ticket_custom_form_list').toString());
  }

  Future getCustomForm() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var session;
    setState(() {
      session = preferences.getString('Session');
    });

    String customFormURI = BaseApi().apiUrl +
        '/custom_form/get?X-API-KEY=${API_KEY}&id=' +
        preferences.getString('eventID');
    print(customFormURI.toString());
    final response = await http.get(customFormURI,
        headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session});

    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        customFormData = json.decode(response.body);
        customFormList = extractedData['data']['question'];

        for (int i = 0; i < customFormList.length; i++) {
          customFormControllers.add(TextEditingController());
        }

        print('customFormController list:' +
            customFormControllers.length.toString());
      });
    } else if (response.statusCode == 400) {
      setState(() {
        customFormData = json.decode(response.body);
      });
    }
  }
}
