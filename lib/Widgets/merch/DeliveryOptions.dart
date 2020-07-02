import 'package:eventevent/Widgets/merch/SelectAddress.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'AddressItem.dart';

class DeliveryOptions extends StatefulWidget {
  @override
  _DeliveryOptionsState createState() => _DeliveryOptionsState();
}

class _DeliveryOptionsState extends State<DeliveryOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 13),
            color: Colors.white,
            child: AppBar(
              brightness: Brightness.light,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/icons/icon_apps/arrow.png',
                  scale: 5.5,
                  alignment: Alignment.centerLeft,
                ),
              ),
              title: Text('Lorem Ipsum'),
              centerTitle: true,
              textTheme: TextTheme(
                  title: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              )),
            ),
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SelectAddress()));
        },
        child: Container(
          height: ScreenUtil.instance.setWidth(50),
          color: Color(0xFFff8812),
          child: Center(
              child: Text(
            'NEXT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          children: <Widget>[
            topSection(context),
            SizedBox(
              height: 20,
            ),
            Divider(),
            SizedBox(
              height: 12,
            ),
            addressSection(context),
            SizedBox(
              height: 20,
            ),
            Divider(),
            SizedBox(
              height: 12,
            ),
            sizeSection(context),
            SizedBox(
              height: 20,
            ),
            Divider(),
            SizedBox(
              height: 12,
            ),
            totalSection(context, title: 'Subtotal:', price: 'Rp. 410.000'),
          ],
        ),
      ),
    );
  }

  Widget topSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
              color: Color(0xfffec97c),
              borderRadius: BorderRadius.circular(10)),
        ),
        SizedBox(
          width: 15,
        ),
        Container(
          height: 98,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 197,
                child: Text(
                  'Tas dari rotan',
                  style: TextStyle(
                    color: eventajaBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Quantity',
                    style: TextStyle(
                        color: eventajaBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    '(2)',
                    style: TextStyle(
                        color: eventajaGreenTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  )
                ],
              ),
              Expanded(child: SizedBox()),
              Text(
                'Rp. 400.000',
                style: TextStyle(
                    color: eventajaGreenTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget addressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Address',
          style: TextStyle(
              color: eventajaBlack, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        AddressItem(isEditing: false,)
      ],
    );
  }

  Widget sizeSection(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Add Delivery',
              style: TextStyle(
                  color: eventajaBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Expanded(child: SizedBox(),),
            Container(
                height: 26,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey)),
                child: Center(child: Text('Edit', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),)),
              ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        totalSection(context, title: 'J&T Regular (2-4 hari)', price: 'Rp. 10.000')
      ],
    );
  }

  Widget totalSection(BuildContext context, {String title, String price}) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
              color: eventajaBlack, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Expanded(
          child: SizedBox(),
        ),
        Text(
          price,
          style: TextStyle(
              color: eventajaGreenTeal,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ],
    );
  }
}
