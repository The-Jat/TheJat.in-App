import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/core/utils/app_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/constants.dart';
import '../../core/models/article.dart';
import '../../core/repositories/posts/offline_post_repository.dart';
import '../home/post_page/post_page.dart';
import '../home/post_page/components/offline_save_button.dart';

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

class OfflinePostsPage extends ConsumerStatefulWidget {
  const OfflinePostsPage({super.key});

  @override
  ConsumerState<OfflinePostsPage> createState() => _OfflinePostsPageState();
}

class _OfflinePostsPageState extends ConsumerState<OfflinePostsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize providers when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(offlinePostsProvider);
      ref.invalidate(offlinePostsMetadataProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final offlinePostsAsync = ref.watch(offlinePostsProvider);
    final metadataAsync = ref.watch(offlinePostsMetadataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('offline_reading'.tr()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(offlinePostsProvider);
              ref.invalidate(offlinePostsMetadataProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showStorageInfo(context),
          ),
        ],
      ),
      body: offlinePostsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _buildHeader(context, posts.length, metadataAsync),
              Expanded(
                child: _buildPostsList(context, posts),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.offline_bolt,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppDefaults.margin),
            Text(
              'no_offline_posts'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: AppDefaults.padding),
            Text(
              'save_posts_while_online'.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int postCount,
      AsyncValue<Map<String, dynamic>> metadataAsync) {
    return Container(
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.offline_bolt,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: AppDefaults.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$postCount ${'saved_posts'.tr()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                metadataAsync.when(
                  data: (metadata) => Text(
                    'using_storage'
                        .tr(namedArgs: {'size': metadata['totalSizeMB']}),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearAllDialog(context),
            tooltip: 'clear_all_offline_posts'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, List<ArticleModel> posts) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDefaults.padding),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(context, ref, post);
      },
    );
  }

  Widget _buildPostCard(
      BuildContext context, WidgetRef ref, ArticleModel post) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDefaults.padding),
      child: InkWell(
        onTap: () => _navigateToPost(context, post),
        borderRadius: BorderRadius.circular(AppDefaults.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDefaults.radius),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: post.featuredImage != null
                      ? NetworkImageWithLoader(
                          post.featuredImage!,
                          fit: BoxFit.cover,
                          cacheHeight: 160,
                          cacheWidth: 160,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.article,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppDefaults.padding),
              // Post content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppUtils.trimHtml(post.title),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(post.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.views,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 18,
                          onPressed: () => _removePost(context, post),
                          tooltip: 'Remove from offline',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: AppDefaults.margin),
            Text(
              'error_fetching_data'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red[600],
                  ),
            ),
            const SizedBox(height: AppDefaults.padding),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDefaults.margin),
            ElevatedButton(
              onPressed: () => ref.invalidate(offlinePostsProvider),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPost(BuildContext context, ArticleModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostPage(article: post),
      ),
    );
  }

  void _removePost(BuildContext context, ArticleModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete'.tr()),
        content: Text('${'remove_from_offline'.tr()}: "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final offlineRepo = ref.read(offlinePostRepoProvider);
              await offlineRepo.removePost(post.id);
              ref.invalidate(offlinePostsProvider);
              ref.invalidate(offlinePostsMetadataProvider);
              ref.invalidate(offlinePostStatusProvider(post.id));
            },
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('clear_all_offline_posts'.tr()),
        content: Text('remove_all_saved_posts'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final offlineRepo = ref.read(offlinePostRepoProvider);
              // Get the list of posts before clearing to invalidate their status providers
              final posts = await offlineRepo.getSavedPosts();
              await offlineRepo.clearAllPosts();
              ref.invalidate(offlinePostsProvider);
              ref.invalidate(offlinePostsMetadataProvider);
              // Invalidate all post status providers
              for (final post in posts) {
                ref.invalidate(offlinePostStatusProvider(post.id));
              }
            },
            child: Text('clear_all_offline_posts'.tr()),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo(BuildContext context) {
    final metadataAsync = ref.read(offlinePostsMetadataProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('storage_information'.tr()),
        content: metadataAsync.when(
          data: (metadata) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('total_posts'.tr(), '${metadata['postCount']}'),
              _buildInfoRow(
                  'storage_used'.tr(), '${metadata['totalSizeMB']} MB'),
              _buildInfoRow(
                  'storage_used_kb'.tr(), '${metadata['totalSizeKB']} KB'),
              if (metadata['lastUpdated'] != null)
                _buildInfoRow(
                    'last_updated'.tr(),
                    timeago.format(DateTime.fromMillisecondsSinceEpoch(
                        metadata['lastUpdated']))),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => Text('error_fetching_data'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('done'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
