import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_all/flutter_html_all.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/controllers/html/font_size_controller.dart';
import '../../../../core/controllers/html/html_extensions.dart';
import '../../../../core/models/article.dart';
import '../../../../core/utils/app_utils.dart';

class ArticleHtmlConverter extends HookConsumerWidget {
  const ArticleHtmlConverter({
    super.key,
    required this.article,
  });

  final ArticleModel article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeNotifier = ref.watch(fontSizeProvider.notifier);
    final fontSize = ref.watch(fontSizeProvider);
    final previousFontSize = useRef(fontSize);

    void handleScaleUpdate(ScaleUpdateDetails details) {
      final newFontSize =
          (previousFontSize.value * details.scale).clamp(9.0, 45.0);
      fontSizeNotifier.setFontSize(newFontSize);
    }

    return GestureDetector(
      onScaleStart: (_) => previousFontSize.value = fontSize,
      onScaleUpdate: handleScaleUpdate,
      child: SelectionArea(
        child: Html(
          data: article.content,
          shrinkWrap: false,
          style: {
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              fontSize: FontSize(fontSize),
              lineHeight: const LineHeight(1.4),
            ),
            'figure': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            'table': Style(
              backgroundColor: Theme.of(context).cardColor,
            ),
            'tr': Style(
              border: const Border(bottom: BorderSide(color: Colors.grey)),
            ),
            'th': Style(
              padding: HtmlPaddings.all(6),
              backgroundColor: Colors.grey,
            ),
            'td': Style(
              padding: HtmlPaddings.all(6),
              alignment: Alignment.topLeft,
            ),
            'blockquote': Style(
              margin: Margins.only(left: 16),
            ),
          },
          extensions: [
            const TableHtmlExtension(),
            const SvgHtmlExtension(),
            const AudioHtmlExtension(),
            AppHtmlExtension(article),
            AppHtmlBlockquoteExtension(),
            AppHtmlCodeExtension(),
          ],
          onLinkTap: (url, renderCtx, _) {
            if (url == null) {
              Fluttertoast.showToast(msg: 'No url found');
            } else {
              AppUtils.handleUrl(url);
            }
          },
        ),
      ),
    );
  }
}
