import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dio/dio_provider.dart';
import '../data/repository/tags_repository.dart';
import 'tags_pagination.dart';

final tagsController =
    StateNotifierProvider<TagsNotifier, TagPagination>((ref) {
  final dio = ref.read(dioProvider);
  final repo = TagRepository(dio);
  return TagsNotifier(repo);
});

class TagsNotifier extends StateNotifier<TagPagination> {
  TagsNotifier(
    this.repository, [
    TagPagination? state,
  ]) : super(state ?? TagPagination.initial()) {
    getPosts();
  }

  final TagRepository repository;

  bool _isAlreadyLoading = false;

  Future<void> getPosts() async {
    if (_isAlreadyLoading) {
      return;
    }
    _isAlreadyLoading = true;

    try {
      if (mounted && state.page > 1) {
        state = state.copyWith(isPaginationLoading: true);
      }

      final fetched = await repository.getAllTags(page: state.page);

      if (mounted && state.page == 1) {
        state = state.copyWith(initialLoaded: true);
      }

      if (mounted) {
        state = state.copyWith(
          items: [...state.items, ...fetched],
          page: state.page + 1,
          isPaginationLoading: false,
          hasReachedMax: fetched.length < 20,
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
    final requestMoreData = itemPosition % 20 == 0 && itemPosition != 0;

    final pageToRequest = itemPosition ~/ 20;
    if (requestMoreData && pageToRequest + 1 >= state.page) {
      getPosts();
    }
  }

  Future<void> onRefresh() async {
    state = TagPagination.initial();
    await getPosts();
  }
}
