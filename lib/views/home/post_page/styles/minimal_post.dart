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

class MinimalPost extends StatelessWidget {
  const MinimalPost({
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
                  AppSizedBox.h100, // Space for transparent app bar

                  // Minimal content container
                  Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clean image presentation
                        if (article.featuredImage != null ||
                            article.extraImages.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 40),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: PostImageRenderer(article: article),
                            ),
                          ),

                        // Minimal title
                        Text(
                          AppUtils.trimHtml(article.title),
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.8,
                                height: 1.3,
                              ),
                        ),
                        AppSizedBox.h32,

                        // Subtle metadata
                        Container(
                          padding: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacityValue(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: PostMetaData(
                                    article: article, useMultiLine: true),
                              ),
                              // Minimal action buttons
                              _MinimalActionButtons(article: article),
                            ],
                          ),
                        ),
                        AppSizedBox.h32,

                        // Categories in minimal style
                        ArticleCategoryRow(
                          article: article,
                          isPostDetailPage: true,
                        ),
                        AppSizedBox.h40,

                        // Clean content
                        ArticleHtmlConverter(article: article),
                        AppSizedBox.h40,

                        // Minimal tags
                        if (article.tags.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey.withOpacityValue(0.2),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: Colors.grey.withOpacityValue(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ArticleTags(article: article),
                          ),
                          AppSizedBox.h40,
                        ],

                        // Comments button
                        Center(
                          child: TotalCommentsButton(article: article),
                        ),
                        AppSizedBox.h60,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacityValue(0.1),
                          foregroundColor:
                              Theme.of(context).textTheme.bodyMedium?.color,
                          elevation: 0,
                        ),
                        child: Text('go_back'.tr()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _MinimalAppBar(article: article),
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

class _MinimalActionButtons extends StatelessWidget {
  const _MinimalActionButtons({required this.article});
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () async {
            await SharePlus.instance.share(ShareParams(
              text:
                  'Check out this article on ${WPConfig.appName}:\n${article.title}\n${article.link}',
            ));
            AnalyticsController.logUserContentShare(article);
          },
          icon: Icon(
            IconlyLight.send,
            size: 20,
            color: Colors.grey.withOpacityValue(0.8),
          ),
        ),
        SavePostButton(
          article: article,
          useMinimalStyle: true,
        ),
        OfflineSaveButton(
          article: article,
          useMinimalStyle: true,
          iconSize: 20,
        ),
      ],
    );
  }
}

class _MinimalAppBar extends StatelessWidget {
  const _MinimalAppBar({
    required this.article,
  });

  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacityValue(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.adaptive.arrow_back_rounded,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: 18,
              ),
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
        ),
      ),
    );
  }
}
