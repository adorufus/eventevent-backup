import 'package:eventevent/Models/DiscoverMerchModel.dart';
import 'package:eventevent/Models/MerchCategoryModel.dart';
import 'package:eventevent/Models/MerchCommentModel.dart';
import 'package:eventevent/Models/MerchDetailModel.dart';
import 'package:eventevent/Models/MerchLoveModels.dart';
import 'package:eventevent/Models/PopularMerchModel.dart';
import 'package:eventevent/Models/SpecificCategoryListModel.dart';
import 'package:eventevent/Models/SpecificCollectionListModel.dart';

import 'MerchBannerModel.dart';
import 'MerchCollectionModel.dart';

class AppState {
  final MerchBannerState banner;
  final MerchCollectionState collections;
  final PopularMerchState popularMerch;
  final DiscoverMerchState discoverMerch;
  final MerchCategoryState category;
  final MerchDetailState merchDetails;
  final SpecificCollectionState specificCollections;
  final SpecificCategoryState specificCategories;
  final MerchCommentState merchComments;
  final MerchLoveModel merchLoves;

  AppState({
    this.category,
    this.discoverMerch,
    this.banner,
    this.collections,
    this.popularMerch,
    this.merchDetails,
    this.specificCollections,
    this.specificCategories,
    this.merchComments,
    this.merchLoves,
  });

  factory AppState.initial() => AppState(
        banner: MerchBannerState.initial(),
        collections: MerchCollectionState.initial(),
        popularMerch: PopularMerchState.initial(),
        discoverMerch: DiscoverMerchState.initial(),
        category: MerchCategoryState.initial(),
        merchDetails: MerchDetailState.initial(),
        specificCollections: SpecificCollectionState.initial(),
        specificCategories: SpecificCategoryState.initial(),
        merchComments: MerchCommentState.initial(),
        merchLoves: MerchLoveModel(isLoved: false, loveCount: 0, productId: ""),
      );

  AppState copyWith({
    MerchBannerState banner,
    MerchCollectionState collections,
    PopularMerchState popularMerch,
    DiscoverMerchState discoverMerch,
    MerchCategoryState category,
    MerchDetailState merchDetails,
    SpecificCollectionState specificCollections,
    SpecificCategoryState specificCategories,
    MerchCommentState merchComments,
    MerchLoveModel merchLoves,
  }) {
    return AppState(
      banner: banner ?? this.banner,
      collections: collections ?? this.collections,
      popularMerch: popularMerch ?? this.popularMerch,
      discoverMerch: discoverMerch ?? this.discoverMerch,
      category: category ?? this.category,
      merchDetails: merchDetails ?? this.merchDetails,
      specificCollections: specificCollections ?? this.specificCollections,
      specificCategories: specificCategories ?? this.specificCategories,
      merchComments: merchComments ?? this.merchComments,
      merchLoves: merchLoves ?? this.merchLoves,
    );
  }

  // static AppState fromJson(dynamic json) {
  //   print('json: ' +json.toString());
  //   if(json != null){
  //     return AppState(
  //       banner: MerchBannerState(
  //           list: ListBannerState.fromJson(json['banner'])));
  //   } else {
  //     return AppState.initial();
  //   }
  // }

  // dynamic toJson() => {'banner': banner.list.toJson()};
}