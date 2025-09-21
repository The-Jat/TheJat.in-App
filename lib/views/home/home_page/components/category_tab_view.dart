import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/components/components.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/controllers/posts/categories_post_controller.dart';
import '../../../../core/controllers/ui/scroll_controller_provider.dart';
import '../../../../core/models/article.dart';
import 'loading_posts_responsive.dart';

class CategoryTabView extends ConsumerWidget {
  const CategoryTabView({
    super.key,
    required this.arguments,
  });

  final CategoryPostsArguments arguments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsProvider = ref.watch(categoryPostController(arguments));
    final controller = ref.watch(categoryPostController(arguments).notifier);
    final scrollState =
        ref.watch(scrollControllerProviderFamily(arguments.categoryId));

    if (postsProvider.refershError) {
      return Center(
        child: Text(postsProvider.errorMessage),
      );

      /// on Initial State it will be empty
    } else if (postsProvider.initialLoaded == false) {
      return const LoadingPostsResponsive(isInSliver: false);
    } else if (postsProvider.posts.isEmpty) {
      return const CategoiesPostEmpty();
    } else {
      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: controller.onRefresh,
            child: Scrollbar(
              controller: scrollState.controller,
              child: CustomScrollView(
                controller: scrollState.controller,
                slivers: [
                  CategoryPostListView(
                    data: postsProvider.posts,
                    handlePagination: controller.handleScrollWithIndex,
                    onRefresh: controller.onRefresh,
                  ),
                  if (postsProvider.isPaginationLoading)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(),
                    )
                ],
              ),
            ),
          ),
          if (scrollState.showBackToTopButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () => ref
                    .read(scrollControllerProviderFamily(arguments.categoryId)
                        .notifier)
                    .scrollToTop(),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.arrow_upward),
              ),
            ),
        ],
      );
    }
  }
}

class CategoryPostListView extends StatelessWidget {
  const CategoryPostListView({
    super.key,
    required this.data,
    required this.handlePagination,
    required this.onRefresh,
  });

  final List<ArticleModel> data;
  final void Function(int) handlePagination;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: SliverPadding(
        padding: const EdgeInsets.only(
          top: AppDefaults.padding,
          left: AppDefaults.padding,
          right: AppDefaults.padding,
        ),
        sliver: ResponsiveListView(
          data: data,
          handleScrollWithIndex: handlePagination,
          isMainPage: true,
        ),
      ),
    );
  }
}

class CategoiesPostEmpty extends StatelessWidget {
  const CategoiesPostEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: SvgPicture.asset(
              AppImages.emptyPost,
              height: 250,
              width: 250,
            ),
          ),
          AppSizedBox.h16,
          Text(
            'Ooh! It\'s empty here',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSizedBox.h10,
          Text(
            'You can explore other categories as well',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
