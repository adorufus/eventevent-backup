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

RSAA getDiscoverMerchRequest(String session) {
  final String baseUrl = BaseApi().restUrl;
  String getDiscoverMerchUrl;

  // if(isInRecommendation) {
  //
  //
  //   getDiscoverMerchUrl = baseUrl + '/product/list?X-API-KEY=$API_KEY&page=1&type=discover&limit=10&$id';
  //   print("discover merch with category url: " + getDiscoverMerchUrl);
  // } else {
  getDiscoverMerchUrl = baseUrl + '/product/list?X-API-KEY=$API_KEY&page=1&type=discover&limit=10';
  // }
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

ThunkAction<AppState> getDiscoverMerch() => (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(
        getDiscoverMerchRequest(
          preferences.getString('Session'),
        ),
      );
    };
