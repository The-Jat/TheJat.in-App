import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:news_pro/config/wp_config.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/controllers/analytics/analytics_controller.dart';
import '../../../../core/models/article.dart';

class ShareButtonAlternative extends StatelessWidget {
  ShareButtonAlternative({
    super.key,
    required this.article,
  });

  final ArticleModel article;
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: _shareButtonKey,
      onPressed: () async {
        final RenderBox button =
            _shareButtonKey.currentContext!.findRenderObject() as RenderBox;
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final Offset position =
            button.localToGlobal(Offset.zero, ancestor: overlay);
        final Size size = button.size;

        await SharePlus.instance.share(ShareParams(
          text:
              'Check out this article on ${WPConfig.appName}:\n${article.title}\n${article.link}',
          sharePositionOrigin: Rect.fromLTWH(
              position.dx, position.dy + size.height, size.width, size.height),
        ));
        AnalyticsController.logUserContentShare(article);
      },
      icon: const Icon(
        IconlyLight.send,
        size: 18,
      ),
      label: Text(
        'share'.tr(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        foregroundColor: AppColors.placeholder,
        side: const BorderSide(color: AppColors.placeholder),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        elevation: 0,
      ),
    );
  }
}
