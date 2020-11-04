import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/DiscoverMerchModel.dart';
import 'package:eventevent/Widgets/merch/MerchDashboard.dart' as appProps;
import 'package:eventevent/Widgets/merch/MerchDetails.dart';
import 'package:eventevent/Widgets/merch/MerchItem.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmerchRecommendation extends StatefulWidget {
  final List<String> categoryIds;

  const EmerchRecommendation({Key key, this.categoryIds}) : super(key: key);

  @override
  _EmerchRecommendationState createState() => _EmerchRecommendationState();
}

class _EmerchRecommendationState extends State<EmerchRecommendation> {
  void handleInitialBuild(appProps.AppScreenProps props) {
    props.getDiscoverMerch();
  }

  @override
  Widget build(BuildContext context) {
    // print("debug emerch");
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil.instance.setWidth(23 * 1.1),
                    width: ScreenUtil.instance.setWidth(95 * 1.1),
                                  child: Image.asset(
                          'assets/drawable/emerch-logo.png',
                          fit: BoxFit.fill,
                        ),
                ),
                // SizedBox(width: 10),
                //       Text('Recommendations',)
              ],
            )
          ),
          StoreConnector<AppState, appProps.AppScreenProps>(
              converter: (store) => appProps.mapStateToProps(store, isInRecommendation: true, categoryIds: widget.categoryIds),
              onInitialBuild: (props) => handleInitialBuild(props),
              builder: (context, props) {
                List<DiscoverMerchModel> discoverMerchData =
                    props.listDiscoverResponse.data;

                return Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: discoverMerchData.length <= 0
                        ? 0
                        : discoverMerchData.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MerchDetails(
                                  merchId: discoverMerchData[i].merchId),
                            ),
                          );
                        },
                        child: MerchItem(
                          imageUrl: discoverMerchData[i].imageUrl,
                          price: "Rp. " +
                              discoverMerchData[i].details[0]['basic_price'],
                          title: discoverMerchData[i].productName,
                          color: Color(0xFF34B323),
                          merchantName: discoverMerchData[i].merchantName,
                          profilePictUrl: discoverMerchData[i].profileImageUrl,
                        ),
                      );
                    },
                  ),
                );
              })
        ],
      ),
    );
  }
}
