import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../../config/ad_config.dart';

class AppAdIdManager extends IAdIdManager {
  const AppAdIdManager();

  static bool isAndroid = Platform.isAndroid;

  @override
  AppAdIds? get admobAdIds => AppAdIds(
        appId: isAndroid ? AdConfig.admobAndroidAppID : AdConfig.admobIOSappID,
        appOpenId: isAndroid
            ? AdConfig.admobAndroidAppOpenAd
            : AdConfig.admobIOSAppOpenAd,
        bannerId:
            isAndroid ? AdConfig.admobAndroidBannerAd : AdConfig.adMobIosBanner,
        interstitialId: isAndroid
            ? AdConfig.admobAndroidInterstitial
            : AdConfig.admobIosInterstitial,
        rewardedId: isAndroid
            ? AdConfig.admobAndroidRewardedAd
            : AdConfig.admobIOSRewardedAd,
      );

  @override
  AppAdIds? get unityAdIds => AppAdIds(
        appId: isAndroid ? AdConfig.unityappIdAndroid : AdConfig.unityappIdIOS,
        bannerId: isAndroid
            ? AdConfig.unitybannerIdAndroid
            : AdConfig.unitybannerIdIOS,
        interstitialId: isAndroid
            ? AdConfig.unityinterstitialIdAndroid
            : AdConfig.unityinterstitialIdIOS,
        rewardedId: isAndroid
            ? AdConfig.unityrewardedIdAndroid
            : AdConfig.unityrewardedIdIOS,
      );

  @override
  AppAdIds? get appLovinAdIds => AppAdIds(
        appId: AdConfig.appLovinappId,
        bannerId: isAndroid
            ? AdConfig.appLovinbannerIdAndroid
            : AdConfig.appLovinbannerIdIOS,
        interstitialId: isAndroid
            ? AdConfig.appLovininterstitialIdAndroid
            : AdConfig.appLovininterstitialIdIOS,
        rewardedId: isAndroid
            ? AdConfig.appLovinrewardedIdAndroid
            : AdConfig.appLovinrewardedIdIOS,
      );

  @override
  AppAdIds? get fbAdIds => AppAdIds(
        appId: isAndroid ? AdConfig.fbappIdAndroid : AdConfig.fbappIdIOS,
        bannerId:
            isAndroid ? AdConfig.fbbannerIdAndroid : AdConfig.fbbannerIdIOS,
        interstitialId: isAndroid
            ? AdConfig.fbinterstitialIdAndroid
            : AdConfig.fbinterstitialIdIOS,
        rewardedId:
            isAndroid ? AdConfig.fbrewardedIdAndroid : AdConfig.fbrewardedIdIOS,
      );
}
