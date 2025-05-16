class UserModel {
  final int id;
  final String username;
  final String name;
  final String surname;
  final String email;
  final String createdAt;
  final String? updatedAt;
  final String? profilePhoto;
  final String role;
  final bool isEmailConfirmed;
  final String? token;
  final String? bio;
  final int? followersCount; // ✅ yeni alan
  final int? followingCount; // ✅ yeni alan

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.createdAt,
    this.updatedAt,
    this.profilePhoto,
    required this.role,
    required this.isEmailConfirmed,
    this.token,
    this.bio,
    this.followersCount, // ✅ constructor'a eklendi
    this.followingCount, // ✅ constructor'a eklendi
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      profilePhoto: json['profilePhoto'],
      role: json['role'],
      isEmailConfirmed: json['isEmailConfirmed'],
      token: json['token'],
      bio: json['bio'],
      followersCount: json['followersCount'], // ✅ json'dan alındı
      followingCount: json['followingCount'], // ✅ json'dan alındı
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'surname': surname,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'profilePhoto': profilePhoto,
      'role': role,
      'isEmailConfirmed': isEmailConfirmed,
      'token': token,
      'bio': bio,
      'followersCount': followersCount, // ✅ json'a yazıldı
      'followingCount': followingCount, // ✅ json'a yazıldı
    };
  }
}
