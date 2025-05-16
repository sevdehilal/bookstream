import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../services/service.dart';
import '../widgets/book_info_card.dart';

class BookDetailPage extends StatefulWidget {
  final int bookId;

  BookDetailPage({required this.bookId});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  // _book null ile başlatıldı, böylece null kontrolü yapılabilir
  Book? _book;
  bool _isLoading = true;
  int? userId;
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
    _loadUserId();
    _loadReviews(); // yorumları da yükle
  }

  Future<void> _loadReviews() async {
    try {
      // Yorumları yüklemek için doğru servisi kullanıyoruz
      final reviews = await ApiService.fetchReviewsByBookId(widget.bookId);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      print("Yorumlar yüklenemedi: $e");
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  // Kullanıcı ID'sini SharedPreferences'ten alıyoruz
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs
        .getInt('userId'); // Kullanıcı ID'sini SharedPreferences'ten alıyoruz
    setState(() {
      userId = id; // userId'yi set ediyoruz
    });
  }

  Future<void> _loadBookDetails() async {
    try {
      final book = await ApiService.fetchBookById(widget.bookId);
      setState(() {
        _book = book; // Book'u null değilse set ediyoruz
        _isLoading = false;
      });
    } catch (e) {
      print('Kitap ayrıntıları yüklenemedi: $e');
      setState(() {
        _isLoading = false; // Hata durumunda da loading state'i bitiriyoruz
      });
    }
  }

  Widget _getImage(String imageStr) {
    ImageProvider? imageProvider;

    try {
      if (imageStr.isEmpty || imageStr.toLowerCase() == "yok") {
        throw FormatException("Geçersiz resim");
      }

      if (imageStr.startsWith("http") || imageStr.startsWith("https")) {
        imageProvider = NetworkImage(imageStr);
      } else {
        final base64Image =
            imageStr.contains(',') ? imageStr.split(',')[1] : imageStr;
        final decodedBytes = base64Decode(base64Image);
        imageProvider = MemoryImage(decodedBytes);
      }
    } catch (e) {
      print("Resim yüklenirken hata oluştu: $e");
      imageProvider =
          AssetImage('assets/logo.png'); // Hatalıysa bir placeholder göster
    }

    return Image(image: imageProvider!); // Image provider ile resmi döndür
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 212, 223, 231),
      appBar: AppBar(
        title: Text('Kitap Detayı'),
        backgroundColor: Color.fromARGB(255, 212, 223, 231),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _book == null
              ? Center(child: Text('Kitap bulunamadı.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookInfoCard(book: _book!),
                      Center(
                        // 👈🏻 Buton grubunun tamamını ortaladık
                        child: Wrap(
                          spacing: 40,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (userId != null) {
                                  Navigator.pushNamed(
                                    context,
                                    '/quotePage',
                                    arguments: {
                                      'userId': userId,
                                      'type': 1,
                                      'bookId': widget.bookId,
                                    },
                                  );
                                }
                              },
                              icon: Icon(Icons.format_quote),
                              label: Text('Alıntı Ekle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                textStyle: TextStyle(fontSize: 14),
                                minimumSize: Size(130, 48),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (userId != null) {
                                  Navigator.pushNamed(
                                    context,
                                    '/commentPage',
                                    arguments: {
                                      'userId': userId,
                                      'type': 2,
                                      'bookId': widget.bookId,
                                    },
                                  );
                                }
                              },
                              icon: Icon(Icons.comment),
                              label: Text('Yorum Ekle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                textStyle: TextStyle(fontSize: 14),
                                minimumSize: Size(130, 48),
                              ),
                            ),
                            ElevatedButton.icon(
                              // 👉🏻 Artık OutlinedButton değil, hepsi ElevatedButton!
                              onPressed: () async {
                                if (userId != null) {
                                  final success =
                                      await ApiService.addBookToLibrary(
                                    userId: userId!,
                                    bookId: widget.bookId,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'Kitap okuyacaklara eklendi.'
                                          : 'Kitap eklenemedi.'),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.library_add),
                              label: Text('Okuyacaklarıma Ekle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                textStyle: TextStyle(fontSize: 13),
                                minimumSize: Size(170, 48),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // YORUMLAR BLOĞU (ROW dışına alındı)
                      Text(
                        'Yorumlar:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      _isLoadingReviews
                          ? Center(child: CircularProgressIndicator())
                          : _reviews.isEmpty
                              ? Text('Henüz yorum yapılmamış.')
                              : Column(
                                  children: _reviews.map((review) {
                                    final profilePhoto =
                                        review.user.profilePhoto;
                                    ImageProvider imageProvider;

                                    try {
                                      if (profilePhoto != null &&
                                          profilePhoto
                                              .startsWith("data:image")) {
                                        final base64Str =
                                            profilePhoto.split(',').last;
                                        imageProvider = MemoryImage(
                                            base64Decode(base64Str));
                                      } else if (profilePhoto != null &&
                                          profilePhoto.startsWith("http")) {
                                        imageProvider =
                                            NetworkImage(profilePhoto);
                                      } else {
                                        throw Exception(
                                            "Boş veya geçersiz resim");
                                      }
                                    } catch (_) {
                                      imageProvider = AssetImage(
                                          'assets/logo.png'); // fallback
                                    }

                                    return Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 4),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// Profil fotoğrafı
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundImage: imageProvider,
                                              backgroundColor: Colors.grey[300],
                                            ),
                                            SizedBox(width: 12),

                                            /// Kullanıcı adı + yorum
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    review.user.username,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.blueGrey[700],
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    review.text,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                    ],
                  ),
                ),
    );
  }
}
