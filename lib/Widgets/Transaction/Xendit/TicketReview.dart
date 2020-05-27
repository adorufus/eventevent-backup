import 'dart:convert';

import 'package:eventevent/Widgets/RecycleableWidget/WaitTransaction.dart';
import 'package:eventevent/Widgets/Transaction/Alfamart/WaitingTransactionAlfamart.dart';
import 'package:eventevent/Widgets/Transaction/BCA/InputBankData.dart';
import 'package:eventevent/Widgets/Transaction/GOPAY/WaitingGopay.dart';
import 'package:eventevent/Widgets/Transaction/ProcessingPayment.dart';
import 'package:eventevent/Widgets/Transaction/SuccesPage.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/WebView.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../CC.dart';

class TicketReview extends StatefulWidget {
  final ticketType;
  final List<Map<String, dynamic>> customForm;
  final List customFormList;
  final List customFormId;
  final bool isCustomForm;

  const TicketReview(
      {Key key,
      this.ticketType,
      this.customForm,
      this.customFormList,
      this.customFormId,
      this.isCustomForm})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _TicketReviewState();
  }
}

class _TicketReviewState extends State<TicketReview> {
  final promoCodeController = TextEditingController();

  String thisEventName;
  String thisEventImage;
  String thisTicketName;
  String thisEventAddres;
  String thisEventDate;
  String thisEventStartTime;
  String thisEventEndTime;
  String thisTicketAmount;
  String thisTicketPrice;
  String thisTicketFee;
  String desc;
  String couponButtonText = 'Apply';
  Map<String, dynamic> paymentData;
  Map<String, dynamic> promoData;
  int pajak;
  int total;

  Color buttonColor = eventajaGreenTeal;
  Color iconStatusColor = eventajaGreenTeal;
  IconData iconStatus = Icons.check;

  bool showCheck = false;
  bool isPromoCodePressed = false;

  var uuid = new Uuid();

  Future getEventDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var eventName = preferences.getString('EventName');
    var eventImage = preferences.getString('EventImage');
    var ticketName = preferences.getString('TicketName');
    var eventAddress = preferences.getString('EventAddress');
    var eventDate = preferences.getString('EventDate');
    var eventStartTime = preferences.getString('EventStartTime');
    var eventEndTime = preferences.getString('EventEndTime');
    var ticketAmount = preferences.getString('ticket_many');
    var ticketPrice = preferences.getString('ticket_price_total');
    var ticketFee = preferences.getString('ticket_fee');

    setState(() {
      thisEventName = eventName;
      thisEventImage = eventImage;
      thisTicketName = ticketName;
      thisEventAddres = eventAddress;
      thisEventDate = eventDate;
      thisEventStartTime = eventStartTime;
      thisEventEndTime = eventEndTime;
      thisTicketAmount = ticketAmount;
      thisTicketPrice = ticketPrice;
      if (widget.ticketType == 'free_limited' || widget.ticketType == 'free_live_stream') {
        thisTicketFee = '0';
        pajak = 0;
        total = 0;
      } else {
        thisTicketFee = ticketFee;
        pajak = int.parse(thisTicketFee);
        total = int.parse(thisTicketPrice) + pajak;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getEventDetails();
    print('answer list' + widget.customFormList.toString());
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
      backgroundColor: Colors.white,
      appBar: AppBar(
          brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_ios,
            size: 35,
            color: eventajaGreenTeal,
          ),
        ),
        centerTitle: true,
        title: Text(
          'REVIEW TICKET',
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProcessingPayment(
                customFormList: widget.customFormList,
                customFormId: widget.customFormId,
                isCustomForm: widget.isCustomForm,
                uuid: uuid,
                ticketType: widget.ticketType,
                total: total,
                loadingType: 'buy ticket',
              ),
            ),
          ).then((val){
            Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            message: '$val',
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            animationDuration: Duration(milliseconds: 500),
          )..show(context);
          });
        },
        child: Container(
            height: ScreenUtil.instance.setWidth(50),
            color: Colors.orange,
            child: Center(
              child: Text(
                'PURCHASE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtil.instance.setSp(20)),
              ),
            )),
      ),
      body: ListView(
        children: <Widget>[
          Container(
              color: Colors.white,
              padding: EdgeInsets.all(15),
              height: ScreenUtil.instance.setWidth(280),
              width: MediaQuery.of(context).size.width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Container(
                          width: 300,
                        child: Text(
                          thisEventName == null ? '' : thisEventName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil.instance.setSp(22)),
                          textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil.instance.setWidth(20)),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              height: ScreenUtil.instance.setWidth(150),
                              width: ScreenUtil.instance.setWidth(100),
                              child: Image(
                                  image: thisEventImage == null
                                      ? AssetImage('assets/white.png')
                                      : NetworkImage(thisEventImage),
                                  fit: BoxFit.fill)),
                          SizedBox(width: ScreenUtil.instance.setWidth(20)),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(thisTicketAmount == null
                                    ? ''
                                    : thisTicketAmount + 'X' + ' Ticket(s)'),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(15)),
                                Text(
                                    thisTicketName == null
                                        ? ''
                                        : thisTicketName,
                                    style: TextStyle(
                                        fontSize: ScreenUtil.instance.setSp(20),
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(15)),
                                Container(
                                    width: ScreenUtil.instance.setWidth(190),
                                    child: Text(
                                        thisEventAddres == null
                                            ? ''
                                            : thisEventAddres,
                                        overflow: TextOverflow.ellipsis)),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(15)),
                                Text(
                                    thisEventDate == null ? '' : thisEventDate),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(15)),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(thisEventStartTime == null
                                          ? ''
                                          : thisEventStartTime +
                                                      ' - ' +
                                                      thisEventEndTime ==
                                                  null
                                              ? ''
                                              : thisEventEndTime)
                                    ])
                              ])
                        ])
                  ])),
          SizedBox(height: ScreenUtil.instance.setWidth(50)),
          Container(
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15),
              color: Colors.white,
              height: ScreenUtil.instance.setWidth(200),
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Input Promo Code'),
                        showCheck == false
                            ? Container()
                            : Icon(
                                iconStatus,
                                color: iconStatusColor,
                              )
                      ],
                    ),
                    TextFormField(
                        controller: promoCodeController,
                        decoration:
                            InputDecoration(hintText: 'Example: TIX25')),
                    SizedBox(height: ScreenUtil.instance.setWidth(15)),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: ScreenUtil.instance.setWidth(40),
                        child: RaisedButton(
                            child: Text(couponButtonText,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            onPressed: promoCodeController.text == "" ||
                                    promoCodeController == null
                                ? () {}
                                : isPromoCodePressed == true
                                    ? () {
                                        setState(() {
                                          isPromoCodePressed = false;
                                          couponButtonText = 'APPLY';
                                          showCheck = false;
                                          buttonColor = eventajaGreenTeal;
                                          promoCodeController.text = "";
                                          total = int.parse(thisTicketPrice);
                                        });
                                      }
                                    : () {
                                        setState(() {
                                          isPromoCodePressed = true;
                                        });
                                        postPromoCode();
                                      },
                            color: promoCodeController.text == "" ||
                                    promoCodeController == null
                                ? Colors.grey
                                : buttonColor))
                  ])),
          SizedBox(height: ScreenUtil.instance.setWidth(50)),
          Container(
              padding: EdgeInsets.all(15),
              color: Colors.white,
              height: ScreenUtil.instance.setWidth(150),
              width: MediaQuery.of(context).size.width,
              child: Column(children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Ticket Price'),
                      SizedBox(width: ScreenUtil.instance.setWidth(95)),
                      Text(':'),
                      SizedBox(width: ScreenUtil.instance.setWidth(50)),
                      Text('Rp. ' + thisTicketPrice)
                    ]),
                SizedBox(height: ScreenUtil.instance.setWidth(20)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Processing Fee'),
                      SizedBox(width: ScreenUtil.instance.setWidth(70.5)),
                      Text(':'),
                      SizedBox(width: ScreenUtil.instance.setWidth(50)),
                      Text(pajak.toString())
                    ]),
                SizedBox(height: ScreenUtil.instance.setWidth(20)),
                Align(
                    alignment: Alignment.centerRight,
                    child: Divider(
                        height: ScreenUtil.instance.setWidth(10), indent: 150)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Total'),
                      SizedBox(width: ScreenUtil.instance.setWidth(135)),
                      Text(':'),
                      SizedBox(width: ScreenUtil.instance.setWidth(50)),
                      Text(
                        'Rp. ' + total.toString(),
                        style: TextStyle(
                            color: eventajaGreenTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil.instance.setSp(20)),
                        textAlign: TextAlign.end,
                      )
                    ]),
              ]))
        ],
      ),
    );
  }

  Future postPromoCode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var session;

    setState(() {
      session = preferences.getString('Session');
    });

    Map<String, dynamic> body = {
      'X-API-KEY': API_KEY,
      'code': promoCodeController.text,
      'quantity': preferences.getString('ticket_many'),
      'ticketID': preferences.getString('TicketID'),
      'paymentID': preferences.getString('payment_method_id')
    };

    String url = BaseApi().apiUrl + '/promo/check';
    final response = await http.post(url,
        headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session},
        body: body);

    print(response.statusCode);
    print(response.body);
    print(preferences.getString('TicketID'));

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        var extractedJson = json.decode(response.body);
        promoData = extractedJson;
        desc = extractedJson['desc'];

        if (desc == 'Promo Checked' && isPromoCodePressed == true) {
          setState(() {
            showCheck = true;
            buttonColor = Colors.red;
            couponButtonText = 'REMOVE PROMO CODE';
            iconStatusColor = eventajaGreenTeal;
            iconStatus = Icons.check;
          });
        } else if (desc == 'Promo not valid') {
          setState(() {
            showCheck = true;
            iconStatus = Icons.close;
            iconStatusColor = Colors.red;
          });
        } else {
          setState(() {
            buttonColor = eventajaGreenTeal;
            couponButtonText = 'APPLY';
            iconStatusColor = Colors.red;
            iconStatus = Icons.close;
            showCheck = true;
          });
        }

        print('desc');

        total = int.parse(
            promoData['data']['amount_detail']['price_after_discount']);
      });
    } else if (response.statusCode == 400) {
      setState(() {
        var extractedJson = json.decode(response.body);
        promoData = extractedJson;
        desc = extractedJson['desc'];
      });

      if (desc == 'Promo not valid') {
        setState(() {
          showCheck = true;
          iconStatus = Icons.close;
          iconStatusColor = Colors.red;
        });
      }
    }
  }
}
