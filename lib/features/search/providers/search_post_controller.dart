import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../posts/data/models/article_model.dart';
import '../data/models/search_model.dart';
import '../data/repository/search_repository.dart';
import '../../posts/data/repository/post_repository.dart';

/* <---- Search Post -----> */
final searchPostController = FutureProvider.autoDispose
    .family<List<ArticleModel>, String>((ref, query) async {
  final postRepo = ref.read(postRepoProvider);
  return await postRepo.searchPost(keyword: query);
});

/* <---- Search history -----> */
final searchHistoryController =
    StateNotifierProvider<SearchHistoryNotifier, AsyncValue<List<SearchModel>>>(
        (ref) {
  return SearchHistoryNotifier(SearchLocalRepo());
});

class SearchHistoryNotifier
    extends StateNotifier<AsyncValue<List<SearchModel>>> {
  SearchHistoryNotifier(this.repo) : super(const AsyncData([])) {
    {
      _init();
    }
  }

  final SearchLocalRepo repo;

  _init() async {
    state = const AsyncLoading();
    final data = await repo.getEntries();
    state = AsyncData(data);
  }

  addEntry(String query) async {
    await repo.saveEntry(query: query);
    final data = await repo.getEntries();
    state = AsyncData(data);
  }

  deleteEntry(SearchModel query) async {
    await repo.deleteEntry(query: query);
    final newList = state.value?.where((element) => element != query).toList();
    state = AsyncData(newList!);
  }

  deleteAll() async {
    await repo.deleteAll();
    state = const AsyncData([]);
  }
}
