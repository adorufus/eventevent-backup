import 'package:eventevent/Widgets/merch/SelectAddress.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuyOptionSelector extends StatefulWidget {
  @override
  _BuyOptionSelectorState createState() => _BuyOptionSelectorState();
}

class _BuyOptionSelectorState extends State<BuyOptionSelector> {
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
        onTap: (){
          Navigator.push(
            context, MaterialPageRoute(builder: (context) => SelectAddress())
          );
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
            quantitySection(context),
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
            totalSection(context),
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
        Column(
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
            Text(
              'Rp. 200.000',
              style: TextStyle(
                  color: eventajaGreenTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            )
          ],
        )
      ],
    );
  }

  Widget quantitySection(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Quantity',
          style: TextStyle(
              color: eventajaBlack, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Expanded(child: SizedBox()),
        Container(
          width: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: eventajaGreenTeal)),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.remove_circle,
                color: Colors.red,
                size: 30,
              ),
              Expanded(
                child: SizedBox(),
              ),
              Text('2'),
              Expanded(
                child: SizedBox(),
              ),
              Icon(
                Icons.add_circle,
                color: eventajaGreenTeal,
                size: 30,
              )
            ],
          ),
        )
      ],
    );
  }

  Widget sizeSection(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 10;
    final double itemWidth = size.width / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Size',
          style: TextStyle(
              color: eventajaBlack, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Container(
          // height: 100,
          child: GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.all(20),
            childAspectRatio: (itemWidth / itemHeight),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            children: <Widget>[
              Container(
                height: 26,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black),
                ),
                child: Center(child: Text('S')),
              ),
              Container(
                height: 26,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black)),
                child: Center(child: Text('M')),
              ),
              Container(
                height: 26,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black)),
                child: Center(child: Text('L')),
              ),
              Container(
                height: 26,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black)),
                child: Center(child: Text('XL')),
              ),
              Container(
                height: 26,
                width: 80,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15),border: Border.all(color: Colors.black)),
                child: Center(child: Text('XXL')),
              ),
              Container(
                height: 26,
                width: 80,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15),border: Border.all(color: Colors.black)),
                child: Center(child: Text('XXXL')),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget totalSection(BuildContext context){
    return Row(
      children: <Widget>[
        Text(
          'Price',
          style: TextStyle(
              color: eventajaBlack, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Expanded(
          child: SizedBox(),
        ),
        Text(
          'Rp. 400.000',
          style: TextStyle(
              color: eventajaGreenTeal, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}
