import 'dart:convert';

import 'package:eventevent/Models/MerchCommentModel.dart';
import 'package:eventevent/Redux/Actions/MerchCommentActions.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

MerchCommentState merchCommentListReducer(MerchCommentState state, FSA action) {
  MerchCommentState newState = state;

  switch (action.type) {
    case REQUEST:
      newState.list.error = null;
      newState.list.loading = true;
      newState.list.data = null;

      return newState;

    case SUCCESS:
      newState.list.error = null;
      newState.list.loading = false;
      newState.list.data = merchCommentFromJSONStr(action.payload);

      return newState;

    case FAILURE:
      newState.list.error = action.payload;
      newState.list.loading = false;
      newState.list.data = [];

      return newState;
      
    default:
      return newState;
  }
}

List<MerchCommentModel> merchCommentFromJSONStr(dynamic payload){
  var extractedJson = json.decode(payload);
  Iterable jsonArray = extractedJson['data'];

  print(jsonArray.runtimeType);
  print('jsonArrayMerchComment = ' + jsonArray.toString());
  return jsonArray.map((data) => MerchCommentModel.fromJson(data)).toList();
}
