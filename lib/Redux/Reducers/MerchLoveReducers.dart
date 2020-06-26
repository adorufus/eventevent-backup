import 'dart:convert';

import 'package:eventevent/Models/MerchLoveModels.dart';
import 'package:eventevent/Redux/Actions/MerchLoveAction.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

MerchLoveModel merchLoveReducers(MerchLoveModel items, dynamic action) {
  if(action is AddLove){
    return addLove(items, action);
  }
  else if (action is DoMerchLove) {
    return doMerchLove(items, action);
  }

  return items;
}

MerchLoveModel addLove(MerchLoveModel item, AddLove action){
  return item = action.item;
}

MerchLoveModel doMerchLove(MerchLoveModel item, DoMerchLove action) {
  MerchLoveModel newItem;
  
  doLove(item.productId).then((response){
    newItem = MerchLoveModel(
      isLoved: true, loveCount: item.loveCount + 1, productId: item.productId);
    if(response.statusCode != 201){
      newItem = MerchLoveModel(
      isLoved: false, loveCount: item.loveCount - 1, productId: item.productId);
    }
  });

  return newItem;
}

Future<http.Response> doLove(String productId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String baseUrl = BaseApi().apiUrl;

  String finalUrl = baseUrl + "/product/like";

  final response = await http.post(
    finalUrl,
    body: {
      'X-API-KEY': API_KEY,
      'productId': productId
    },
    headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    }
  );

  return response;
}
