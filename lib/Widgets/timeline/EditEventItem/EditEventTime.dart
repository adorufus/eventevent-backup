import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class EditEventTime extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditEventTimeState();
  }
}

class EditEventTimeState extends State<EditEventTime> {
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
            'TIME',
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
      //format minute to have 0 in front of them if less than 10
      String formattedMinute = _selectedDate.minute.toString();
      String formattedHour = _selectedDate.hour.toString();

      if (_selectedDate.hour < 10) {
        formattedHour = "0" + formattedHour;
      }

      if (_selectedDate.minute < 10) {
        formattedMinute = "0" + formattedMinute;
      }

      prefs.setString(
          'POST_EVENT_START_TIME', formattedHour + ':' + formattedMinute);

      Navigator.pop(context, formattedHour + ':' + formattedMinute);
    }
  }
}
