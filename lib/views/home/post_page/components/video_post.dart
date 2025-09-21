import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../../../../core/components/ad_widgets.dart';
import '../../../../core/components/app_video.dart';
import '../../../../core/components/mini_player.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/models/article.dart';
import '../components/more_related_post.dart';
import '../components/post_image_renderer.dart';
import '../components/post_page_body.dart';
import 'comment_button_floating.dart';

class VideoPost extends StatelessWidget {
  const VideoPost({
    super.key,
    required this.article,
  });
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ArticleModel.isVideoArticle(article)
                        ? CustomVideoRenderer(article: article)
                        : PostImageRenderer(article: article),
                    AppSizedBox.h10,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16),
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          label: Text('go_back'.tr()),
                          icon: Icon(
                            IconlyLight.arrowLeft,
                            color: AppColors.primary,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    PostPageBody(article: article),
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
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
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
            CommentButtonFloating(article: article),
            MiniPlayer(
              isOnStack: true,
              articleModel: article,
            ),
          ],
        ),
      ),
    );
  }
}

/// Used for rendering vidoe on top
class CustomVideoRenderer extends StatelessWidget {
  const CustomVideoRenderer({
    super.key,
    required this.article,
  });

  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    bool isNormalVideo = article.featuredVideo != null;
    bool isYoutubeVideo = article.featuredYoutubeVideoUrl != null;
    String? thumbnail;
    String getYouTubeThumbnail(String url) {
      final Uri uri = Uri.parse(url);
      final videoId = uri.queryParameters['v'] ?? uri.pathSegments.last;
      return 'https://img.youtube.com/vi/$videoId/0.jpg';
    }

    if (isYoutubeVideo) {
      thumbnail = getYouTubeThumbnail(article.featuredYoutubeVideoUrl ?? '');
      return AppVideoHtmlRender(
        url: article.featuredYoutubeVideoUrl ?? '',
        isYoutube: true,
        aspectRatio: 16 / 9,
        isVideoPage: true,
        thumbnail: thumbnail,
        article: article,
      );
    } else if (isNormalVideo) {
      return AppVideoHtmlRender(
        url: article.featuredVideo ?? '',
        isYoutube: false,
        aspectRatio: 16 / 9,
        isVideoPage: true,
        thumbnail: article.featuredYoutubeVideoUrl,
        article: article,
      );
    } else {
      return const Text('No video found');
    }
  }
}
