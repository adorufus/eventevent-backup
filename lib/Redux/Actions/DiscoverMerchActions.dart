import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const LIST_DISCOVERMERCH_REQUEST = 'LIST_DISCOVERMERCH_REQUEST';
const LIST_DISCOVERMERCH_SUCCESS = 'LIST_DISCOVERMERCH_SUCCESS';
const LIST_DISCOVERMERCH_FAILURE = 'LIST_DISCOVERMERCH_FAILURE';

RSAA getDiscoverMerchRequest(String session, bool isInRecommendation, List<String> categoryId) {
  final String baseUrl = BaseApi().restUrl;
  String getDiscoverMerchUrl;
  String myString = '';
  List<String> myList = [];
  if(isInRecommendation) {
    for(var id in categoryId){
      if(id == categoryId.last){
        myString = "categoryId[]=$id";
      } else {
        myString = "categoryId[]=$id&";
      }
      myList.add(myString);

      print (myList);
    }

    for(var catId in myList){
      getDiscoverMerchUrl = baseUrl + '/product/list?X-API-KEY=$API_KEY&page=1&type=discover&limit=10&$catId';
    }
  } else {
    getDiscoverMerchUrl = baseUrl + '/product/list?X-API-KEY=$API_KEY&page=1&type=discover&limit=10';
  }
  return RSAA(
    method: 'GET',
    endpoint: getDiscoverMerchUrl,
    types: [
      LIST_DISCOVERMERCH_REQUEST,
      LIST_DISCOVERMERCH_SUCCESS,
      LIST_DISCOVERMERCH_FAILURE
    ],
    headers: {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE},
  );
}

ThunkAction<AppState> getDiscoverMerch({bool isInRecommendation, List<String> categoryId}) => (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(
        getDiscoverMerchRequest(
          preferences.getString('Session'),
          isInRecommendation,
          categoryId
        ),
      );
    };
