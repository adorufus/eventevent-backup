import 'dart:convert';

import 'package:eventevent/Redux/Actions/BannerActions.dart';
import 'package:eventevent/Models/MerchBannerModel.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

MerchBannerState bannerReducer(MerchBannerState state, FSA action) {
  MerchBannerState newState = state;

  switch (action.type) {
    case LIST_BANNER_REQUEST:
      newState.list.error = null;
      newState.list.loading = true;
      newState.list.data = null;

      return newState;

    case LIST_BANNER_SUCCESS:
      newState.list.error = null;
      newState.list.loading = false;
      newState.list.data = bannerFromJSONStr(action.payload);

      return newState;

    case LIST_BANNER_FAILURE:
      newState.list.error = action.payload;
      newState.list.loading = false;
      newState.list.data = null;

      return newState;
      
    default:
      return newState;
  }
}

List<MerchBannerModel> bannerFromJSONStr(dynamic payload){
  var extractedJson = json.decode(payload);
  Iterable jsonArray = extractedJson['data'];

  print(jsonArray.runtimeType);
  print('jsonArray = ' + jsonArray.toString());
  return jsonArray.map((data) => MerchBannerModel.fromJson(data)).toList();
}
