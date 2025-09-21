import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../config/app_images_config.dart';
import '../../../views/home/post_page/components/post_gallery_handler.dart';
import '../../components/app_loader.dart';
import '../../components/app_video.dart';
import '../../components/network_image.dart';
import '../../components/skeleton.dart';
import '../../constants/constants.dart';
import '../../models/article.dart';
import '../../themes/theme_manager.dart';
import '../../utils/app_utils.dart';

String getYouTubeThumbnail(String url) {
  final Uri uri = Uri.parse(url);
  final videoId = uri.queryParameters['v'] ?? uri.pathSegments.last;
  return 'https://img.youtube.com/vi/$videoId/0.jpg';
}

class AppHtmlExtension extends HtmlExtension {
  final ArticleModel article;

  AppHtmlExtension(this.article);

  @override
  Set<String> get supportedTags =>
      {'iframe', 'figure', 'img', 'wp-block-gallery', 'video', 'div'};

  @override
  InlineSpan build(ExtensionContext context) {
    return WidgetSpan(child: returnView(context));
  }

  Widget returnView(ExtensionContext context) {
    final element = context.element;
    if (element == null) return const SizedBox();
    if (element.localName == 'div' && element.classes.contains('wp-video')) {
      final videoElement = element.querySelector('video');
      if (videoElement != null) {
        debugPrint('Found WordPress video container');
        return buildVideoView(videoElement);
      }
    } else if (element.localName == 'figure') {
      // Check if the figure contains an iframe
      final iframeElement = element.querySelector('iframe');
      if (iframeElement != null) {
        return buildIframeView(iframeElement);
      }

      // Check if the figure contains an image
      final imgElement = element.querySelector('img');
      if (imgElement != null) {
        return buildImageView(imgElement);
      }

      // Check if the figure contains a video
      final videoElement = element.querySelector('video');
      if (videoElement != null) {
        return buildVideoView(videoElement);
      }
    } else if (element.localName == 'iframe') {
      return buildIframeView(element);
    } else if (element.localName == 'img') {
      return buildImageView(element);
    } else if (element.localName == 'wp-block-gallery') {
      return buildGalleryView(element);
    } else if (element.localName == 'video') {
      return buildVideoView(element);
    }

    return const SizedBox();
  }

  Widget buildIframeView(dom.Element element) {
    final String? srcAttribute = element.attributes['src'];
    final String videoSource =
        srcAttribute != null && srcAttribute.startsWith('data:')
            ? element.attributes['data-src'].toString()
            : srcAttribute.toString();
    final width = element.attributes['width'] ?? '1920';
    final height = element.attributes['height'] ?? '1080';

    double? aspectRatio;
    aspectRatio = double.parse(width) / double.parse(height);
    if (videoSource.contains('youtube')) {
      final thumbnail = getYouTubeThumbnail(videoSource);
      return AppVideoHtmlRender(
        url: videoSource,
        isYoutube: true,
        aspectRatio: aspectRatio,
        thumbnail: thumbnail,
        article: article,
      );
    } else if (videoSource.contains('facebook.com')) {
      return SocialEmbedRenderer(data: videoSource, platform: 'facebook');
    } else {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: NetworkImageWithLoader(AppImagesConfig.noImageUrl),
      );
    }
  }

  Widget buildImageView(dom.Element element) {
    String? src = element.attributes['data-src'];
    src ??= element.attributes['src'];

    // Handle base64 encoded images
    if (src!.startsWith('data:image')) {
      final base64String = src.split(',').last;
      final bytes = base64.decode(base64String);
      return Image.memory(bytes, fit: BoxFit.cover);
    } else {
      return CachedNetworkImage(
        imageUrl: src,
        placeholder: (context, url) => const AspectRatio(
          aspectRatio: 16 / 9,
          child: Skeleton(),
        ),
      );
    }
  }

  Widget buildGalleryView(dom.Element element) {
    List<String> imagesUrl = [];
    final src = element.children;
    imagesUrl =
        src.map((e) => e.children.first.attributes['src'] ?? '').toList();

    return PostGalleryRenderer(imagesUrl: imagesUrl);
  }

  Widget buildVideoView(dom.Element element) {
    // Get src from the video element or its source child
    String? src = element.attributes['src'];

    // If no src directly on video element, look for source element
    if (src == null || src.isEmpty) {
      final sourceElement = element.querySelector('source');
      if (sourceElement != null) {
        src = sourceElement.attributes['src'];
      }
    }

    // If still no source, check for fallback anchor
    if (src == null || src.isEmpty) {
      final anchorElement = element.querySelector('a');
      if (anchorElement != null) {
        src = anchorElement.attributes['href'];
      }
    }

    // No usable source found
    if (src == null || src.isEmpty) {
      return const SizedBox();
    }

    // Check if this is a WordPress video with the wp-video-shortcode class
    final bool isWordPressVideo =
        element.classes.contains('wp-video-shortcode');

    // Get width and height, prioritizing attributes over inline style
    double? aspectRatio;

    // Try to extract dimensions and calculate aspect ratio
    if (element.attributes.containsKey('width') &&
        element.attributes.containsKey('height')) {
      try {
        final widthValue = double.parse(element.attributes['width']!);
        final heightValue = double.parse(element.attributes['height']!);
        if (widthValue > 0 && heightValue > 0) {
          aspectRatio = widthValue / heightValue;
        }
      } catch (e) {
        // Parsing failed, will use default
      }
    }

    // If we couldn't get aspect ratio from attributes, use default
    aspectRatio ??= 16 / 9;

    // For debugging
    debugPrint('Video URL: $src');
    debugPrint('Is WordPress Video: $isWordPressVideo');
    debugPrint('Aspect Ratio: $aspectRatio');

    // Return wrapped in a container that constrains the width
    return LayoutBuilder(
      builder: (context, constraints) {
        // Limit the video width to the available width
        final maxWidth = constraints.maxWidth;

        return Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          width: maxWidth,
          child: AspectRatio(
            aspectRatio: aspectRatio ?? 16 / 9,
            child: AppVideoHtmlRender(
              url: src!,
              isYoutube: false,
              aspectRatio: aspectRatio ?? 16 / 9,
              article: article,
            ),
          ),
        );
      },
    );
  }
}

class AppHtmlBlockquoteExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'blockquote'};

  @override
  InlineSpan build(ExtensionContext context) {
    return WidgetSpan(child: returnView(context));
  }

  Widget returnView(ExtensionContext context) {
    if (context.classes.contains('twitter-tweet')) {
      return SocialEmbedRenderer(data: context.innerHtml, platform: 'twitter');
    } else if (context.classes.contains('instagram-media')) {
      return SocialEmbedRenderer(
          data: context.element!.outerHtml, platform: 'instagram');
    } else if (context.classes.contains('wp-block-quote')) {
      return QuoteRenderer(quote: context.innerHtml);
    } else {
      return SocialEmbedRenderer(data: context.innerHtml, platform: null);
    }
  }
}

class AppHtmlCodeExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'code'};

  @override
  InlineSpan build(ExtensionContext context) {
    return WidgetSpan(child: returnView(context));
  }

  Widget returnView(ExtensionContext context) {
    final code =
        HtmlUnescape().convert(parse(context.innerHtml).documentElement!.text);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SyntaxView(
        code: code,
        syntax: Syntax.DART,
        syntaxTheme: SyntaxTheme.vscodeDark(),
        fontSize: 12.0,
        withZoom: true,
        expanded: false,
        selectable: true,
      ),
    );
  }
}

class SocialEmbedRenderer extends ConsumerStatefulWidget {
  const SocialEmbedRenderer({super.key, required this.data, this.platform});

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
        ? AppColors.scaffoldBackgrounDark
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return !loaded
        ? const Center(child: AppLoader())
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

class QuoteRenderer extends StatelessWidget {
  final String quote;
  const QuoteRenderer({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            VerticalDivider(
                color: Theme.of(context).primaryColor, width: 20, thickness: 2),
            Expanded(
                child: Text(
              HtmlUnescape().convert(parse(quote).documentElement!.text),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
