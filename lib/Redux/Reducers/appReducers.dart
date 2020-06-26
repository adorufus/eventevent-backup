import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Redux/Reducers/BannerReducers.dart';
import 'package:eventevent/Redux/Reducers/CategoryReducers.dart';
import 'package:eventevent/Redux/Reducers/CollectionReducers.dart';
import 'package:eventevent/Redux/Reducers/DiscoverMerchReducers.dart';
import 'package:eventevent/Redux/Reducers/MerchCommentReducers.dart';
import 'package:eventevent/Redux/Reducers/MerchDetailReducers.dart';
import 'package:eventevent/Redux/Reducers/MerchLoveReducers.dart';
import 'package:eventevent/Redux/Reducers/PopularMerchReducers.dart';
import 'package:eventevent/Redux/Reducers/SpecificCategoryReducers.dart';
import 'package:eventevent/Redux/Reducers/SpecificCollectionReducers.dart';

AppState appReducer(AppState state, action){
  
  return AppState(
    banner: bannerReducer(state.banner, action),
    collections: collectionReducer(state.collections, action),
    popularMerch: popularMerchReducer(state.popularMerch, action),
    discoverMerch: discoverMerchReducer(state.discoverMerch, action),
    category: categoryReducer(state.category, action),
    merchDetails: merchDetailReducer(state.merchDetails, action),
    specificCollections: specificCollectionReducer(state.specificCollections, action),
    specificCategories: specificCategoryReducer(state.specificCategories, action),
    merchComments: merchCommentListReducer(state.merchComments, action),
    merchLoves: merchLoveReducers(state.merchLoves, action),
  );
}