import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/wp_ad.dart';
import '../data/repository/wp_ad_repository.dart';
import '../../config/providers/config_providers.dart';
import '../../../core/dio/dio_provider.dart';

final wpAdProvider =
    StateNotifierProvider<WPAdNotifier, AsyncData<List<WPAd>>>((ref) {
  final dio = ref.read(dioProvider);
  final repo = WPAdRepository(dio);
  final isCustomOn = ref.watch(configProvider).value?.isCustomAdOn ?? false;
  return WPAdNotifier(repo, isCustomOn);
});

class WPAdNotifier extends StateNotifier<AsyncData<List<WPAd>>> {
  WPAdNotifier(this.repo, this.isCustomAdOn) : super(const AsyncData([])) {
    {
      onInit();
    }
  }

  final WPAdRepository repo;
  final bool isCustomAdOn;

  onInit() async {
    if (isCustomAdOn) {
      final allAds = await repo.getAllAds();
      final now = DateTime.now();

      final validAds = allAds.where((ad) {
        return ad.expiryDate == null || ad.expiryDate!.isAfter(now);
      }).toList();

      state = AsyncData(validAds);
    } else {
      state = const AsyncData([]);
    }
  }

  int getRandomAdNumber() {
    final totalAds = state.value.length;

    if (totalAds > 0) {
      final random = math.Random();
      final adNumber = random.nextInt(totalAds);
      return adNumber;
    } else {
      return -1;
    }
  }

  WPAd? getABannerAd() {
    final allBannerAds =
        state.value.where((element) => element.isBanner).toList();
    if (allBannerAds.isNotEmpty) {
      final totalAds = allBannerAds.length;
      final random = math.Random();
      final adNumber = random.nextInt(totalAds);
      return allBannerAds[adNumber];
    } else {
      return null;
    }
  }

  WPAd? getALargeBannerAd() {
    final allBannerAds =
        state.value.where((element) => !element.isBanner).toList();
    if (allBannerAds.isNotEmpty) {
      final totalAds = allBannerAds.length;
      final random = math.Random();
      final adNumber = random.nextInt(totalAds);
      return allBannerAds[adNumber];
    } else {
      return null;
    }
  }
}
