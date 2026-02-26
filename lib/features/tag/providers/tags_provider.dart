import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/post_tag.dart';
import '../data/repository/tags_repository.dart';
import '../../../core/dio/dio_provider.dart';

final tagsProvider = FutureProvider.family
    .autoDispose<List<PostTag>, List<int>>((ref, tagIDList) async {
  final dio = ref.read(dioProvider);
  final repo = TagRepository(dio);
  final tags = await repo.getTagsNameById(tagIDList);
  return tags;
});
