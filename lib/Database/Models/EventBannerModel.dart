// To parse this JSON data, do
//
//     final banner = bannerFromJson(jsonString);

import 'dart:convert';

BannerModel bannerFromJson(String str) => BannerModel.fromJson(json.decode(str));

String bannerToJson(BannerModel data) => json.encode(data.toJson());

class BannerModel {
  List<Datum> data;

  BannerModel({
    this.data,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String id;
  String eventId;
  String categoryId;
  String type;
  String title;
  String description;
  String image;
  String countView;
  String countClick;
  String orderNumber;
  DateTime createdDate;
  DateTime updatedDate;
  String status;

  Datum({
    this.id,
    this.eventId,
    this.categoryId,
    this.type,
    this.title,
    this.description,
    this.image,
    this.countView,
    this.countClick,
    this.orderNumber,
    this.createdDate,
    this.updatedDate,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    eventId: json["eventID"],
    categoryId: json["categoryID"],
    type: json["type"],
    title: json["title"],
    description: json["description"],
    image: json["image"],
    countView: json["count_view"],
    countClick: json["count_click"],
    orderNumber: json["order_number"],
    createdDate: DateTime.parse(json["createdDate"]),
    updatedDate: DateTime.parse(json["updatedDate"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "eventID": eventId,
    "categoryID": categoryId,
    "type": type,
    "title": title,
    "description": description,
    "image": image,
    "count_view": countView,
    "count_click": countClick,
    "order_number": orderNumber,
    "createdDate": createdDate.toIso8601String(),
    "updatedDate": updatedDate.toIso8601String(),
    "status": status,
  };
}
