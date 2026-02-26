import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/core/constants/app_defaults.dart';
import 'package:news_pro/core/components/network_image.dart';
import 'package:news_pro/features/categories/providers/preference_categories_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CategorySelectionWidget extends ConsumerWidget {
  const CategorySelectionWidget({
    super.key,
    required this.selectedIds,
    required this.onToggle,
  });

  final Set<int> selectedIds;
  final Function(int) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(preferenceCategoriesController);

    if (categoriesState.items.isEmpty) {
      if (categoriesState.initialLoaded == false &&
          categoriesState.isPaginationLoading) {
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
            children: categoriesState.items.map((category) {
              final isSelected = selectedIds.contains(category.id);
              return FilterChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (bool value) => onToggle(category.id),
                avatar: category.thumbnail == null
                    ? null
                    : ClipOval(
                        child: NetworkImageWithLoader(
                          category.thumbnail!,
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
        if (!categoriesState.hasReachedMax)
          VisibilityDetector(
            key: const Key('category_loader'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.1 &&
                  !categoriesState.isPaginationLoading) {
                ref.read(preferenceCategoriesController.notifier).getPosts();
              }
            },
            child: categoriesState.isPaginationLoading
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
