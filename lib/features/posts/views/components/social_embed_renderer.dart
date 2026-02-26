import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/themes/theme_manager.dart';
import '../../../../core/utils/app_utils.dart';

class SocialEmbedRenderer extends ConsumerStatefulWidget {
  const SocialEmbedRenderer({
    super.key,
    required this.data,
    this.platform,
  });

  final String data;
  final String? platform;

  @override
  ConsumerState<SocialEmbedRenderer> createState() => _SocialEmbedWidgetState();
}

class _SocialEmbedWidgetState extends ConsumerState<SocialEmbedRenderer> {
  late WebViewController controller;
  double height = 0.0;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    final bgColor = _getBgColor();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bgColor)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) async {
        final h = await controller.runJavaScriptReturningResult(
            'document.documentElement.scrollHeight');
        height = double.tryParse(h.toString()) ?? 700;
        loaded = true;
        setState(() {});
      }))
      ..loadRequest(Uri.dataFromString(
        _getEmbedData(widget.platform, widget.data),
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));
  }

  String _getEmbedData(String? platform, String data) {
    final isDark = ref.read(isDarkMode(context));
    switch (platform) {
      case 'facebook':
        return _facebookRender(data);
      case 'twitter':
        return _xRender(data, isDark);
      case 'instagram':
        return _instagramEmbed(data);
      default:
        return _othersRender(data);
    }
  }

  Color _getBgColor() {
    return ref.read(isDarkMode(context)) ?? false
        ? const Color(0xFF121212) // AppColors.scaffoldBackgrounDark
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return !loaded
        ? const Center(child: CircularProgressIndicator())
        : InkWell(
            onTap: () {
              final link = getLinksFromString(widget.data);
              if (link != null) {
                AppUtils.openLink(link);
              } else {
                if (widget.platform == 'facebook') {
                  AppUtils.openLink(widget.data);
                }
              }
            },
            child: IgnorePointer(
              child: SizedBox(
                height: height,
                child: WebViewWidget(controller: controller),
              ),
            ),
          );
  }

  static String _xRender(String data, bool isDarkMode) {
    final theme = isDarkMode ? 'dark' : 'light';
    return """<!DOCTYPE html>
      <html>
      <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
      <body style='margin: 0; padding: 0;'>
        <blockquote class="twitter-tweet" data-theme="$theme">$data</blockquote> 
        <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
      </body>
      </html>""";
  }

  static String _facebookRender(String data) {
    return """<!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style='margin: 0; padding: 0;'>
        <iframe src="$data" width="380" height="476" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowfullscreen="true" allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share" allowFullScreen="true"></iframe>
      </body>
      </html>""";
  }

  static String _othersRender(String data) {
    return """<!DOCTYPE html>
      <html>
      <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, width=device-width, viewport-fit=cover">
      <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
      <body style='margin: 0; padding: 0;'>
        <div>$data</div>
      </body>
      </html>""";
  }

  static String _instagramEmbed(String source) {
    return '''<!doctype html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width">
      </head>
      <body>
        $source
        <script async src="https://www.instagram.com/embed.js"></script>
      </body>
      </html>''';
  }

  static String? getLinksFromString(String text) {
    final regex = RegExp(r'href="([^"]+)"');
    final matches = regex.allMatches(text);
    return matches.isNotEmpty ? matches.last.group(1) : null;
  }
}
