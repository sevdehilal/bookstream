import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/active_user.dart';
import 'user_library_page.dart';
import 'user_quotes_page.dart';
import 'user_comments_page.dart';
import 'user_followers_page.dart';
import 'user_following_page.dart';
import 'user_liked_posts_page.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with TickerProviderStateMixin {
  ActiveUserModel? _user;
  bool _isLoading = true;
  bool _isFollowing = false;
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: "Kitaplık"),
    Tab(text: "Alıntı"),
    Tab(text: "Yorum"),
    Tab(text: "Beğeni"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadUser();
    _checkIfFollowing();
  }

  Future<void> _loadUser() async {
    try {
      final user = await ApiService.fetchOtherUserProfile(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Kullanıcı yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfFollowing() async {
    try {
      final isFollowing = await ApiService.isFollowing(widget.userId);
      setState(() {
        _isFollowing = isFollowing;
      });
    } catch (e) {
      print('Takip kontrol hatası: $e');
    }
  }

  Future<void> _followUser() async {
    try {
      await ApiService.followUser(widget.userId);
      setState(() {
        _isFollowing = true;
      });
      await _loadUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı takip edildi.')),
      );
    } catch (e) {
      print('Takip hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Takip işlemi başarısız.')),
      );
    }
  }

  Future<void> _unfollowUser() async {
    try {
      await ApiService.unfollowUser(widget.userId);
      setState(() {
        _isFollowing = false;
      });
      await _loadUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı takipten çıkarıldı.')),
      );
    } catch (e) {
      print('Takipten çıkma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Takipten çıkma işlemi başarısız.')),
      );
    }
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 223, 231),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 212, 223, 231),
        title: const Text('Kullanıcı Profili'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text("Kullanıcı bilgisi alınamadı."))
              : SafeArea(
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sol taraf: Fotoğraf + username + bio
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
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (_user!.bio != null &&
                                        _user!.bio!.isNotEmpty)
                                      Text(
                                        _user!.bio!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                // Sağ taraf: Ad Soyad + Takip Bilgileri + Takip butonu
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // TAKİPÇİ
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      UserFollowersPage(
                                                          userId:
                                                              widget.userId),
                                                ),
                                              );
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
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(
                                              width:
                                                  32), // iki kutu arasına boşluk

                                          // TAKİP EDİLENLER
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      UserFollowingPage(
                                                          userId:
                                                              widget.userId),
                                                ),
                                              );
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
                                                  "Takip Edilenler",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_isFollowing) {
                                            await _unfollowUser();
                                          } else {
                                            await _followUser();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(100, 36),
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.blueGrey[700],
                                          textStyle:
                                              const TextStyle(fontSize: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                        ),
                                        child: Text(_isFollowing
                                            ? 'Takipten Çık'
                                            : 'Takip Et'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                            UserLibraryPage(userId: widget.userId),
                            UserQuotesPage(userId: widget.userId),
                            UserCommentsPage(userId: widget.userId),
                            FollowedUsersLikedPostsPage(userId: widget.userId),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
