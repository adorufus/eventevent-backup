import 'package:flutter/foundation.dart';
import 'package:googleapis/androidenterprise/v1.dart';

class SpecificCollectionListModel {
  final String merchId;
  final String imageUrl;
  final String profileImageUrl;
  final String productName;
  final String merchantName;
  final List details;

  SpecificCollectionListModel(
      {@required this.merchId,
      @required this.imageUrl,
      @required this.profileImageUrl,
      @required this.details,
      @required this.merchantName,
      @required this.productName});

  factory SpecificCollectionListModel.fromJson(Map<String, dynamic> json) =>
      SpecificCollectionListModel(
          merchId: json['product_id'] as String,
          details: json['details'],
          merchantName: json['seller']['username'],
          profileImageUrl: json['seller']['photo'],
          productName: json['product_name'],
          imageUrl: json['images']['mainImage'] as String);
}

// class PopularMerchMiniDetails {
//   final String product_id;
//   final String basic_price;
//   final String stock;
//   final String final_price;
//   final String createdAt;
//   final String updatedAt;

//   PopularMerchMiniDetails(
//       {this.basic_price,
//       this.createdAt,
//       this.final_price,
//       this.product_id,
//       this.stock,
//       this.updatedAt});

//   factory PopularMerchMiniDetails.fromJson(dynamic json) {
//     return json.map(
//       (data) => PopularMerchMiniDetails(
//         basic_price: data['basic_price'],
//         createdAt: data['created_at'],
//         final_price: data['final_price'],
//         product_id: data['product_id'],
//         stock: data['stock'],
//         updatedAt: data['stock'],
//       ),
//     );
//   }
// }

class SpecificCollectionState {
  ListSpecificCollection list;

  SpecificCollectionState({this.list});

  factory SpecificCollectionState.initial() =>
      SpecificCollectionState(list: ListSpecificCollection.initial());
}

class ListSpecificCollection {
  dynamic error;
  bool loading;
  List<SpecificCollectionListModel> data;

  ListSpecificCollection({
    this.error,
    this.loading,
    this.data,
  });

  factory ListSpecificCollection.initial() =>
      ListSpecificCollection(error: null, loading: false, data: []);

  dynamic toJson() {
    return {"error": error, "loading": loading, "data": data};
  }
}
