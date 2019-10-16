class Register{
  final String desc;
  final Data data;

  Register({
    this.desc,
    this.data
  });

  factory Register.fromJson(Map<String, dynamic> json){
    return Register(
      desc: json['desc'],
      data: Data.fromJson(json['data'])
    );
  }
}

class Data{
  final String pictureAvatarUrl;

  Data({this.pictureAvatarUrl});

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(pictureAvatarUrl: json['pictureAvatarURL']);
  }
}