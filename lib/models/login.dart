class LoginModel {
  final String token;

  LoginModel({required this.token});

  // JSON verisini LoginModel'e dönüştürme
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['data']['token'],
    );
  }

  // LoginModel'i JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'token': token,
      },
    };
  }
}
