import 'dart:convert';

import 'package:eventevent/Redux/Actions/CategoryActions.dart';
import 'package:eventevent/Models/MerchCategoryModel.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

MerchCategoryState categoryReducer(MerchCategoryState state, FSA action) {
  MerchCategoryState newState = state;

  switch (action.type) {
    case LIST_CATEGORY_REQUEST:
      newState.list.error = null;
      newState.list.loading = true;
      newState.list.data = null;

      return newState;

    case LIST_CATEGORY_SUCCESS:
      newState.list.error = null;
      newState.list.loading = false;
      newState.list.data = categoryFromJSONStr(action.payload);

      return newState;

    case LIST_CATEGORY_FAILURE:
      newState.list.error = action.payload;
      newState.list.loading = false;
      newState.list.data = null;

      return newState;
      
    default:
      return newState;
  }
}

List<MerchCategoryModel> categoryFromJSONStr(dynamic payload){
  var extractedJson = json.decode(payload);
  Iterable jsonArray = extractedJson['data'];

  print(jsonArray.runtimeType);
  print('jsonArray = ' + jsonArray.toString());
  return jsonArray.map((data) => MerchCategoryModel.fromJson(data)).toList();
}
