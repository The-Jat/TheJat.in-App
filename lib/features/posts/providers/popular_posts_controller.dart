import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/article_model.dart';
import '../data/repository/post_repository.dart';
import '../../config/providers/config_providers.dart';

/// Provides Popular Posts
final popularPostsController = FutureProvider<List<ArticleModel>>((ref) async {
  final repo = ref.read(postRepoProvider);
  final featuredPostIds = ref.read(configProvider).value?.featuredPosts ?? [];

  if (featuredPostIds.isEmpty) {
    /// If popular post plugin is enabled and no custom feature category is provided
    List<ArticleModel> allPosts = await repo.getPopularPosts();
    if (allPosts.isEmpty) {
      allPosts = await repo.getAllPost(pageNumber: 1);
    }
    final updatedList =
        allPosts.map((e) => e.copyWith(heroTag: '${e.link}popular')).toList();

    return updatedList;
  } else {
    List<ArticleModel> allPosts =
        await repo.getThesePosts(ids: featuredPostIds);

    final updatedList =
        allPosts.map((e) => e.copyWith(heroTag: '${e.link}popular')).toList();

    return updatedList;
  }
});

final isTrendingProvider = Provider.family<bool, ArticleModel>((ref, article) {
  final posts = ref.watch(popularPostsController).value ?? [];
  final found = posts.map((e) => e.id).toList();
  return found.contains(article.id);
});
