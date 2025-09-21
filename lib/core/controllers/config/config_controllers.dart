import 'package:easy_ads_flutter/easy_ads_flutter.dart'
    show AdRequest, EasyAds, IAdIdManager, RequestConfiguration;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/core/ads/ad_id_provider.dart';
import 'package:news_pro/core/logger/app_logger.dart';

import '../../models/config.dart';
import '../../repositories/configs/config_repository.dart';
import '../dio/dio_provider.dart';

final configProvider =
    StateNotifierProvider<NewsProConfigNotifier, AsyncValue<NewsProConfig>>(
        (ref) {
  final dio = ref.read(dioProvider);
  final repo = ConfigRepository(dio: dio);

  return NewsProConfigNotifier(repo);
});

class NewsProConfigNotifier extends StateNotifier<AsyncValue<NewsProConfig>> {
  NewsProConfigNotifier(
    this.repo,
  ) : super(const AsyncValue.loading());

  final ConfigRepository repo;

  Future<void> init() async {
    final data = await repo.getNewsProConfig();
    if (data == null) {
      const errorMessage = 'No configuration found';
      state = AsyncError(errorMessage, StackTrace.fromString(errorMessage));
    } else {
      if (data.isAdOn) {
        await initializeAdNetworks();
      }
      state = AsyncData(data);
      return;
    }
  }

  Future<NewsProConfig?> getConfig() async {
    if (state.value != null) return state.value!;

    final data = await repo.getNewsProConfig();
    if (data == null) {
      const errorMessage = 'No configuration found';
      state = AsyncError(errorMessage, StackTrace.fromString(errorMessage));
      return null;
    }
    return data;
  }

  Future<void> initializeAdNetworks() async {
    try {
      const IAdIdManager adIdManager = AppAdIdManager();
      // Initialize the ad networks
      await EasyAds.instance.initialize(
        adIdManager,
        adMobAdRequest: const AdRequest(),
        // Set true if you want to show age restricted (age below 16 years) ads for applovin
        isAgeRestrictedUserForApplovin: true,
        // To enable Facebook Test mode ads
        admobConfiguration: RequestConfiguration(testDeviceIds: [
          '072D2F3992EF5B4493042ADC632CE39F',
          '00008030-00163022226A802E',
        ]),
        enableLogger: false,
      );
    } on Exception catch (e) {
      Log.error('Error initializing ad networks: $e');
    }
  }
}
