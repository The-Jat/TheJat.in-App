import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_defaults.dart';
import '../../../core/constants/constants.dart';
import '../../../core/repositories/posts/offline_post_repository.dart';
import '../../offline/offline_posts_page.dart';

class OfflineSettings extends ConsumerWidget {
  const OfflineSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineRepo = ref.read(offlinePostRepoProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Row(
              children: [
                Icon(
                  IconlyLight.bookmark,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: AppDefaults.padding),
                Text(
                  'offline_reading'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          // Saved Posts
          ListTile(
            leading: const Icon(IconlyLight.document),
            title: Text('saved_posts'.tr()),
            subtitle: FutureBuilder<int>(
              future: offlineRepo.getSavedPostsCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Text('$count ${'posts_saved_for_offline'.tr()}');
              },
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OfflinePostsPage(),
                ),
              );
              // Refresh the providers when returning from offline posts page
              ref.invalidate(offlinePostRepoProvider);
            },
          ),

          // Clear All Offline Posts
          const Divider(height: 1),
          ListTile(
            leading: const Icon(IconlyLight.delete),
            title: Text('clear_all_offline_posts'.tr()),
            subtitle: Text('remove_all_saved_posts'.tr()),
            onTap: () => _showClearAllDialog(context, ref),
          ),

          // Storage Information
          const Divider(height: 1),
          FutureBuilder<Map<String, dynamic>>(
            future: offlineRepo.getStorageInfo(),
            builder: (context, snapshot) {
              final storageInfo = snapshot.data ?? {};
              final totalSizeMB = storageInfo['totalSizeMB'] ?? '0.00';

              return ListTile(
                leading: const Icon(IconlyLight.chart),
                title: Text('storage_information'.tr()),
                subtitle:
                    Text('using_storage'.tr(namedArgs: {'size': totalSizeMB})),
                trailing: const Icon(Icons.info_outline),
                onTap: () => _showStorageInfoDialog(context, storageInfo),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
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
              final success = await offlineRepo.clearAllPosts();

              if (success) {
                // Refresh providers after clearing
                ref.invalidate(offlinePostRepoProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('offline_posts_cleared'.tr()),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('failed_clear_offline_posts'.tr()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('clear_all_offline_posts'.tr()),
          ),
        ],
      ),
    );
  }

  void _showStorageInfoDialog(
      BuildContext context, Map<String, dynamic> storageInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('storage_information'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                'total_posts'.tr(), '${storageInfo['postCount'] ?? 0}'),
            _buildInfoRow('storage_used'.tr(),
                '${storageInfo['totalSizeMB'] ?? '0.00'} MB'),
            _buildInfoRow('storage_used_kb'.tr(),
                '${storageInfo['totalSizeKB'] ?? '0.00'} KB'),
            if (storageInfo['lastUpdated'] != null)
              _buildInfoRow(
                'last_updated'.tr(),
                _formatDate(storageInfo['lastUpdated']),
              ),
          ],
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
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
