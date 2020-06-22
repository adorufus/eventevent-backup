import 'package:flutter/foundation.dart';
import 'package:googleapis/androidenterprise/v1.dart';

class MerchCommentModel {
  final String commentId;
  final String userId;
  final String comment;
  final User user;

  MerchCommentModel({
    @required this.commentId,
    @required this.userId,
    @required this.comment,
    @required this.user,
  });

  factory MerchCommentModel.fromJson(Map<String, dynamic> json) =>
      MerchCommentModel(
        commentId: json['id'] as String,
        user: User.fromJson(json['user']),
        comment: json['comment'],
        userId: json['user_id'],
      );
}

class User {
  final String photo;
  final String username;
  final String fullName;
  final String lastName;
  final String email;
  final String isVerified;

  User({
    @required this.email,
    @required this.fullName,
    @required this.isVerified,
    @required this.lastName,
    @required this.photo,
    @required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      photo: json['photo'],
      email: json['email'],
      fullName: json['fullName'],
      isVerified: json['isVerified'],
      lastName: json['lastName'],
      username: json['username'],
    );
  }
}

class MerchCommentState {
  ListMerchComment list;

  MerchCommentState({this.list});

  factory MerchCommentState.initial() =>
      MerchCommentState(list: ListMerchComment.initial());
}

class ListMerchComment {
  dynamic error;
  bool loading;
  List<MerchCommentModel> data;

  ListMerchComment({
    this.error,
    this.loading,
    this.data,
  });

  factory ListMerchComment.initial() =>
      ListMerchComment(error: null, loading: false, data: []);

  dynamic toJson() {
    return {"error": error, "loading": loading, "data": data};
  }
}
