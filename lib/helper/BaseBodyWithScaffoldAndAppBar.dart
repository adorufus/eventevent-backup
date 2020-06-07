import 'package:flutter/material.dart';

class BaseBodyWithScaffoldAndAppBar extends StatefulWidget {
  final String title;
  final customAppBar;
  final bottomNavBar;
  final Widget body;

  const BaseBodyWithScaffoldAndAppBar({Key key, this.title, this.body, this.customAppBar, this.bottomNavBar}) : super(key: key);
  @override
  _BaseBodyWithScaffoldAndAppBarState createState() => _BaseBodyWithScaffoldAndAppBarState();
}

class _BaseBodyWithScaffoldAndAppBarState extends State<BaseBodyWithScaffoldAndAppBar> {
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
              title: Text(widget.title),
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
      bottomNavigationBar: widget.bottomNavBar != null ? widget.bottomNavBar : Container(),
      body: widget.body,
    );
  }
}