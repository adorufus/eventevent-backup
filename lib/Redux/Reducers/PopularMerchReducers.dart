import 'dart:convert';

import 'package:eventevent/Models/PopularMerchModel.dart';
import 'package:eventevent/Redux/Actions/PopularMerchActions.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

PopularMerchState popularMerchReducer(PopularMerchState state, FSA action) {
  PopularMerchState newState = state;

  switch (action.type) {
    case LIST_POPULARMERCH_REQUEST:
      newState.list.error = null;
      newState.list.loading = true;
      newState.list.data = null;

      return newState;

    case LIST_POPULARMERCH_SUCCESS:
      newState.list.error = null;
      newState.list.loading = false;
      newState.list.data = popularMerchFromJSONStr(action.payload);

      return newState;

    case LIST_POPULARMERCH_FAILURE:
      newState.list.error = action.payload;
      newState.list.loading = false;
      newState.list.data = null;

      return newState;
      
    default:
      return newState;
  }
}

List<PopularMerchModel> popularMerchFromJSONStr(dynamic payload){
  var extractedJson = json.decode(payload);
  Iterable jsonArray = extractedJson['data'];

  print(jsonArray.runtimeType);
  print('jsonArrayPopularMerch = ' + jsonArray.toString());
  return jsonArray.map((data) => PopularMerchModel.fromJson(data)).toList();
}
