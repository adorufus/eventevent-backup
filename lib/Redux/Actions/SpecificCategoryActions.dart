import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const LIST_SPECCATEGORY_REQUEST = 'LIST_SPECCATEGORY_REQUEST';
const LIST_SPECCATEGORY_SUCCESS = 'LIST_SPECCATEGORY_SUCCESS';
const LIST_SPECCATEGORY_FAILURE = 'LIST_SPECCATEGORY_FAILURE';

RSAA getSpecificCategoryListRequest({String session, String id}) {
  final String baseUrl = BaseApi().restUrl;
  final String getSpecCategoryUrl = baseUrl +
      '/product/list?X-API-KEY=$API_KEY&page=1&type=popular&categoryId=$id&limit=10';
  return RSAA(
    method: 'GET',
    endpoint: getSpecCategoryUrl,
    types: [
      LIST_SPECCATEGORY_REQUEST,
      LIST_SPECCATEGORY_SUCCESS,
      LIST_SPECCATEGORY_FAILURE
    ],
    headers: {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE},
  );
}

ThunkAction<AppState> getSpecificCategory(String categoryId) =>
    (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(
        getSpecificCategoryListRequest(
            session: preferences.getString('Session'), id: categoryId),
      );
    };
