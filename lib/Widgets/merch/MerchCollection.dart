import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'CollectionItem.dart';

class MerchCollection extends StatefulWidget {
  @override
  _MerchCollectionState createState() => _MerchCollectionState();
}

class _MerchCollectionState extends State<MerchCollection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil.instance.setWidth(50),
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
              title: Text('Collections'),
              centerTitle: true,
              textTheme: TextTheme(
                  title: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.instance.setSp(14),
                color: Colors.black,
              )),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            children: <Widget>[
              Container(
                height: ScreenUtil.instance.setWidth(200),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xfffec97c),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.2),
                      blurRadius: 2.5,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                'From This Collection',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: eventajaBlack),
              ),
              SizedBox(
                height: 15,
              ),
              ColumnBuilder(
                itemCount: 10,
                itemBuilder: (context, i) {
                  return CollectionItem(
                    image: '',
                    isAvailable: true,
                    itemColor: eventajaGreenTeal,
                    itemPrice: 'Rp. 50.000,-',
                    title: 'Lorem Ipsum Dolor Sit Amet',
                    username: '@Wijaya Teknik',
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
