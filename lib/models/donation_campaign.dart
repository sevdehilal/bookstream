class DonationCampaign {
  final int id;
  final int creatorUserId;
  final String institutionName;
  final String institutionCity;
  final String institutionAddress;
  final String detail;
  final int targetBookCount;
  final int collectedBookCount;
  final String createdDate;
  final String? approvedDate;
  final String? endDate;
  final String? rejectionReason;
  final String? cargoCode;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final String? image; // ✅ düzeltme burada
  final int status;

  DonationCampaign({
    required this.id,
    required this.creatorUserId,
    required this.institutionName,
    required this.institutionCity,
    required this.institutionAddress,
    required this.detail,
    required this.targetBookCount,
    required this.collectedBookCount,
    required this.createdDate,
    this.approvedDate,
    this.endDate,
    this.rejectionReason,
    this.cargoCode,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    this.image, // ✅ burada da
    required this.status,
  });

  factory DonationCampaign.fromJson(Map<String, dynamic> json) {
    return DonationCampaign(
      id: json['id'],
      creatorUserId: json['creatorUserId'],
      institutionName: json['institutionName'],
      institutionCity: json['institutionCity'],
      institutionAddress: json['institutionAddress'],
      detail: json['detail'],
      targetBookCount: json['targetBookCount'],
      collectedBookCount: json['collectedBookCount'],
      createdDate: json['createdDate'],
      approvedDate: json['approvedDate'],
      endDate: json['endDate'],
      rejectionReason: json['rejectionReason'],
      cargoCode: json['cargoCode'],
      contactName: json['contactName'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      image: json['image'], // ✅ burada bir değişiklik yok
      status: json['status'],
    );
  }
}
