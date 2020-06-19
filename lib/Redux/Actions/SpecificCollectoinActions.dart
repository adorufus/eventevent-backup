import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const LIST_SPECCOLLECTION_REQUEST = 'LIST_SPECCOLLECTION_REQUEST';
const LIST_SPECCOLLECTION_SUCCESS = 'LIST_SPECCOLLECTION_SUCCESS';
const LIST_SPECCOLLECTION_FAILURE = 'LIST_SPECCOLLECTION_FAILURE';

RSAA getSpecificCollectionListRequrest({String session, String id}) {
  final String baseUrl = BaseApi().restUrl;
  final String getSpecCollectionUrl = baseUrl +
      '/product/list?X-API-KEY=$API_KEY&page=1&type=popular&categoryId=$id&limit=10';
  return RSAA(
    method: 'GET',
    endpoint: getSpecCollectionUrl,
    types: [
      LIST_SPECCOLLECTION_REQUEST,
      LIST_SPECCOLLECTION_SUCCESS,
      LIST_SPECCOLLECTION_FAILURE
    ],
    headers: {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE},
  );
}

ThunkAction<AppState> getSpecificCollection(String collectionId) =>
    (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(
        getSpecificCollectionListRequrest(
            session: preferences.getString('Session'), id: collectionId),
      );
    };
