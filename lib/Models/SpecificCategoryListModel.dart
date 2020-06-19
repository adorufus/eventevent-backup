import 'package:flutter/foundation.dart';
import 'package:googleapis/androidenterprise/v1.dart';

class SpecificCategoryListModel {
  final String merchId;
  final String imageUrl;
  final String profileImageUrl;
  final String productName;
  final String merchantName;
  final List details;

  SpecificCategoryListModel({
    @required this.merchId,
    @required this.imageUrl,
    @required this.profileImageUrl,
    @required this.details,
    @required this.merchantName,
    @required this.productName,
  });

  factory SpecificCategoryListModel.fromJson(Map<String, dynamic> json) =>
      SpecificCategoryListModel(
          merchId: json['product_id'] as String,
          details: json['details'],
          merchantName: json['seller']['username'],
          profileImageUrl: json['seller']['photo'],
          productName: json['product_name'],
          imageUrl: json['images']['mainImage'] as String);
}

class SpecificCategoryState {
  ListSpecificCategory list;

  SpecificCategoryState({this.list});

  factory SpecificCategoryState.initial() =>
      SpecificCategoryState(list: ListSpecificCategory.initial());
}

class ListSpecificCategory {
  dynamic error;
  bool loading;
  List<SpecificCategoryListModel> data;

  ListSpecificCategory({
    this.error,
    this.loading,
    this.data,
  });

  factory ListSpecificCategory.initial() =>
      ListSpecificCategory(error: null, loading: false, data: []);

  dynamic toJson() {
    return {"error": error, "loading": loading, "data": data};
  }
}
