import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/register.dart';
import '../models/login.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../models/active_user.dart';
import '../models/donation_campaign.dart';
import '../models/comment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://www.bookstream.online/api/Auth/';

  // Kayıt işlemi
  static Future<UserModel?> registerUser({
    required String username,
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(baseUrl + 'register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "name": name,
        "surname": surname,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['success']) {
        return UserModel.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Kayıt işlemi başarısız: ${response.statusCode}');
    }
  }

  static Future<LoginModel?> loginUser(String username, String password) async {
    final client = http.Client();
    final request = http.Request(
      'POST',
      Uri.parse('https://bookstream.online/api/Auth/login'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    request.body = json.encode({
      'username': username,
      'password': password,
    });

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return LoginModel.fromJson(responseData);
    } else {
      throw Exception(responseData['message'] ?? 'Bilinmeyen hata oluştu');
    }
  }

  static Future<UserModel?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Token yok");
      return null;
    }

    final url = Uri.parse("https://bookstream.online/api/User/profile");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          // Profil verisi başarıyla geldiğinde
          UserModel user = UserModel.fromJson(jsonData['data']);

          // Kullanıcı ID'sini SharedPreferences'e kaydediyoruz
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', user.id);
          print('userId: ${user.id}');
          // Kullanıcı ID'sini kaydediyoruz

          return user;
        } else {
          print("API başarısız döndü: ${jsonData['message']}");
          return null;
        }
      } else {
        print("HTTP Hatası: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Profil çekme hatası: $e");
      return null;
    }
  }

  static Future<List<Book>> fetchBooks() async {
    final url = Uri.parse('https://bookstream.online/api/Book');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> booksJson = data['data'];

        return booksJson.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Kitaplar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Kitap çekme hatası: $e');
      rethrow;
    }
  }

  static Future<Book?> fetchBookById(int bookId) async {
    try {
      final response = await http
          .get(Uri.parse('https://bookstream.online/api/Book/$bookId'));

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        final data = responseJson['data'];
        if (data == null) {
          print('API yanıtı boş: $data');
          return null;
        }
        return Book.fromJson(data);
      } else {
        print('API isteği başarısız: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Hata: $e');
      return null; // Hata oluşursa null döndür
    }
  }

  // Yorum ekle
  static Future<Review> postReview({
    required int userId,
    required int bookId,
    required int typeId,
    required String text,
  }) async {
    final url = Uri.parse('https://bookstream.online/api/Post');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'bookId': bookId,
        'typeId': typeId,
        'text': text,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      // API'den dönen başarılı response'ı Review modeline dönüştür
      if (responseData['success']) {
        return Review.fromJson(responseData['data']);
      } else {
        throw Exception('Yorum eklenemedi: ${responseData['message']}');
      }
    } else {
      throw Exception('Yorum eklenemedi: ${response.statusCode}');
    }
  }

  static Future<List<Review>> fetchReviewsByBookId(int bookId) async {
    final url = Uri.parse(
        'https://bookstream.online/api/Post/byBookId/ozet?bookId=$bookId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded['data'];

      // Burada sadece typeId'si 2 olanları filtreliyoruz
      return data
          .where((json) => json['typeId'] == 2) // typeId == 2 olanları alıyoruz
          .map<Review>((json) => Review.fromJson(json))
          .toList();
    } else {
      throw Exception('Yorumlar yüklenemedi');
    }
  }

  static Future<List<Review>> fetchReviewsByUserId(int userId) async {
    final url = Uri.parse(
        'https://bookstream.online/api/Post/byUserId/ozet?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded['data'];

      // Burada sadece typeId'si 2 olanları filtreliyoruz
      return data
          .where((json) => json['typeId'] == 2)
          .map<Review>((json) => Review.fromJson(json))
          .toList();
    } else {
      throw Exception('Kullanıcının yorumları yüklenemedi');
    }
  }

  static Future<List<Review>> fetchAlintiByUserId(int userId) async {
    final url = Uri.parse(
        'https://bookstream.online/api/Post/byUserId/alinti?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded['data'];

      // Burada sadece typeId'si 2 olanları filtreliyoruz
      return data
          .where((json) => json['typeId'] == 1)
          .map<Review>((json) => Review.fromJson(json))
          .toList();
    } else {
      throw Exception('Kullanıcının yorumları yüklenemedi');
    }
  }

  static Future<List<DonationCampaign>> fetchPendingDonationCampaigns() async {
    final url =
        Uri.parse('https://bookstream.online/api/DonationCampaign/active');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> campaignList = data['data'];

        return campaignList
            .map((json) => DonationCampaign.fromJson(json))
            .toList();
      } else {
        throw Exception('Kampanyalar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Bağış kampanyası çekme hatası: $e');
      rethrow;
    }
  }

  static Future<bool> createDonationCampaign(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) throw Exception('Giriş yapılmamış.');

    final url = Uri.parse('https://bookstream.online/api/DonationCampaign');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        ...body,
        "creatorUserId": userId,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Kampanya oluşturulamadı');
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token"); // veya session'dan vs.

      final response = await http.put(
        Uri.parse("https://bookstream.online/api/User/update"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // ✅ TOKEN GÖNDERİLİYOR
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        } else {
          return {
            "success": false,
            "message": "Boş yanıt alındı.",
          };
        }
      } else {
        return {
          "success": false,
          "message": "Hata: ${response.statusCode} - ${response.reasonPhrase}",
          "response": response.body,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Bir hata oluştu: $e",
      };
    }
  }

  static Future<bool> deleteAlinti(int postId) async {
    final url = Uri.parse('https://bookstream.online/api/Post/$postId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["success"] == true;
      } else {
        print('Alıntı silinemedi: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Alıntı silme hatası: $e');
      return false;
    }
  }

  static Future<bool> addBookToLibrary(
      {required int userId, required int bookId}) async {
    final url = Uri.parse('https://bookstream.online/api/Library/add');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'bookId': bookId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Kitap ekleme hatası: $e');
      return false;
    }
  }

  static const String baseUrl_ = 'https://bookstream.online/api/Library';

  // Tüm Kitaplar
  static Future<List<dynamic>> fetchLibraryBooks(int userId) async {
    final url = Uri.parse('$baseUrl_/$userId');
    return await _fetchBooks(url);
  }

  // Okuyacağım Kitaplar
  static Future<List<dynamic>> fetchToReadBooks(int userId) async {
    final url = Uri.parse('$baseUrl_/$userId/toRead');
    return await _fetchBooks(url);
  }

  // Okuyorum Kitaplar
  static Future<List<dynamic>> fetchReadingBooks(int userId) async {
    final url = Uri.parse('$baseUrl_/$userId/reading');
    return await _fetchBooks(url);
  }

  // Okudum Kitaplar
  static Future<List<dynamic>> fetchReadBooks(int userId) async {
    final url = Uri.parse('$baseUrl_/$userId/read');
    return await _fetchBooks(url);
  }

  // Yarıda Bıraktım Kitaplar
  static Future<List<dynamic>> fetchAbandonedBooks(int userId) async {
    final url = Uri.parse('$baseUrl_/$userId/abandoned');
    return await _fetchBooks(url);
  }

  // Ortak GET fonksiyonu
  static Future<List<dynamic>> _fetchBooks(Uri url) async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? [];
      } else {
        throw Exception('Kitap verileri yüklenemedi: ${url.path}');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  static Future<bool> updateLibraryStatus({
    required int userId,
    required int bookId,
    required String statusType,
    int? rating,
  }) async {
    String url = '';

    switch (statusType) {
      case 'toRead':
        url = 'https://bookstream.online/api/Library/markAsToRead';
        break;
      case 'reading':
        url = 'https://bookstream.online/api/Library/markAsReading';
        break;
      case 'read':
        url = 'https://bookstream.online/api/Library/markAsRead';
        break;
      case 'abandoned':
        url = 'https://bookstream.online/api/Library/markAsAbandoned';
        break;
      default:
        throw Exception('Geçersiz durum!');
    }

    try {
      // Eğer rating varsa, URL'ye query parametre olarak ekle
      if (rating != null &&
          (statusType == 'read' || statusType == 'abandoned')) {
        url += '?rating=$rating';
      }

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'bookId': bookId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Durum güncelleme hatası: $e');
      return false;
    }
  }

  static Future<List<ActiveUserModel>> fetchAllActiveUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://bookstream.online/api/User/allActiveUsers'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return (decoded['data'] as List)
              .map((userJson) => ActiveUserModel.fromJson(userJson))
              .toList();
        } else {
          throw Exception('Kullanıcı verisi bulunamadı.');
        }
      } else {
        throw Exception(
            'Aktif kullanıcılar alınamadı. Hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  static Future<ActiveUserModel> fetchOtherUserProfile(int userId) async {
    final response = await http.get(
      Uri.parse('https://bookstream.online/api/User/otherProfile/$userId'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true && body['data'] != null) {
        return ActiveUserModel.fromJson(body['data']);
      } else {
        throw Exception('Kullanıcı bulunamadı.');
      }
    } else {
      throw Exception(
          'Kullanıcı bilgisi alınamadı. Hata kodu: ${response.statusCode}');
    }
  }

  // Takip Etme (POST)
  static Future<bool> followUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token bulunamadı.');
    }

    final response = await http.post(
      Uri.parse('https://bookstream.online/api/Follow/follow/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Takip işlemi başarısız: ${response.statusCode}');
    }
  }

// Takipten Çıkma (DELETE)
  static Future<bool> unfollowUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token bulunamadı.');
    }

    final response = await http.delete(
      Uri.parse('https://bookstream.online/api/Follow/unfollow/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Takipten çıkma işlemi başarısız: ${response.statusCode}');
    }
  }

  static Future<bool> isFollowing(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token bulunamadı.');
    }

    final response = await http.get(
      Uri.parse('https://bookstream.online/api/Follow/isFollowing/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ??
          false; // takip ediyorsa true döner, etmiyorsa false
    } else {
      throw Exception('Takip durumu alınamadı: ${response.statusCode}');
    }
  }

  static Future<List<UserModel>> fetchFollowers(int userId) async {
    final response = await http.get(
      Uri.parse('https://bookstream.online/api/Follow/followers/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> followersData = body['data'] ?? [];
      return followersData.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Takipçiler yüklenemedi');
    }
  }

  static Future<List<UserModel>> fetchFollowings(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://bookstream.online/api/Follow/followings/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Takip edilenler yüklenemedi.');
    }
  }

  static Future<List<Review>> fetchPagedPosts(
      {required int page, required int pageSize}) async {
    final response = await http.get(
      Uri.parse(
          'https://bookstream.online/api/Post/paged?page=$page&pageSize=$pageSize'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];

      return data.map((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception('Veriler alınamadı: ${response.statusCode}');
    }
  }

  static Future<bool> toggleFavorite(int userId, int bookId) async {
    try {
      final response = await http.patch(
        Uri.parse('https://bookstream.online/api/Library/toggleFavorite'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'bookId': bookId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] == true;
      } else {
        print('Favori güncelleme hatası: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Favori güncelleme exception: $e');
      return false;
    }
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<int>> fetchFavoriteBookIds(int userId) async {
    final response = await http.get(
      Uri.parse('https://bookstream.online/api/Library/$userId/favorites'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List favorites = decoded['data'];
      return favorites.map<int>((item) => item['bookId'] as int).toList();
    } else {
      throw Exception('Favori kitaplar alınamadı.');
    }
  }

  static Future<List<DonationCampaign>> fetchDonationCampaignsByUser(
      int userId) async {
    final response = await http.get(
      Uri.parse(
          'https://bookstream.online/api/DonationCampaign/byUser/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => DonationCampaign.fromJson(json)).toList();
    } else {
      throw Exception('Kullanıcının kampanyaları alınamadı.');
    }
  }

  static Future<void> likePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('https://bookstream.online/api/PostLike/$postId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      print("API HATASI: ${response.body}");
      throw Exception('Beğenme işlemi başarısız.');
    }
  }

  static Future<bool> isPostLiked(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://bookstream.online/api/PostLike/$postId/isLiked'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? false;
    } else {
      throw Exception('Beğeni durumu alınamadı');
    }
  }

  static Future<void> unlikePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.delete(
      Uri.parse('https://bookstream.online/api/PostLike/$postId/unlike'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Beğeni kaldırma işlemi başarısız.');
    }
  }

  static Future<List<Review>> fetchLikedPosts({
    required int userId,
    required int page,
    required int pageSize,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(
          'https://bookstream.online/api/PostLike/likedPosts/$userId?page=$page&pageSize=$pageSize'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('Beğenilen gönderiler alınamadı');
    }
  }

  static Future<List<Review>> fetchFollowedUsersLikedPosts({
    required int userId,
    required int page,
    required int pageSize,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(
          'https://bookstream.online/api/PostLike/likedPosts/$userId?page=$page&pageSize=$pageSize'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('Takip edilen kullanıcıların beğenileri alınamadı');
    }
  }

  static Future<bool> addComment({
    required int postId,
    required String text,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString("token"); // ya da "accessToken", nasıl kaydettiysen

    if (token == null) {
      print("⚠️ Token bulunamadı.");
      return false;
    }

    final url = Uri.parse('https://bookstream.online/api/Comment/add');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "postId": postId,
        "text": text,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['success'] == true;
    } else {
      print('Yorum gönderme hatası: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  static Future<List<Comment>> fetchCommentsForPost(int postId) async {
    final url = Uri.parse('https://bookstream.online/api/Comment/post/$postId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final commentList = data['data'] as List;
      return commentList.map((c) => Comment.fromJson(c)).toList();
    } else {
      throw Exception(
          'Yorumlar getirilemedi: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<bool> deleteComment(int commentId) async {
    final url = Uri.parse('https://bookstream.online/api/Comment/$commentId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        print("Token bulunamadı");
        return false;
      }

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      } else {
        print("Yorum silme başarısız: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Yorum silme hatası: $e");
      return false;
    }
  }

  // services/service.dart
  static Future<bool> removeBookFromLibrary(int userId, int bookId) async {
    final response = await http.delete(Uri.parse(
        'https://bookstream.online/api/Library/remove?userId=$userId&bookId=$bookId'));

    return response.statusCode == 200;
  }

  static Future<List<Book>> fetchRecommendedBooks({
    required int userId,
    required int page,
    required int pageSize,
  }) async {
    final response = await http.get(Uri.parse(
        'https://bookstream.online/api/Recommendation/$userId?page=$page&pageSize=$pageSize'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> dataList = decoded['data'];
      return dataList.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Kitap önerileri alınamadı.');
    }
  }

  static Future<Map<String, dynamic>?> fetchBookRating(int bookId) async {
    final url = Uri.parse('https://bookstream.online/api/Book/rating/$bookId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return {
            'averageRating': (data['data']['averageRating'] as num).toDouble(),
            'totalVotes': data['data']['totalVotes'] as int,
          };
        }
      }
    } catch (e) {
      // log ya da hata mesajı göstermek istersen buraya yaz
    }
    return null;
  }
}
