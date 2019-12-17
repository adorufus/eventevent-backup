class BannerModel{
  String image;
  String categoryId;
  String name;
  String eventId;
  String type;

  BannerModel.fromJson(Map<String, dynamic> json) : image = json['image'], categoryId = json['categoryID'], name = json['name'], eventId = json['eventID'], type = json['type'];
}