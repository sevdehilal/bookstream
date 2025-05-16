import 'package:flutter/material.dart';
import 'general_overview_page.dart';
import 'home_page_page.dart';
import 'profile_page.dart';
import 'navbar.dart';
import 'login_page.dart';
import 'search_page.dart'; // Search sayfasını import et

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    GeneralOverviewPage(),
    HomePagePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SearchPage()), // Arama sayfasına yönlendir
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 212, 223, 231),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 212, 223, 231),
        title: Row(
          children: [
            Icon(Icons.library_books, color: Colors.blueGrey[700]),
            SizedBox(width: 8),
            Text(
              'BookStream',
              style: TextStyle(
                color: Colors.blueGrey[700], // Arka planla uyumlu
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _navigateToSearch, // Arama sayfasına yönlendirme
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
