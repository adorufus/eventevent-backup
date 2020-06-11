import 'dart:convert';

import 'package:eventevent/Redux/Actions/CollectionActions.dart';
import 'package:eventevent/Models/MerchCollectionModel.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

MerchCollectionState collectionReducer(MerchCollectionState state, FSA action) {
  MerchCollectionState newState = state;

  switch (action.type) {
    case LIST_COLLECTION_REQUEST:
      newState.list.error = null;
      newState.list.loading = true;
      newState.list.data = null;

      return newState;

    case LIST_COLLECTION_SUCCESS:
      newState.list.error = null;
      newState.list.loading = false;
      newState.list.data = collectionFromJSONStr(action.payload);

      return newState;

    case LIST_COLLECTION_FAILURE:
      newState.list.error = action.payload;
      newState.list.loading = false;
      newState.list.data = null;

      return newState;
      
    default:
      return newState;
  }
}

List<MerchCollectionModel> collectionFromJSONStr(dynamic payload){
  var extractedJson = json.decode(payload);
  Iterable jsonArray = extractedJson['data'];

  print(jsonArray.runtimeType);
  print('jsonArray = ' + jsonArray.toString());
  return jsonArray.map((data) => MerchCollectionModel.fromJson(data)).toList();
}
