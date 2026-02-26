import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/features/posts/providers/post_pagination_class.dart';
import '../../auth/providers/user_data_provider.dart';
import '../data/repository/recommended_post_repository.dart';

final recommendedPostsProvider =
    StateNotifierProvider<RecommendedPostsController, PostPagination>((ref) {
  final repo = ref.read(recommendedPostRepoProvider);
  return RecommendedPostsController(repo);
});

class RecommendedPostsController extends StateNotifier<PostPagination> {
  RecommendedPostsController(
    this.repository, [
    PostPagination? state,
  ]) : super(state ?? PostPagination.initial()) {
    getPosts();
  }

  final RecommendedPostRepository repository;

  bool _isAlreadyLoading = false;

  Future<void> getPosts() async {
    if (_isAlreadyLoading) {
      return;
    }
    _isAlreadyLoading = true;

    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted && state.page > 1) {
          state = state.copyWith(isPaginationLoading: true);
        }
      });

      final fetched =
          await repository.getRecommendedPosts(pageNumber: state.page);

      /// Make's seperate list for categories with different hero ID
      final posts = fetched
          .map((e) => e.copyWith(heroTag: '${e.link}recommended'))
          .toList();

      if (mounted && state.page == 1) {
        state = state.copyWith(initialLoaded: true);
      }

      if (mounted) {
        state = state.copyWith(
          posts: [...state.posts, ...posts],
          page: state.page + 1,
          isPaginationLoading: false,
        );
      }
    } on Exception {
      state = state.copyWith(
        errorMessage: 'Fetch Error',
        initialLoaded: true,
        isPaginationLoading: false,
      );
    }
    _isAlreadyLoading = false;
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;

    final pageToRequest = itemPosition ~/ 10;
    if (requestMoreData && pageToRequest + 1 >= state.page) {
      getPosts();
    }
  }

  Future<void> onRefresh() async {
    state = PostPagination.initial();
    await getPosts();
  }

  Future<bool> updateCategories(List<int> categories) async {
    final success =
        await repository.updateUserPreferences(categories: categories);
    if (success) {
      onRefresh();
    }
    return success;
  }

  Future<bool> updateTags(List<int> tags) async {
    final success = await repository.updateUserPreferences(tags: tags);
    if (success) {
      onRefresh();
    }
    return success;
  }

  Future<void> saveAndContinue({
    required Set<int> selectedCategories,
    required Set<int> selectedTags,
    required Set<int> selectedMembers,
    required VoidCallback onSuccess,
    Function(String)? onError,
    required WidgetRef ref,
  }) async {
    try {
      final success = await repository.updateUserPreferences(
        categories: selectedCategories.toList(),
        tags: selectedTags.toList(),
        authors: selectedMembers.toList(),
      );

      if (success) {
        ref.invalidate(userDataProvider);
        onRefresh();
        onSuccess();
      } else {
        onError?.call('Failed to save preferences');
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<bool> updateAuthors(List<int> authors) async {
    final success = await repository.updateUserPreferences(authors: authors);
    if (success) {
      onRefresh();
    }
    return success;
  }
}
