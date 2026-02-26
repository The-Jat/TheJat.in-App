import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/core/constants/app_defaults.dart';
import 'package:news_pro/core/components/network_image.dart';
import 'package:news_pro/features/auth/providers/authors_pagination.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AuthorSelectionWidget extends ConsumerWidget {
  const AuthorSelectionWidget({
    super.key,
    required this.selectedIds,
    required this.onToggle,
  });

  final Set<int> selectedIds;
  final Function(int) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorsState = ref.watch(usersController);

    if (authorsState.items.isEmpty) {
      if (authorsState.initialLoaded == false &&
          authorsState.isPaginationLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return const SizedBox();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: authorsState.items.map((author) {
              final isSelected = selectedIds.contains(author.userID);
              return FilterChip(
                label: Text(author.name),
                selected: isSelected,
                onSelected: (bool value) => onToggle(author.userID),
                avatar: ClipOval(
                  child: NetworkImageWithLoader(
                    author.avatarUrl,
                    fit: BoxFit.cover,
                    radius: 100,
                  ),
                ),
                showCheckmark: false,
                checkmarkColor: Colors.white,
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.all(8),
              );
            }).toList(),
          ),
        ),
        if (!authorsState.hasReachedMax)
          VisibilityDetector(
            key: const Key('author_loader'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.1 &&
                  !authorsState.isPaginationLoading) {
                ref.read(usersController.notifier).getPosts();
              }
            },
            child: authorsState.isPaginationLoading
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox(height: 50, width: double.infinity),
          ),
      ],
    );
  }
}
