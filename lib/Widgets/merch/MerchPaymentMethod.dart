import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/Transaction/Xendit/TicketReview.dart';
import 'package:eventevent/Widgets/Transaction/Xendit/vaList.dart';
import 'package:eventevent/Widgets/merch/TransactionTimeline.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eventevent/Widgets/Transaction/Alfamart/WaitingTransactionAlfamart.dart';

class MerchPaymentMethod extends StatefulWidget {
  final shippingName;
  final shippingCode;
  final shippingService;
  final price;

  const MerchPaymentMethod(
      {Key key,
      this.shippingName,
      this.shippingCode,
      this.shippingService,
      this.price})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MerchPaymentMethodState();
  }
}

class MerchPaymentMethodState extends State<MerchPaymentMethod> {
  List paymentMethodList = [];

  String paymentAmount = '0';

  SharedPreferences preferences;
  bool isProcessingTransaction = false;

  Future getPaymentData() async {
    setState(() {
      paymentAmount = widget.price;
    });

    print(paymentAmount);
  }

  savePaymentInfo(String fee, String methodID, {String paymentCode}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('ticket_fee', fee);
    prefs.setString('payment_method_id', methodID);
    prefs.setString('payment_code', paymentCode);
  }

  void initialize() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    initialize();
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
                            fontSize: ScreenUtil.instance.setSp(20),
                            color: Colors.grey)),
                    SizedBox(height: ScreenUtil.instance.setWidth(20)),
                    Text('Rp. ${widget.price}',
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
                              // if (paymentMethodList[i]['method'] ==
                              //     'Virtual Account') {
                              //   savePaymentInfo(paymentMethodList[i]['fee'],
                              //       paymentMethodList[i]['id']);
                              //   print(paymentMethodList[i]['id']);
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (BuildContext contex) =>
                              //             VirtualAccountListWidget()),
                              //   );
                              // }
                              submitTransaction(
                                      paymentMethodId: paymentMethodList[i]
                                          ['id'])
                                  .then((response) {
                                var extractedData = json.decode(response.body);
                                print(extractedData);
                                print(response.statusCode);

                                if (response.statusCode == 201 ||
                                    response.statusCode == 200) {
                                  isProcessingTransaction = false;
                                  if (mounted) setState(() {});

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionTimeline(
                                        transactionData: extractedData['data'],
                                      ),
                                    ),
                                  );

                                  // if()
                                } else {
                                  print(extractedData);
                                  Flushbar(
                                    message:
                                        'Transaction Failed, ${extractedData['desc']}',
                                        backgroundColor: Colors.red,
                                        flushbarPosition: FlushbarPosition.TOP,
                                        animationDuration: Duration(milliseconds: 500),
                                        duration: Duration(seconds: 3),
                                  ).show(context);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      paymentMethodList[i]['method'] == null
                                          ? ''
                                          : paymentMethodList[i]['method'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
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
                                                  .withOpacity(.5))
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
                                            width: paymentMethodList[i]
                                                        ['method'] ==
                                                    'Virtual Account'
                                                ? ScreenUtil.instance
                                                    .setWidth(200)
                                                : ScreenUtil.instance
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

  Future<http.Response> submitTransaction(
      {String paymentMethodId, String virtualAccountVendorId}) async {
    String url = BaseApi().apiUrl + '/product/transaction';
    print(url);
    isProcessingTransaction = true;
    if (mounted) setState(() {});

    print('product id: ' + preferences.getString('productId'));
    print('product detail id: ' + preferences.getString('productDetailsId'));
    print('currentBuyerAddressId: ' + preferences.getString('currentBuyerAddressId'));
    print('product quantity: ' + preferences.getInt('productQuantity').toString());
    print('shipping name: ' + widget.shippingName);
    print('shipping code: ' + widget.shippingCode);
    print('shipping Service: ' + widget.shippingService);

    try {
      final response = await http.post(url, body: {
        'X-API-KEY': API_KEY,
        'productId': preferences.getString("productId"),
        'productDetailId': preferences.getString("productDetailsId"),
        'addressId': preferences.getString("currentBuyerAddressId"),
        'quantity': preferences.getInt("productQuantity").toString(),
        'shippingName': widget.shippingName,
        'shippingCode': widget.shippingCode,
        'shippingService': widget.shippingService,
        'paymentId': paymentMethodId,
        'virtualAccountVendorId':
            virtualAccountVendorId == null ? '' : virtualAccountVendorId,
        'note': '',
      }, headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString("Session")
      });

      return response;
    } on SocketException catch (e) {
      print(e.message);
      isProcessingTransaction = false;
      if (mounted) setState(() {});
      return null;
    }
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
      setState(() {
        var extractedData = json.decode(response.body);
        print(extractedData['data'].runtimeType);

        if (extractedData['data'].runtimeType.toString() ==
            '_InternalLinkedHashMap<String, dynamic>') {
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
