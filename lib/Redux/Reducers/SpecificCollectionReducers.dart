import 'dart:convert';

import 'package:eventevent/Models/SpecificCollectionListModel.dart';
import 'package:eventevent/Redux/Actions/SpecificCollectoinActions.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

SpecificCollectionState specificCollectionReducer(SpecificCollectionState state, FSA action) {
  SpecificCollectionState newState = state;

  switch (action.type) {
    case LIST_SPECCOLLECTION_REQUEST:
      newState.list.error = null;
      newState.list.loading = true;
      newState.list.data = null;

      return newState;

    case LIST_SPECCOLLECTION_SUCCESS:
      newState.list.error = null;
      newState.list.loading = false;
      newState.list.data = specificCollectionFromJSONStr(action.payload);

      return newState;

    case LIST_SPECCOLLECTION_FAILURE:
      newState.list.error = action.payload;
      newState.list.loading = false;
      newState.list.data = [];

      return newState;
      
    default:
      return newState;
  }
}

List<SpecificCollectionListModel> specificCollectionFromJSONStr(dynamic payload){
  var extractedJson = json.decode(payload);
  Iterable jsonArray = extractedJson['data'];

  print(jsonArray.runtimeType);
  print('jsonArraySpecCol = ' + jsonArray.toString());
  return jsonArray.map((data) => SpecificCollectionListModel.fromJson(data)).toList();
}
