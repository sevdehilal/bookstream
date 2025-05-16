class Book {
  final int id;
  final String title;
  final int authorId;
  final String isbn;
  final int publishedYear;
  final int pageCount;
  final String publisher;
  final String description;
  final String coverImage;
  final Author author;
  final Genre genre;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Book({
    required this.id,
    required this.title,
    required this.authorId,
    required this.isbn,
    required this.publishedYear,
    required this.pageCount,
    required this.publisher,
    required this.description,
    required this.coverImage,
    required this.author,
    required this.genre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Başlık yok',
      authorId: json['authorId'] as int? ?? 0,
      isbn: json['isbn'] as String? ?? 'ISBN yok',
      publishedYear: json['publishedYear'] as int? ?? 0,
      pageCount: json['pageCount'] as int? ?? 0,
      publisher: json['publisher'] as String? ?? 'Yayınevi yok',
      description: json['description'] as String? ?? 'Açıklama yok',
      coverImage: json['coverImage'] as String? ?? '',
      author: json['author'] != null
          ? Author.fromJson(json['author'])
          : Author(
              id: 0, firstName: 'Bilinmeyen', lastName: 'Yazar', photo: ''),
      genre: json['genre'] != null
          ? Genre.fromJson(json['genre'])
          : Genre(id: 0, name: 'Tür bilinmiyor'),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}

class Author {
  final int id;
  final String firstName;
  final String lastName;
  final String photo;

  Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.photo,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? 'Ad yok',
      lastName: json['lastName'] ?? 'Soyad yok',
      photo: json['photo'] ?? '',
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tür bilgisi yok',
    );
  }
}
