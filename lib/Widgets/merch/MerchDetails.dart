import 'dart:async';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/MerchDetailModel.dart';
import 'package:eventevent/Models/MerchLoveModels.dart';
import 'package:eventevent/Redux/Actions/MerchDetailsActions.dart';
import 'package:eventevent/Redux/Actions/MerchLoveAction.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/merch/BuyOptionSelector.dart';
import 'package:eventevent/Widgets/merch/MerchCommentDetail.dart';
import 'package:eventevent/Widgets/merch/MerchLove.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redux/redux.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MerchDetails extends StatefulWidget {
  final merchId;
  final minimalData;

  const MerchDetails({Key key, this.merchId, this.minimalData})
      : super(key: key);
  @override
  _MerchDetailsState createState() => _MerchDetailsState();
}

typedef OnMerchLoveAddItem = Function(
    String productId, bool isLoved, int loveCount);
typedef OnMerchLoved = Function(MerchLoveModel item);

class _MerchDetailsState extends State<MerchDetails> {
  StreamController<String> controllerUrl = StreamController<String>();
  int currentTab = 0;
  String currentUserID = "";
  SharedPreferences preferences;
  String generatedLink = "";

  BranchContentMetaData metaData;
  BranchUniversalObject buo;
  BranchLinkProperties lp;
  BranchEvent eventStandard;
  BranchEvent eventCustom;

  void initDeepLinkData({String merchName, String imageUrl, String merchId}) {
    setState(() {
      metaData = BranchContentMetaData()
          .addCustomMetadata('merch_name', merchName)
          .addCustomMetadata('merch_id', merchId)
          .addCustomMetadata('image_url', imageUrl)
          .addCustomMetadata('merch_detail', widget.minimalData.toString());

      buo = BranchUniversalObject(
          canonicalIdentifier: 'merch_$merchId',
          title: merchName,
          imageUrl: imageUrl,
          contentDescription: 'you can see the merch description on the app',
          contentMetadata: metaData,
          publiclyIndex: true,
          keywords: [],
          locallyIndex: true);
    });

    print('Branch universal object' +
        buo.contentMetadata.customMetadata.toString());

    FlutterBranchSdk.registerView(buo: buo);
    FlutterBranchSdk.listOnSearch(buo: buo);

    lp = BranchLinkProperties(
      feature: "sharing",
    );

    lp.addControlParam(
        '\$desktop_url', 'http://eventevent.com/merch/product/$merchId');
  }

  void generateLink() async {
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);

    if (response.success) {
      print('generated link: ' + response.result);
      setState(() {
        generatedLink = response.result;
      });
    } else {
      controllerUrl.sink
          .add('Error: ${response.errorCode} - ${response.errorDescription}');
    }
  }

  void initialization() async {
    preferences = await SharedPreferences.getInstance();

    currentUserID = preferences.getString("Last User ID");

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    print("minimalData: " + widget.minimalData.toString());

    initialization();
    initDeepLinkData(
      imageUrl: widget.minimalData['imageUrl'],
      merchId: widget.merchId,
      merchName: widget.minimalData['productName'],
    );

    generateLink();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, MerchDetailScreenProps>(
      converter: (store) => mapStateToProps(store),
      onInitialBuild: (props) => props.getMerchDetail(widget.merchId),
      builder: (context, props) => Scaffold(
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
                    onTap: () {
                      if (generatedLink != null || generatedLink != "") {
                        ShareExtend.share(generatedLink, 'text');
                      }
                    }),
                SizedBox(width: ScreenUtil.instance.setWidth(8)),
                actionButton(
                  icons: Icons.more_vert,
                ),
                SizedBox(width: ScreenUtil.instance.setWidth(8)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 25.7),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, -1),
                  blurRadius: 2,
                  color: Color(0xff8a8a8b).withOpacity(.2),
                  spreadRadius: 1.5)
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Buy this product',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff231f20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: SizedBox(),
              ),
              props.merchDetailResponse.loading == true
                  ? Container()
                  : priceButton(data: props.merchDetailResponse.data)
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            child: ListView(
              children: <Widget>[
                Container(
                  // height: ScreenUtil.instance
                  //     .setWidth(MediaQuery.of(context).size.height / 1.05),
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
                            props.merchDetailResponse.loading == true
                                ? HomeLoadingScreen().merchImageDetailLoading()
                                : imageItem(
                                    data: props.merchDetailResponse.data),
                            SizedBox(
                              height: 12,
                            ),
                            props.merchDetailResponse.loading == true
                                ? Container()
                                : productName(
                                    data: props.merchDetailResponse.data),
                            SizedBox(
                              height: 6,
                            ),
                            props.merchDetailResponse.loading == true
                                ? HomeLoadingScreen()
                                    .merchDetailUsernameWithProfilePicLoading()
                                : usernameWithProfilePic(
                                    data: props.merchDetailResponse.data),
                            SizedBox(height: 25),
                            props.merchDetailResponse.loading == true
                                ? Container()
                                : itemButton(
                                    data: props.merchDetailResponse.data)
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 28.4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          contactButton(
                              image: 'assets/icons/btn_phone.png',
                              onTap: () {
                                launch('tel:' +
                                    props.merchDetailResponse.data
                                        .merchantDetails.phone);
                              }),
                          SizedBox(width: 50),
                          contactButton(
                            image: 'assets/icons/btn_mail.png',
                            onTap: () {
                              if (props.merchDetailResponse.data.merchantDetails
                                          .email !=
                                      null ||
                                  props.merchDetailResponse.data.merchantDetails
                                          .email !=
                                      "") {
                                launch(
                                  'mailto:' +
                                      props.merchDetailResponse.data
                                          .merchantDetails.email,
                                );
                              }
                            },
                          ),
                          SizedBox(width: 50),
                          contactButton(
                            image: 'assets/icons/btn_web.png',
                            onTap: () {
                              launch(props.merchDetailResponse.data
                                  .merchantDetails.website);
                            },
                          ),
                        ],
                      ),
                      // Expanded(child: SizedBox()),
                      SizedBox(
                        height: 15,
                      ),
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
                currentTab == 0
                    ? props.merchDetailResponse.loading == true
                        ? Container()
                        : details(data: props.merchDetailResponse.data)
                    : commentButton(
                        data: props.merchDetailResponse.data, props: props)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget itemButton({MerchDetailModel data}) {
    print(data.isLoved);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {},
            child: MerchLove(
              merchId: data.merchId,
              isComment: false,
              loveCount: data.likeCount,
              isAlreadyLoved: data.isLoved,
            ),
          ),
          SizedBox(
            width: ScreenUtil.instance.setWidth(10),
          ),
          MerchLove(
            merchId: data.merchId,
            isComment: true,
            commentCount: data.commentCount,
            isAlreadyCommented: true,
          ),
          Expanded(
            child: SizedBox(),
          ),
          priceButton(data: data)
        ],
      ),
    );
  }

  Widget priceButton({MerchDetailModel data}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString(
            "sellerProductId", data.merchantDetails.merchantId);
        preferences.setString("productId", data.merchId);
        preferences.setString("productName", data.productName);
        preferences.setString("productPrice", data.details[0]['basic_price']);
        preferences.setString("productImage", data.imageUrl);
        preferences.setString("productDetailsId", data.details[0]['id']);

        print(preferences.getString("sellerProductId"));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyOptionSelector(),
          ),
        );
      },
      child: Container(
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
          'Rp. ${data.details[0]['basic_price']},-',
          style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil.instance.setSp(14),
              fontWeight: FontWeight.bold),
        )),
      ),
    );
  }

  Widget productName({MerchDetailModel data}) {
    return Flexible(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 13),
          width:
              ScreenUtil.instance.setWidth(MediaQuery.of(context).size.width),
          child: Text(
            data.productName,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: ScreenUtil.instance.setSp(16),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget usernameWithProfilePic({MerchDetailModel data}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 10,
            backgroundImage: NetworkImage(data.profileImageUrl),
            backgroundColor: Colors.grey,
          ),
          SizedBox(width: ScreenUtil.instance.setWidth(3)),
          Container(
            width: ScreenUtil.instance.setWidth(112),
            child: Text(
              data.merchantName,
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

  Widget commentButton({MerchDetailModel data, MerchDetailScreenProps props}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 13),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => MerchCommentDetail(
                    merchId: data.merchId,
                  ),
                ),
              )
                  .then((onValue) {
                props.getMerchDetail(widget.merchId);
              });
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
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount:
                data == null || data.comments == null || data.comments.isEmpty
                    ? 0
                    : data.comments.length,
            itemBuilder: (context, i) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(data.comments[i]['user']['photo']),
                ),
                title: Text(
                  data.comments[i]['user']['fullName'] + '' + ': ',
                  style: TextStyle(
                      fontSize: ScreenUtil.instance.setSp(12),
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data.comments[i]['comment']),
                trailing: data.comments[i]['user_id'] == currentUserID
                    ? Container(
                        height: 50,
                        width: 50,
                        child: GestureDetector(
                          onTap: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (thisContext) {
                                return CupertinoAlertDialog(
                                  title: Text('Notice'),
                                  content: Text(
                                    'Do you want to delete this comment?',
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.of(
                                          thisContext,
                                        ).pop();
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(
                                          thisContext,
                                        ).pop();
                                        deleteComment(
                                          data.comments[i]['id'],
                                        ).then(
                                          (response) {
                                            data.comments.removeAt(i);
                                            if (mounted) setState(() {});
                                            if (response.statusCode == 200 ||
                                                response.statusCode == 201) {
                                              print(response.body);
                                            } else {
                                              print(response.body);
                                              Flushbar(
                                                backgroundColor: Colors.red,
                                                flushbarPosition:
                                                    FlushbarPosition.TOP,
                                                animationDuration:
                                                    Duration(milliseconds: 500),
                                                duration: Duration(seconds: 3),
                                                message: response.body,
                                              ).show(context);
                                            }
                                          },
                                        ).catchError((err) {
                                          Flushbar(
                                                  backgroundColor: Colors.red,
                                                  flushbarPosition:
                                                      FlushbarPosition.TOP,
                                                  animationDuration: Duration(
                                                      milliseconds: 500),
                                                  duration:
                                                      Duration(seconds: 3),
                                                  message: err.toString())
                                              .show(context);
                                        });
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      )
                    : Container(width: 100),
              );
            },
          )
        ],
      ),
    );
  }

  Widget imageItem({MerchDetailModel data}) {
    return Container(
      width: ScreenUtil.instance.setWidth(330),
      height: ScreenUtil.instance.setHeight(330),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey,
        image: DecorationImage(
          image: NetworkImage(data.imageUrl),
          fit: BoxFit.cover,
        ),
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

  Widget details({MerchDetailModel data}) {
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
            data.productName,
            style: TextStyle(
                color: eventajaBlack,
                fontSize: 16.3,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 22,
          ),
          Text(data.description)
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
      behavior: HitTestBehavior.opaque,
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
      child: Container(
        height: ScreenUtil.instance.setWidth(50),
        width: ScreenUtil.instance.setWidth(50),
        child: Image.asset(image),
      ),
    );
  }

  Future<http.Response> deleteComment(String commentId) async {
    String baseUrl = BaseApi().apiUrl;
    String finalUrl = baseUrl + '/product/delete_comment';

    final response = await http.post(
      finalUrl,
      body: {
        'X-API-KEY': API_KEY,
        'commentId': commentId,
      },
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session'),
      },
    );

    return response;
  }
}

class MerchDetailScreenProps {
  final MerchDetailState merchDetailResponse;
  final Function getMerchDetail;

  MerchDetailScreenProps({this.merchDetailResponse, this.getMerchDetail});
}

MerchDetailScreenProps mapStateToProps(Store<AppState> store) {
  return MerchDetailScreenProps(
      merchDetailResponse: store.state.merchDetails,
      getMerchDetail: (merchId) => store.dispatch(getMerchDetail(merchId)));
}
