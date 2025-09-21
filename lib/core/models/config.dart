// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../repositories/others/post_style_local.dart';

class NewsProConfig {
  String mainTabName;
  List<int> homeTopTabCategories;
  List<int> blockedCategories;
  List<int> featuredPosts;
  bool automaticSlide;
  bool showTopLogoInHome;

  String privacyPolicyUrl;
  String termsAndServicesUrl;
  String cookieConsentText;
  bool showCookieConsent;
  String aboutPageUrl;

  String facebookUrl;
  String twitterUrl;
  String telegramUrl;
  String instagramUrl;
  String tiktokUrl;
  String youtubeUrl;
  String whatsappUrl;

  String appShareLink;
  String appstoreAppID;

  String ownerName;
  String ownerEmail;
  String ownerPhone;
  String ownerAddress;
  String appDescription;
  String reportEmail;

  bool isAdOn;
  bool isCustomAdOn;
  int interstialAdCount;
  int adIntervalinPost;
  int customAdIntervalInPost;
  List<AdNetwork> adnetwork;

  bool showDateInApp;
  bool showAuthor;
  bool showTrendingPopularIcon;
  bool showComment;
  bool showViewOnWebsiteButton;
  bool showReportButton;

  bool isSocialLoginEnabled;
  bool isLoginEnabled;

  bool onboardingEnabled;
  bool multiLanguageEnabled;
  bool showAuthorsInExplorePage;
  bool showPostViews;

  PostDetailStyle postDetailStyle;
  bool hidePageStyle; // If true, the post detail style will be hidden

  NewsProConfig({
    required this.mainTabName,
    required this.homeTopTabCategories,
    required this.blockedCategories,
    required this.featuredPosts,
    required this.automaticSlide,
    required this.showTopLogoInHome,
    required this.privacyPolicyUrl,
    required this.termsAndServicesUrl,
    required this.cookieConsentText,
    required this.showCookieConsent,
    required this.aboutPageUrl,
    required this.facebookUrl,
    required this.twitterUrl,
    required this.telegramUrl,
    required this.instagramUrl,
    required this.tiktokUrl,
    required this.youtubeUrl,
    required this.whatsappUrl,
    required this.appShareLink,
    required this.appstoreAppID,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
    required this.ownerAddress,
    required this.appDescription,
    required this.reportEmail,
    required this.isAdOn,
    required this.isCustomAdOn,
    required this.interstialAdCount,
    required this.adIntervalinPost,
    required this.customAdIntervalInPost,
    required this.adnetwork,
    required this.showDateInApp,
    required this.showAuthor,
    required this.showTrendingPopularIcon,
    required this.showComment,
    required this.showViewOnWebsiteButton,
    required this.showReportButton,
    required this.isSocialLoginEnabled,
    required this.isLoginEnabled,
    required this.onboardingEnabled,
    required this.multiLanguageEnabled,
    required this.showAuthorsInExplorePage,
    required this.showPostViews,
    required this.postDetailStyle,
    required this.hidePageStyle,
  });

  factory NewsProConfig.fromMap(Map<String, dynamic> map) {
    return NewsProConfig(
      mainTabName: map['mainTabName'] as String,
      homeTopTabCategories: List<int>.from(map['homeTopTabCategories']),
      blockedCategories: List<int>.from(map['blockedCategories']),
      featuredPosts: List<int>.from(map['featuredPosts']),
      automaticSlide: map['automaticSlide'] as bool,
      showTopLogoInHome: map['showTopLogoInHome'] as bool,
      privacyPolicyUrl: map['privacyPolicyUrl'] as String,
      termsAndServicesUrl: map['termsAndServicesUrl'] as String,
      cookieConsentText: map['cookieConsentText'] as String,
      aboutPageUrl: map['aboutPageUrl'] as String,
      facebookUrl: map['facebookUrl'] as String,
      twitterUrl: map['twitterUrl'] as String,
      telegramUrl: map['telegramUrl'] as String,
      instagramUrl: map['instagramUrl'] as String,
      tiktokUrl: map['tiktokUrl'] as String,
      youtubeUrl: map['youtubeUrl'] as String,
      whatsappUrl: map['whatsappUrl'] as String,
      appShareLink: map['appShareLink'] as String,
      appstoreAppID: map['appstoreAppID'] as String,
      ownerName: map['ownerName'] as String,
      ownerEmail: map['ownerEmail'] as String,
      ownerPhone: map['ownerPhone'] as String,
      ownerAddress: map['ownerAddress'] as String,
      appDescription: map['appDescription'] as String,
      reportEmail: map['reportEmail'] as String,
      isAdOn: map['isAdOn'] as bool,
      isCustomAdOn: map['isCustomAdOn'] as bool,
      interstialAdCount: int.parse(map['interstialAdCount']),
      adIntervalinPost: int.parse(map['adIntervalinPost']),
      customAdIntervalInPost: int.parse(map['customAdIntervalInPost']),
      showDateInApp: map['showDateInApp'] as bool,
      showAuthor: map['showAuthor'] as bool,
      showTrendingPopularIcon: map['showTrendingPopularIcon'] as bool,
      showComment: map['showComment'] as bool,
      showViewOnWebsiteButton: map['showViewOnWebsiteButton'] as bool,
      showReportButton: map['showReportButton'] as bool,
      isSocialLoginEnabled: map['isSocialLoginEnabled'] as bool,
      isLoginEnabled: map['isLoginEnabled'] as bool,
      onboardingEnabled: map['onboardingEnabled'] as bool,
      multiLanguageEnabled: map['multiLanguageEnabled'] as bool,
      showCookieConsent: map['showCookieConsent'] as bool,
      showAuthorsInExplorePage: map['showAuthorsInExplorePage'] as bool,
      showPostViews: map['showPostViews'] as bool,
      adnetwork: showAdFrom(map['showAdOnlyFrom']),
      postDetailStyle: getPostDetailStyle(map['page_style'] as String),
      hidePageStyle: map['hide_page_style'] as bool,
    );
  }

  static List<AdNetwork> showAdFrom(String? data) {
    if (data == null || data == '') {
      return [
        AdNetwork.admob,
        AdNetwork.unity,
        AdNetwork.appLovin,
      ];
    } else if (data == 'admob') {
      return [AdNetwork.admob];
    } else if (data == 'facebook') {
      return [AdNetwork.any];
    } else if (data == 'unity') {
      return [AdNetwork.unity];
    } else if (data == 'applovin') {
      return [AdNetwork.appLovin];
    } else {
      return [AdNetwork.any];
    }
  }

  static PostDetailStyle getPostDetailStyle(String style) {
    switch (style.toLowerCase()) {
      case 'classic':
        return PostDetailStyle.classic;
      case 'magazine':
        return PostDetailStyle.magazine;
      case 'minimal':
        return PostDetailStyle.minimal;
      case 'card':
        return PostDetailStyle.card;
      case 'story':
        return PostDetailStyle.story;
      default:
        return PostDetailStyle.classic;
    }
  }
}
