import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/features/categories/data/repository/category_repository.dart';
import 'package:news_pro/features/categories/providers/parent_categories_pagination.dart';

final preferenceCategoriesController =
    StateNotifierProvider<PreferenceCategoriesController, CategoryPagination>(
        (ref) {
  final categoryRepo = ref.read(categoriesRepoProvider);
  return PreferenceCategoriesController(categoryRepo);
});

class PreferenceCategoriesController extends StateNotifier<CategoryPagination> {
  PreferenceCategoriesController(
    this.repository, [
    CategoryPagination? state,
  ]) : super(state ?? CategoryPagination.initial()) {
    getPosts();
  }

  final CategoriesRepository repository;

  bool _isAlreadyLoading = false;
  bool _isFetchingParents = true;
  final Set<int> _fetchedParentIds = {};
  int _parentPage = 1;
  int _subPage = 1;

  Future<void> getPosts() async {
    if (_isAlreadyLoading || state.hasReachedMax) return;
    _isAlreadyLoading = true;

    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state = state.copyWith(isPaginationLoading: true);
        }
      });

      List<dynamic> fetched = []; // using dynamic to hold CategoryModel list

      if (_isFetchingParents) {
        final parents = await repository.getAllParentCategories(_parentPage);
        fetched = parents;

        if (parents.isNotEmpty) {
          _fetchedParentIds.addAll(parents.map((e) => e.id));
          _parentPage++;
        }

        if (parents.length < 10) {
          // End of parents.
          _isFetchingParents = false;
          // If we got some parents (but not a full page), we display them.
          // Next time user clicks load more, we go to Phase 2.
          // If we got 0 parents, we should immediately try Phase 2?
          if (parents.isEmpty) {
            _isAlreadyLoading = false;
            await getPosts(); // Recurse to fetch subs immediately
            return;
          }
        }
      } else {
        // Phase 2: Subcategories
        // We fetch generic categories but exclude the parents we already have.
        // Note: exclude list might get too long for URL.
        // For now, let's pass it. If it fails, the repo handles generic fetch.
        final subs = await repository.getAllSubcategoriesTogether(
          page: _subPage,
          exclude: _fetchedParentIds.toList(),
        );
        fetched = subs;

        if (subs.isNotEmpty) {
          _subPage++;
        }

        if (subs.length < 20) {
          // End of everything
          if (mounted) {
            state = state.copyWith(hasReachedMax: true);
          }
        }
      }

      if (mounted) {
        state = state.copyWith(
          items: [...state.items, ...fetched.cast()],
          initialLoaded: true,
          isPaginationLoading: false,
        );
      }
    } on Exception {
      state = state.copyWith(
        errorMessage: 'Fetch Error',
        initialLoaded: true,
        isPaginationLoading: false,
      );
    } finally {
      _isAlreadyLoading = false;
    }
  }

  void handleScrollWithIndex(int index) {
    // Logic if we were using infinite scroll. For "Load More" button, explicit call is used.
  }
}
