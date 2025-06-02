import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../book_detail_page.dart'; // Detay sayfan

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 225, 241, 252),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailPage(bookId: book.id),
            ),
          );
        },
        child: ListTile(
          leading: Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: _getImage(book.coverImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(book.title),
          subtitle: Text('${book.author.firstName} ${book.author.lastName}'),
        ),
      ),
    );
  }

  ImageProvider _getImage(String imageStr) {
    try {
      if (imageStr.isEmpty || imageStr.toLowerCase() == "yok") {
        throw FormatException("Geçersiz resim");
      }

      if (imageStr.startsWith("http") || imageStr.startsWith("https")) {
        return NetworkImage(imageStr);
      } else {
        final base64Image =
            imageStr.contains(',') ? imageStr.split(',')[1] : imageStr;
        final decodedBytes = base64Decode(base64Image);
        return MemoryImage(decodedBytes);
      }
    } catch (e) {
      return const AssetImage('assets/logo.png');
    }
  }
}
