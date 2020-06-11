import 'package:flutter/foundation.dart';
import 'package:googleapis/androidenterprise/v1.dart';

class MerchCategoryModel {
  final String categoryId;
  final String imageUrl;

  MerchCategoryModel({
    @required this.categoryId,
    @required this.imageUrl,
  });

  factory MerchCategoryModel.fromJson(Map<String, dynamic> json) =>
      MerchCategoryModel(
          categoryId: json['id'] as String,
          imageUrl: json['logo_avatar'] as String);
}

class MerchCategoryState {
  ListCategoryState list;

  MerchCategoryState({this.list});

  factory MerchCategoryState.initial() =>
      MerchCategoryState(list: ListCategoryState.initial());
}

class ListCategoryState {
  dynamic error;
  bool loading;
  List<MerchCategoryModel> data;

  ListCategoryState({
    this.error,
    this.loading,
    this.data,
  });

  factory ListCategoryState.initial() =>
      ListCategoryState(error: null, loading: false, data: []);

  dynamic toJson() {
    return {"error": error, "loading": loading, "data": data};
  }
}
