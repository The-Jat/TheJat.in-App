import 'dart:ui';

import 'package:timeago/timeago.dart' as timeago;

class AppLocales {
  static Locale english = const Locale('en', 'US');
  static Locale arabic = const Locale('ar', 'SA');
  static Locale spanish = const Locale('es', 'ES');
  static Locale hindi = const Locale('hi', 'IN');
  static Locale turkish = const Locale('tr', 'TR');
  static Locale french = const Locale('fr', 'FR');
  static Locale bengali = const Locale('bn', 'BD');
  static Locale chinese = const Locale('zh', 'CN');

  static List<Locale> supportedLocales = [
    english,
    arabic,
    chinese,
    turkish,
    spanish,
    hindi,
    french,
    bengali
  ];

  /// Returns a formatted version of language
  /// if nothing is present than it will pass the locale to a string
  static String formattedLanguageName(Locale locale) {
    if (locale == english) {
      return 'English';
    } else if (locale == arabic) {
      return 'عربي';
    } else if (locale == spanish) {
      return 'Español';
    } else if (locale == hindi) {
      return 'हिन्दी';
    } else if (locale == turkish) {
      return 'Türkçe';
    } else if (locale == french) {
      return 'Français';
    } else if (locale == bengali) {
      return 'বাংলা';
    } else if (locale == chinese) {
      return '中文';
    } else {
      return locale.countryCode.toString();
    }
  }

  /// If you want custom messages on time ago (eg. a minute ago, a while ago)
  /// you can modify the below code, otherwise don't modify it unless necesarry
  static void setLocaleMessages() {
    timeago.setLocaleMessages(english.toString(), timeago.EnMessages());
    timeago.setLocaleMessages(spanish.toString(), timeago.EsMessages());
    timeago.setLocaleMessages(arabic.toString(), timeago.ArMessages());
    timeago.setLocaleMessages(turkish.toString(), timeago.TrMessages());
    timeago.setLocaleMessages(hindi.toString(), timeago.HiMessages());
    timeago.setLocaleMessages(french.toString(), timeago.FrMessages());
    timeago.setLocaleMessages(bengali.toString(), timeago.BnMessages());
    timeago.setLocaleMessages(chinese.toString(), timeago.ZhMessages());
  }
}
