import 'package:flutter/foundation.dart';
import 'package:googleapis/androidenterprise/v1.dart';

class MerchBannerModel {
  final String bannerId;
  final String imageUrl;

  MerchBannerModel({
    @required this.bannerId,
    @required this.imageUrl,
  });

  factory MerchBannerModel.fromJson(Map<String, dynamic> json) =>
      MerchBannerModel(
          bannerId: json['id'] as String,
          imageUrl: json['image_avatar'] as String);
}

class MerchBannerState {
  ListBannerState list;

  MerchBannerState({this.list});

  factory MerchBannerState.initial() =>
      MerchBannerState(list: ListBannerState.initial());
}

class ListBannerState {
  dynamic error;
  bool loading;
  List<MerchBannerModel> data;

  ListBannerState({
    this.error,
    this.loading,
    this.data,
  });

  factory ListBannerState.initial() =>
      ListBannerState(error: null, loading: false, data: []);
}
