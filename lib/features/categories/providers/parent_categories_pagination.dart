import 'package:flutter/foundation.dart';

import '../data/models/category.dart';

class CategoryPagination {
  List<CategoryModel> items;
  int page;
  String errorMessage;
  bool initialLoaded;
  bool isPaginationLoading;
  bool hasReachedMax;
  CategoryPagination({
    required this.items,
    required this.page,
    required this.errorMessage,
    required this.initialLoaded,
    required this.isPaginationLoading,
    required this.hasReachedMax,
  });

  CategoryPagination.initial()
      : items = [],
        page = 1,
        errorMessage = '',
        initialLoaded = false,
        isPaginationLoading = false,
        hasReachedMax = false;

  bool get refershError => errorMessage != '' && items.length <= 10;

  CategoryPagination copyWith({
    List<CategoryModel>? items,
    int? page,
    String? errorMessage,
    bool? initialLoaded,
    bool? isPaginationLoading,
    bool? hasReachedMax,
  }) {
    return CategoryPagination(
      items: items ?? this.items,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
      initialLoaded: initialLoaded ?? this.initialLoaded,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryPagination &&
        listEquals(other.items, items) &&
        other.page == page &&
        other.errorMessage == errorMessage &&
        other.initialLoaded == initialLoaded &&
        other.isPaginationLoading == isPaginationLoading;
  }

  @override
  int get hashCode =>
      items.hashCode ^
      page.hashCode ^
      errorMessage.hashCode ^
      isPaginationLoading.hashCode ^
      initialLoaded.hashCode;
}
