class LoginModel{
  String description;
  Data data;

  LoginModel({
    this.description,
    this.data
  });

  factory LoginModel.fromJson(Map<String, dynamic> json){
    return LoginModel(
      description: json['description'],
      data: Data.fromJson(json['data'])
    );
  }

  Map<String, dynamic> toJson() => {
    'desc': description
  };
}

class Data{
  String id;
  String username;
  String picturAvatarUrl;

  Data({
    this.id,
    this.username,
    this.picturAvatarUrl
  });

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(id: json['id'], username: json['username'], picturAvatarUrl: json['pictureAvatarURL']);
  }
}