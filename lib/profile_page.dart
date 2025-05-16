import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/liked_posts_page.dart';
import '../models/register.dart';
import '../services/service.dart';
import 'library_page.dart';
import 'quotes_page.dart';
import 'comments_page.dart';
import 'edit_profile_page.dart';
import 'followers_page.dart';
import 'followings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  UserModel? _user;
  bool _isLoading = true;
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: "Kitaplık"),
    Tab(text: "Alıntılar"),
    Tab(text: "Yorumlar"),
    Tab(text: "Beğeniler"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await ApiService.getUserProfile();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  ImageProvider? _getProfileImage(String? photo) {
    if (photo == null) return null;
    try {
      if (photo.startsWith("data:image")) {
        final base64String = photo.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } else {
        return NetworkImage(photo);
      }
    } catch (e) {
      print("Profil fotoğrafı çözümlenemedi: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("Profil bilgisi alınamadı.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 223, 231),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: const Color.fromARGB(255, 212, 223, 231),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.grey[800],
                                backgroundImage:
                                    _getProfileImage(_user!.profilePhoto),
                                child: _user!.profilePhoto == null
                                    ? const Icon(Icons.person,
                                        size: 45, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _user!.username,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _user!.bio ?? "",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${_user!.name} ${_user!.surname}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FollowersPage(
                                                userId: _user!.id),
                                          ),
                                        ).then((_) => _loadProfile());
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            "${_user!.followersCount ?? 0}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            "Takipçi",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FollowingsPage(
                                                userId: _user!.id),
                                          ),
                                        ).then((_) => _loadProfile());
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            "${_user!.followingCount ?? 0}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            "Takip Edilen",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfilePage(user: _user!),
                            ),
                          );
                          if (result == true) _loadProfile();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.black,
              tabs: _tabs,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  LibraryPage(),
                  QuotesPage(),
                  CommentsPage(),
                  LikedPostsPage(userId: _user!.id), // ✅ HATA BURADA DÜZELTİLDİ
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
