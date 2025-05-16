class ReviewType {
  final int id;
  final String name;

  ReviewType({
    required this.id,
    required this.name,
  });

  factory ReviewType.fromJson(Map<String, dynamic> json) {
    return ReviewType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
