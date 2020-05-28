import 'package:eventevent/Widgets/merch/MerchLove.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MerchDetails extends StatefulWidget {
  @override
  _MerchDetailsState createState() => _MerchDetailsState();
}

class _MerchDetailsState extends State<MerchDetails> {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(75),
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
            actions: <Widget>[
              actionButton(
                icons: Icons.share,
              ),
              SizedBox(width: ScreenUtil.instance.setWidth(8)),
              actionButton(
                icons: Icons.more_vert,
              ),
              SizedBox(width: ScreenUtil.instance.setWidth(8)),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: ListView(
            children: <Widget>[
              Container(
                height: ScreenUtil.instance
                    .setWidth(MediaQuery.of(context).size.height / 1.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.2),
                      blurRadius: 2.5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 15.3),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 13),
                      padding: EdgeInsets.symmetric(vertical: 13),
                      height: ScreenUtil.instance.setWidth(455),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.2),
                            blurRadius: 2.5,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          imageItem(),
                          SizedBox(
                            height: 12,
                          ),
                          usernameWithProfilePic(),
                          SizedBox(
                            height: 10,
                          ),
                          productName(),
                          itemButton()
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 28.4,
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          contactButton(
                            image: 'assets/icons/btn_phone.png',
                          ),
                          SizedBox(width: 50),
                          contactButton(
                            image: 'assets/icons/btn_mail.png',
                          ),
                          SizedBox(width: 50),
                          contactButton(
                            image: 'assets/icons/btn_web.png',
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Container(
                      height: ScreenUtil.instance.setWidth(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          tabItem(
                            title: 'Detail',
                            thisCurrentTab: 0,
                            onTap: () {
                              currentTab = 0;
                              if (mounted) setState(() {});
                            },
                          ),
                          tabItem(
                            title: 'Comments',
                            thisCurrentTab: 1,
                            onTap: () {
                              currentTab = 1;
                              if (mounted) setState(() {});
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              currentTab == 0 ? details() : commentButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget itemButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        children: <Widget>[
          MerchLove(
            merchId: 0,
            isComment: false,
            loveCount: 99,
            isAlreadyLoved: true,
          ),
          SizedBox(
            width: ScreenUtil.instance.setWidth(10),
          ),
          MerchLove(
            merchId: 0,
            isComment: true,
            commentCount: '99',
            isAlreadyCommented: true,
          ),
          Expanded(
            child: SizedBox(),
          ),
          priceButton()
        ],
      ),
    );
  }

  Widget priceButton() {
    return Container(
      height: ScreenUtil.instance.setWidth(28),
      width: ScreenUtil.instance.setWidth(120),
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: eventajaGreenTeal.withOpacity(0.4),
            blurRadius: 2,
            spreadRadius: 1.5)
      ], color: eventajaGreenTeal, borderRadius: BorderRadius.circular(15)),
      child: Center(
          child: Text(
        'Rp. 50.0000,-',
        style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil.instance.setSp(14),
            fontWeight: FontWeight.bold),
      )),
    );
  }

  Widget productName() {
    return Flexible(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 13),
          width:
              ScreenUtil.instance.setWidth(MediaQuery.of(context).size.width),
          child: Text(
            'Flowers Logo T-Shirt The 1975',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: ScreenUtil.instance.setSp(16),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget usernameWithProfilePic() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 10,
            backgroundImage: AssetImage('assets/grey-fade.jpg'),
          ),
          SizedBox(width: ScreenUtil.instance.setWidth(3)),
          Container(
            width: ScreenUtil.instance.setWidth(112),
            child: Text(
              'wijaya teknik',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: ScreenUtil.instance.setSp(15),
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget commentButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 13),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => EventDetailComment(
              //           eventID: detailData['id'],
              //         )));
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 13),
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xff8a8a8b).withOpacity(.2),
                        blurRadius: 2,
                        spreadRadius: 1.5)
                  ]),
              child: Center(
                child: Text('Write a Comment',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.5))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageItem() {
    return Container(
      width: ScreenUtil.instance.setWidth(330),
      height: ScreenUtil.instance.setHeight(330),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xfffec97c),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 2.5,
            spreadRadius: 2,
          )
        ],
      ),
    );
  }

  Widget details() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13, vertical: 25),
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 2.5,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Flowers Logo T-shirt The 1975',
            style: TextStyle(
                color: eventajaBlack,
                fontSize: 16.3,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 22,
          ),
          Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.')
        ],
      ),
    );
  }

  Widget tabItem({String title, int thisCurrentTab, Function onTap}) {
    return Flexible(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: ScreenUtil.instance.setWidth(115),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Row(
              //   children: <Widget>[
              //     CircleAvatar(
              //       backgroundImage: ,
              //     )
              //   ],
              // )
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(
                thickness: 2,
                color: currentTab == thisCurrentTab
                    ? eventajaGreenTeal
                    : Theme.of(context).dividerColor,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget actionButton({IconData icons, Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icons,
        color: eventajaGreenTeal,
        size: 30,
      ),
    );
  }

  Widget contactButton({String image, Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: ScreenUtil.instance.setWidth(50),
        width: ScreenUtil.instance.setWidth(50),
        child: Image.asset(image),
      ),
    );
  }
}
