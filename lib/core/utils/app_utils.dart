import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

import '../logger/app_logger.dart';

class AppUtils {
  static String totalMinute(String theString, BuildContext context) {
    int wpm = 225;
    int totalWords = theString.trim().split(' ').length;
    int totalMinutes = (totalWords / wpm).ceil();
    final totalMinutesFormat =
        NumberFormat('', context.locale.toLanguageTag()).format(totalMinutes);
    return totalMinutesFormat;
  }

  /// Dismissises Keyboard From Anywhere
  static void dismissKeyboard({required BuildContext context}) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  /// Set status bar and Color to Light
  static Future<void> setStatusBarDark() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Set status bar and Color to Dark
  static Future<void> setStatusBarLight() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  static Future<void> applyStatusBarColor(bool isDark) async {
    if (isDark) {
      setStatusBarDark();
    } else {
      setStatusBarLight();
    }
  }

  /// Set the display refresh rate to maximum
  /// Doesn't apply to IOS
  static Future<void> setDisplayToHighRefreshRate() async {
    if (Platform.isAndroid) {
      try {
        await FlutterDisplayMode.setHighRefreshRate();
      } catch (e) {
        // Fluttertoast.showToast(msg: e.toString());
        Log.error('Error setting high refresh rate: $e');
      }
    } else {
      Log.debug('Not an Android Device');
    }
  }

  /// Launch url
  static Future<void> launchUrl(String url, {bool isExternal = false}) async {
    bool canLaunch = await launcher.canLaunchUrl(Uri.parse(url));
    if (canLaunch) {
      launcher.launchUrl(
        Uri.parse(url),
        mode: isExternal
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } else {
      Fluttertoast.showToast(msg: 'Oops, can\'t launch this url');
    }
  }

  /// Open links inside app
  static Future<void> openLink(String url) async {
    try {
      final validUrl = Uri.parse(url);
      launcher.launchUrl(validUrl, mode: LaunchMode.inAppBrowserView);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Invalid URL');
    }
  }

  static Future<void> sendEmail(
      {required String email,
      required String content,
      required String subject}) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject&body=$content', //add subject and body here
    );

    var url = params.toString();
    if (await launcher.canLaunchUrl(Uri.parse(url))) {
      await launcher.launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  static String getTime(DateTime time, BuildContext context) {
    final currentLocale = EasyLocalization.of(context)!.currentLocale;
    final data = timeago.format(time, locale: currentLocale.toString());
    return data;
  }

  static String trimHtml(String html) {
    final unescape = HtmlUnescape();
    final data = unescape.convert(html);
    return data;
  }

  static void handleUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      AppUtils.openLink(url);
    } else {
      AppUtils.launchUrl(url);
    }
  }
}
