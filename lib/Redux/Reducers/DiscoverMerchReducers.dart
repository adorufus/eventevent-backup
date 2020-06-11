import 'dart:convert';

import 'package:eventevent/Models/DiscoverMerchModel.dart';
import 'package:eventevent/Redux/Actions/DiscoverMerchActions.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

DiscoverMerchState discoverMerchReducer(DiscoverMerchState state, FSA action) {
  DiscoverMerchState newState = state;

  switch (action.type) {
    case LIST_DISCOVERMERCH_REQUEST:
      newState.list.error = null;
      newState.list.loading = true;
      newState.list.data = null;

      return newState;

    case LIST_DISCOVERMERCH_SUCCESS:
      newState.list.error = null;
      newState.list.loading = false;
      newState.list.data = discoverMerchFromJSONStr(action.payload);

      return newState;

    case LIST_DISCOVERMERCH_FAILURE:
      newState.list.error = action.payload;
      newState.list.loading = false;
      newState.list.data = null;

      return newState;
      
    default:
      return newState;
  }
}

List<DiscoverMerchModel> discoverMerchFromJSONStr(dynamic payload){
  var extractedJson = json.decode(payload);
  Iterable jsonArray = extractedJson['data'];

  print(jsonArray.runtimeType);
  print('jsonArrayDiscoverMerch = ' + jsonArray.toString());
  return jsonArray.map((data) => DiscoverMerchModel.fromJson(data)).toList();
}
