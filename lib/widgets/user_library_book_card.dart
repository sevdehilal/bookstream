import 'dart:convert';
import 'package:flutter/material.dart';

class UserLibraryBookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final int status;

  const UserLibraryBookCard({
    super.key,
    required this.book,
    required this.status,
  });

  ImageProvider _getImage(dynamic imageStr) {
    try {
      if (imageStr == null) {
        throw Exception();
      }

      final str = imageStr.toString(); // 👈 Her şeyi stringe çevirdik

      if (str.isEmpty || str.toLowerCase() == "yok") {
        throw Exception();
      }

      if (str.startsWith("http") || str.startsWith("https")) {
        return NetworkImage(str);
      } else if (str.startsWith('data:image')) {
        final base64Part = str.split(',').last;
        final decodedBytes = base64Decode(base64Part);
        return MemoryImage(decodedBytes);
      } else {
        throw Exception(); // Geçersiz format
      }
    } catch (e) {
      return const AssetImage('lib/assets/logo.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      elevation: 3,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Container(
              height: 140, // 📏 Sabit bir yükseklik verdik
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(2)),
                image: DecorationImage(
                  image: _getImage(book['coverImage'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book['title'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${book['author']['firstName']} ${book['author']['lastName']}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
