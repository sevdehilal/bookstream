class ActiveUserModel {
  final int id;
  final String username;
  final String name;
  final String surname;
  final String? profilePhoto;
  final String? bio;
  final int? followersCount;
  final int? followingCount;

  ActiveUserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    this.profilePhoto,
    this.bio,
    this.followersCount,
    this.followingCount,
  });

  factory ActiveUserModel.fromJson(Map<String, dynamic> json) {
    return ActiveUserModel(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      surname: json['surname'],
      profilePhoto: json['profilePhoto'],
      bio: json['bio'],
      followersCount: json['followersCount'],
      followingCount: json['followingCount'],
    );
  }
}
