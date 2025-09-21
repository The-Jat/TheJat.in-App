import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:news_pro/core/components/ad_widgets.dart';
import 'package:news_pro/core/utils/extensions.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/wp_config.dart';
import '../../../../core/ads/ad_state_provider.dart';
import '../../../../core/components/article_category_row.dart';
import '../../../../core/components/mini_player.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/controllers/analytics/analytics_controller.dart';
import '../../../../core/controllers/auth/auth_controller.dart';
import '../../../../core/controllers/auth/auth_state.dart';
import '../../../../core/controllers/posts/saved_posts_controller.dart';
import '../../../../core/models/article.dart';
import '../../../../core/repositories/posts/offline_post_repository.dart';
import '../../../../core/utils/app_utils.dart';
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

class CardPost extends StatelessWidget {
  const CardPost({
    super.key,
    required this.article,
  });
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.grey.shade100,
      body: Stack(
        children: [
          Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppSizedBox.h100, // Space for app bar

                  // Content cards
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Image card
                        if (article.featuredImage != null ||
                            article.extraImages.isNotEmpty)
                          Card(
                            elevation: 4,
                            shadowColor:
                                isDark ? Colors.black54 : Colors.black26,
                            color: Theme.of(context).cardColor,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PostImageRenderer(article: article),
                            ),
                          ),
                        AppSizedBox.h16,

                        // Title and meta card
                        Card(
                          elevation: 4,
                          shadowColor: isDark ? Colors.black54 : Colors.black26,
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppUtils.trimHtml(article.title),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                      ),
                                ),
                                AppSizedBox.h16,
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withOpacityValue(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withOpacityValue(0.2),
                                    ),
                                  ),
                                  child: PostMetaData(article: article),
                                ),
                                AppSizedBox.h16,
                                ArticleCategoryRow(
                                  article: article,
                                  isPostDetailPage: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSizedBox.h16,

                        // Content card
                        Card(
                          elevation: 4,
                          shadowColor: isDark ? Colors.black54 : Colors.black26,
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: ArticleHtmlConverter(article: article),
                          ),
                        ),
                        AppSizedBox.h16,

                        // Tags card
                        if (article.tags.isNotEmpty)
                          Card(
                            elevation: 4,
                            shadowColor:
                                isDark ? Colors.black54 : Colors.black26,
                            color: Theme.of(context).cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tags',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  AppSizedBox.h12,
                                  ArticleTags(article: article),
                                ],
                              ),
                            ),
                          ),
                        AppSizedBox.h16,

                        // Action card
                        Card(
                          elevation: 4,
                          shadowColor: isDark ? Colors.black54 : Colors.black26,
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                TotalCommentsButton(article: article),
                                AppSizedBox.h16,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _CardActionButton(
                                      icon: IconlyLight.send,
                                      label: 'Share',
                                      onTap: () async {
                                        await SharePlus.instance
                                            .share(ShareParams(
                                          text:
                                              'Check out this article on ${WPConfig.appName}:\n${article.title}\n${article.link}',
                                        ));
                                        AnalyticsController.logUserContentShare(
                                            article);
                                      },
                                    ),
                                    _CardSaveButton(article: article),
                                    _CardOfflineSaveButton(article: article),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const NativeAdWidget(),
                  Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    shadowColor: isDark ? Colors.black54 : Colors.black26,
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
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('go_back'.tr()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CardAppBar(article: article),
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

class _CardSaveButton extends ConsumerWidget {
  const _CardSaveButton({required this.article});
  final ArticleModel article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedPostsController);
    final isSaved = saved.postIds.contains(article.id);
    final isSaving = saved.isSavingPost;
    final controller = ref.read(savedPostsController.notifier);
    final auth = ref.watch(authController);

    return _CardActionButton(
      icon: isSaving
          ? Icons.favorite
          : (isSaved ? IconlyBold.heart : IconlyLight.heart),
      label: isSaving ? 'Saving...' : (isSaved ? 'Saved' : 'Save'),
      isActive: isSaved || isSaving,
      onTap: isSaving
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
    );
  }
}

class _CardOfflineSaveButton extends ConsumerWidget {
  const _CardOfflineSaveButton({required this.article});
  final ArticleModel article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineRepo = ref.read(offlinePostRepoProvider);
    final offlineStatusAsync = ref.watch(offlinePostStatusProvider(article.id));

    return offlineStatusAsync.when(
      data: (isOfflineSaved) {
        void onTap() async {
          if (isOfflineSaved) {
            await offlineRepo.removePost(article.id);
            Fluttertoast.showToast(msg: 'removed_from_offline'.tr());
          } else {
            await offlineRepo.savePost(article);
            Fluttertoast.showToast(msg: 'saved_for_offline_reading'.tr());
          }
          // Invalidate the provider to refresh the UI
          ref.invalidate(offlinePostStatusProvider(article.id));
        }

        return _CardActionButton(
          icon: isOfflineSaved ? IconlyBold.download : IconlyLight.download,
          label: isOfflineSaved ? 'Offline' : 'Save Offline',
          isActive: isOfflineSaved,
          onTap: onTap,
        );
      },
      loading: () => _CardActionButton(
        icon: IconlyLight.download,
        label: 'Loading...',
        isActive: false,
        onTap: null,
      ),
      error: (error, stack) => _CardActionButton(
        icon: IconlyLight.download,
        label: 'Error',
        isActive: false,
        onTap: () => ref.invalidate(offlinePostStatusProvider(article.id)),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.7),
              size: 24,
            ),
            AppSizedBox.h4,
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.7),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAppBar extends StatelessWidget {
  _CardAppBar({
    required this.article,
  });

  final ArticleModel article;
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 100,
      child: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 2,
        shadowColor: isDark ? Colors.black54 : Colors.black26,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacityValue(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.adaptive.arrow_back_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
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
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacityValue(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  IconlyLight.send,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
