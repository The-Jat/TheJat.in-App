import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/wp_config.dart';
import '../../../../core/ads/ad_state_provider.dart';
import '../../../../core/components/ad_widgets.dart';
import '../../../../core/components/article_category_row.dart';
import '../../../../core/components/mini_player.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/controllers/analytics/analytics_controller.dart';
import '../../../../core/controllers/auth/auth_controller.dart';
import '../../../../core/controllers/auth/auth_state.dart';
import '../../../../core/controllers/posts/saved_posts_controller.dart';
import '../../../../core/models/article.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/extensions.dart';
import '../components/article_html_converter.dart';
import '../components/comment_button_floating.dart';
import '../components/more_related_post.dart';
import '../components/post_image_renderer.dart';
import '../components/post_meta_data.dart';
import '../components/post_sidebar.dart';
import '../components/post_tags.dart';
// import '../components/save_post_button.dart'; // No longer needed
import '../components/total_comments_button.dart';
import '../components/offline_save_button.dart';

class StoryPost extends StatelessWidget {
  const StoryPost({
    super.key,
    required this.article,
  });
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Immersive full-screen story
          Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Full-screen hero image
                  _StoryHeroSection(article: article),

                  // Story content with theme-aware styling
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                AppColors.scaffoldBackgrounDark,
                                AppColors.cardColorDark,
                              ]
                            : [
                                Colors.white,
                                Colors.grey.shade50,
                              ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Story content
                        Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Story-style title
                              Text(
                                AppUtils.trimHtml(article.title),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: -1.0,
                                      height: 1.2,
                                    ),
                              ),
                              AppSizedBox.h32,

                              // Story metadata with elegant styling
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: AppColors.primary,
                                      width: 3,
                                    ),
                                  ),
                                  color: isDark
                                      ? Colors.transparent
                                      : Colors.grey.withValues(alpha: 0.05),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        textTheme:
                                            Theme.of(context).textTheme.apply(
                                                  bodyColor: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  displayColor: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                      ),
                                      child: PostMetaData(article: article),
                                    ),
                                    AppSizedBox.h8,
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        textTheme:
                                            Theme.of(context).textTheme.apply(
                                                  bodyColor: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  displayColor: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                      ),
                                      child: ArticleCategoryRow(
                                        article: article,
                                        isPostDetailPage: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSizedBox.h40,

                              // Story content with better reading typography
                              Theme(
                                data: Theme.of(context).copyWith(
                                  textTheme: Theme.of(context)
                                      .textTheme
                                      .apply(
                                        bodyColor: isDark
                                            ? Colors.white.withOpacityValue(0.9)
                                            : Colors.black87,
                                        displayColor: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      )
                                      .copyWith(
                                        bodyMedium: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 18,
                                              height: 1.8,
                                              letterSpacing: 0.3,
                                              color: isDark
                                                  ? Colors.white
                                                      .withOpacityValue(0.9)
                                                  : Colors.black87,
                                            ),
                                        bodyLarge: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontSize: 20,
                                              height: 1.8,
                                              letterSpacing: 0.3,
                                              color: isDark
                                                  ? Colors.white
                                                      .withOpacityValue(0.9)
                                                  : Colors.black87,
                                            ),
                                      ),
                                ),
                                child: ArticleHtmlConverter(article: article),
                              ),
                              AppSizedBox.h40,

                              // Story tags with elegant styling
                              if (article.tags.isNotEmpty) ...[
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: isDark
                                            ? Colors.white.withOpacityValue(0.2)
                                            : Colors.grey
                                                .withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      textTheme:
                                          Theme.of(context).textTheme.apply(
                                                bodyColor: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                                displayColor: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                    ),
                                    child: ArticleTags(article: article),
                                  ),
                                ),
                                AppSizedBox.h40,
                              ],

                              // Comments in story style
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withOpacityValue(0.3)
                                          : Colors.grey.withValues(alpha: 0.4),
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      textTheme:
                                          Theme.of(context).textTheme.apply(
                                                bodyColor: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                                displayColor: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                    ),
                                    child:
                                        TotalCommentsButton(article: article),
                                  ),
                                ),
                              ),
                              AppSizedBox.h60,
                            ],
                          ),
                        ),

                        // Story actions
                        _StoryActions(article: article),
                        AppSizedBox.h40,
                      ],
                    ),
                  ),

                  // Related stories
                  Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: [
                        const NativeAdWidget(),
                        MoreRelatedPost(
                          categoryID: article.categories.isNotEmpty
                              ? article.categories.first
                              : 0,
                          currentArticleID: article.id,
                        ),
                        const BannerAdWidget(),
                        Padding(
                          padding: const EdgeInsets.all(AppDefaults.padding),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white.withOpacityValue(0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                foregroundColor:
                                    isDark ? Colors.white : Colors.black87,
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white.withOpacityValue(0.3)
                                      : Colors.grey.withValues(alpha: 0.4),
                                ),
                                elevation: 0,
                              ),
                              child: Text('go_back'.tr()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _StoryAppBar(article: article),
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

class _StoryHeroSection extends StatelessWidget {
  const _StoryHeroSection({required this.article});
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen background image
          if (article.featuredImage != null || article.extraImages.isNotEmpty)
            PostImageRenderer(article: article)
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColors.primary.withOpacityValue(0.8),
                          Theme.of(context).scaffoldBackgroundColor,
                        ]
                      : [
                          AppColors.primary.withOpacityValue(0.1),
                          Colors.white,
                        ],
                ),
              ),
            ),

          // Overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.transparent,
                        Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacityValue(0.8),
                        Theme.of(context).scaffoldBackgroundColor,
                      ]
                    : [
                        Colors.transparent,
                        Colors.white.withOpacityValue(0.8),
                        Colors.white,
                      ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          // Scroll indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark
                      ? Colors.white.withOpacityValue(0.8)
                      : Colors.black54,
                  size: 32,
                ),
                AppSizedBox.h8,
                Text(
                  'Scroll to read',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withOpacityValue(0.8)
                            : Colors.black54,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryActions extends ConsumerWidget {
  const _StoryActions({required this.article});
  final ArticleModel article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StoryActionButton(
            icon: IconlyLight.send,
            label: 'Share Story',
            isDark: isDark,
            onTap: () async {
              await SharePlus.instance.share(ShareParams(
                text:
                    'Check out this story on ${WPConfig.appName}:\n${article.title}\n${article.link}',
              ));
              AnalyticsController.logUserContentShare(article);
            },
          ),
          AppSizedBox.w32,
          OfflineSaveButton(
            article: article,
            useMinimalStyle: true,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

class _StoryActionButton extends StatelessWidget {
  const _StoryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacityValue(0.3)
                : Colors.grey.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white : Colors.black87,
              size: 18,
            ),
            AppSizedBox.w8,
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryAppBar extends StatelessWidget {
  const _StoryAppBar({
    required this.article,
  });

  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                color: isDark
                    ? Colors.black.withOpacityValue(0.5)
                    : Colors.white.withOpacityValue(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.adaptive.arrow_back_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 18,
              ),
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _StorySaveButton(article: article, isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class _StorySaveButton extends ConsumerWidget {
  const _StorySaveButton({
    required this.article,
    required this.isDark,
  });

  final ArticleModel article;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedPostsController);
    final isSaved = saved.postIds.contains(article.id);
    final isSaving = saved.isSavingPost;
    final controller = ref.read(savedPostsController.notifier);
    final auth = ref.watch(authController);

    return IconButton(
      onPressed: isSaving
          ? null
          : () async {
              if (auth is AuthLoggedIn) {
                ref.read(loadInterstitalAd(context))?.call();
                if (isSaved) {
                  await controller.removePostFromSaved(article.id);
                  Fluttertoast.showToast(msg: 'article_removed_message'.tr());
                } else {
                  await controller.addPostToSaved(article);
                  Fluttertoast.showToast(msg: 'article_saved_message'.tr());
                }
              } else {
                Fluttertoast.showToast(msg: 'login_is_needed'.tr());
              }
            },
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (isSaved || isSaving)
              ? AppColors.primary.withValues(alpha: isDark ? 0.8 : 0.9)
              : isDark
                  ? Colors.black.withOpacityValue(0.5)
                  : Colors.white.withOpacityValue(0.8),
          shape: BoxShape.circle,
        ),
        child: isSaving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : Icon(
                isSaved ? IconlyBold.heart : IconlyLight.heart,
                color: isSaved
                    ? Colors.white
                    : isDark
                        ? Colors.white
                        : Colors.black87,
                size: 18,
              ),
      ),
    );
  }
}
