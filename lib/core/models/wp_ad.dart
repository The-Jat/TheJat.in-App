import '../logger/app_logger.dart';

class WPAd {
  int id;
  String imageURL;
  String adTarget;
  bool isBanner;
  String size;
  DateTime? expiryDate;
  WPAd({
    required this.id,
    required this.imageURL,
    required this.adTarget,
    required this.isBanner,
    required this.size,
    this.expiryDate,
  });

  factory WPAd.fromMap(Map<String, dynamic> map) {
    // Parse expiry date if it exists
    DateTime? parsedExpiryDate;
    if (map['expiry_date'] != null &&
        map['expiry_date'].toString().isNotEmpty) {
      try {
        // Split the date string and rearrange to standard format
        List<String> dateParts = map['expiry_date'].split('/');
        if (dateParts.length == 3) {
          String standardDate =
              '${dateParts[2]}-${dateParts[0]}-${dateParts[1]}';
          parsedExpiryDate = DateTime.parse(standardDate);
        }
      } catch (e) {
        Log.error('Error parsing expiry date: ${e.toString()}');
      }
    }

    return WPAd(
      id: map['id']?.toInt() ?? 0,
      imageURL: map['thumbnail'] ?? '',
      adTarget: map['ad_target'] ?? '',
      isBanner: map['ad_size'] == 'Banner' ? true : false,
      size: map['ad_size'] ?? '',
      expiryDate: parsedExpiryDate,
    );
  }

  @override
  String toString() {
    return 'WPAd(id: $id, imageURL: $imageURL, adTarget: $adTarget, isBanner: $isBanner, size: $size, expiryDate: $expiryDate)';
  }
}
