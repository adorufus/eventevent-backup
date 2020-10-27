import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/DiscoverMerchModel.dart';
import 'package:eventevent/Widgets/merch/MerchDashboard.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class EmerchRecommendation extends StatefulWidget {
  @override
  _EmerchRecommendationState createState() => _EmerchRecommendationState();
}

class _EmerchRecommendationState extends State<EmerchRecommendation> {

  void handleInitialBuild (AppScreenProps props) {
    props.getDiscoverMerch();
  }

  @override
  Widget build(BuildContext context) {
    print("debug emerch");
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('EMERCH', style: TextStyle(fontWeight: FontWeight.bold, color: eventajaGreenTeal),),
          StoreConnector<AppState, AppScreenProps>(
            converter: (store) => mapStateToProps(store),
            onInitialBuild: (props) => handleInitialBuild(props),
            builder: (context, props) {
              List<DiscoverMerchModel> discoverMerchData = props.listDiscoverResponse.data;

              return Container(
                height: 300,
                child: ListView.builder(
                  itemCount: discoverMerchData.length <= 0 ? 0 : discoverMerchData.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i){
                    return Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 200,
                            width: 200,
                            child: Image.network(discoverMerchData[i].imageUrl),
                          ),
                          SizedBox(height: 10),
                          Text(discoverMerchData[i].productName),
                          SizedBox(height: 10,),
                          Text(discoverMerchData[i].details[0]['basic_price']),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          )
        ],
      ),
    );
  }
}
