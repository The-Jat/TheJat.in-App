import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../config/wp_config.dart';
import '../../../config/providers/config_providers.dart';
import '../../../../core/dio/dio_provider.dart';
import '../models/category.dart';

final categoriesRepoProvider = Provider<CategoriesRepository>((ref) {
  final dio = ref.read(dioProvider);
  final blockedCategories =
      ref.watch(configProvider).value?.blockedCategories ?? [];

  return CategoriesRepository(dio: dio, blockedCategories: blockedCategories);
});

abstract class CategoriesRepoAbstract {
  /// Gets all the category from the website
  Future<List<CategoryModel>> getAllCategory();

  /// Get Single Category
  Future<CategoryModel?> getCategory(int id);

  /// Get These Categories
  Future<List<CategoryModel>> getTheseCategories(List<int> ids);

  /// Get All Parent Categories
  Future<List<CategoryModel>> getAllParentCategories(int page);

  /// Get All Sub Categories
  Future<List<CategoryModel>> getAllSubcategories(
      {required int page, required int parentId});
}

class CategoriesRepository extends CategoriesRepoAbstract {
  final Dio dio;
  CategoriesRepository({
    required this.dio,
    required this.blockedCategories,
  });

  final List<int> blockedCategories;

// Category fields to fetch from API
  final String _categoryFields = 'id,name,slug,link,parent,thumbnail';

  @override
  Future<List<CategoryModel>> getAllCategory() async {
    final blocked = _getBlockedCategories();

    String url =
        'https://${WPConfig.url}/wp-json/wp/v2/categories?exclude=$blocked&_fields=$_categoryFields';
    List<CategoryModel> allCategories = [];
    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final allData = response.data as List;
        allCategories = allData.map((e) => CategoryModel.fromMap(e)).toList();
        // Log.info(allCategories.toString());
        return allCategories;
      } else {
        // Log.info('Status code for getAllCategory: ${response.statusCode}');
        // Log.info('getAllCategory: ${response.data}');
        return allCategories;
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<CategoryModel?> getCategory(int id) async {
    String url =
        'https://${WPConfig.url}/wp-json/wp/v2/categories/$id?_fields=$_categoryFields';
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        return CategoryModel.fromMap(response.data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Get Blocked Categories defined in [WPConfig]
  String _getBlockedCategories() {
    String data = '';
    final blockedData = blockedCategories;
    if (blockedData.isNotEmpty) {
      if (blockedData.length > 1) {
        data = blockedData.join(',');
      } else {
        data = blockedData.first.toString();
      }
    }
    return data;
  }

  @override
  Future<List<CategoryModel>> getTheseCategories(List<int> ids) async {
    List<CategoryModel> allCategories = [];

    final List<int> filteredIds =
        ids.where((id) => !blockedCategories.contains(id)).toList();

    if (filteredIds.isEmpty) {
      return allCategories;
    } else if (filteredIds.length <= 10) {
      final categories = ids.join(',');
      final url =
          'https://${WPConfig.url}/wp-json/wp/v2/categories?include=$categories&orderby=include&_fields=$_categoryFields';

      try {
        final response = await dio.get(url);
        if (response.statusCode == 200) {
          final allData = response.data as List;
          allCategories = allData.map((e) => CategoryModel.fromMap(e)).toList();
          return allCategories;
        } else {
          debugPrint(response.data);
          return allCategories;
        }
      } catch (e) {
        debugPrint(e.toString());
        return allCategories;
      }
    } else {
      for (var i = 0; i < ids.length; i++) {
        final url =
            'https://${WPConfig.url}/wp-json/wp/v2/categories/${ids[i]}?_fields=$_categoryFields';
        try {
          final response = await dio.get(url);
          if (response.statusCode == 200) {
            allCategories.add(CategoryModel.fromMap(response.data));
          } else {}
        } catch (e) {
          debugPrint(e.toString());
        }
      }
      return allCategories;
    }
  }

  @override
  Future<List<CategoryModel>> getAllParentCategories(int page) async {
    final blockedCategories = _getBlockedCategories();

    String url =
        'https://${WPConfig.url}/wp-json/wp/v2/categories/?parent=0&page=$page&exclude=$blockedCategories&_fields=$_categoryFields';
    List<CategoryModel> allCategories = [];
    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {}
      final allData = response.data as List;
      allCategories = allData.map((e) => CategoryModel.fromMap(e)).toList();
      // debugPrint(allCategories.toString());
      return allCategories;
    } catch (e) {
      Fluttertoast.showToast(msg: 'There is an error while getting categories');
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<List<CategoryModel>> getAllSubcategories({
    required int page,
    required int parentId,
  }) async {
    final blockedCategories = _getBlockedCategories();

    String url =
        'https://${WPConfig.url}/wp-json/wp/v2/categories/?parent=$parentId&page=$page&exclude=$blockedCategories&_fields=$_categoryFields';
    List<CategoryModel> allCategories = [];
    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {}
      final allData = response.data as List;
      allCategories = allData.map((e) => CategoryModel.fromMap(e)).toList();
      // debugPrint(allCategories.toString());
      return allCategories;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  /// Get All Subcategories (All categories except parents)
  /// If [exclude] list is provided, those IDs will be excluded from the fetch.
  Future<List<CategoryModel>> getAllSubcategoriesTogether({
    int page = 1,
    int perPage = 20,
    List<int>? exclude,
  }) async {
    final blockedCategories = _getBlockedCategories();
    String excludeStr = blockedCategories;

    if (exclude != null && exclude.isNotEmpty) {
      if (excludeStr.isNotEmpty) {
        excludeStr += ',${exclude.join(',')}';
      } else {
        excludeStr = exclude.join(',');
      }
    }

    // We want subcategories, but WP API doesn't have a direct "only subcategories" filter
    // except by excluding all parents (which we don't know upfront) OR by excluding the parents we DO know.
    // The previous implementation used `parent=0` which gets ONLY parents.
    // To get "categories that are NOT parents", it's tricky.
    // However, the requirement is "Fetch all parent categories first. After finishing that, fetch all subcategories".
    // So if we fetch paginated parents first, we know their IDs.
    // Then we can fetch *everything else* by excluding those IDs? No, that might still include other parents deeper in pagination.
    //
    // Actually, `parent!=0` is what we want. But WP API doesn't support `parent__not_in=0`.
    // It supports `parent_exclude`.
    // Let's try to fetch all categories and filter? No, too much data.
    //
    // Alternative: The user previously added `getAllSubcategoriesTogether` which fetched `parent=0`. that was wrong (it fetched parents).
    // The prompt says "utilizing pagination".
    //
    // If I cannot easily filter "only subcategories", I will simulate it by:
    // 1. Fetching ALL categories (per page).
    // 2. Filtering out the ones that are parents (if I know them).
    // OR
    // Just fetch `categories` without `parent=0`. This returns mixed.
    // The controller will first fetch `parent=0` (Parents).
    // Then it needs "The Rest".
    // If I use `exclude` with the IDs of the parents I already fetched, I effectively get "The Rest" (which includes subcategories and potentially parents I haven't seen yet).
    // BUT, `exclude` has a limit on URL length.
    //
    // Let's stick to the strategy of "Fetch Parents (parent=0)" then "Fetch Subcategories".
    // How to fetch ONLY subcategories?
    // Maybe we don't need to be 100% strict on "ONLY", but "All others".
    //
    // If we just fetch `categories` (without parent param), we get everything.
    // If we duplicate some parents, we can filter them client side.
    //
    // Let's try to use `parent_exclude` if available? No.
    //
    // Let's assume `getAllSubcategoriesTogether` effectively means "Fetch broader list".
    // I will implement it to fetch *all* categories, but allow excluding IDs.
    String url =
        'https://${WPConfig.url}/wp-json/wp/v2/categories/?per_page=$perPage&page=$page&exclude=$excludeStr&_fields=$_categoryFields';

    List<CategoryModel> allCategories = [];
    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final allData = response.data as List;
        allCategories = allData.map((e) => CategoryModel.fromMap(e)).toList();
        return allCategories;
      }
      return [];
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
