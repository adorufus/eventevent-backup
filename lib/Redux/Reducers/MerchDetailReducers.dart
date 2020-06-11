import 'dart:convert';

import 'package:eventevent/Models/MerchDetailModel.dart';
import 'package:eventevent/Redux/Actions/MerchDetailsActions.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

MerchDetailState merchDetailReducer(MerchDetailState state, FSA action) {
  MerchDetailState newState = state;

  switch (action.type) {
    case MERCH_DETAIL_REQUEST:
      newState.error = null;
      newState.loading = true;
      newState.data = null;

      return newState;

    case MERCH_DETAIL_SUCCESS:
      newState.error = null;
      newState.loading = false;
      newState.data = merchDetailFromJSONStr(action.payload);

      return newState;

    case MERCH_DETAIL_FAILURE:
      newState.error = action.payload;
      newState.loading = false;
      newState.data = null;

      return newState;
      
    default:
      return newState;
  }
}

MerchDetailModel merchDetailFromJSONStr(dynamic payload){
  var extractedJson = json.decode(payload);
  var jsonArray = extractedJson['data'];

  print(jsonArray.runtimeType);
  print('jsonArrayMerchDetail = ' + jsonArray.toString());
  return MerchDetailModel.fromJson(jsonArray);
}
