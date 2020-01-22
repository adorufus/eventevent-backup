import 'dart:async';
import 'dart:convert';
import 'package:eventevent/Widgets/TransactionHistory.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/countdownCounter.dart';
import 'package:flushbar/flushbar.dart';
import 'package:quiver/async.dart';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:eventevent/helper/inappbrowser/chromeSafariBrowser.dart';

class WaitTransaction extends StatefulWidget {
  final expDate;
  final String transactionID;
  final String finalPrice;

  const WaitTransaction(
      {Key key, this.expDate, this.transactionID, this.finalPrice})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WaitTransactionState();
  }
}

// InitInAppBrowser inAppBrowserFallback = new InitInAppBrowser();

class _WaitTransactionState extends State<WaitTransaction>
    with TickerProviderStateMixin {
  String month;
  String hour;
  String min;
  String sec;
  CountdownTimer timer;
  String bank_code;
  String bank_acc;
  String bank_number;
  DateTime _dDay;
  DateTime _currentTime = DateTime.now();
  Duration duration;
  String timertick = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // MyChromeSafariBrowser myChromeSafariBrowser = new MyChromeSafariBrowser(inAppBrowserFallback);

  DateTime dateTime;

  var expDate;

  Map<String, dynamic> paymentData;

  AnimationController animationController;

  timerCounter() {}

  String get timerString {
    Duration duration =
        animationController.duration * animationController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void startCounter(String expired) {
    int hoursStart, minuteStart, secondStart;
    String strHour, strMinute, strSecond;

    dateTime = DateTime.parse(expired);

    hoursStart = dateTime.hour;
    minuteStart = dateTime.minute;
    secondStart = dateTime.second;

    setState(() {
      hour = hoursStart.toString();
      min = minuteStart.toString();
      sec = secondStart.toString();
    });

    print(hoursStart.toString() +
        minuteStart.toString() +
        secondStart.toString());

    // timer = new CountdownTimer();
  }

  Future getBankInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String bankNumber;
    String bankCode;
    String bankAcc;

    bankNumber = preferences.getString('bank_acc');
    bankCode = preferences.getString('bank_code');
    bankAcc = preferences.getString('bank_name');

    setState(() {
      bank_number = bankNumber;
      bank_code = bankCode;
      bank_acc = bankAcc;
    });
  }

  int days;
  int hours;
  int minutes;
  int seconds;

  @override
  void initState() {
    super.initState();
    getTransactionDetail();
    getBankInfo();

    _dDay = DateTime.parse(widget.expDate);

    final salesDay = DateTime.parse(widget.expDate);
    final remaining = salesDay.difference(_currentTime);

    final days = remaining.inDays;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes;
    seconds = remaining.inSeconds;

    final countdownAsString = '$days : $hours : $minutes : $seconds';

    print(countdownAsString);

    animationController = AnimationController(
        vsync: this,
        duration: Duration(
            days: days, hours: hours, minutes: minutes, seconds: seconds));

    animationController.reverse(
        from:
            animationController.value == 0.0 ? 1.0 : animationController.value);

    duration = animationController.duration * animationController.value;

    timertick =
        '${duration.inHours % 24} : ${duration.inMinutes % 60} : ${(duration.inSeconds % 60)}';

    print(timertick);
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
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardWidget(
                          isRest: false,
                          selectedPage: 3,
                        )),
                ModalRoute.withName('/EventDetails'));
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TransactionHistory()));
          },
          child: Icon(
            Icons.close,
            size: 35,
            color: eventajaGreenTeal,
          ),
        ),
      ),
      body: paymentData == null
          ? Container(
              child: Center(child: CupertinoActivityIndicator(radius: 20)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: ScreenUtil.instance.setWidth(380),
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: ScreenUtil.instance.setWidth(200),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: eventajaGreenTeal),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(10),
                            ),
                            Text('Complete Payment In',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.instance.setSp(18),
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            CountDownTimer(
                              secondsRemaining: seconds,
                              whenTimeExpires: () {},
                              countDownTimerStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil.instance.setSp(25),
                                  fontWeight: FontWeight.bold),
                            ),
//                            AnimatedBuilder(
//                              animation: animationController,
//                              builder: (_, Widget child){
//                                return Text(
//                                  timertick,
//                                  style: TextStyle(color: Colors.white, fontSize: ScreenUtil.instance.setSp(18),
//                fontWeight: FontWeight.bold));
//                              },
//                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('H',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            ScreenUtil.instance.setSp(20))),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(35),
                                ),
                                Text('M',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            ScreenUtil.instance.setSp(20))),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(35),
                                ),
                                Text('S',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            ScreenUtil.instance.setSp(20))),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Complete payment before ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text('${widget.expDate}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(20),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'TRANSFER AMOUNT',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(20),
                                color: Colors.black45),
                          ),
                          SizedBox(height: ScreenUtil.instance.setWidth(15)),
                          Text(
                            'Rp. ' + widget.finalPrice.toString(),
                            style: TextStyle(
                                fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: ScreenUtil.instance.setWidth(15)),
                          Text(
                            'Eventevent will automatically check your payment. It may take up to 1 hour to process',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: ScreenUtil.instance.setSp(12)),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Text(
                  'TRANSFER TO',
                  style: TextStyle(fontSize: ScreenUtil.instance.setSp(20)),
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(15)),
                GestureDetector(
                  onTap: () {
                    if (paymentData['payment_method_id'] == '2') {
                      print('string copied');
                      Clipboard.setData(ClipboardData(text: bank_number));
                      print(Clipboard.getData('text/plain'));
                      Flushbar(
                        flushbarPosition: FlushbarPosition.TOP,
                        message: 'Text Coppied!',
                        duration: Duration(seconds: 3),
                        animationDuration: Duration(milliseconds: 500),
                      )..show(context);
                    } else if (paymentData['payment_method_id'] == '9') {
                      String url =
                          paymentData['payment']['data_vendor']['payment_url'];
                      launch(url,
                          forceSafariVC: true,
                          enableJavaScript: true,
                          forceWebView: true,
                          statusBarBrightness: Brightness.light);
                    }
                  },
                  child: Container(
                    height: ScreenUtil.instance.setWidth(130),
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.only(
                        left: 15, right: 7, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 1,
                              offset: Offset(1, 1))
                        ],
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: ScreenUtil.instance.setWidth(30),
                            child: Image.asset(
                                paymentData['payment']['vendor'] == 'bca'
                                    ? 'assets/drawable/bca.png'
                                    : 'assets/drawable/bri.png'),
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil.instance.setWidth(20),
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                paymentData['payment']['vendor'] == 'bca'
                                    ? paymentData['payment']['data_vendor']
                                        ['account_name']
                                    : paymentData['payment']['data_vendor']
                                            ['available_banks'][0]
                                        ['account_holder_name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil.instance.setSp(20),
                                    color: Colors.black54),
                              ),
                              SizedBox(
                                  height: ScreenUtil.instance.setWidth(10)),
                              Text(
                                  paymentData['payment']['vendor'] == 'bca'
                                      ? paymentData['payment']['method']
                                      : paymentData['payment']['data_vendor']
                                          ['available_banks'][0]['bank_code'],
                                  style: TextStyle(color: Colors.grey)),
                              SizedBox(
                                  height: ScreenUtil.instance.setWidth(10)),
                              Text(
                                paymentData['payment']['vendor'] == 'bca'
                                    ? paymentData['payment']['data_vendor']
                                        ['account_number']
                                    : paymentData['payment']['data_vendor']
                                                ['available_banks'][0]
                                            ['bank_account_number']
                                        .toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil.instance.setSp(15),
                                    color: Colors.black54),
                              ),
                            ])
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

//  Widget countdownTimer() {
//    final salesDay = _dDay;
//    final remaining = salesDay.difference(_currentTime);
//
//    final days = remaining.inDays;
//    final hours = remaining.inHours - remaining.inDays * 24;
//    final minutes = remaining.inMinutes - remaining.inHours * 60;
//    final seconds = remaining.inSeconds - remaining.inMinutes * 60;
//
//    final countdownAsString = '$days : $hours : $minutes : $seconds';
//
//    print(countdownAsString);
//
//    return Container(
//      child: Center(
//        child: Text(countdownAsString,
//            style: TextStyle(
//              color: Colors.white,
//                fontSize: ScreenUtil.instance.setSp(18),
//                fontWeight: FontWeight.bold)),
//      ),
//    );
//  }

  Future getTransactionDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var session;

    setState(() {
      session = prefs.getString('Session');
    });

    String url = BaseApi().apiUrl +
        '/ticket_transaction/detail?transID=${widget.transactionID}&X-API-KEY=${API_KEY}';
    final response = await http.get(url,
        headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session});

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      var extractedData = json.decode(response.body);
      setState(() {
        paymentData = extractedData['data'];
        _dDay = DateTime.parse(paymentData['expired_time']);
        startCounter(paymentData['expired_time']);
        print(paymentData);
      });
    }
  }

//  String get timerString {
//    Duration duration = new Duration(hours: 60, minutes: 10, seconds: 5);
//    return '${duration.inHours}:${duration.inMinutes % 60}:${duration.inSeconds % 60}'
//        .toString()
//        .padLeft(2, '0');
//  }
}
