import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/author.dart';
import '../data/repository/auth_repository.dart';
import '../data/repository/user_repository.dart';

final userDataProvider = FutureProvider<AuthorData?>((ref) async {
  final auth = ref.read(authRepositoryProvider);
  final repo = ref.read(userRepoProvider);
  final token = await auth.getToken();
  AuthorData? author;
  if (token != null) author = await repo.getMe(token);
  return author;
});
