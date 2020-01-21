import 'dart:convert';
import 'dart:math' as math;

import 'package:eventevent/Widgets/TransactionHistory.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/countdownCounter.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PaymentBCA extends StatefulWidget {
  final expDate;
  final transactionID;

  const PaymentBCA({Key key, this.transactionID, this.expDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PaymentBcaState();
  }
}

class PaymentBcaState extends State<PaymentBCA> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String month;
  String hour;
  String min;
  String sec;
  String finalAmount;
  String firstAmount;
  String uniqueAmount;
  DateTime _dDay;
  DateTime _currentTime = DateTime.now();

  String bank_number;
  String bank_code;
  String bank_acc;
  String imageUriBank;

  Text finalPriceString;

  DateTime dateTime;
  Map<String, dynamic> paymentData;

  int seconds;

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

  @override
  void initState() {
    super.initState();
    getPaymentData();

    final salesDay = DateTime.parse(widget.expDate);
    final remaining = salesDay.difference(_currentTime);

    final days = remaining.inDays;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes;
    seconds = remaining.inSeconds;

    print(seconds);

    //getFinalAmount();
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
          : Container(
              height: MediaQuery.of(context).size.height,
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
                              fontSize: ScreenUtil.instance.setSp(18),
                              fontWeight: FontWeight.bold),
                        ),
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
                                    fontSize: ScreenUtil.instance.setSp(20))),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(35),
                            ),
                            Text('M',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.instance.setSp(20))),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(35),
                            ),
                            Text('S',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.instance.setSp(20))),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Rp. ' + firstAmount + ',',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(30),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(uniqueAmount,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: ScreenUtil.instance.setSp(30),
                                  fontWeight: FontWeight.bold)),
                          Text(',-',
                              style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(30),
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(15)),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil.instance.setWidth(50),
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                              child: Text(
                            'IMPORTANT! Please transfer until the last 3 digits',
                            style: TextStyle(color: Colors.white),
                          ))),
                      SizedBox(height: ScreenUtil.instance.setWidth(15)),
                      Text(
                        'Eventevent will automatically check your payment. It may take up to 1 hour to process',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: ScreenUtil.instance.setSp(12)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(15),
                      ),
                      Text('TRANSFER KE'),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(10),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: bank_number));
                          print(Clipboard.getData('text/plain'));
                          Flushbar(
                            flushbarPosition: FlushbarPosition.TOP,
                            message: 'Text Coppied!',
                            duration: Duration(seconds: 3),
                            animationDuration: Duration(milliseconds: 500),
                          )..show(context);
                        },
                        child: Container(
                          height: ScreenUtil.instance.setWidth(100),
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
                                  height: ScreenUtil.instance.setWidth(20),
                                  child: Image.asset('assets/drawable/bca.png'),
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(10),
                              ),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      bank_acc,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil.instance.setSp(20),
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Text(bank_code.toUpperCase(),
                                        style: TextStyle(color: Colors.grey)),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Text(
                                      bank_number,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              ScreenUtil.instance.setSp(15),
                                          color: Colors.black54),
                                    ),
                                  ])
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  Widget countdownTimer() {
    var countdownAsString;

    setState(() {
      final salesDay = _dDay;
      print('salesDay:' + salesDay.toString());
      final remaining = salesDay.difference(DateTime.now());

      final days = remaining.inDays;
      final hours = remaining.inHours - remaining.inDays * 24;
      final minutes = remaining.inMinutes - remaining.inHours * 60;
      final seconds = remaining.inSeconds - remaining.inMinutes * 60;

      countdownAsString = '$days : $hours : $minutes : $seconds';
    });

    print(countdownAsString);

    return Container(
      child: Center(
        child: Text(countdownAsString,
            style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil.instance.setSp(18),
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future getPaymentData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String session;

    setState(() {
      session = preferences.getString('Session');
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
        startCounter(paymentData['expired_time']);
        print(paymentData);

        bank_number = paymentData['payment']['data_vendor']['account_number'];
        bank_acc = paymentData['payment']['data_vendor']['account_name'];
        bank_code = paymentData['payment']['vendor'];
        imageUriBank = paymentData['payment']['data_vendor']['icon'];
        _dDay = DateTime.parse(paymentData['expired_time']);

        int firstPrice = int.parse(paymentData['amount_detail']['total_price']);
        int uniqueCode =
            int.parse(paymentData['amount_detail']['unique_amount']);
        finalAmount = (firstPrice + uniqueCode).toString();

        firstAmount = finalAmount.substring(0, finalAmount.length - 3);
        uniqueAmount =
            finalAmount.substring(finalAmount.length - 3, finalAmount.length);
        print(firstAmount + uniqueAmount);

        print(finalAmount);
      });
    }
  }

  String get timerString {
    Duration duration = new Duration(hours: 60, minutes: 10, seconds: 5);
    return '${duration.inHours}:${duration.inMinutes % 60}:${duration.inSeconds % 60}'
        .toString()
        .padLeft(2, '0');
  }
}
