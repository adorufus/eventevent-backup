import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressItem extends StatelessWidget {
  final addressName;
  final fullAddress;

  const AddressItem({Key key, this.addressName, this.fullAddress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
      width: MediaQuery.of(context).size.width,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 15,
              width: 15,
              child: Image.asset('assets/icons/icon_apps/location.png'),
            ),
            SizedBox(
              width: 9,
            ),
            Expanded(
              child: Container(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    'Address 1',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
                Container(
                  width: ScreenUtil.instance.setWidth(280),
                  child: Text(
                    'Jl Jend Gatot Subroto Kav 23 Graha BIP Lt 9,Karet Semanggi',
                    style: TextStyle(fontSize: 13),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            Radio(value: null, groupValue: null, onChanged: null)
          ],
        ),
      ),
    );
  }
}