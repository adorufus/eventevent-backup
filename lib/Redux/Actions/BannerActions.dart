import 'package:eventevent/Models/MerchBannerModel.dart';

class AddItemAction {
  final MerchBannerModel banner;

  AddItemAction(this.banner);
}

class DeleteItemAction {
  final MerchBannerModel banner;

  DeleteItemAction(this.banner);
}