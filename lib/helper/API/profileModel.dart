class Profile{
  final String desc;
  //final Data data;
  final List<Data> data;

  Profile({this.desc, this.data});

  factory Profile.fromJson(Map<String, dynamic> json){
    return Profile(
      desc: json['desc'],
      data: parseData(json),
    );
  }

  static List<Data> parseData(dataJson){
    var list = dataJson['data'] as List;
    List<Data> dataList = list.map((data) => Data.fromJson(data)).toList();
    return dataList;
  }
}

class Data{
  final String id;
  final String fullName;
  final String lastName;
  final String email;
  final String username;
  final String phone;
  final String pictureAvatarUrl;
  final String dateBirth;
  final String bio;
  final String website;

  Data({this.id, this.fullName, this.lastName, this.email, this.username, this.phone, this.pictureAvatarUrl, this.dateBirth, this.bio, this.website});

  factory Data.fromJson(Map<String, dynamic> parsedJson){
    return Data(
      id: parsedJson['id'] as String,
      fullName: parsedJson['fullName'] as String,
      lastName: parsedJson['lastName'] as String,
      email: parsedJson['email'] as String,
      username: parsedJson['username'] as String,
      phone: parsedJson['phone'] as String,
      pictureAvatarUrl: parsedJson['pictureAvatarURL'] as String,
      dateBirth: parsedJson['birthDay'] as String,
      bio: parsedJson['shortBio'] as String,
      website: parsedJson['website'] as String
    );
  }
}