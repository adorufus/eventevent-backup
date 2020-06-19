import 'dart:convert';

import 'package:eventevent/Models/SpecificCategoryListModel.dart';
import 'package:eventevent/Redux/Actions/SpecificCategoryActions.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

SpecificCategoryState specificCategoryReducer(
    SpecificCategoryState state, FSA action) {
  SpecificCategoryState newState = state;

  switch (action.type) {
    case LIST_SPECCATEGORY_REQUEST:
      newState.list.error = null;
      newState.list.loading = true;
      newState.list.data = null;

      return newState;

    case LIST_SPECCATEGORY_SUCCESS:
      newState.list.error = null;
      newState.list.loading = false;
      newState.list.data = specificCategoryFromJSONStr(action.payload);

      return newState;

    case LIST_SPECCATEGORY_FAILURE:
      APIError apiError = action.payload;
      
      newState.list.error = action.payload;
      newState.list.loading = false;
      newState.list.data = [];

      return newState;

    default:
      return newState;
  }
}

List<SpecificCategoryListModel> specificCategoryFromJSONStr(dynamic payload) {
  var extractedJson = json.decode(payload);
  Iterable jsonArray = extractedJson['data'];

  print(jsonArray.runtimeType);
  print('jsonArraySpecCategory = ' + jsonArray.toString());
  return jsonArray
      .map((data) => SpecificCategoryListModel.fromJson(data))
      .toList();
}
