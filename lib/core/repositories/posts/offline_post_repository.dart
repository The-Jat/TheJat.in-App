import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logger/app_logger.dart';
import '../../models/article.dart';

final offlinePostRepoProvider = Provider<OfflinePostRepository>((ref) {
  final repo = OfflinePostRepository();
  return repo;
});

/// Repository for managing offline posts storage using Hive
class OfflinePostRepository {
  static const String _boxName = 'offline_posts';
  static const String _postsKey = 'saved_posts';
  static const String _metadataKey = 'posts_metadata';

  /// Initialize the offline posts repository
  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);

        // Try to migrate old data format first
        await _migrateOldData();
        // Check for corrupted data and clear it if found
        try {
          await getSavedPosts();
          Log.info('Offline posts repository initialized successfully');
        } catch (e) {
          Log.warning(
              'Found corrupted data during initialization, clearing...');
          await _clearCorruptedData();
          Log.info(
              'Offline posts repository initialized after clearing corrupted data');
        }
      }
    } catch (e, stack) {
      Log.fatal(
          error: 'Failed to initialize offline posts repository: $e',
          stackTrace: stack);
    }
  }

  /// Save a post for offline reading
  Future<bool> savePost(ArticleModel post) async {
    try {
      final box = Hive.box(_boxName);
      final savedPosts = await getSavedPosts();

      // Check if post already exists
      final existingIndex = savedPosts.indexWhere((p) => p.id == post.id);

      if (existingIndex != -1) {
        // Update existing post
        savedPosts[existingIndex] = post;
        Log.info('Updated existing offline post: ${post.title}');
      } else {
        // Add new post
        savedPosts.add(post);
        Log.info('Saved new offline post: ${post.title}');
      }

      // Save to storage
      final postsJson = savedPosts.map((p) => p.toOfflineJson()).toList();
      await box.put(_postsKey, postsJson);

      // Update metadata
      await _updateMetadata();

      return true;
    } catch (e, stack) {
      Log.fatal(error: 'Failed to save post offline: $e', stackTrace: stack);
      return false;
    }
  }

  /// Get all saved posts
  Future<List<ArticleModel>> getSavedPosts() async {
    try {
      final box = Hive.box(_boxName);
      final postsData = box.get(_postsKey, defaultValue: <String>[]);

      final posts = <ArticleModel>[];

      for (final data in postsData) {
        try {
          // Try to parse as offline JSON
          final article = ArticleModel.fromOfflineJson(data);
          posts.add(article);
        } catch (parseError) {
          // If parsing fails, it might be corrupted data, skip it
          Log.warning('Skipping corrupted offline post data: $data');
          continue;
        }
      }

      // Sort by date (newest first)
      posts.sort((a, b) => b.date.compareTo(a.date));
      return posts;
    } catch (e, stack) {
      Log.fatal(error: 'Failed to get saved posts: $e', stackTrace: stack);
      // If there's a major error, clear the corrupted data
      await _clearCorruptedData();
      return [];
    }
  }

  /// Clear corrupted data from storage
  Future<void> _clearCorruptedData() async {
    try {
      final box = Hive.isBoxOpen(_boxName);
      if (box) {
        await Hive.box(_boxName).put(_postsKey, <String>[]);
      }
      await _updateMetadata();
      Log.info('Cleared corrupted offline posts data');
    } catch (e) {
      Log.error('Failed to clear corrupted data: $e');
    }
  }

  /// Get a specific post by ID
  Future<ArticleModel?> getPostById(int postId) async {
    try {
      final savedPosts = await getSavedPosts();
      return savedPosts.where((post) => post.id == postId).firstOrNull;
    } catch (e, stack) {
      Log.fatal(error: 'Failed to get post by ID: $e', stackTrace: stack);
      return null;
    }
  }

  /// Remove a post from offline storage
  Future<bool> removePost(int postId) async {
    try {
      final box = Hive.box(_boxName);
      final savedPosts = await getSavedPosts();

      final updatedPosts =
          savedPosts.where((post) => post.id != postId).toList();

      final postsJson = updatedPosts.map((p) => p.toOfflineJson()).toList();
      await box.put(_postsKey, postsJson);

      // Update metadata
      await _updateMetadata();

      Log.info('Removed offline post with ID: $postId');
      return true;
    } catch (e, stack) {
      Log.fatal(error: 'Failed to remove post: $e', stackTrace: stack);
      return false;
    }
  }

  /// Check if a post is saved offline
  Future<bool> isPostSaved(int postId) async {
    try {
      final savedPosts = await getSavedPosts();
      return savedPosts.any((post) => post.id == postId);
    } catch (e, stack) {
      Log.fatal(
          error: 'Failed to check if post is saved: $e', stackTrace: stack);
      return false;
    }
  }

  /// Get the count of saved posts
  Future<int> getSavedPostsCount() async {
    try {
      final savedPosts = await getSavedPosts();
      return savedPosts.length;
    } catch (e, stack) {
      Log.fatal(
          error: 'Failed to get saved posts count: $e', stackTrace: stack);
      return 0;
    }
  }

  /// Clear all saved posts
  Future<bool> clearAllPosts() async {
    try {
      final box = Hive.box(_boxName);
      await box.put(_postsKey, <String>[]);
      await _updateMetadata();

      Log.info('Cleared all offline posts');
      return true;
    } catch (e, stack) {
      Log.fatal(error: 'Failed to clear all posts: $e', stackTrace: stack);
      return false;
    }
  }

  /// Clear corrupted data and reset storage
  Future<bool> clearCorruptedData() async {
    try {
      await _clearCorruptedData();
      Log.info('Cleared corrupted offline posts data');
      return true;
    } catch (e, stack) {
      Log.fatal(error: 'Failed to clear corrupted data: $e', stackTrace: stack);
      return false;
    }
  }

  /// Migrate old data format to new format (if needed)
  Future<void> _migrateOldData() async {
    try {
      final box = Hive.box(_boxName);
      final postsData = box.get(_postsKey, defaultValue: <String>[]);

      if (postsData.isEmpty) return;

      final migratedPosts = <String>[];
      bool needsMigration = false;

      for (final data in postsData) {
        try {
          // Try to parse with new format first
          ArticleModel.fromOfflineJson(data);
          migratedPosts.add(data);
        } catch (e) {
          // If that fails, try old format and migrate
          try {
            final article = ArticleModel.fromMap(jsonDecode(data));
            migratedPosts.add(article.toOfflineJson());
            needsMigration = true;
            Log.info('Migrated old format post: ${article.title}');
          } catch (migrationError) {
            Log.warning('Skipping unmigratable post data: $data');
          }
        }
      }

      if (needsMigration) {
        await box.put(_postsKey, migratedPosts);
        await _updateMetadata();
        Log.info('Migration completed successfully');
      }
    } catch (e) {
      Log.error('Failed to migrate old data: $e');
    }
  }

  /// Get metadata about saved posts
  Future<Map<String, dynamic>> getMetadata() async {
    try {
      final box = Hive.box(_boxName);
      return Map<String, dynamic>.from(
          box.get(_metadataKey, defaultValue: <String, dynamic>{}));
    } catch (e, stack) {
      Log.fatal(error: 'Failed to get metadata: $e', stackTrace: stack);
      return {};
    }
  }

  /// Update metadata
  Future<void> _updateMetadata() async {
    try {
      final box = Hive.box(_boxName);
      final savedPosts = await getSavedPosts();

      final metadata = {
        'count': savedPosts.length,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'oldestPost': savedPosts.isNotEmpty
            ? savedPosts.last.date.millisecondsSinceEpoch
            : null,
        'newestPost': savedPosts.isNotEmpty
            ? savedPosts.first.date.millisecondsSinceEpoch
            : null,
      };

      await box.put(_metadataKey, metadata);
    } catch (e, stack) {
      Log.fatal(error: 'Failed to update metadata: $e', stackTrace: stack);
    }
  }

  /// Search saved posts by title or content
  Future<List<ArticleModel>> searchSavedPosts(String query) async {
    try {
      final savedPosts = await getSavedPosts();
      final lowercaseQuery = query.toLowerCase();

      return savedPosts.where((post) {
        return post.title.toLowerCase().contains(lowercaseQuery) ||
            post.content.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e, stack) {
      Log.fatal(error: 'Failed to search saved posts: $e', stackTrace: stack);
      return [];
    }
  }

  /// Get storage size information
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final savedPosts = await getSavedPosts();
      final metadata = await getMetadata();

      // Calculate approximate storage size
      int totalSize = 0;
      for (final post in savedPosts) {
        totalSize += post.toOfflineJson().length;
      }

      return {
        'postCount': savedPosts.length,
        'totalSizeBytes': totalSize,
        'totalSizeKB': (totalSize / 1024).toStringAsFixed(2),
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'lastUpdated': metadata['lastUpdated'],
        'oldestPost': metadata['oldestPost'],
        'newestPost': metadata['newestPost'],
      };
    } catch (e, stack) {
      Log.fatal(error: 'Failed to get storage info: $e', stackTrace: stack);
      return {};
    }
  }
}
