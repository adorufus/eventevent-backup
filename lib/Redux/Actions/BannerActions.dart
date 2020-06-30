import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/MerchBannerModel.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const LIST_BANNER_REQUEST = 'LIST_BANNER_REQUEST';
const LIST_BANNER_SUCCESS = 'LIST_BANNER_SUCCESS';
const LIST_BANNER_FAILURE = 'LIST_BANNER_FAILURE';

RSAA getBannerRequest(String session) {
  final String baseUrl = BaseApi().restUrl;
  final String getBannerUrl =
      baseUrl + '/product/banner?X-API-KEY=$API_KEY&page=1';
  return RSAA(
    method: 'GET',
    endpoint: getBannerUrl,
    types: [LIST_BANNER_REQUEST, LIST_BANNER_SUCCESS, LIST_BANNER_FAILURE],
    headers: {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE},
    // headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session}
  );
}

// Future<http.Response> getBannerRequest() async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();

//   String baseUrl = '';
//   Map<String, String> headers;

//   if (preferences.getBool("isRest") == true) {
//     baseUrl = BaseApi().restUrl;
//     headers = {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE};
//   } else {
//     baseUrl = BaseApi().apiUrl;
//     headers = {
//       'Authorization': AUTHORIZATION_KEY,
//       'cookie': preferences.getString('Session')
//     };
//   }

//   String url = BaseApi().restUrl + '/product/banner?X-API-KEY=$API_KEY&page=1';

//   final response = http.get(
//     url,
//     headers: {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE},
//   );

//   return response;
// }

ThunkAction<AppState> getBanners() => (Store<AppState> store) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      return store.dispatch(getBannerRequest(preferences.getString('Session')));
      // getBannerRequest().then((response) {
      //   return json.decode(response.body);
      // }).then((bannerData) {
      //   print(bannerData);
      //   store.dispatch({
      //     'type': 'FETCH_BANNER',
      //     'payload': bannerData
      //   });
      // });
    };
