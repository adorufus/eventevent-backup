import 'package:flutter/foundation.dart';
import 'package:googleapis/androidenterprise/v1.dart';

class PopularMerchModel {
  final String merchId;
  final String imageUrl;
  final String profileImageUrl;
  final String productName;
  final String merchantName;
  final List details;

  PopularMerchModel(
      {@required this.merchId,
      @required this.imageUrl,
      @required this.profileImageUrl,
      @required this.details,
      @required this.merchantName,
      @required this.productName});

  factory PopularMerchModel.fromJson(Map<String, dynamic> json) =>
      PopularMerchModel(
          merchId: json['product_id'] as String,
          details: json['details'],
          merchantName: json['seller']['username'],
          profileImageUrl: json['seller']['photo'],
          productName: json['product_name'],
          imageUrl: json['images']['mainImage'] as String);
}

class PopularMerchMiniDetails {
  final String product_id;
  final String basic_price;
  final String stock;
  final String final_price;
  final String createdAt;
  final String updatedAt;

  PopularMerchMiniDetails(
      {this.basic_price,
      this.createdAt,
      this.final_price,
      this.product_id,
      this.stock,
      this.updatedAt});

  factory PopularMerchMiniDetails.fromJson(dynamic json) {
    return json.map(
      (data) => PopularMerchMiniDetails(
        basic_price: data['basic_price'],
        createdAt: data['created_at'],
        final_price: data['final_price'],
        product_id: data['product_id'],
        stock: data['stock'],
        updatedAt: data['stock'],
      ),
    );
  }
}

class PopularMerchState {
  ListPopularState list;

  PopularMerchState({this.list});

  factory PopularMerchState.initial() =>
      PopularMerchState(list: ListPopularState.initial());
}

class ListPopularState {
  dynamic error;
  bool loading;
  List<PopularMerchModel> data;

  ListPopularState({
    this.error,
    this.loading,
    this.data,
  });

  factory ListPopularState.initial() =>
      ListPopularState(error: null, loading: false, data: []);

  dynamic toJson() {
    return {"error": error, "loading": loading, "data": data};
  }
}
