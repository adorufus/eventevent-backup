import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eventevent/Widgets/PostEvent/PostEventInvitePeople.dart';
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
  final from;

  const CustomFormActivator({Key key, this.eventId, this.from})
      : super(key: key);
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
        },  responseType: ResponseType.plain),
        data: FormData.fromMap(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(response.data);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManageCustomForm(
                      from: "createEvent",
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
        }, responseType: ResponseType.plain),
        data: FormData.fromMap(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('form deactivated!');
        print(response.data);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => widget.from == 'createEvent'
                    ? PostEventInvitePeople(
                        calledFrom: "new event",
                      )
                    : ManageCustomForm(
                        from: widget.from,
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
          brightness: Brightness.light,
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
  final from;

  const ManageCustomForm({Key key, this.eventId, this.from}) : super(key: key);

  @override
  _ManageCustomFormState createState() => _ManageCustomFormState();
}

class _ManageCustomFormState extends State<ManageCustomForm> {
  List<Widget> customFormList = [];
  List customForms = [];
  bool isRequired = false;
  PageController pageViewController = PageController(initialPage: 0);
  String nextText = '';
  TextEditingController simpleQuestionController = TextEditingController();
  bool noForm;
  List<TextEditingController> textEditingControllers = [];

  Dio dio = new Dio(BaseOptions(
      connectTimeout: 10000, baseUrl: BaseApi().apiUrl, receiveTimeout: 10000));

  @override
  void initState() {
    getCustomForm();
    super.initState();
  }

  Future createCustomForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> data = {
      'X-API-KEY': API_KEY,
      'eventID': widget.eventId
    };

    for (var i = 0; i < customForms.length; i++) {
      var forms = customForms;
      if (forms[i]['type'] == '1') {
        data['question[$i][name]'] = forms[i]['name'];
        data['question[$i][type]'] = forms[i]['type'];
        data['question[$i][order]'] = forms[i]['order'];
        data['question[$i][isRequired]'] = forms[i]['isRequired'];
      } else if (forms[i]['type'] == '2') {
        data['question[$i][name]'] = forms[i]['name'];
        data['question[$i][type]'] = forms[i]['type'];
        data['question[$i][order]'] = forms[i]['order'];
        data['question[$i][isRequired]'] = forms[i]['isRequired'];
        for (var j = 0; j < forms[i]['option'].length; j++) {
          data['question[$i][option][$j][name]'] =
              forms[i]['option'][j]['name'];
          if (forms[i]['option'][j].containsKey('id').toString() == 'false') {
          } else {
            data['question[$i][option][$j][id]'] = forms[i]['option'][j]['id'];
          }
        }
      }
    }

    print(data);
    print('creating');

    try {
      Response response = await dio.post('/custom_form/create',
          options: Options(headers: {
            'Authorization': AUTHORIZATION_KEY,
            'cookie': prefs.getString('Session')
          }, responseType: ResponseType.plain),
          data: FormData.fromMap(data));

      print(response.statusCode);
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (widget.from == "createEvent") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostEventInvitePeople(
                        calledFrom: "new event",
                      )));
        }
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (e is DioError) {
        print(e.message);
        print(e.response);
        print(e.response.data.runtimeType);
        var extractedData = json.decode(e.response.data);
        if (extractedData['desc'] ==
            'Question already created, you must use update\/delete instead') {
//          updateCustomForm();
        }
      }
    }
  }

  Future updateCustomForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> data = {
      'X-API-KEY': API_KEY,
      'eventID': widget.eventId
    };

    for (var i = 0; i < customForms.length; i++) {
      var forms = customForms;
      if (forms[i]['type'] == '1') {
        data['question[$i][name]'] = forms[i]['name'];
        data['question[$i][type]'] = forms[i]['type'];
        data['question[$i][order]'] = forms[i]['order'];
        data['question[$i][isRequired]'] = forms[i]['isRequired'];
      } else if (forms[i]['type'] == '2') {
        data['question[$i][name]'] = forms[i]['name'];
        data['question[$i][type]'] = forms[i]['type'];
        data['question[$i][order]'] = forms[i]['order'];
        data['question[$i][isRequired]'] = forms[i]['isRequired'];
        for (var j = 0; j < forms[i]['option'].length; j++) {
          data['question[$i][option][$j][name]'] =
              forms[i]['option'][j]['name'];
          if (forms[i]['option'].contains('id').toString() == 'false') {
          } else {
            data['question[$i][option][$j][id]'] = forms[i]['option'][j]['id'];
          }
        }
      }

      if (forms[i].containsKey('id').toString() == 'false') {
      } else {
        data['question[$i][id]'] = forms[i]['id'];
      }
    }

    print(data);

    try {
      Response response = await dio.post('/custom_form/update',
          options: Options(headers: {
            'Authorization': AUTHORIZATION_KEY,
            'cookie': prefs.getString('Session')
          }, responseType: ResponseType.plain),
          data: FormData.fromMap(data));

      print(response.statusCode);
      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (widget.from == "createEvent") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostEventInvitePeople(
                        calledFrom: "new event",
                      )));
        }
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (e is DioError) {
        print(e.message);
        print(e.response);
        print(e.response.data.runtimeType);
        var extractedData = json.decode(e.response.data);
        Flushbar(
          animationDuration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          message: extractedData['desc'],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
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
          Center(
            child: GestureDetector(
              onTap: () {
                if (noForm == true) {
                  createCustomForm();
                } else {
                  updateCustomForm();
                }
              },
              child: Text(
                'Submit',
                style: TextStyle(color: eventajaGreenTeal),
              ),
            ),
          ),
          SizedBox(
            width: 13,
          )
        ],
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
                setState(() {
                  isEditForm = false;
                });
                showAddBottomSheet();
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

  void showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            color: Color(0xFF737373),
            child: Container(
              padding: EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        color: eventajaGreenTeal,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Add Custom Form',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: SizedBox(),
                        ),
                        Text(
                          nextText,
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 200,
                    child: PageView(
                      controller: pageViewController,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        questionFormat(),
                        simpleQuestion(),
                        currentType == "1"
                            ? Container(
                                child: Text('type 1'),
                              )
                            : multipleFormat(),
                        multipleForm()
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showEditBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            color: Color(0xFF737373),
            child: Container(
              padding: EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        color: eventajaGreenTeal,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Add Custom Form',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: SizedBox(),
                        ),
                        Text(
                          nextText,
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 200,
                    child: PageView(
                      controller: pageViewController,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        simpleQuestion(),
                        currentType == "1"
                            ? Container(
                                child: Text('type 1'),
                              )
                            : multipleFormat(),
                        multipleForm()
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String currentType;

  Widget questionFormat() {
    return StatefulBuilder(builder: (context, updateState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    pageViewController
                        .nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut)
                        .then((res) {
                      updateState(() {
                        currentType = "1";
                      });
                      print(pageViewController.page);
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Simple Question',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('Question with single answers.')
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    pageViewController
                        .nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn)
                        .then((res) {
                      updateState(() {
                        currentType = "2";
                      });
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Multiple Choices',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'For question that requires multiple\nchoices (Example: music\npreferences).',
                            maxLines: 3,
                            textAlign: TextAlign.left,
                          )
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget simpleQuestion() {
    return StatefulBuilder(builder: (context, updateState) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: SizedBox(),
            ),
            Container(
              width: 200,
              child: TextFormField(
                controller: simpleQuestionController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'enter your question',
                ),
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                children: <Widget>[
                  Text(
                    '*Required',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Switch(
                    value: isRequired,
                    onChanged: (result) {
                      updateState(() {
                        isRequired = result;
                      });

                      print(isRequired);
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: SizedBox()),
            GestureDetector(
              onTap: () {
                if (currentType == '1') {
                  int order;
                  print(customForms.length);
                  updateState(() {
                    if (customForms.length < 1) {
                      order = 1;
                    } else {
                      for (int i = 0; i < customForms.length; i++) {
                        print(i);
                        order = i;
                        order += 1;
                        print('orders: ' + order.toString());
                      }
                    }
                    if (simpleQuestionController.text != null) {
                      if (isEditForm == true) {
                        customForms[currentFormIndex]['name'] =
                            simpleQuestionController.text;
                        customForms[currentFormIndex]['isRequired'] =
                            isRequired == true ? '2' : '1';
                      } else {
                        customForms.add({
                          'name': simpleQuestionController.text,
                          'type': '1',
                          'order': order.toString(),
                          'isRequired': isRequired == true ? '2' : '1'
                        });
                      }

                      print(customForms);
                    }
                  });

                  Navigator.pop(context, setState(() {}));
                } else {
                  pageViewController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                }
              },
              child: Container(
                color: eventajaGreenTeal,
                height: 50,
                child: Center(
                    child: Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                )),
              ),
            )
          ],
        ),
      );
    });
  }

  int multipleFormCount = 0;

  Widget multipleFormat() {
    return StatefulBuilder(
      builder: (context, setState) => Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 50,
                  children: [2, 3, 4, 5].map((val) {
                    return Container(
                      child: Center(
                          child: Text(
                        val.toString(),
                        style: TextStyle(fontSize: 20),
                      )),
                    );
                  }).toList(),
                  onSelectedItemChanged: (int value) {
                    print((value + 1).toString());
                    setState(() {
                      if (value == 0) {
                        multipleFormCount = 2;
                      } else if (value == 1) {
                        multipleFormCount = 3;
                      } else if (value == 2) {
                        multipleFormCount = 4;
                      } else if (value == 3) {
                        multipleFormCount = 5;
                      }
                    });
                    print(multipleFormCount);
                  },
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print(multipleFormCount > textEditingControllers.length);
                if(multipleFormCount < textEditingControllers.length){
                  textEditingControllers.length = 0;
                }
                print('multiple form count' + multipleFormCount.toString());
                for (int i = 0; i < multipleFormCount; i++) {
                  setState(() {
                    textEditingControllers.add(TextEditingController());
                  });
                }

                if (isEditForm = true) {
                  print('editing');
                  for (int i = 0; i < textEditingControllers.length; i++) {
                    if (textEditingControllers.length >
                        currentQuestionList.length) {
                      for (int j = 0; j < currentQuestionList.length; j++) {
                        textEditingControllers[j].text =
                            currentQuestionList[j]['name'] == null
                                ? ''
                                : currentQuestionList[j]['name'];
                      }
                    } else {
                      textEditingControllers[i].text =
                          currentQuestionList[i]['name'];
                    }
                    print(textEditingControllers[i].text);
                  }
                }

                pageViewController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
              child: Container(
                color: eventajaGreenTeal,
                height: 50,
                child: Center(
                    child: Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget multipleForm() {
    return StatefulBuilder(
      builder: (context, updateState) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: ListView.builder(
                itemCount: multipleFormCount,
                itemBuilder: (context, i) {
                  return TextFormField(
                    controller: textEditingControllers[i],
                    decoration: InputDecoration(
                        hintText: '${(i + 1).toString()}. Type Question Here'),
                    onChanged: ((val) {
                      print(textEditingControllers[i].text);
                    }),
                  );
                },
              ),
            )),
            GestureDetector(
              onTap: () {
                if (currentType == '2') {
                  int order;
                  print(customForms.length);
                  updateState(() {
                    if (customForms.length < 1) {
                      order = 1;
                    } else {
                      for (int i = 0; i < customForms.length; i++) {
                        print(i);
                        order = i;
                        order += 1;
                        print('orders: ' + order.toString());
                      }
                    }
                    if (simpleQuestionController.text != null) {
                      List questions = [];
                      if (isEditForm == true) {
                        setState(() {
                          questions.addAll(currentQuestionList);
                          print(textEditingControllers.length.toString() +
                              ' ' +
                              questions.length.toString());
                          if (textEditingControllers.length >
                              questions.length) {
                            questions.add(
                                {'name': textEditingControllers.last.text});
                          } else {}
                          print(questions);
                        });
                      }
                      for (int i = 0; i < textEditingControllers.length; i++) {
                        if (isEditForm == true) {
                          if (textEditingControllers.length >=
                              questions.length) {
                            for (int j = 0; j < questions.length; j++) {
                              questions[j]['name'] =
                                  textEditingControllers[j].text;
                            }
                          } else {
                            questions.length = textEditingControllers.length;
                            questions[i]['name'] =
                                textEditingControllers[i].text;
                          }
                        } else {
                          questions
                              .add({'name': textEditingControllers[i].text});
                        }
                      }

                      if (isEditForm == true) {
                        customForms[currentFormIndex]['name'] =
                            simpleQuestionController.text;
                        customForms[currentFormIndex]['isRequired'] =
                            isRequired == true ? '2' : '1';
                        customForms[currentFormIndex]['option'] = questions;
                      } else {
                        customForms.add({
                          'name': simpleQuestionController.text,
                          'type': '2',
                          'order': order.toString(),
                          'isRequired': isRequired == true ? '2' : '1',
                          'option': questions
                        });
                      }
                    }

                    print(customForms);
                  });

                  Navigator.pop(context, setState(() {}));
                }
              },
              child: Container(
                color: eventajaGreenTeal,
                height: 50,
                child: Center(
                    child: Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  String thisFormId;
  bool isEditForm = false;
  int currentFormIndex;
  List currentQuestionList = [];

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
            child: Row(
              children: <Widget>[
                customForms[index]['isRequired'] == '1' ? Container() : Text('*', style: TextStyle(color: Colors.red,)),
                Text(formName),
              ],
            ),
          ),
          customForms[index]['type'] == '1'
              ? Container()
              : ColumnBuilder(
                  itemCount: customForms[index]['option'].length,
                  itemBuilder: (context, i) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Radio(
                          groupValue: null,
                          onChanged: (int i) {},
                          value: 1,
                        ),
                        Text(customForms[index]['option'][i]['name']),
                      ],
                    );
                  }),
          Divider(),
          GestureDetector(
            onTap: () {
              setState(() {
                simpleQuestionController.text = formName;
                currentType = customForms[index]['type'];
                thisFormId = formId;
                isEditForm = true;
                currentFormIndex = index;
                currentQuestionList = customForms[index]['option'];
              });
              showEditBottomSheet();
            },
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

    try {
      Response response = await dio.get(
        '/custom_form/get?X-API-KEY=$API_KEY&id=${widget.eventId}',
        options: Options(headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session')
        }, responseType: ResponseType.plain),
      );

      var extractedData = json.decode(response.data);

      if (response.statusCode == 200) {
        print(extractedData);
        setState(() {
          noForm = false;
          customForms.addAll(extractedData['data']['question']);
        });

        print(customForms);
      }
    } catch (e) {
      if (e is DioError) {
        print(e.response.data);
        var extractedData = json.decode(e.response.data);

        if (extractedData['desc'] == 'Question isn\'t exist') {
          setState(() {
            noForm = true;
            print('no form: ' + noForm.toString());
          });
        }
      }
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
        }, responseType: ResponseType.plain));

    var extractedData = json.decode(response.data);

    if (response.statusCode == 200) {
      setState(() {
        customForms.removeAt(index);
      });
    }
  }
}
