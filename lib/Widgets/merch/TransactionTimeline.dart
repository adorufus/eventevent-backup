import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionTimeline extends StatefulWidget {
  final transactionData;

  const TransactionTimeline({Key key, this.transactionData}) : super(key: key);
  @override
  _TransactionTimelineState createState() => _TransactionTimelineState();
}

class _TransactionTimelineState extends State<TransactionTimeline> {
  SharedPreferences preferences;
  String productName = '';
  String subtotal = '';
  String shippingPrice = '';
  String grandtotal = '';
  String uniqueAmount = '';
  String bankFee = '';
  String productImage = '';
  String orderStatus = '';
  String paymentMethodName = '';
  String paymentMethodAccName = '';
  String paymentMethodAccNumber = '';
  String paymentMethodLogo = '';
  // int accumulatedPrice = 0;
  int howMuch = 0;

  void initializeValue() async {
    preferences = await SharedPreferences.getInstance();

    productName = preferences.getString("productName");
    subtotal = widget.transactionData['subtotal'].toString();
    productImage = preferences.getString("productImage");
    orderStatus = widget.transactionData['order_status'];
    subtotal = widget.transactionData['subtotal'].toString();
    grandtotal = widget.transactionData['grandtotal'].toString();
    shippingPrice = widget.transactionData['shipping_price'].toString();
    uniqueAmount = widget.transactionData['unique_amount'].toString();
    bankFee = widget.transactionData['payment']['fee'].toString();
    paymentMethodName =
        widget.transactionData['payment']['method'].toString().toUpperCase();
    paymentMethodAccName =
        widget.transactionData['payment']['data_vendor']['account_name'];
    paymentMethodAccNumber =
        widget.transactionData['payment']['data_vendor']['account_number'];
    paymentMethodLogo =
        widget.transactionData['payment']['data_vendor']['icon'];
    // howMuch = preferences.getInt("productQuantity");
    // accumulatedPrice = productPrice;

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    initializeValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          children: [
            transactionDetails(),
            SizedBox(height: 20),
            horizontalTransactionStepper(),
          ]),
    );
  }

  Widget transactionDetails() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  blurRadius: 1.2,
                  spreadRadius: 2,
                  color: Colors.grey.withOpacity(.5))
            ],
            image: DecorationImage(
              image: NetworkImage(productImage),
              fit: BoxFit.cover,
            )),
      ),
      SizedBox(width: 15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(productName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: eventajaBlack,
                  fontSize: 25)),
          SizedBox(height: 15),
          Row(
            children: <Widget>[
              Container(
                  width: 120,
                  child: Text('subtotal:',
                      style: TextStyle(color: eventajaBlack, fontSize: 12))),
              Container(
                  child: Text('Rp.' + subtotal,
                      style: TextStyle(color: eventajaBlack, fontSize: 12))),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                  width: 120,
                  child: Text('shipping:',
                      style: TextStyle(color: eventajaBlack, fontSize: 12))),
              Text('Rp.' + shippingPrice,
                  style: TextStyle(color: eventajaBlack, fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                  width: 120,
                  child: Text('bank fee:',
                      style: TextStyle(color: eventajaBlack, fontSize: 12))),
              Text('Rp.' + bankFee,
                  style: TextStyle(color: eventajaBlack, fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                  width: 120,
                  child: Text('unique amount:',
                      style: TextStyle(color: eventajaBlack, fontSize: 12))),
              Text('Rp.' + uniqueAmount,
                  style: TextStyle(color: eventajaBlack, fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                  width: 120,
                  child: Text('Total:',
                      style: TextStyle(
                          color: eventajaBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
              Text('Rp.' + grandtotal,
                  style: TextStyle(
                      color: eventajaBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      )
    ]);
  }

  Widget horizontalTransactionStepper() {
    return Container(
        height: 160,
        width: 290,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                blurRadius: 1.2,
                spreadRadius: 2,
                color: Colors.grey.withOpacity(.5))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Transaction Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),
          Divider(),
          Flexible(
              child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.account_balance_wallet,
                      color: orderStatus == 'waiting_payment'
                          ? eventajaGreenTeal
                          : Colors.grey,
                      size: 40,
                    ),
                    Text(
                      'Waiting For \nPayment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          color: orderStatus == 'waiting_payment'
                              ? eventajaGreenTeal
                              : Colors.grey),
                    )
                  ],
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.access_time,
                      color: orderStatus == 'waiting_confirmation'
                          ? eventajaGreenTeal
                          : Colors.grey,
                      size: 40,
                    ),
                    Text(
                      'Waiting \nConfirmation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          color: orderStatus == 'waiting_confirmation'
                              ? eventajaGreenTeal
                              : Colors.grey),
                    )
                  ],
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward,
                  color: orderStatus == 'waiting_confirmation'
                      ? eventajaGreenTeal
                      : Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.local_shipping,
                      color: orderStatus == 'sent'
                              ? eventajaGreenTeal
                              : Colors.grey,
                      size: 40,
                    ),
                    Text(
                      'Shipping \nProccess',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: orderStatus == 'finish'
                              ? eventajaGreenTeal
                              : Colors.grey),
                    )
                  ],
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.pin_drop,
                      color: orderStatus == 'finish'
                              ? eventajaGreenTeal
                              : Colors.grey,
                      size: 40,
                    ),
                    Text(
                      'Finish',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: orderStatus == 'finish'
                              ? eventajaGreenTeal
                              : Colors.grey),
                    )
                  ],
                ),
              ],
            ),
          ))
        ]));
  }
}
