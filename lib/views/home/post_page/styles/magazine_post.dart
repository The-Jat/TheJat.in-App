import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:news_pro/core/utils/extensions.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/wp_config.dart';
import '../../../../core/components/ad_widgets.dart';
import '../../../../core/components/article_category_row.dart';
import '../../../../core/components/mini_player.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/controllers/analytics/analytics_controller.dart';
import '../../../../core/models/article.dart';
import '../../../../core/utils/app_utils.dart';
import '../components/article_html_converter.dart';
import '../components/comment_button_floating.dart';
import '../components/more_related_post.dart';
import '../components/post_image_renderer.dart';
import '../components/post_meta_data.dart';
import '../components/post_sidebar.dart';
import '../components/post_tags.dart';
import '../components/save_post_button.dart';
import '../components/total_comments_button.dart';
import '../components/offline_save_button.dart';

class MagazinePost extends StatelessWidget {
  const MagazinePost({
    super.key,
    required this.article,
  });
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Magazine-style header with overlay
                  _MagazineHeader(article: article),

                  // Content with magazine typography
                  Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppDefaults.padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with magazine-style typography
                              Text(
                                AppUtils.trimHtml(article.title),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                    ),
                              ),
                              AppSizedBox.h16,

                              // Byline with magazine-style formatting
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withOpacityValue(0.1),
                                  borderRadius: AppDefaults.borderRadius,
                                ),
                                child: PostMetaData(article: article),
                              ),
                              AppSizedBox.h16,

                              ArticleCategoryRow(
                                article: article,
                                isPostDetailPage: true,
                                useEnhancedStyling: true,
                              ),
                              AppSizedBox.h24,
                            ],
                          ),
                        ),

                        // Article content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDefaults.padding,
                          ),
                          child: ArticleHtmlConverter(article: article),
                        ),

                        AppSizedBox.h24,

                        // Tags in magazine style
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDefaults.padding,
                          ),
                          child: ArticleTags(article: article),
                        ),

                        AppSizedBox.h24,
                        const Divider(height: 0),
                        AppSizedBox.h16,

                        TotalCommentsButton(article: article),
                        AppSizedBox.h16,
                      ],
                    ),
                  ),

                  const NativeAdWidget(),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: MoreRelatedPost(
                      categoryID: article.categories.isNotEmpty
                          ? article.categories.first
                          : 0,
                      currentArticleID: article.id,
                    ),
                  ),
                  const BannerAdWidget(),
                  Padding(
                    padding: const EdgeInsets.all(AppDefaults.padding),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('go_back'.tr()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _MagazineAppBar(article: article),
          CommentButtonFloating(article: article),
          PostSidebar(
            link: article.link,
            title: article.title,
          ),
          MiniPlayer(
            isOnStack: true,
            articleModel: article,
          ),
        ],
      ),
    );
  }
}

class _MagazineHeader extends StatelessWidget {
  const _MagazineHeader({required this.article});
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PostImageRenderer(article: article),

          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacityValue(0.7),
                ],
              ),
            ),
          ),

          // Magazine-style badge
          Positioned(
            top: 100,
            left: AppDefaults.padding,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'FEATURED'.tr().toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MagazineAppBar extends StatelessWidget {
  _MagazineAppBar({
    required this.article,
  });

  final ArticleModel article;
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Colors.black54,
              elevation: 0,
              padding: const EdgeInsets.all(8),
            ),
            onPressed: () => Navigator.pop(context),
            child: Icon(
              Icons.adaptive.arrow_back_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        actions: [
          ElevatedButton(
            key: _shareButtonKey,
            onPressed: () async {
              final RenderBox button = _shareButtonKey.currentContext!
                  .findRenderObject() as RenderBox;
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final Offset position =
                  button.localToGlobal(Offset.zero, ancestor: overlay);
              final Size size = button.size;

              await SharePlus.instance.share(ShareParams(
                text:
                    'Check out this article on ${WPConfig.appName}:\n${article.title}\n${article.link}',
                sharePositionOrigin: Rect.fromLTWH(position.dx,
                    position.dy + size.height, size.width, size.height),
              ));
              AnalyticsController.logUserContentShare(article);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Colors.black54,
              elevation: 0,
              padding: const EdgeInsets.all(8),
            ),
            child: const Icon(
              IconlyLight.send,
              color: Colors.white,
              size: 18,
            ),
          ),
          SavePostButton(article: article),
          OfflineSaveButton(
            article: article,
            useMinimalStyle: true,
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}
