import 'package:flutter/foundation.dart';
import 'package:googleapis/androidenterprise/v1.dart';

class MerchCollectionModel {
  final String collectionId;
  final String imageUrl;

  MerchCollectionModel({
    @required this.collectionId,
    @required this.imageUrl,
  });

  factory MerchCollectionModel.fromJson(Map<String, dynamic> json) =>
      MerchCollectionModel(
          collectionId: json['id'] as String,
          imageUrl: json['image_avatar'] as String);
}

class MerchCollectionState {
  ListCollectionState list;

  MerchCollectionState({this.list});

  factory MerchCollectionState.initial() =>
      MerchCollectionState(list: ListCollectionState.initial());
}

class ListCollectionState {
  dynamic error;
  bool loading;
  List<MerchCollectionModel> data;

  ListCollectionState({
    this.error,
    this.loading,
    this.data,
  });

  factory ListCollectionState.initial() =>
      ListCollectionState(error: null, loading: false, data: []);

  dynamic toJson() {
    return {
      "error": error,
      "loading": loading,
      "data": data
    };
  }
}
