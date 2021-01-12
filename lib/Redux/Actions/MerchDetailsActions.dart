import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/MerchCollectionModel.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const MERCH_DETAIL_REQUEST = 'MERCH_DETAIL_REQUEST';
const MERCH_DETAIL_SUCCESS = 'MERCH_DETAIL_SUCCESS';
const MERCH_DETAIL_FAILURE = 'MERCH_DETAIL_FAILURE';

RSAA getMerchDetailsRequest(String session, String id) {
  final String baseUrl = BaseApi().apiUrl;
  final String getMerchDetailUrl =
      baseUrl + '/product/detail?X-API-KEY=$API_KEY&productId=$id';
  print(getMerchDetailUrl);
  return RSAA(
    method: 'GET',
    endpoint: getMerchDetailUrl,
    types: [MERCH_DETAIL_REQUEST, MERCH_DETAIL_SUCCESS, MERCH_DETAIL_FAILURE],
    // headers: {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE},
    headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session},
  );
}

ThunkAction<AppState> getMerchDetail(String id) =>
    (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(
        getMerchDetailsRequest(preferences.getString('Session'), id),
      );
    };
