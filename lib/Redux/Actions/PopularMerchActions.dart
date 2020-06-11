import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const LIST_POPULARMERCH_REQUEST = 'LIST_POPULARMERCH_REQUEST';
const LIST_POPULARMERCH_SUCCESS = 'LIST_POPULARMERCH_SUCCESS';
const LIST_POPULARMERCH_FAILURE = 'LIST_POPULARMERCH_FAILURE';

RSAA getPopularMerchRequest(String session) {
  final String baseUrl = BaseApi().restUrl;
  final String getPopularMerchUrl =
      baseUrl + '/product/list?X-API-KEY=$API_KEY&page=1&type=popular&limit=10';
  return RSAA(
    method: 'GET',
    endpoint: getPopularMerchUrl,
    types: [LIST_POPULARMERCH_REQUEST, LIST_POPULARMERCH_SUCCESS, LIST_POPULARMERCH_FAILURE],
    headers: {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE},
  );
}

ThunkAction<AppState> getPopularMerch() => (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(getPopularMerchRequest(preferences.getString('Session')));
    };
