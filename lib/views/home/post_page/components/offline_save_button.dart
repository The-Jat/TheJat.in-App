import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/models/article.dart';
import '../../../../core/repositories/posts/offline_post_repository.dart';

/// Provider for checking if a specific post is saved offline
final offlinePostStatusProvider =
    FutureProvider.family<bool, int>((ref, postId) async {
  final offlineRepo = ref.read(offlinePostRepoProvider);
  return await offlineRepo.isPostSaved(postId);
});

class OfflineSaveButton extends ConsumerWidget {
  const OfflineSaveButton({
    super.key,
    required this.article,
    this.iconSize = 18,
    this.useMinimalStyle = false,
  });

  final ArticleModel article;
  final double iconSize;
  final bool useMinimalStyle;

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

        if (useMinimalStyle) {
          return IconButton(
            onPressed: onTap,
            icon: Icon(
              isOfflineSaved ? IconlyBold.download : IconlyLight.download,
              color: isOfflineSaved
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.8),
              size: iconSize,
            ),
            tooltip: isOfflineSaved
                ? 'remove_from_offline'.tr()
                : 'save_for_offline_reading'.tr(),
          );
        }

        return OutlinedButton.icon(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: isOfflineSaved ? AppColors.primary : Colors.grey,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            side: BorderSide(
              color: isOfflineSaved ? AppColors.primary : Colors.grey,
            ),
          ),
          label: Text(
            isOfflineSaved
                ? 'remove_from_offline'.tr()
                : 'save_for_offline_reading'.tr(),
          ),
          icon: Icon(
            isOfflineSaved ? IconlyBold.download : IconlyLight.download,
            size: iconSize,
          ),
        );
      },
      loading: () => useMinimalStyle
          ? IconButton(
              onPressed: null,
              icon: Icon(
                IconlyLight.download,
                color: Colors.grey.withValues(alpha: 0.5),
                size: iconSize,
              ),
            )
          : OutlinedButton.icon(
              onPressed: null,
              icon: Icon(
                IconlyLight.download,
                size: iconSize,
              ),
              label: Text('loading'.tr()),
            ),
      error: (error, stack) => useMinimalStyle
          ? IconButton(
              onPressed: () =>
                  ref.invalidate(offlinePostStatusProvider(article.id)),
              icon: Icon(
                IconlyLight.download,
                color: Colors.red.withValues(alpha: 0.8),
                size: iconSize,
              ),
              tooltip: 'Error loading status',
            )
          : OutlinedButton.icon(
              onPressed: () =>
                  ref.invalidate(offlinePostStatusProvider(article.id)),
              icon: Icon(
                IconlyLight.download,
                size: iconSize,
              ),
              label: Text('Error'),
            ),
    );
  }
}
