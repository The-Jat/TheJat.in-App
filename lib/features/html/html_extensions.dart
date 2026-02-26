import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';

import '../../config/wp_config.dart';
import '../posts/views/components/post_gallery_handler.dart';
import '../posts/views/components/optimized_table_view.dart';
import '../posts/views/components/virtualized_table_view.dart';
import '../posts/views/components/social_embed_renderer.dart';
import '../posts/views/components/quote_renderer.dart';
import '../../core/components/app_video.dart';
import '../../core/components/network_image.dart';
import '../../core/components/skeleton.dart';
import '../posts/data/models/article_model.dart';

String getYouTubeThumbnail(String url) {
  final Uri uri = Uri.parse(url);
  final videoId = uri.queryParameters['v'] ?? uri.pathSegments.last;
  return 'https://img.youtube.com/vi/$videoId/0.jpg';
}

/// Preprocesses HTML content to group consecutive figure elements into galleries
/// This function detects multiple consecutive <figure class="wp-block-image"> elements
/// and converts them into proper wp-block-gallery structures for better rendering
/// Skips elements that are already inside existing wp-block-gallery elements
String preprocessHtmlForGalleries(String htmlContent) {
  final document = parse(htmlContent);
  final body = document.body;
  if (body == null) return htmlContent;

  // Find all figure elements with wp-block-image class that are NOT inside wp-block-gallery
  final allFigureElements = body.querySelectorAll('figure.wp-block-image');
  final figureElements = allFigureElements
      .where((element) => _isNotInsideGallery(element))
      .toList();

  // Need at least 2 images to form a gallery
  if (figureElements.length < 2) return htmlContent;

  // Group consecutive figure elements into galleries
  final List<List<dom.Element>> galleryGroups = [];
  List<dom.Element> currentGroup = [];

  for (int i = 0; i < figureElements.length; i++) {
    final element = figureElements[i];

    if (currentGroup.isEmpty) {
      currentGroup.add(element);
    } else {
      // Check if this element is consecutive to the previous one
      final prevElement = currentGroup.last;
      final isConsecutive = _areConsecutiveElements(prevElement, element);

      if (isConsecutive) {
        currentGroup.add(element);
      } else {
        // Start a new group if current group has multiple elements
        if (currentGroup.length > 1) {
          galleryGroups.add(List.from(currentGroup));
        }
        currentGroup = [element];
      }
    }
  }

  // Add the last group if it has multiple elements
  if (currentGroup.length > 1) {
    galleryGroups.add(currentGroup);
  }

  // Replace each group with a wp-block-gallery element
  for (final group in galleryGroups) {
    _replaceGroupWithGallery(group);
  }

  return document.outerHtml;
}

/// Checks if two elements are consecutive in the DOM
/// Returns true if element2 is the immediate next sibling of element1
bool _areConsecutiveElements(dom.Element element1, dom.Element element2) {
  return element1.nextElementSibling == element2;
}

/// Checks if an element is NOT inside a wp-block-gallery
/// Returns true if the element is not nested within a gallery
bool _isNotInsideGallery(dom.Element element) {
  dom.Element? parent = element.parent;
  while (parent != null) {
    if (parent.localName == 'figure' &&
        parent.classes.contains('wp-block-gallery')) {
      return false;
    }
    parent = parent.parent;
  }
  return true;
}

/// Replaces a group of figure elements with a wp-block-gallery
/// Creates a proper WordPress gallery structure with all images
void _replaceGroupWithGallery(List<dom.Element> group) {
  if (group.isEmpty) return;

  final parent = group.first.parent;
  if (parent == null) return;

  // Create a new wp-block-gallery element with proper classes
  final galleryElement = dom.Element.tag('wp-block-gallery');
  galleryElement.classes
      .addAll(['wp-block-gallery', 'columns-2', 'is-cropped']);

  // Convert each figure element to a gallery item
  for (final figure in group) {
    final galleryItem = dom.Element.tag('figure');
    galleryItem.classes.add('wp-block-image');

    // Copy the img element to the gallery item
    final img = figure.querySelector('img');
    if (img != null) {
      galleryItem.append(img.clone(true));
    }

    galleryElement.append(galleryItem);
  }

  // Replace the first element with the gallery and remove the rest
  group.first.replaceWith(galleryElement);
  for (int i = 1; i < group.length; i++) {
    group[i].remove();
  }
}

/// Main HTML extension for processing WordPress content elements
/// Handles various WordPress blocks including galleries, videos, images, and tables
class AppHtmlExtension extends HtmlExtension {
  final ArticleModel article;

  AppHtmlExtension(this.article);

  @override
  Set<String> get supportedTags =>
      {'iframe', 'figure', 'img', 'wp-block-gallery', 'video', 'div', 'table'};

  @override
  InlineSpan build(ExtensionContext context) {
    return WidgetSpan(child: returnView(context));
  }

  /// Main routing method that determines how to render each HTML element
  /// Processes different WordPress block types and media elements
  Widget returnView(ExtensionContext context) {
    final element = context.element;
    if (element == null) return const SizedBox();

    // Handle WordPress video containers
    if (element.localName == 'div' && element.classes.contains('wp-video')) {
      final videoElement = element.querySelector('video');
      if (videoElement != null) {
        return buildVideoView(videoElement);
      }
    }
    // Handle figure elements (images, videos, tables, iframes, galleries)
    else if (element.localName == 'figure') {
      // Check if this is a gallery first
      if (element.classes.contains('wp-block-gallery')) {
        return buildGalleryView(element);
      }
      return _handleFigureElement(element);
    }
    // Handle standalone elements
    else if (element.localName == 'iframe') {
      return buildIframeView(element);
    } else if (element.localName == 'img') {
      return buildImageView(element);
    } else if (element.localName == 'wp-block-gallery') {
      return buildGalleryView(element);
    } else if (element.localName == 'video') {
      return buildVideoView(element);
    } else if (element.localName == 'table') {
      return buildTableView(element);
    }

    return const SizedBox();
  }

  /// Handles figure elements and determines their content type
  Widget _handleFigureElement(dom.Element element) {
    // Check for WordPress table blocks
    if (element.classes.contains('wp-block-table')) {
      final tableElement = element.querySelector('table');
      if (tableElement != null) {
        return buildTableView(tableElement);
      }
    }

    // Check for embedded iframes
    final iframeElement = element.querySelector('iframe');
    if (iframeElement != null) {
      return buildIframeView(iframeElement);
    }

    // Check for images
    final imgElement = element.querySelector('img');
    if (imgElement != null) {
      // Handle WordPress image blocks (may be part of a gallery)
      if (element.classes.contains('wp-block-image')) {
        return buildConsecutiveImageView(element);
      }
      return buildImageView(imgElement);
    }

    // Check for videos
    final videoElement = element.querySelector('video');
    if (videoElement != null) {
      return buildVideoView(videoElement);
    }

    return const SizedBox();
  }

  /// Builds iframe view for embedded content (YouTube, Facebook, etc.)
  /// Handles video embeds and social media content
  Widget buildIframeView(dom.Element element) {
    final String? srcAttribute = element.attributes['src'];
    final String videoSource =
        srcAttribute != null && srcAttribute.startsWith('data:')
            ? element.attributes['data-src'].toString()
            : srcAttribute.toString();

    // Extract dimensions for aspect ratio calculation
    final width = element.attributes['width'] ?? '1920';
    final height = element.attributes['height'] ?? '1080';
    final aspectRatio = double.parse(width) / double.parse(height);

    // Handle different iframe sources
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
      // Fallback for unknown iframe sources
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: NetworkImageWithLoader(WPConfig.noImageUrl),
      );
    }
  }

  /// Builds image view with support for both network and base64 images
  /// Uses cached network images for better performance
  Widget buildImageView(dom.Element element) {
    String? src = element.attributes['data-src'];
    src ??= element.attributes['src'];

    if (src == null || src.isEmpty) {
      return const SizedBox();
    }

    // Handle base64 encoded images
    if (src.startsWith('data:image')) {
      final base64String = src.split(',').last;
      final bytes = base64.decode(base64String);
      return Image.memory(bytes, fit: BoxFit.cover);
    }

    // Handle network images with caching and loading states
    return CachedNetworkImage(
      imageUrl: src,
      placeholder: (context, url) => const AspectRatio(
        aspectRatio: 16 / 9,
        child: Skeleton(),
      ),
    );
  }

  /// Handles individual figure elements that may be part of a consecutive image sequence
  /// After HTML preprocessing, most consecutive images are grouped into galleries
  Widget buildConsecutiveImageView(dom.Element element) {
    final imgElement = element.querySelector('img');
    if (imgElement != null) {
      return buildImageView(imgElement);
    }
    return const SizedBox();
  }

  /// Builds gallery view from wp-block-gallery elements
  /// Extracts image URLs and renders them using PostGalleryRenderer
  Widget buildGalleryView(dom.Element element) {
    List<String> imagesUrl = [];

    // Handle wp-block-gallery structure (can be either custom element or figure with wp-block-gallery class)
    if (element.localName == 'wp-block-gallery' ||
        element.classes.contains('wp-block-gallery')) {
      // Extract all figure elements within the gallery
      final figures = element.querySelectorAll('figure');

      imagesUrl = figures
          .map((figure) {
            final img = figure.querySelector('img');
            if (img != null) {
              return img.attributes['src'] ?? img.attributes['data-src'] ?? '';
            }
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    } else {
      // Fallback: handle individual figure elements
      final img = element.querySelector('img');
      if (img != null) {
        final src = img.attributes['src'] ?? img.attributes['data-src'] ?? '';
        if (src.isNotEmpty) {
          imagesUrl = [src];
        }
      }
    }

    // Only render gallery if we have images
    if (imagesUrl.isEmpty) {
      return const SizedBox();
    }

    return PostGalleryRenderer(imagesUrl: imagesUrl);
  }

  /// Builds table view with performance optimization for large tables
  /// Uses virtualization for tables with more than 50 rows
  Widget buildTableView(dom.Element element) {
    final rowCount = element.querySelectorAll('tr').length;

    // Use virtualization for large tables to improve performance
    if (rowCount > 50) {
      return VirtualizedTableView(element: element);
    }

    return OptimizedTableView(element: element);
  }

  /// Builds video view with support for various video sources and formats
  /// Handles WordPress video shortcodes and standard video elements
  Widget buildVideoView(dom.Element element) {
    // Extract video source from various possible locations
    String? src = element.attributes['src'];

    // Try to find source in child source element
    if (src == null || src.isEmpty) {
      final sourceElement = element.querySelector('source');
      if (sourceElement != null) {
        src = sourceElement.attributes['src'];
      }
    }

    // Try to find source in fallback anchor element
    if (src == null || src.isEmpty) {
      final anchorElement = element.querySelector('a');
      if (anchorElement != null) {
        src = anchorElement.attributes['href'];
      }
    }

    // Return empty widget if no source found
    if (src == null || src.isEmpty) {
      return const SizedBox();
    }

    // Calculate aspect ratio from element attributes
    double? aspectRatio;
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

    // Use default aspect ratio if calculation failed
    aspectRatio ??= 16 / 9;

    // Ensure aspectRatio is not null for the widgets
    final finalAspectRatio = aspectRatio;

    // Return video player with proper constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          width: constraints.maxWidth,
          child: AspectRatio(
            aspectRatio: finalAspectRatio,
            child: AppVideoHtmlRender(
              url: src!,
              isYoutube: false,
              aspectRatio: finalAspectRatio,
              article: article,
            ),
          ),
        );
      },
    );
  }
}

/// HTML extension for handling blockquote elements
/// Supports social media embeds (Twitter, Instagram) and WordPress quotes
class AppHtmlBlockquoteExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'blockquote'};

  @override
  InlineSpan build(ExtensionContext context) {
    return WidgetSpan(child: returnView(context));
  }

  /// Routes blockquote content based on CSS classes
  Widget returnView(ExtensionContext context) {
    if (context.classes.contains('twitter-tweet')) {
      return SocialEmbedRenderer(data: context.innerHtml, platform: 'twitter');
    } else if (context.classes.contains('instagram-media')) {
      return SocialEmbedRenderer(
          data: context.element!.outerHtml, platform: 'instagram');
    } else if (context.classes.contains('wp-block-quote')) {
      return QuoteRenderer(quote: context.innerHtml);
    } else {
      // Generic blockquote handling
      return SocialEmbedRenderer(data: context.innerHtml, platform: null);
    }
  }
}

/// HTML extension for handling code blocks
/// Provides syntax highlighting and code formatting
class AppHtmlCodeExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'code'};

  @override
  InlineSpan build(ExtensionContext context) {
    return WidgetSpan(child: returnView(context));
  }

  /// Renders code blocks with syntax highlighting
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
