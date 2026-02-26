import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/features/offline/providers/offline_providers.dart';
import 'package:news_pro/features/settings/views/components/setting_list_tile.dart';

import '../../../../core/constants/app_defaults.dart';
import '../../../../core/constants/constants.dart';
import '../../../offline/data/repository/offline_post_repository.dart';
import '../../../offline/views/offline_posts_page.dart';

class OfflineSettings extends ConsumerWidget {
  const OfflineSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedPostsCount = ref.watch(offlineSavedPostsCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDefaults.margin),
          child: Text(
            'offline_reading'.tr(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              // Saved Posts
              SettingTile(
                icon: IconlyLight.document,
                iconColor: Colors.green,
                label: 'saved_posts',
                subtitle: savedPostsCount.when(
                  data: (data) => data.toString(),
                  error: (error, stackTrace) => 'Error',
                  loading: () => 'Loading...',
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

              SettingTile(
                icon: IconlyLight.delete,
                iconColor: Colors.red,
                label: 'clear_all_offline_posts',
                subtitle: 'remove_all_saved_posts'.tr(),
                onTap: () => _showClearAllDialog(context, ref),
              ),

              FutureBuilder<Map<String, dynamic>>(
                future: ref.read(offlinePostRepoProvider).getStorageInfo(),
                builder: (context, snapshot) {
                  final storageInfo = snapshot.data ?? {};
                  final totalSizeMB =
                      storageInfo['totalSizeMB']?.toString() ?? '0.00';

                  return SettingTile(
                    icon: IconlyLight.chart,
                    iconColor: Colors.blue,
                    label: 'storage_information',
                    subtitle:
                        'using_storage'.tr(namedArgs: {'size': totalSizeMB}),
                    trailing: const Icon(Icons.info_outline),
                    onTap: () => _showStorageInfoDialog(context, storageInfo),
                  );
                },
              ),
            ],
          ),
        ),
      ],
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
