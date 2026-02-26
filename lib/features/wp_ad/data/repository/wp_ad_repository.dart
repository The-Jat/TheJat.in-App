import 'package:dio/dio.dart';

import '../../../../config/wp_config.dart';
import '../../../../core/logger/app_logger.dart';
import '../models/wp_ad.dart';

class WPAdRepository {
  final Dio dio;

  WPAdRepository(this.dio);

  Future<List<WPAd>> getAllAds() async {
    List<WPAd> allAds = [];
    const url =
        'https://${WPConfig.url}/wp-json/wp/v2/custom-ads?per_page=100&_fields=id,thumbnail,ad_target,ad_size,expiry_date';

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final decodedResponse = response.data as List;
        allAds = decodedResponse.map((e) => WPAd.fromMap(e)).toList();
        return allAds;
      } else {
        Log.info('Response Code: ${response.statusCode}');
        Log.info(response.data);
        return allAds;
      }
    } catch (e) {
      Log.error(e.toString());
      return allAds;
    }
  }
}
