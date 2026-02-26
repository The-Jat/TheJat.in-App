import 'package:flutter/foundation.dart';

import '../data/models/post_tag.dart';

class TagPagination {
  List<PostTag> items;
  int page;
  String errorMessage;
  bool initialLoaded;
  bool isPaginationLoading;
  bool hasReachedMax;
  TagPagination({
    required this.items,
    required this.page,
    required this.errorMessage,
    required this.initialLoaded,
    required this.isPaginationLoading,
    required this.hasReachedMax,
  });

  TagPagination.initial()
      : items = [],
        page = 1,
        errorMessage = '',
        initialLoaded = false,
        isPaginationLoading = false,
        hasReachedMax = false;

  bool get refershError => errorMessage != '' && items.length <= 10;

  TagPagination copyWith({
    List<PostTag>? items,
    int? page,
    String? errorMessage,
    bool? initialLoaded,
    bool? isPaginationLoading,
    bool? hasReachedMax,
  }) {
    return TagPagination(
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

    return other is TagPagination &&
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
