import 'package:flutter/material.dart';
import '../services/service.dart';
import '../widgets/user_library_book_card.dart';

class UserLibraryPage extends StatefulWidget {
  final int userId;

  const UserLibraryPage({super.key, required this.userId});

  @override
  _UserLibraryPageState createState() => _UserLibraryPageState();
}

class _UserLibraryPageState extends State<UserLibraryPage> {
  List<dynamic> allBooks = [];
  List<dynamic> toReadBooks = [];
  List<dynamic> readingBooks = [];
  List<dynamic> readBooks = [];
  List<dynamic> abandonedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      final all = await ApiService.fetchLibraryBooks(widget.userId);
      final toRead = await ApiService.fetchToReadBooks(widget.userId);
      final reading = await ApiService.fetchReadingBooks(widget.userId);
      final read = await ApiService.fetchReadBooks(widget.userId);
      final abandoned = await ApiService.fetchAbandonedBooks(widget.userId);

      setState(() {
        allBooks = all;
        toReadBooks = toRead;
        readingBooks = reading;
        readBooks = read;
        abandonedBooks = abandoned;
        _isLoading = false;
      });
    } catch (e) {
      print('Kullanıcının kitapları yüklenirken hata oluştu: $e');
      setState(() {
        _isLoading = false;
      });
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

              return UserLibraryBookCard(
                book: book,
                status: item['status'],
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
    return _isLoading
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
          );
  }
}
