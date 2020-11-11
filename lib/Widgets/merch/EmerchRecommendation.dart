import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/DiscoverMerchModel.dart';
import 'package:eventevent/Widgets/merch/MerchDashboard.dart' as appProps;
import 'package:eventevent/Widgets/merch/MerchDetails.dart';
import 'package:eventevent/Widgets/merch/MerchItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EmerchRecommendation extends StatefulWidget {
  final List<String> categoryIds;

  const EmerchRecommendation({Key key, this.categoryIds}) : super(key: key);

  @override
  _EmerchRecommendationState createState() => _EmerchRecommendationState();
}

class _EmerchRecommendationState extends State<EmerchRecommendation> {

  List discoverMerchList = [];
  String status = '';

  @override
  void initState() {
    getRecommendedMerchByCategory().then((response){
      print('status code' + response.statusCode.toString());
      print('response body' + response.body);

      var extractedData = json.decode(response.body);

      if(response.statusCode == 200){
        discoverMerchList.addAll(extractedData['data']);
        print('discoverMerchList: ' + discoverMerchList.toString());

        setState(() {

        });
      } else {
        status = extractedData['desc'];
        if(status == 'Product not found'){
          getRecommendedMerchByCategory(retryAfterCategoryNotFound: true).then((response){
            print('status code' + response.statusCode.toString());
            print('response body' + response.body);

            var extractedData = json.decode(response.body);

            if(response.statusCode == 200){
              discoverMerchList.addAll(extractedData['data']);
              print('discoverMerchList: ' + discoverMerchList.toString());

              setState(() {

              });
            }
          });
        }
        setState(() {

        });
      }
    });
    super.initState();
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
          Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: discoverMerchList.length <= 0 || discoverMerchList == null
                        ? 0
                        : discoverMerchList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MerchDetails(
                                  merchId: discoverMerchList[i]['product_id']),
                            ),
                          );
                        },
                        child: MerchItem(
                          imageUrl: discoverMerchList[i]['images']['mainImage'],
                          price: "Rp. " +
                              discoverMerchList[i]['details'][0]['basic_price'],
                          title: discoverMerchList[i]['product_name'],
                          color: Color(0xFF34B323),
                          merchantName: discoverMerchList[i]['seller']['username'],
                          profilePictUrl: discoverMerchList[i]['seller']['photo'],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Future<http.Response> getRecommendedMerchByCategory({bool retryAfterCategoryNotFound = false}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String myString = '';
    List<String> myList = [];
    String id = '';
    String url = '';

    for(var id in widget.categoryIds){
      if(id == widget.categoryIds.last){
        myString = "categoryId[]=$id";
      } else {
        myString = "categoryId[]=$id&";
      }
      myList.add(myString);

      print (myList);
    }

    for(var catId in myList){
      id = id + catId;
    }

    if(retryAfterCategoryNotFound == true){
      url = BaseApi().apiUrl + '/product/list?X-API-KEY=$API_KEY&page=1&type=discover&limit=10';
    } else {
      url = BaseApi().apiUrl + '/product/list?X-API-KEY=$API_KEY&page=1&type=discover&limit=10&$id';
    }


    print('merch recommended url: ' + url);

    var response = await http.get(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString("Session")
      }
    );

    return response;
  }
}
