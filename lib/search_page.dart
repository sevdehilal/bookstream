import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/service.dart'; // ApiService burada
import '../models/book.dart';
import '../models/active_user.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_page.dart';
import 'book_detail_page.dart';
import 'user_profile_page.dart'; // Kullanıcı profiline yönlendirmek için

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  List<ActiveUserModel> _allUsers = [];
  List<ActiveUserModel> _filteredUsers = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final books = await ApiService.fetchBooks();
      final users = await ApiService.fetchAllActiveUsers();
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Verileri yüklerken hata: $e');
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();

      _filteredBooks = _allBooks.where((book) {
        return book.title.toLowerCase().contains(_searchQuery);
      }).toList();

      _filteredUsers = _allUsers.where((user) {
        final fullName = '${user.name} ${user.surname}'.toLowerCase();
        return user.username.toLowerCase().contains(_searchQuery) ||
            fullName.contains(_searchQuery);
      }).toList();
    });
  }

  Widget _buildBookCard(Book book) {
    ImageProvider? imageProvider;

    try {
      final imageStr = book.coverImage ?? '';

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
      imageProvider = null;
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () {
          try {
            print("Tıklanan kitap ID: ${book.id}");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailPage(bookId: book.id),
              ),
            );
          } catch (e) {
            print("Hata: ${e.toString()}");
          }
        },
        leading: imageProvider != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image(
                  image: imageProvider,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 50,
                height: 70,
                color: Colors.grey,
              ),
        title: Text(
          book.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${book.author.firstName} ${book.author.lastName}'),
      ),
    );
  }

  Widget _buildUserCard(ActiveUserModel user) {
    ImageProvider? imageProvider;

    try {
      final imageStr = user.profilePhoto ?? '';

      if (imageStr.isEmpty) {
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
      print("Kullanıcı resmi yüklenirken hata: $e");
      imageProvider = null;
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
          leading: imageProvider != null
              ? ClipOval(
                  child: Image(
                    image: imageProvider,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
          title: Text(
            '${user.name} ${user.surname}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('@${user.username}'),
          onTap: () async {
            print('Tıklanan kullanıcı id: ${user.id}');

            final prefs = await SharedPreferences.getInstance();
            final currentUserId = prefs.getInt('userId');

            if (user.id == currentUserId) {
              // ✅ Kullanıcı kendisi ise: arama sayfasını kapat ve doğrudan HomePage'in profil sekmesine yönlendir
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(initialIndex: 2)),
                (route) => false,
              );
            } else {
              // Başka bir kullanıcıya gidilecekse
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(userId: user.id),
                ),
              );
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 212, 223, 231),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 212, 223, 231),
        title: Row(
          children: [
            Icon(Icons.search),
            SizedBox(width: 8),
            Text('BookStream'),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Kitap veya kullanıcı ara...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : (_searchQuery.isEmpty
                      ? Container()
                      : (_filteredBooks.isEmpty && _filteredUsers.isEmpty
                          ? Center(child: Text('Hiç sonuç bulunamadı.'))
                          : ListView(
                              children: [
                                if (_filteredUsers.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Kullanıcılar',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ..._filteredUsers.map(_buildUserCard).toList(),
                                if (_filteredBooks.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Kitaplar',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ..._filteredBooks.map(_buildBookCard).toList(),
                              ],
                            ))),
            ),
          ],
        ),
      ),
    );
  }
}
