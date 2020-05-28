class MerchBannerModel{
  String bannerId;
  String imageUrl;

  MerchBannerModel({
    this.bannerId, this.imageUrl
  });

  @override
  String toString() {
    return "{banner_id: $bannerId, image_url: $imageUrl}";
  }
}