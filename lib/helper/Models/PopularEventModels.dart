import 'dart:convert';

class PopularEvent{
  final List<Data> data;

  PopularEvent({this.data});

  factory PopularEvent.fromJson(Map<String, dynamic> parsedJson){
    return PopularEvent(data: parseData(json));
  }

  static List<Data> parseData(dataJson){
    var list = dataJson['data'] as List;
    List<Data> dataList = list.map((datas) => Data.fromJson(datas)).toList();
    return dataList;
  }
}

class Data{
  final String name;
  final String desc;
  final String isGoing;
  final String address;
  final String picture;
  final String category;
  final String status;
  final String jarak;

  Data({this.name, this.desc, this.isGoing, this.address, this.picture, this.category, this.status, this.jarak});

  factory Data.fromJson(Map<String, dynamic> parsedJson){
    return Data(
      name: parsedJson['name'], 
      desc: parsedJson['description'], 
      isGoing: parsedJson['isGoing'], 
      address: parsedJson['address'], 
      picture: parsedJson['picture'],
      category: parsedJson['category'],
      status: parsedJson['status'],
      jarak: parsedJson['jarak']
    );
  }
}

