import 'MerchBannerModel.dart';

class AppState {
  final MerchBannerState banner;

  AppState({this.banner});

  factory AppState.initial() => AppState(banner: MerchBannerState.initial());

  AppState copyWith({MerchBannerState banner}) {
    return AppState(banner: banner ?? this.banner);
  }
}