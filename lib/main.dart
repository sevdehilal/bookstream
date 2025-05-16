import 'package:flutter/material.dart';
import 'login_page.dart';
import 'quotePage.dart'; // quote_page dosyasını ekle
import 'commentPage.dart'; // varsa yorum sayfasını da ekle

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/quotePage': (context) => QuotePage(),
        '/commentPage': (context) => CommentPage(), // eğer varsa
      },
    );
  }
}
