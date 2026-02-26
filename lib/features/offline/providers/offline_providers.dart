import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../posts/data/models/article_model.dart';
import '../data/repository/offline_post_repository.dart';

/// Provider for offline posts
final offlinePostsProvider = FutureProvider<List<ArticleModel>>((ref) async {
  final offlineRepo = ref.read(offlinePostRepoProvider);
  return await offlineRepo.getSavedPosts();
});

/// Provider for offline posts metadata
final offlinePostsMetadataProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final offlineRepo = ref.read(offlinePostRepoProvider);
  return await offlineRepo.getStorageInfo();
});

final offlineSavedPostsCountProvider = FutureProvider<int>((ref) async {
  final offlineRepo = ref.read(offlinePostRepoProvider);
  return await offlineRepo.getSavedPostsCount();
});
