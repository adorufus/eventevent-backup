import 'package:eventevent/Widgets/merch/CollectionItem.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';

class PopularItem extends StatefulWidget {
  final bool loading;
  final data;

  const PopularItem({Key key, this.loading, this.data}) : super(key: key);

  @override
  _PopularItemState createState() => _PopularItemState();
}

class _PopularItemState extends State<PopularItem> {
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
              title: Text('Popular'),
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
      body: ListView.builder(
        itemCount: widget.data == null ? 0 : widget.data.length,
        padding: EdgeInsets.only(bottom: 13, left: 13, right: 13),
        itemBuilder: (context, i) {
          return CollectionItem(
            image: widget.data[i].imageUrl,
            itemColor: eventajaGreenTeal,
            profileImage: widget.data[i].profileImageUrl,
            itemPrice: 'Rp. ' + widget.data[i].details[0]['basic_price'],
            title: widget.data[i].productName,
            username: widget.data[i].merchantName,
          );
        },
      ),
    );
  }
}
