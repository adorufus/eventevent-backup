import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/MerchCollectionModel.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const LIST_COLLECTION_REQUEST = 'LIST_COLLECTION_REQUEST';
const LIST_COLLECTION_SUCCESS = 'LIST_COLLECTION_SUCCESS';
const LIST_COLLECTION_FAILURE = 'LIST_COLLECTION_FAILURE';

RSAA getCollectionRequest(String session) {
  final String baseUrl = BaseApi().restUrl;
  final String getCollectionUrl =
      baseUrl + '/product/collection?X-API-KEY=$API_KEY&page=1';
  return RSAA(
    method: 'GET',
    endpoint: getCollectionUrl,
    types: [LIST_COLLECTION_REQUEST, LIST_COLLECTION_SUCCESS, LIST_COLLECTION_FAILURE],
    headers: {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE},
  );
}

ThunkAction<AppState> getCollection() => (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(getCollectionRequest(preferences.getString('Session')));
    };
