import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/ads/ad_state_provider.dart';
import '../../../core/controllers/analytics/analytics_controller.dart';
import '../../../core/controllers/ui/post_style_controller.dart';
import '../../../core/models/article.dart';
import '../../../core/repositories/others/post_style_local.dart';
import '../../../core/repositories/posts/post_repository.dart';
import 'components/video_post.dart';
import 'styles/card_post.dart';
import 'styles/classic_post.dart';
import 'styles/magazine_post.dart';
import 'styles/minimal_post.dart';
import 'styles/story_post.dart';

class PostPage extends HookConsumerWidget {
  const PostPage({
    super.key,
    required this.article,
  });
  final ArticleModel article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(loadInterstitalAd(context))?.call();
    final isVideoPost = ArticleModel.isVideoArticle(article);
    final selectedStyle = ref.watch(postStyleControllerProvider);
    
    AnalyticsController.logPostView(article);
    PostRepository.addViewsToPost(postID: article.id);
    
    if (isVideoPost) {
      return VideoPost(article: article);
    } else {
      return _buildPostWithStyle(selectedStyle);
    }
  }
  
  Widget _buildPostWithStyle(PostDetailStyle style) {
    switch (style) {
      case PostDetailStyle.classic:
        return ClassicPost(article: article);
      case PostDetailStyle.magazine:
        return MagazinePost(article: article);
      case PostDetailStyle.minimal:
        return MinimalPost(article: article);
      case PostDetailStyle.card:
        return CardPost(article: article);
      case PostDetailStyle.story:
        return StoryPost(article: article);
    }
  }
}
