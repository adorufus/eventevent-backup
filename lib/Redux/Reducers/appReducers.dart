import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Redux/Reducers/BannerReducers.dart';

AppState appReducer(AppState state, action){
  
  return AppState(
    banner: bannerReducer(state.banner, action)
  );
}