import 'package:flutter/foundation.dart';

class DiscoverMerchModel {
  final String merchId;
  final String imageUrl;
  final String profileImageUrl;
  final String productName;
  final String merchantName;
  final List details;

  DiscoverMerchModel(
      {@required this.merchId,
      @required this.imageUrl,
      @required this.profileImageUrl,
      @required this.details,
      @required this.merchantName,
      @required this.productName});

  factory DiscoverMerchModel.fromJson(Map<String, dynamic> json) =>
      DiscoverMerchModel(
          merchId: json['product_id'] as String,
          details: json['details'],
          merchantName: json['seller']['username'],
          profileImageUrl: json['seller']['photo'],
          productName: json['product_name'],
          imageUrl: json['images']['mainImage'] as String);
}

class DiscoverMerchMiniDetails {
  final String product_id;
  final String basic_price;
  final String stock;
  final String final_price;
  final String createdAt;
  final String updatedAt;

  DiscoverMerchMiniDetails(
      {this.basic_price,
      this.createdAt,
      this.final_price,
      this.product_id,
      this.stock,
      this.updatedAt});

  factory DiscoverMerchMiniDetails.fromJson(dynamic json) {
    return json.map(
      (data) => DiscoverMerchMiniDetails(
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

class DiscoverMerchState {
  ListDiscoverState list;

  DiscoverMerchState({this.list});

  factory DiscoverMerchState.initial() =>
      DiscoverMerchState(list: ListDiscoverState.initial());
}

class ListDiscoverState {
  dynamic error;
  bool loading;
  List<DiscoverMerchModel> data;

  ListDiscoverState({
    this.error,
    this.loading,
    this.data,
  });

  factory ListDiscoverState.initial() =>
      ListDiscoverState(error: null, loading: false, data: []);

  dynamic toJson() {
    return {"error": error, "loading": loading, "data": data};
  }
}
