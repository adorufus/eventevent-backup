import 'dart:convert';

import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';

class Data{
  final int id;
  final String name;
  final String picture;

  Data({this.id, this.name, this.picture});

  factory Data.fromJson(Map<String, dynamic> parsedJson ){
    return Data(
      id: parsedJson['id'] as int,
      name: parsedJson['name']as String,
      picture: parsedJson['picture'] as String
    );
  }
}

class Catalog{
  final String desc;
  final List<Data> data;

  Catalog({this.desc, this.data});

  factory Catalog.fromJson(Map<String, dynamic> parsedJson ){
    return Catalog(
      desc: parsedJson['desc'],
      data: parseData(json)
    );
  }

  static List<Data> parseData(dataJson){
    var list = dataJson['data'] as List;
    List<Data> dataList = list.map((data) => Data.fromJson(data)).toList();
    return dataList;
  }
}