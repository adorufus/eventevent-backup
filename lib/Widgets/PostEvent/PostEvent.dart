import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:shared_preferences/shared_preferences.dart';

import 'PostEventCategory.dart';

class PostEvent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEventState();
  }
}

class PostEventState extends State<PostEvent> {
  var textController = new TextEditingController();
  var thisScaffold = new GlobalKey<ScaffoldState>();

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
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        key: thisScaffold,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0,
          // leading: GestureDetector(
          //   onTap: (){
          //     Navigator.popUntil(context, ModalRoute.withName('/Dashboard'));
          //   },
          //   child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
          // ),
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
                    'Event Name',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
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
                padding: const EdgeInsets.only(right: 50, left: 35),
                child: TextFormField(
                  onFieldSubmitted: (value) {
                    navigateToNextStep();
                  },
                  controller: textController,
                  autocorrect: false,
                  autofocus: false,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'enter your event name',
                  ),
                ),
              )
            ],
          ),
        ));
  }

  navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (textController.text == null ||
        textController.text == '' ||
        textController.text == ' ') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Input event name!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      prefs.setString('POST_EVENT_NAME', textController.text);
      prefs.getString('POST_EVENT_NAME');
      Navigator.push(context,
          CupertinoPageRoute(builder: (BuildContext context) => PostEvent2()));
    }
  }
}

class PostEvent2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEvent2State();
  }
}

class PostEvent2State extends State<PostEvent2> {
  var thisTextController = TextEditingController();
  var thisScaffold = new GlobalKey<ScaffoldState>();

  String isPrivate;
  bool isPrivateChecked = null;

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
        backgroundColor: Colors.white,
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
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 15, top: 15),
          height: ScreenUtil.instance.setWidth(400),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Event Type',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6.7,
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
                height: ScreenUtil.instance.setWidth(50),
              ),
              Padding(
                  padding: const EdgeInsets.only(
                    right: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPrivate = '0';
                            isPrivateChecked = false;
                          });
                          navigateToNextStep();
                        },
                        child: Container(
                            height: ScreenUtil.instance.setWidth(75),
                            width: ScreenUtil.instance.setWidth(320),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: ScreenUtil.instance.setWidth(40),
                                      width: ScreenUtil.instance.setWidth(40),
                                      child: Image.asset(
                                        'assets/icons/Event_public.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(15),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Public Event',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize:
                                              ScreenUtil.instance.setSp(18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: ScreenUtil.instance.setWidth(5),
                                    ),
                                    Container(
                                        height:
                                            ScreenUtil.instance.setWidth(45),
                                        child: Text(
                                          'Everyone can discover and get \naccess to your event',
                                          maxLines: 2,
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(40),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                )
                                // isPrivateChecked == null ||
                                //         isPrivateChecked == true
                                //     ? Container()
                                //     : SizedBox(
                                //         height:
                                //             ScreenUtil.instance.setWidth(20),
                                //         width: ScreenUtil.instance.setWidth(20),
                                //         child: Image.asset(
                                //             'assets/icons/checklist_green.png'))
                              ],
                            )),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(20),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPrivate = '1';
                            isPrivateChecked = true;
                          });
                          navigateToNextStep();
                        },
                        child: Container(
                            height: ScreenUtil.instance.setWidth(75),
                            width: ScreenUtil.instance.setWidth(320),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: ScreenUtil.instance.setWidth(40),
                                      width: ScreenUtil.instance.setWidth(35),
                                      child: Image.asset(
                                        'assets/icons/Event_private.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(15),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Private Event',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize:
                                              ScreenUtil.instance.setSp(18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: ScreenUtil.instance.setWidth(5),
                                    ),
                                    Container(
                                        height:
                                            ScreenUtil.instance.setWidth(45),
                                        child: Text(
                                          'For events that can be find and \naccess only by your invitation',
                                          maxLines: 2,
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(40),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                )
                                // isPrivateChecked == null ||
                                //         isPrivateChecked == false
                                //     ? Container()
                                //     : SizedBox(
                                //         height:
                                //             ScreenUtil.instance.setWidth(20),
                                //         width: ScreenUtil.instance.setWidth(20),
                                //         child: Image.asset(
                                //             'assets/icons/checklist_green.png'))
                              ],
                            )),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }

  navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isPrivate == null || isPrivate == '') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Choose your event type!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      print(isPrivate);
      if (isPrivateChecked == true) {
        prefs.setString('POST_EVENT_TYPE', isPrivate);
      } else {
        prefs.setString('POST_EVENT_TYPE', isPrivate);
      }
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => PostEvent3()));
    }
  }
}

class PostEvent3 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEvent3State();
  }
}

class PostEvent3State extends State<PostEvent3> {
  var thisScaffold = new GlobalKey<ScaffoldState>();
  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;

  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _firstDate = DateTime.now().subtract(Duration(days: 45));
    _lastDate = DateTime(2030);
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
    dp.DatePickerStyles styles = dp.DatePickerStyles(
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .body2
            .copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: selectedSingleDateDecorationColor, shape: BoxShape.circle));

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
                    'Start Date',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
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
                height: ScreenUtil.instance.setWidth(50),
              ),
              dp.DayPicker(
                currentDate: DateTime.now(),
                selectedDate: _selectedDate,
                onChanged: onDateChanged,
                firstDate: _firstDate,
                lastDate: _lastDate,
                datePickerStyles: styles,
              )
            ],
          ),
        ));
  }

  // testPicker()async{
  //   final DateTime picked = await showDatePicker(
  //     context: context,

  //   )
  // }

  void onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    print(_selectedDate.day.toString());
    navigateToNextStep();
  }

  navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedDate.day == null || _selectedDate.day.toString() == '') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Choose event start date!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      String formatedDay = _selectedDate.day.toString().length == 1
          ? '0' + _selectedDate.day.toString()
          : _selectedDate.day.toString();

      prefs.setString(
          'POST_EVENT_START_DATE',
          _selectedDate.year.toString() +
              '-' +
              _selectedDate.month.toString() +
              '-' +
              formatedDay);
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => PostEvent4(
                    firstDate: _selectedDate,
                  )));
    }
  }
}

class PostEvent4 extends StatefulWidget {
  final firstDate;

  const PostEvent4({Key key, this.firstDate}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PostEvent4State();
  }
}

class PostEvent4State extends State<PostEvent4> {
  var thisScaffold = new GlobalKey<ScaffoldState>();
  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;

  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;
  Color currentDateColor;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.firstDate;
    _firstDate = DateTime.now().subtract(Duration(days: 45));
    _lastDate = DateTime(2030);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    currentDateColor = eventajaGreenTeal;
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
    dp.DatePickerStyles styles = dp.DatePickerStyles(
        currentDateStyle: Theme.of(context)
            .accentTextTheme
            .body2
            .copyWith(color: currentDateColor),
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .body2
            .copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: selectedSingleDateDecorationColor, shape: BoxShape.circle));

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
                    'End Date',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
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
                height: ScreenUtil.instance.setWidth(50),
              ),
              dp.DayPicker(
                currentDate: widget.firstDate,
                selectedDate: _selectedDate,
                onChanged: onDateChanged,
                firstDate: _firstDate,
                lastDate: _lastDate,
                datePickerStyles: styles,
              )
            ],
          ),
        ));
  }

  void onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    print(_selectedDate.day.toString());
    navigateToNextStep();
  }

  navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedDate.day == null || _selectedDate.day.toString() == '') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Choose event end date!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      String formatedDay = _selectedDate.day.toString().length == 1
          ? '0' + _selectedDate.day.toString()
          : _selectedDate.day.toString();

      prefs.setString(
          'POST_EVENT_END_DATE',
          _selectedDate.year.toString() +
              '-' +
              _selectedDate.month.toString() +
              '-' +
              formatedDay);
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => PostEvent5()));
      print(_selectedDate.day);
    }
  }
}

class PostEvent5 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEvent5State();
  }
}

class PostEvent5State extends State<PostEvent5> {
  var thisScaffold = new GlobalKey<ScaffoldState>();
  DateTime _selectedDate;

  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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
    dp.DatePickerStyles styles = dp.DatePickerStyles(
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .body2
            .copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: selectedSingleDateDecorationColor, shape: BoxShape.circle));

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
                    'Start Time',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
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
                height: ScreenUtil.instance.setWidth(30),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Start Time',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(18),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: ScreenUtil.instance.setWidth(30),
                  ),
                  Container(
                    height: MediaQuery.of(context).copyWith().size.height / 2,
                    width: ScreenUtil.instance.setWidth(200),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(18)),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime.now(),
                        onDateTimeChanged: (DateTime newDate) {
                          onDateChanged(newDate);
                        },
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  void onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    print(_selectedDate.hour.toString());
  }

  navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedDate.hour == null ||
        _selectedDate.hour.toString() == '' ||
        _selectedDate.minute == null ||
        _selectedDate.minute.toString() == '') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Choose event start date!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      prefs.setString(
          'POST_EVENT_START_TIME',
          _selectedDate.hour.toString() +
              ':' +
              _selectedDate.minute.toString());
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => PostEvent6()));
    }
  }
}

class PostEvent6 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEvent6State();
  }
}

class PostEvent6State extends State<PostEvent6> {
  var thisScaffold = new GlobalKey<ScaffoldState>();
  DateTime _selectedDate;

  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;

  bool isSelected;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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
    dp.DatePickerStyles styles = dp.DatePickerStyles(
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .body2
            .copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: selectedSingleDateDecorationColor, shape: BoxShape.circle));

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
                    'End Time',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
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
                height: ScreenUtil.instance.setWidth(30),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'End Time',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(18),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: ScreenUtil.instance.setWidth(30),
                  ),
                  Container(
                    height: MediaQuery.of(context).copyWith().size.height / 2,
                    width: ScreenUtil.instance.setWidth(200),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(18)),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime.now(),
                        onDateTimeChanged: (DateTime newDate) {
                          onDateChanged(newDate);
                        },
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  void onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    print(_selectedDate.hour.toString());
  }

  navigateToNextStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedDate.hour == null ||
        _selectedDate.hour.toString() == '' ||
        _selectedDate.minute == null ||
        _selectedDate.minute.toString() == '') {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Choose event end time!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      prefs.setString(
          'POST_EVENT_END_TIME',
          _selectedDate.hour.toString() +
              ':' +
              _selectedDate.minute.toString());
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => PostEvent7()));
    }
  }
}
