import 'package:eventevent/Redux/Actions/BannerActions.dart';
import 'package:eventevent/Models/MerchBannerModel.dart';

List<MerchBannerModel> merchBannerReducers(List<MerchBannerModel> banner, dynamic action){
  if(action is AddItemAction){
    return null;
  } else if (action is DeleteItemAction){
    return null;
  }
}