import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const REQUEST = 'REQUEST';
const SUCCESS = 'SUCCESS';
const FAILURE = 'FAILURE';

RSAA getCommentListRequrest({String session, String id}) {
  final String baseUrl = BaseApi().apiUrl;
  final String getCommentListUrl = baseUrl +
      '/product/list_comment?X-API-KEY=$API_KEY&productId=$id';

      print(getCommentListUrl);
  return RSAA(
    method: 'GET',
    endpoint: getCommentListUrl,
    types: [
      REQUEST,
      SUCCESS,
      FAILURE
    ],
    headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session},
  );
}

ThunkAction<AppState> getCommentList(String merchId) =>
    (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(
        getCommentListRequrest(
            session: preferences.getString('Session'), id: merchId),
      );
    };
