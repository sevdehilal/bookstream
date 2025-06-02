import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/donation_campaign.dart';
import '../services/service.dart';
import '../create_campaign_page.dart';

class GeneralOverviewPage extends StatefulWidget {
  @override
  _GeneralOverviewPageState createState() => _GeneralOverviewPageState();
}

class _GeneralOverviewPageState extends State<GeneralOverviewPage> {
  List<DonationCampaign> campaigns = [];
  bool isLoading = true;
  bool showingMyCampaigns = false;

  @override
  void initState() {
    super.initState();
    _loadAllCampaigns(); // Sayfa açıldığında herkese açık kampanyaları getir
  }

  Future<void> _loadAllCampaigns() async {
    setState(() {
      isLoading = true;
      showingMyCampaigns = false;
    });

    try {
      final data = await ApiService.fetchPendingDonationCampaigns();
      setState(() {
        campaigns = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tüm kampanyalar alınamadı.')),
      );
    }
  }

  Widget _getImage(String imageStr) {
    ImageProvider? imageProvider;

    try {
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
      imageProvider = const AssetImage('assets/logo.png');
    }

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: imageProvider!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _loadMyCampaigns() async {
    setState(() {
      isLoading = true;
      showingMyCampaigns = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");

      if (userId == null) throw Exception("Kullanıcı ID bulunamadı");

      final data = await ApiService.fetchDonationCampaignsByUser(userId);
      setState(() {
        campaigns = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kampanyalarım alınamadı.')),
      );
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Cevap Bekleniyor';
      case 1:
        return 'Bağış İşleminiz Onaylandı';
      case 2:
        return 'Tamamlandı';
      case 3:
        return 'İptal Edildi';
      default:
        return 'Reddedildi';
    }
  }

  void showDetailsPopup(DonationCampaign campaign) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${campaign.institutionName} Detayları'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📷 Resim ekleniyor:
              if (campaign.image != null)
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _getImage(campaign.image!),
                  ),
                ),
              SizedBox(height: 12),
              Text("Şehir: ${campaign.institutionCity}"),
              Text("Adres: ${campaign.institutionAddress}"),
              Text(
                  "İletişim: ${campaign.contactName} - ${campaign.contactPhone}"),
              Text("E-Posta: ${campaign.contactEmail}"),
              SizedBox(height: 6),
              Text("🎯 Hedef Kitap: ${campaign.targetBookCount}"),
              Text("📦 Toplanan Kitap: ${campaign.collectedBookCount}"),
              SizedBox(height: 6),
              Text("📝 Açıklama: ${campaign.detail}"),
              SizedBox(height: 6),
              if (showingMyCampaigns)
                Text("📌 Durum: ${_getStatusText(campaign.status)}"),
              SizedBox(height: 6),
              Text(
                campaign.cargoCode?.isNotEmpty == true
                    ? 'Kargo Kodu: ${campaign.cargoCode}'
                    : 'Henüz kargo kodu yok.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Kapat'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void showCargoCodePopup(String cargoCode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Kargo Kodu'),
        content: Text(
          cargoCode.isNotEmpty
              ? 'Bu kampanyanın kargo kodu: $cargoCode'
              : 'Bu kampanya için henüz kargo kodu oluşturulmamış.',
        ),
        actions: [
          TextButton(
            child: Text('Kapat'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              showingMyCampaigns
                  ? ElevatedButton(
                      onPressed: _loadAllCampaigns,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Geri"),
                    )
                  : ElevatedButton(
                      onPressed: _loadMyCampaigns,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Kampanyalarım"),
                    ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateCampaignPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Kampanya Oluştur'),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : campaigns.isEmpty
                  ? Center(
                      child: Text(showingMyCampaigns
                          ? 'Henüz sizin oluşturduğunuz kampanya yok.'
                          : 'Henüz kampanya yok.'),
                    )
                  : ListView.builder(
                      itemCount: campaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = campaigns[index];
                        return SizedBox(
                          height: 220,
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "📚 ${campaign.institutionName}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "📝 ${campaign.detail}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                                "🎯 Hedef Kitap: ${campaign.targetBookCount}"),
                                            Text(
                                                "📦 Toplanan Kitap: ${campaign.collectedBookCount}"),
                                            if (showingMyCampaigns)
                                              Text(
                                                  "📌 Durum: ${_getStatusText(campaign.status)}"),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            showDetailsPopup(campaign),
                                        icon: Icon(Icons.info_outline),
                                        tooltip: "Detayları Gör",
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  if (!showingMyCampaigns)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton(
                                        onPressed: () => showCargoCodePopup(
                                            campaign.cargoCode ?? ''),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal[700],
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                            "Bağışta bulunmak istiyorsanız tıklayın"),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
