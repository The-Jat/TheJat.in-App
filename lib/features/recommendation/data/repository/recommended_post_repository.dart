import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/config/wp_config.dart';
import 'package:news_pro/core/dio/dio_provider.dart';
import 'package:news_pro/core/logger/app_logger.dart';
import 'package:news_pro/features/posts/data/models/article_model.dart';

import '../../../auth/data/repository/auth_repository.dart';
import '../../../auth/data/repository/user_repository.dart';

final recommendedPostRepoProvider = Provider<RecommendedPostRepository>((ref) {
  final auth = ref.read(authRepositoryProvider);
  final repo = ref.read(userRepoProvider);
  final dio = ref.read(dioProvider);
  return RecommendedPostRepository(auth: auth, repo: repo, dio: dio);
});

class RecommendedPostRepository {
  final AuthRepository auth;
  final UserRepository repo;
  final Dio dio;

  RecommendedPostRepository({
    required this.auth,
    required this.repo,
    required this.dio,
  });

  final String baseUrl = 'https://${WPConfig.url}/wp-json';

  // Get saved categories
  Future<List<int>> getSavedCategories() async {
    final token = await auth.getToken();
    if (token != null) {
      final me = await repo.getMe(token);
      if (me != null) {
        List<int> categoryIDs = [];
        for (var element in me.savedCategories) {
          final id = int.tryParse(element) ?? 0;
          if (id > 0) categoryIDs.add(id);
        }
        return categoryIDs;
      } else {
        debugPrint('no profile found for this token');
        return [];
      }
    } else {
      debugPrint('No token found for favourite post');
      return [];
    }
  }

  // Get saved tags
  Future<List<int>> getSavedTags() async {
    final token = await auth.getToken();
    if (token != null) {
      final me = await repo.getMe(token);
      if (me != null) {
        List<int> tagIDs = [];
        for (var element in me.savedTags) {
          final id = int.tryParse(element) ?? 0;
          if (id > 0) tagIDs.add(id);
        }
        return tagIDs;
      } else {
        debugPrint('no profile found for this token');
        return [];
      }
    } else {
      debugPrint('No token found for favourite post');
      return [];
    }
  }

  // Get saved authors
  Future<List<int>> getSavedAuthors() async {
    final token = await auth.getToken();
    if (token != null) {
      final me = await repo.getMe(token);
      if (me != null) {
        List<int> authorIDs = [];
        for (var element in me.savedAuthors) {
          final id = int.tryParse(element) ?? 0;
          if (id > 0) authorIDs.add(id);
        }
        return authorIDs;
      } else {
        debugPrint('no profile found for this token');
        return [];
      }
    } else {
      debugPrint('No token found for favourite post');
      return [];
    }
  }

  // Update saved categories
  Future<List<String>> updateSavedCategories(List<int> updatedList) async {
    final token = await auth.getToken();
    if (token != null) {
      final me = await repo.updateProfile(token, {
        'saved_categories': updatedList,
      });
      if (me != null) {
        return me.savedCategories;
      } else {
        debugPrint('no profile found for this token');
        return [];
      }
    } else {
      debugPrint('No token found for favourite post');
      return [];
    }
  }

  // Update saved tags
  Future<List<String>> updateSavedTags(List<int> updatedList) async {
    final token = await auth.getToken();
    if (token != null) {
      final me = await repo.updateProfile(token, {
        'saved_tags': updatedList,
      });
      if (me != null) {
        return me.savedTags;
      } else {
        debugPrint('no profile found for this token');
        return [];
      }
    } else {
      debugPrint('No token found for favourite post');
      return [];
    }
  }

  // Update saved authors
  Future<List<String>> updateSavedAuthors(List<int> updatedList) async {
    final token = await auth.getToken();
    if (token != null) {
      final me = await repo.updateProfile(token, {
        'saved_authors': updatedList,
      });
      if (me != null) {
        return me.savedAuthors;
      } else {
        debugPrint('no profile found for this token');
        return [];
      }
    } else {
      debugPrint('No token found for favourite post');
      return [];
    }
  }

  /* <-----------------------> 
      Fetch Posts    
   <-----------------------> */

  Future<List<ArticleModel>> getAllPost({
    required int pageNumber,
    int perPage = 10,
  }) async {
    final String url =
        '$baseUrl/wp/v2/posts?page=$pageNumber&per_page=$perPage';
    final List<ArticleModel> articles = [];

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200 || response.statusCode == 304) {
        final List posts = response.data as List;

        for (final post in posts) {
          try {
            final article = ArticleModel.fromMap(post);
            articles.add(article);
          } catch (parseError) {
            Log.error('Failed to parse article: $parseError');
            Log.error('Problematic article data: $post');
            continue;
          }
        }
      } else {
        Log.error('Unexpected response status code: ${response.statusCode}');
      }

      return articles;
    } catch (networkError) {
      debugPrint('Network error while fetching articles: $networkError');
      return articles;
    }
  }

  /// Fetch recommended posts based on user's saved preferences
  ///
  /// [pageNumber] - Page number for pagination
  /// [perPage] - Number of posts per page (default: 10)
  /// [filterBy] - Filter type: 'any' (default), 'categories', 'tags', 'authors'
  ///
  /// Returns list of recommended articles based on saved preferences
  Future<List<ArticleModel>> getRecommendedPosts({
    required int pageNumber,
    int perPage = 10,
    String filterBy = 'any',
  }) async {
    final token = await auth.getToken();

    if (token == null) {
      debugPrint('No token found for recommended posts');
      return [];
    }

    final String url = '$baseUrl/newspro/v2/posts/recommended';
    final List<ArticleModel> articles = [];

    try {
      final response = await dio.get(
        url,
        queryParameters: {
          'page': pageNumber,
          'per_page': perPage,
          'filter_by': filterBy,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List posts = data['posts'] as List? ?? [];

        debugPrint('Recommended posts: ${posts.length} found');
        debugPrint('Total: ${data['total']}, Pages: ${data['total_pages']}');

        for (final post in posts) {
          try {
            final article = ArticleModel.fromMap(post);
            articles.add(article);
          } catch (parseError) {
            Log.error('Failed to parse recommended article: $parseError');
            continue;
          }
        }
      } else {
        Log.error('Unexpected response status code: ${response.statusCode}');
      }

      return articles;
    } catch (error) {
      debugPrint('Error fetching recommended posts: $error');
      return articles;
    }
  }

  /// Fetch recommended posts by categories only
  Future<List<ArticleModel>> getRecommendedPostsByCategories({
    required int pageNumber,
    int perPage = 10,
  }) async {
    return getRecommendedPosts(
      pageNumber: pageNumber,
      perPage: perPage,
      filterBy: 'categories',
    );
  }

  /// Fetch recommended posts by tags only
  Future<List<ArticleModel>> getRecommendedPostsByTags({
    required int pageNumber,
    int perPage = 10,
  }) async {
    return getRecommendedPosts(
      pageNumber: pageNumber,
      perPage: perPage,
      filterBy: 'tags',
    );
  }

  /// Fetch recommended posts by authors only
  Future<List<ArticleModel>> getRecommendedPostsByAuthors({
    required int pageNumber,
    int perPage = 10,
  }) async {
    return getRecommendedPosts(
      pageNumber: pageNumber,
      perPage: perPage,
      filterBy: 'authors',
    );
  }

  /// Update user preferences in WordPress
  ///
  /// Pass null for fields you don't want to update
  Future<bool> updateUserPreferences({
    List<int>? categories,
    List<int>? tags,
    List<int>? authors,
  }) async {
    final token = await auth.getToken();

    if (token == null) {
      debugPrint('No token found for updating preferences');
      return false;
    }

    try {
      final Map<String, dynamic> body = {};

      if (categories != null) {
        body['saved_categories'] = categories;
      }
      if (tags != null) {
        body['saved_tags'] = tags;
      }
      if (authors != null) {
        body['saved_authors'] = authors;
      }

      final me = await repo.updateProfile(token, body);

      if (me != null) {
        debugPrint('User preferences updated successfully');
        return true;
      }

      return false;
    } catch (error) {
      debugPrint('Error updating user preferences: $error');
      return false;
    }
  }
}
