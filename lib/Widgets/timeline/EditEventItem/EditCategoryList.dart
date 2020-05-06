import 'dart:convert';

import 'package:eventevent/Widgets/PostEvent/PostEventPoster.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditCategoryList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditCategoryListState();
  }
}

class EditCategoryListState extends State<EditCategoryList> {
  var thisScaffold = new GlobalKey<ScaffoldState>();
  DateTime _selectedDate;
  String selectedCategoryId;

  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;
  List categoryEventData;
  List<String> categoryListId = ['', '', ''];
  Widget imageWidget;
  String idCategory;
  String categoryName;
  String categoryName1;
  String categoryName2;
  String categoryName3;

  bool isSelected = false;

  var myList = new List<String>();
  var myListName = new List<String>();

  int counter = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    fetchCategoryEvent();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    selectedDateStyleColor = Theme.of(context).accentTextTheme.body2.color;
    selectedSingleDateDecorationColor = Theme.of(context).accentColor;
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
        key: thisScaffold,
        appBar: AppBar(
          brightness: Brightness.light,
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
            'CREATE EVENT',
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
                    style: TextStyle(
                        color: eventajaGreenTeal,
                        fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                ),
              ),
            )
          ],
        ),
        body: categoryEventData == null
            ? Center(child: CupertinoActivityIndicator(radius: 20))
            : Container(
                color: Colors.white,
                padding: EdgeInsets.only(left: 15, top: 15),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Category',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: <
                        Widget>[
                      Text(categoryName1 == null ? '' : categoryName1 + ', '),
                      Text(categoryName2 == null ? '' : categoryName2 + ', '),
                      Text(categoryName3 == null ? '' : categoryName3 + ', '),
                    ]),
                    SizedBox(
                      height: ScreenUtil.instance.setWidth(10),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Divider(
                        color: Colors.grey,
                        height: ScreenUtil.instance.setWidth(5),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 1.33,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: categoryEventData.length == null
                              ? 0
                              : categoryEventData.length,
                          itemBuilder: (BuildContext context, i) {
                            print(idCategory);
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  selectedCategoryId = i.toString();
                                  idCategory = categoryEventData[i]['id'];
                                  categoryName = categoryEventData[i]['name'];
                                });
                                //categoryListId.add(categoryEventData[i]['id']);
                                //print(categoryListId);

                                isSelected = !isSelected;

                                onCategorySelected();
                              },
                              leading:
                                  Image.network(categoryEventData[i]['logo']),
                              subtitle: Text(categoryEventData[i]['name']),
                              trailing: myListName
                                      .contains(categoryEventData[i]['name'])
                                  ? Container(
                                      child: Icon(
                                        Icons.check,
                                        color: eventajaGreenTeal,
                                      ),
                                    )
                                  : Container(
                                      height: ScreenUtil.instance.setWidth(10),
                                      width: ScreenUtil.instance.setWidth(10),
                                    ),
                            );
                          }),
                    )
                  ],
                ),
              ));
  }

  onCategorySelected() async {
    if (myList.length > 0) {
      for (int index = 0; index < myList.length; index++) {
        if (idCategory == myList[index]) {
          imageWidget = Image.asset('assets/icons/checklist_green.png');
        } else {
          imageWidget = Container();
        }
      }
      counter = myList.length;
      print(counter);
    } else {
      myList.clear();
      myListName.clear();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (counter > 2) {
      prefs.setStringList('category_option_lists', myList);
      setState(() {
        imageWidget = Container();
        counter--;
        myList.remove(idCategory);
        myListName.remove(categoryName);
      });
      //Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) => PostEventPoster()));
    } else {
      if (myList.contains(idCategory) && myListName.contains(categoryName)) {
        imageWidget = Container();
        counter--;
        myList.remove(idCategory);
        myListName.remove(categoryName);
        if (myListName[0] == null) {
          setState(() {
            categoryName1 = null;
          });
        } else if (myListName[1] == null) {
          setState(() {
            categoryName2 = null;
          });
        }
        if (myListName[2] == null) {
          setState(() {
            categoryName3 = null;
          });
        }
      } else {
        imageWidget = Image.asset('assets/icons/checklist_green.png');
        counter++;
        myList.add(idCategory);
        myListName.add(categoryName);
        setState(() {
          categoryName1 = myListName[0];
          categoryName2 = myListName[1];
          categoryName3 = myListName[2];
        });
      }
    }

    if (counter == 3) {
      prefs.setStringList('POST_EVENT_CATEGORY', myListName);
      prefs.setStringList('POST_EVENT_CATEGORY_ID', myList);
      print(prefs.getStringList('POST_EVENT_CATEGORY'));
      Navigator.pop(
          context,
          {"myListName": myListName, "myList": myList}
      );
    }
    print(imageWidget.toString() +
        ' ' +
        counter.toString() +
        ' ' +
        myList.toString() +
        ' ' +
        myListName.toString());
  }

  Future fetchCategoryEvent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final categoryApi =
        BaseApi().apiUrl + '/category/list?X-API-KEY=$API_KEY&page=1';
    final response = await http.get(categoryApi, headers: {
      'Authorization': "Basic YWRtaW46MTIzNA==",
      'cookie': preferences.getString('Session')
    });

    print(response.body);

    if (response.statusCode == 200) {
      var extractedData = json.decode(response.body);
      setState(() {
        categoryEventData = extractedData['data'];
        assert(categoryEventData != null);
        categoryEventData.removeAt(0);
      });
    }
  }

  void onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    print(_selectedDate.hour.toString());
  }

  navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (myListName == null || myListName.isEmpty || myList == null || myList.isEmpty) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Please select at least one category',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      prefs.setStringList('POST_EVENT_CATEGORY', myListName);
      prefs.setStringList('POST_EVENT_CATEGORY_ID', myList);
      print(prefs.getStringList('POST_EVENT_CATEGORY'));
      Navigator.pop(
        context,
        {"myListName": myListName, "myList": myList}
      );
    }
  }
}

//
