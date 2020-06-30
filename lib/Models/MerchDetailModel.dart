import 'package:flutter/foundation.dart';
import 'package:googleapis/androidenterprise/v1.dart';

class MerchDetailModel {
  final String merchId;
  final String imageUrl;
  final String profileImageUrl;
  final String productName;
  final String merchantName;
  final List details;
  final List comments;
  final String description;
  final int commentCount;
  final int likeCount;
  final bool isLoved;

  MerchDetailModel({
    @required this.merchId,
    @required this.imageUrl,
    @required this.profileImageUrl,
    @required this.details,
    @required this.merchantName,
    @required this.productName,
    @required this.description,
    @required this.comments,
    @required this.commentCount,
    @required this.likeCount,
    @required this.isLoved
  });

  factory MerchDetailModel.fromJson(Map<String, dynamic> json) =>
      MerchDetailModel(
        merchId: json['id'] as String,
        details: json['details'],
        merchantName: json['seller']['username'],
        profileImageUrl: json['seller']['photo'],
        productName: json['name'],
        imageUrl: json['image']['mainImage'] as String,
        description: json['description'] as String,
        comments: json['comment'],
        commentCount: json['count_comment'],
        likeCount: json['like'],
        isLoved: json['isLiked'],
      );
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

// class MerchDetailState {
//   ListMerchDetail list;

//   MerchDetailState({this.list});

//   factory MerchDetailState.initial() =>
//       MerchDetailState(list: ListMerchDetail.initial());
// }

class MerchDetailState {
  dynamic error;
  bool loading;
  MerchDetailModel data;

  MerchDetailState({
    this.error,
    this.loading,
    this.data,
  });

  factory MerchDetailState.initial() =>
      MerchDetailState(error: null, loading: false, data: MerchDetailModel(commentCount: 0, comments: [], description: '', details: [], imageUrl: '', likeCount: 0, merchantName: '', merchId: '', productName: '', profileImageUrl: '', isLoved: false));

  dynamic toJson() {
    return {"error": error, "loading": loading, "data": data};
  }
}
