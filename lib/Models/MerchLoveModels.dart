import 'package:flutter/foundation.dart';
import 'package:googleapis/androidenterprise/v1.dart';

class MerchLoveModel {
  final int loveCount;
  final String productId;
  // final String userId;
  final bool isLoved;
  // final User user;

  MerchLoveModel({
    @required this.loveCount,
    @required this.productId, 
    // @required this.userId,
    @required this.isLoved,
    // @required this.user,
  });

  factory MerchLoveModel.fromJson(Map<String, dynamic> json) =>
      MerchLoveModel(
        loveCount: json['like'] as int,
        isLoved: json['isLiked'] as bool,
        productId: json['id'],
        // user: User.fromJson(json['user']),
        // isLoved: json['comment'],
        // userId: json['user_id'],
      );
}

// class User {
//   final String photo;
//   final String username;
//   final String fullName;
//   final String lastName;
//   final String email;
//   final String isVerified;

//   User({
//     @required this.email,
//     @required this.fullName,
//     @required this.isVerified,
//     @required this.lastName,
//     @required this.photo,
//     @required this.username,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       photo: json['photo'],
//       email: json['email'],
//       fullName: json['fullName'],
//       isVerified: json['isVerified'],
//       lastName: json['lastName'],
//       username: json['username'],
//     );
//   }
// }

class MerchLoveState {
  ListMerchLove list;

  MerchLoveState({this.list});

  factory MerchLoveState.initial() =>
      MerchLoveState(list: ListMerchLove.initial());
}

class ListMerchLove {
  dynamic error;
  bool loading;
  MerchLoveModel data;

  ListMerchLove({
    this.error,
    this.loading,
    this.data,
  });

  factory ListMerchLove.initial() =>
      ListMerchLove(error: null, loading: false, data: MerchLoveModel(loveCount: 0, isLoved: false, productId: ''));

  dynamic toJson() {
    return {"error": error, "loading": loading, "data": data};
  }
}
