import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/ad_config.dart';
import '../../config/wp_config.dart';
import '../constants/constants.dart';
import '../controllers/config/config_controllers.dart';
import '../themes/theme_manager.dart';

class BannerAdWidget extends ConsumerWidget {
  const BannerAdWidget({
    super.key,
    this.isLarge = false,
  });

  final bool isLarge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value;
    final isAdOn = config?.isAdOn ?? false;
    final priority = config?.adnetwork;
    if (isAdOn) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
            vertical: 16.0, horizontal: 12.0), // Added padding
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.scaffoldBackgrounDark
              : Colors.white,
          border: Border.all(
            color: Colors.grey.withValues(alpha: .2),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ad label is now always visible
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Advertisement',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[600],
                ),
              ),
            ),
            Center(
              child: EasySmartBannerAd(
                priorityAdNetworks: priority ?? [AdNetwork.any],
                adSize: isLarge ? AdSize.largeBanner : AdSize.banner,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class NativeAdWidget extends HookConsumerWidget {
  final bool isSmallSize;
  final bool hasBorderAndLabel;

  const NativeAdWidget({
    super.key,
    this.isSmallSize = false,
    this.hasBorderAndLabel =
        true, // Changed default to true for policy compliance
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double minHeight = isSmallSize ? 90.0 : 320.0;
    final double maxHeight = isSmallSize ? 120.0 : 360.0;

    final nativeAd = useState<NativeAd?>(null);
    final nativeAdIsLoaded = useState<bool>(false);
    final isDark = ref.watch(isDarkMode(context));
    final isAdOn = ref.watch(configProvider).value?.isAdOn ?? false;

    if (!isAdOn) {
      return const SizedBox();
    }

    useEffect(() {
      bool isMounted = true;

      Future<void> loadAd() async {
        if (nativeAd.value != null) {
          await nativeAd.value!.dispose();
          if (!isMounted) return;
          nativeAd.value = null;
        }

        try {
          final ad = NativeAd(
            adUnitId: kDebugMode
                ? Platform.isIOS
                    ? 'ca-app-pub-3940256099942544/3986624511'
                    : 'ca-app-pub-3940256099942544/2247696110'
                : Platform.isIOS
                    ? AdConfig.admobIosNative
                    : AdConfig.admobAndroidNative,
            listener: NativeAdListener(
              onAdLoaded: (ad) {
                if (isMounted) {
                  debugPrint('Native Ad loaded successfully');
                  nativeAdIsLoaded.value = true;
                }
              },
              onAdFailedToLoad: (ad, error) {
                debugPrint('Native Ad failed to load: $error');
                if (isMounted) {
                  nativeAdIsLoaded.value = false;
                  ad.dispose();
                }
                if (error.code == 1 && isMounted) {
                  Future.delayed(const Duration(seconds: 30), () {
                    if (isMounted) loadAd();
                  });
                }
              },
              onAdClicked: (ad) => debugPrint('Native Ad clicked'),
              onAdImpression: (ad) => debugPrint('Native Ad impression'),
              onAdClosed: (ad) => debugPrint('Native Ad closed'),
            ),
            request: const AdRequest(),
            nativeTemplateStyle: NativeTemplateStyle(
              templateType:
                  isSmallSize ? TemplateType.small : TemplateType.medium,
              mainBackgroundColor:
                  isDark ? AppColors.scaffoldBackgrounDark : Colors.white,
              cornerRadius: 10.0,
              callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.white,
                backgroundColor: WPConfig.primaryColor,
                style: NativeTemplateFontStyle.normal,
                size: 16.0,
              ),
              primaryTextStyle: NativeTemplateTextStyle(
                textColor: isDark ? Colors.white : Colors.grey.shade900,
                backgroundColor: Colors.transparent,
                style: NativeTemplateFontStyle.bold,
                size: 16.0,
              ),
              secondaryTextStyle: NativeTemplateTextStyle(
                textColor:
                    isDark ? Colors.grey.shade100 : Colors.blueGrey.shade600,
                backgroundColor: Colors.transparent,
                style: NativeTemplateFontStyle.normal,
                size: 14.0,
              ),
              tertiaryTextStyle: NativeTemplateTextStyle(
                textColor:
                    isDark ? Colors.grey.shade100 : Colors.blueGrey.shade500,
                backgroundColor: Colors.transparent,
                style: NativeTemplateFontStyle.normal,
                size: 14.0,
              ),
            ),
          );

          if (!isMounted) {
            ad.dispose();
            return;
          }

          nativeAd.value = ad;
          await ad.load();
        } catch (e) {
          debugPrint('Error loading Native Ad: $e');
          if (isMounted) {
            nativeAdIsLoaded.value = false;
          }
        }
      }

      loadAd();

      return () async {
        isMounted = false;
        final currentAd = nativeAd.value;
        if (currentAd != null) {
          await currentAd.dispose();
        }
      };
    }, [isDark, isSmallSize]);

    if (!nativeAdIsLoaded.value || nativeAd.value == null) {
      return const SizedBox();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0), // Added padding
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Added margin
      decoration: BoxDecoration(
        color: isDark ? AppColors.scaffoldBackgrounDark : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withValues(alpha: .2),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ad label is now always visible with consistent styling
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Advertisement',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 320.0,
                minHeight: minHeight,
                maxHeight: maxHeight,
              ),
              child: AdWidget(ad: nativeAd.value!),
            ),
          ),
        ],
      ),
    );
  }
}
