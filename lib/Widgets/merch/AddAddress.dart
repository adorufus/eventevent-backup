import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddAddress extends StatefulWidget {
  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
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
              title: Text('Add Address'),
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13),
          child: ListView(
            cacheExtent: 15,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Masukan provinsi kamu disini',
                  labelText: 'Provinsi',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Masukan Kota / Kabupaten kamu disini',
                  labelText: 'Kota/Kabupaten',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Masukan Kecamatan kamu disini',
                  labelText: 'Kecamatan',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Masukan Kode Pos kamu disini',
                  labelText: 'Kode Pos',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Masukan Alamat Lengkap kamu disini',
                  labelText: 'Kecamatan',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin: EdgeInsets.only(left: 13, right: 13, top: 13),
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1.5)
                    ]),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 15,
                        width: 15,
                        child:
                            Image.asset('assets/icons/icon_apps/location.png'),
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      Container(
                        child: Text(
                          'Pilih Lokasi',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          maxLines: 2,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  height: 35,
                  width: 150,
                  decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: eventajaGreenTeal.withOpacity(0.4),
                          blurRadius: 2,
                          spreadRadius: 1.5,
                        )
                      ],
                      color: eventajaGreenTeal,
                      borderRadius: BorderRadius.circular(30)),
                  child: Center(
                      child: Text(
                    'SAVE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
