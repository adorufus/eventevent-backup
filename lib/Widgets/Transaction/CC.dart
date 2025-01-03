import 'dart:convert';

import 'package:eventevent/Widgets/Transaction/AddCreditCard.dart';
import 'package:eventevent/Widgets/TransactionHistory.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/WebView.dart';
import 'package:eventevent/helper/WebView3DS.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/countdownCounter.dart';
import 'package:eventevent/helper/utils.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mid_flutter/mid_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreditCardInput extends StatefulWidget {
  final String transactionID;
  final expDate;

  const CreditCardInput({Key key, this.transactionID, this.expDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CreditCardInputState();
  }
}

class CreditCardInputState extends State<CreditCardInput> {
  String month;
  String hour;
  String min;
  String sec;

  List<RegExp> listOfPattern = new List<RegExp>();

  RegExp visa = new RegExp(r"^4[0-9]$");

  RegExp mastercard = new RegExp(r"^5[1-5]$");

  RegExp discover = new RegExp(r"^6(?:011|5[0-9]{2})$");

  RegExp ameExp = new RegExp(r"^3[47]$");

  Image visaImg;
  Image mastercardImg;
  Image amexImg;
  Image discoverImg;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isShowBackView = false;
  String _error = "";
  String _result = "";

  int seconds;
  bool isMakePayment = false;

  DateTime dateTime;

  Map<String, dynamic> paymentData;

  @override
  void initState() {
    super.initState();
    getTransactionDetail();

    listOfPattern.add(visa);
    listOfPattern.add(mastercard);
    listOfPattern.add(discover);
    listOfPattern.add(ameExp);

    visaImg = Image.asset('assets/drawable/visa.png');
    mastercardImg = Image.asset('assets/drawable/mastercard.png');
    amexImg = Image.asset('assets/drawable/amex.png');
    discoverImg = Image.asset('assets/drawable/discover.png');
    final salesDay = DateTime.parse(widget.expDate);
    final remaining = salesDay.difference(DateTime.now());
    seconds = remaining.inSeconds;
  }

  _makePayment() {
    setState(() {
      isMakePayment = true;
    });
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        bottomNavigationBar: GestureDetector(
          onTap: () async {
            checkMidtransCC();
            // Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewTest(url: paymentData['payment']['data_vendor']['payment_url'])));
          },
          child: Container(
              height: ScreenUtil.instance.setWidth(50),
              color: Colors.orange,
              child: Center(
                child: Text(
                  'CONFIRM',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.instance.setSp(20)),
                ),
              )),
        ),
        appBar: AppBar(
          brightness: Brightness.light,
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionHistory()));
            },
            child: Icon(
              Icons.close,
              color: eventajaGreenTeal,
            ),
          ),
        ),
        body: paymentData == null
            ? Container()
            : ListView(
                children: <Widget>[
                  Container(
                    height: ScreenUtil.instance.setWidth(380),
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 15),
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
                                height: ScreenUtil.instance.setWidth(20),
                              ),
                              Text('Complete Payment In',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.instance.setSp(14),
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: ScreenUtil.instance.setWidth(20),
                              ),
                              CountDownTimer(
                                secondsRemaining: seconds,
                                whenTimeExpires: () {},
                                countDownTimerStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.instance.setSp(38),
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                  Text('${widget.expDate}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
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
                              'Rp' +
                                  formatPrice(
                                      price: paymentData['amount_detail']
                                          ['final_amount']),
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
                  SizedBox(height: ScreenUtil.instance.setWidth(5)),
                  CreditCardWidget(
                    cardNumber: cardNumber,
                    cardHolderName: cardHolderName,
                    expiryDate: expiryDate,
                    cvvCode: cvvCode,
                    showBackView: isShowBackView,
                    height: 175,
                    width: MediaQuery.of(context).size.width,
                    animationDuration: Duration(milliseconds: 100),
                  ),
                  CreditCardForm(
                    themeColor: eventajaGreenTeal,
                    onCreditCardModelChange: onCreditCardModelChange,
                  ),
                  Container(),
                  Container(),
                  Container()
                ],
              ),
      ),
    );
  }

  Future checkMidtransCC() async {
    String baseApi = BaseApi.midtransUrlProd +
        'v2/token?client_key=$MIDTRANS_CLIENT_KEY&card_number=$cardNumber&card_exp_month=${expiryDate.split("/")[0]}&card_exp_year=20${expiryDate.split("/")[1]}&card_cvv=$cvvCode';
    print(baseApi);
    final response = await http.get(baseApi, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization':
          'Basic ${base64.encode(utf8.encode(MIDTRANS_SERVER_KEY + ':'))}'
    });

    var extractedData = json.decode(response.body);

    if (response.statusCode == 200) {
      print(response.body);
      if (extractedData['status_code'] == '200') {
        midtransCC3DS(extractedData['token_id']);
      } else {
        for (int i = 0; i < extractedData['validation_messages'].length; i++) {
          var error = extractedData['validation_messages'].toString();
          print(error);
          Flushbar(
            animationDuration: Duration(milliseconds: 500),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
            message: error,
          ).show(context);
        }
      }
    }
  }

  Future midtransCC3DS(String token_id) async {
    String baseApi = BaseApi.midtransUrlProd + 'v2/charge';
    var encodingBody = json.encode({
      "payment_type": "credit_card",
      "transaction_details": {
        "order_id": paymentData['transaction_code'],
        "gross_amount": int.parse(paymentData['amount'])
      },
      "credit_card": {
        "token_id": token_id,
        "authentication": true,
        "bank": "maybank"
      },
      "item_details": [
        {
          "id": paymentData['paid_ticket_id'],
          "price": int.parse(paymentData['ticket']['final_price']),
          "quantity": int.parse(paymentData['quantity']),
          "name": paymentData['ticket']['ticket_name'],
        },
        {
          'id': "eventevent_fee",
          'name': "Fee",
          'price': int.parse(paymentData['amount_detail']['final_fee']),
          'quantity': 1
        }
      ],
      "customer_details": {
        "first_name": paymentData['firstname'],
        "last_name": paymentData['lastname'],
        "email": paymentData['email'],
        "phone": paymentData['phone'],
      }
    });

    // var encodedBody = json.encode({
    //   'payment_type': "credit_card",
    //   'credit_card': {
    //     'token_id': token_id,
    //     'authentication': true,
    //   },
    //   'transaction_details': {
    //     "order_id": paymentData['transaction_code'],
    //     "gross_amount": int.parse(paymentData['amount']),
    //   },
    //   'item_details': [
    //     {
    //       'id': paymentData['paid_ticket_id'],
    //       'name': paymentData['ticket']['ticket_name'],
    //       'price': int.parse(paymentData['ticket']['final_price']),
    //       'quantity': int.parse(paymentData['quantity'])
    //     },
    //     {
    //       'id': "eventevent_fee",
    //       'name': "Fee",
    //       'price': int.parse(paymentData['amount_detail']['final_fee']),
    //       'quantity': 1
    //     }
    //   ],
    //   'customer_details': {
    //     "first_name": paymentData['firstname'],
    //     "last_name": paymentData['lastname'],
    //     "email": paymentData['email'],
    //     "phone": paymentData['phone'],
    //   },
    // });
    print(encodingBody);
    print(baseApi);
    final response = await http.post(baseApi, body: encodingBody, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization':
          'Basic ${base64.encode(utf8.encode(MIDTRANS_SERVER_KEY + ':'))}'
    });

    var extractedData = json.decode(response.body);
    print(response.statusCode);

    if (response.statusCode == 201 || response.statusCode == 200) {
      print(response.body);
      if (extractedData['status_code'] == "201") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebView3DS(
              transaction_id: extractedData['transaction_id'],
              url: extractedData['redirect_url'],
            ),
          ),
        ).then((result) {
          Flushbar(
            backgroundColor: Colors.red,
            animationDuration: Duration(milliseconds: 500),
            duration: Duration(seconds: 4),
            flushbarPosition: FlushbarPosition.TOP,
            message: result,
          ).show(context);
        });
      }
    } else {
      print(response.body);
    }
  }

  void onCreditCardModelChange(CreditCardModel data) {
    setState(() {
      print(expiryDate.split("/")[0]);
      cardNumber = data.cardNumber;
      cardHolderName = data.cardHolderName;
      expiryDate = data.expiryDate;
      cvvCode = data.cvvCode;
      isShowBackView = data.isCvvFocused;
    });
  }

  Future getTransactionDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var session;

    setState(() {
      session = prefs.getString('Session');
    });

    String url = BaseApi().apiUrl +
        '/ticket_transaction/detail?transID=${widget.transactionID}&X-API-KEY=${API_KEY}';
    final response = await http
        .get(url, headers: {'Authorization': AUTH_KEY, 'cookie': session});

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      var extractedData = json.decode(response.body);
      setState(() {
        paymentData = extractedData['data'];
        print(paymentData);
      });
    }
  }
}
