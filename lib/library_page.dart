import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service.dart';
import '../widgets/library_book_card.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<dynamic> allBooks = [];
  List<dynamic> toReadBooks = [];
  List<dynamic> readingBooks = [];
  List<dynamic> readBooks = [];
  List<dynamic> abandonedBooks = [];
  Set<int> favoriteBookIds = {}; // ✅ Favori kitap ID'leri
  bool _isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> refreshFavorites() async {
    if (userId != null) {
      final favorites = await ApiService.fetchFavoriteBookIds(userId!);
      setState(() {
        favoriteBookIds = favorites.toSet();
      });
    }
  }

  Future<void> _fetchAllData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    if (userId != null) {
      try {
        final all = await ApiService.fetchLibraryBooks(userId!);
        final toRead = await ApiService.fetchToReadBooks(userId!);
        final reading = await ApiService.fetchReadingBooks(userId!);
        final read = await ApiService.fetchReadBooks(userId!);
        final abandoned = await ApiService.fetchAbandonedBooks(userId!);
        final favorites = await ApiService.fetchFavoriteBookIds(userId!); // ✅

        setState(() {
          allBooks = all;
          toReadBooks = toRead;
          readingBooks = reading;
          readBooks = read;
          abandonedBooks = abandoned;
          favoriteBookIds = favorites.toSet();
          _isLoading = false;
        });
      } catch (e) {
        print('Hata: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSection(String title, List<dynamic> books) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 2,
          width: 80,
          color: Colors.black87,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: books.map((item) {
              final book = item['book'];
              final userId = item['userId'];
              final status = item['status'];

              return LibraryBookCard(
                book: book,
                userId: userId,
                status: status,
                favoriteBookIds: favoriteBookIds, // ✅ BURASI EKSİKTİ
                onFavoriteUpdated: _fetchAllData, // ✅
                onUpdate: _fetchAllData, // ✅
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 223, 231),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Tümü', allBooks),
                  _buildSection('Okuyacağım', toReadBooks),
                  _buildSection('Okuyorum', readingBooks),
                  _buildSection('Okudum', readBooks),
                  _buildSection('Yarıda Bıraktım', abandonedBooks),
                ],
              ),
            ),
    );
  }
}
