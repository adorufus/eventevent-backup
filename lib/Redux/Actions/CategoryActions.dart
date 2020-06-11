import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:shared_preferences/shared_preferences.dart';

const LIST_CATEGORY_REQUEST = 'LIST_CATEGORY_REQUEST';
const LIST_CATEGORY_SUCCESS = 'LIST_CATEGORY_SUCCESS';
const LIST_CATEGORY_FAILURE = 'LIST_CATEGORY_FAILURE';

RSAA getCategoryRequest(String session) {
  final String baseUrl = BaseApi().restUrl;
  final String getCategoryUrl =
      baseUrl + '/product/category?X-API-KEY=$API_KEY&page=1';
  return RSAA(
    method: 'GET',
    endpoint: getCategoryUrl,
    types: [LIST_CATEGORY_REQUEST, LIST_CATEGORY_SUCCESS, LIST_CATEGORY_FAILURE],
    headers: {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE},
  );
}

ThunkAction<AppState> getCategory() => (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(getCategoryRequest(preferences.getString('Session')));
    };
