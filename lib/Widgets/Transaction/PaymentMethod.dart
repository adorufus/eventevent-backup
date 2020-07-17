import 'dart:convert';

import 'package:eventevent/Widgets/Transaction/Xendit/TicketReview.dart';
import 'package:eventevent/Widgets/Transaction/Xendit/vaList.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Alfamart/WaitingTransactionAlfamart.dart';

class PaymentMethod extends StatefulWidget {
  final List answerList;
  final List customFormId;
  final bool isCustomForm;

  const PaymentMethod(
      {Key key, this.answerList, this.customFormId, this.isCustomForm})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PaymentMethodState();
  }
}

class PaymentMethodState extends State<PaymentMethod> {
  List paymentMethodList = [];

  String paymentAmount = '0';

  Future getPaymentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String data = prefs.getString('ticket_price_total');
    setState(() {
      paymentAmount = data;
    });

    print(paymentAmount);
  }

  savePaymentInfo(String fee, String methodID, {String paymentCode}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('ticket_fee', fee);
    prefs.setString('payment_method_id', methodID);
    prefs.setString('payment_code', paymentCode);
  }

  @override
  void initState() {
    getPaymentData();
    super.initState();
    getPaymentMethod();
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
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
              size: 40,
            )),
        centerTitle: true,
        title: Text('PAYMENT', style: TextStyle(color: eventajaGreenTeal)),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 13),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil.instance.setWidth(100),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Transfer Amount'.toUpperCase(),
                        style: TextStyle(
                            fontSize: ScreenUtil.instance.setSp(14),
                            color: Colors.grey)),
                    SizedBox(height: ScreenUtil.instance.setWidth(8)),
                    Text('Rp. $paymentAmount',
                        style: TextStyle(
                            fontSize: 35, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              paymentMethodList == null
                  ? CupertinoActivityIndicator(radius: 20)
                  : Container(
                      height: MediaQuery.of(context).size.height * 1.5,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: paymentMethodList == null
                            ? 0
                            : paymentMethodList.length,
                        itemBuilder: (BuildContext context, i) {
                          return GestureDetector(
                            onTap: () {
                              if (paymentMethodList[i]['method'] ==
                                  'Virtual Account') {
                                savePaymentInfo(paymentMethodList[i]['fee'],
                                    paymentMethodList[i]['id']);
                                print(paymentMethodList[i]['id']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext contex) =>
                                          VirtualAccountListWidget()),
                                );
                              } else if (paymentMethodList[i]['id'] == '3') {
                                savePaymentInfo(paymentMethodList[i]['fee'],
                                    paymentMethodList[i]['id']);
                                print(paymentMethodList[i]['id']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        TicketReview(
                                      isCustomForm: widget.isCustomForm,
                                      customFormId: widget.customFormId,
                                      customFormList: widget.answerList,
                                    ),
                                  ),
                                );
                              } else if (paymentMethodList[i]['vendor'] ==
                                  'midtrans'.toLowerCase()) {
                                if (paymentMethodList[i]['id'] == '1') {
                                  savePaymentInfo(paymentMethodList[i]['fee'],
                                      paymentMethodList[i]['id']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          TicketReview(
                                        isCustomForm: widget.isCustomForm,
                                        customFormId: widget.customFormId,
                                        customFormList: widget.answerList,
                                      ),
                                    ),
                                  );
                                } else if (paymentMethodList[i]['id'] == '5') {
                                  savePaymentInfo(paymentMethodList[i]['fee'],
                                      paymentMethodList[i]['id']);
                                  print('payment method used: ' +
                                      paymentMethodList[i]['id']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          TicketReview(
                                        isCustomForm: widget.isCustomForm,
                                        customFormId: widget.customFormId,
                                        customFormList: widget.answerList,
                                      ),
                                    ),
                                  );
                                } else if (paymentMethodList[i]['id'] == '4') {
                                  savePaymentInfo(paymentMethodList[i]['fee'],
                                      paymentMethodList[i]['id']);
                                  print('payment method used: ' +
                                      paymentMethodList[i]['id']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          TicketReview(
                                        isCustomForm: widget.isCustomForm,
                                        customFormId: widget.customFormId,
                                        customFormList: widget.answerList,
                                      ),
                                    ),
                                  );
                                }
                              } else if (paymentMethodList[i]['id'] == '9') {
                                savePaymentInfo(paymentMethodList[i]['fee'],
                                    paymentMethodList[i]['id']);
                                print('payment method used: ' +
                                    paymentMethodList[i]['id']);
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => widget.customFormId == null || widget.answerList == null ? TicketReview(
                                        isCustomForm: widget.isCustomForm
                                      ) : TicketReview(
                                        customFormId: widget.customFormId,
                                        isCustomForm: widget.isCustomForm,
                                        customFormList: widget.answerList
                                      )
                                    ));
                              } else if (paymentMethodList[i]['id'] == '7') {
                                savePaymentInfo(paymentMethodList[i]['fee'],
                                    paymentMethodList[i]['id']);
                                print('payment method used: ' +
                                    paymentMethodList[i]['id']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => widget
                                                    .customFormId ==
                                                null ||
                                            widget.answerList == null
                                        ? TicketReview(
                                            isCustomForm: widget.isCustomForm,
                                          )
                                        : TicketReview(
                                            customFormId: widget.customFormId,
                                            isCustomForm: widget.isCustomForm,
                                            customFormList: widget.answerList,
                                          ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  // Padding(
                                  //   padding: const EdgeInsets.only(left: 2, bottom: 4),
                                  //   child: Text(
                                  //     paymentMethodList[i]['method'] == null
                                  //         ? ''
                                  //         : paymentMethodList[i]['method'],
                                  //     style: TextStyle(
                                  //         fontWeight: FontWeight.bold),
                                  //   ),
                                  // ),
                                  Container(
                                    height: ScreenUtil.instance.setWidth(60),
                                    width: MediaQuery.of(context).size.width,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 5,
                                              spreadRadius: 5,
                                              color: Color(0xff8a8a8b)
                                                  .withOpacity(.1))
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Row(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: SizedBox(
                                              child: Image(
                                            image: paymentMethodList[i]
                                                        ['photo'] ==
                                                    null
                                                ? AssetImage('assets/white.png')
                                                : NetworkImage(
                                                    paymentMethodList[i]
                                                        ['photo']),
                                            width: paymentMethodList[i]['method'] ==
                                  'Virtual Account' ? ScreenUtil.instance
                                                .setWidth(200) : ScreenUtil.instance
                                                .setWidth(150),
                                          )),
                                        ),
                                        Expanded(child: SizedBox()),
                                        Icon(
                                          Icons.navigate_next,
                                          color: Colors.black,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
            ],
          )
        ],
      ),
    );
  }

  Future getPaymentMethod() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var session;
    setState(() {
      session = preferences.getString('Session');
    });

    String paymentMethodURI = BaseApi().apiUrl +
        '/payment_method/list?X-API-KEY=$API_KEY&indomaret=true';

    final response = await http.get(paymentMethodURI, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': session
    }).timeout(Duration(seconds: 30));

    print(response.body);

    if (response.statusCode == 200) {
      if(!mounted) return;
      setState(() {
        var extractedData = json.decode(response.body);
        print(extractedData['data'].runtimeType);

        if(extractedData['data'].runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>'){
          extractedData['data'].forEach((k, v) => paymentMethodList.add(v));
          print(paymentMethodList);
        } else {
          paymentMethodList = extractedData['data'];
        }

      });
    }
  }

  Future getMidtransFee() async {}
}
