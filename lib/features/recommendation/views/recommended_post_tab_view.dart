import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:news_pro/core/components/list_view_responsive.dart';

import '../../../../core/components/components.dart';
import '../../../../core/constants/constants.dart';
import '../../home/providers/scroll_controller_provider.dart';
import '../../home/views/components/loading_posts_responsive.dart';
import '../providers/recommended_posts_provider.dart';

class RecommendedPostTabView extends ConsumerWidget {
  const RecommendedPostTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommended = ref.watch(recommendedPostsProvider);
    final recommendedController = ref.read(recommendedPostsProvider.notifier);
    final scrollState = ref.watch(scrollControllerProviderFamily(0));

    if (recommended.refershError) {
      return Center(
        child: Text(recommended.errorMessage),
      );
    } else if (recommended.initialLoaded == false) {
      return const LoadingPostsResponsive(isInSliver: false);
    } else if (recommended.posts.isEmpty) {
      return const RecommendedPostEmpty();
    } else {
      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: recommendedController.onRefresh,
            child: Scrollbar(
              controller: scrollState.controller,
              child: CustomScrollView(
                controller: scrollState.controller,
                slivers: [
                  AnimationLimiter(
                    child: SliverPadding(
                      padding: const EdgeInsets.only(
                        top: AppDefaults.padding,
                        left: AppDefaults.padding,
                        right: AppDefaults.padding,
                      ),
                      sliver: ResponsiveListView(
                        data: recommended.posts,
                        handleScrollWithIndex:
                            recommendedController.handleScrollWithIndex,
                        isMainPage: true,
                        isInSliver: true,
                      ),
                    ),
                  ),
                  if (recommended.isPaginationLoading)
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
                    .read(scrollControllerProviderFamily(0).notifier)
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

class RecommendedPostEmpty extends StatelessWidget {
  const RecommendedPostEmpty({
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
            'Keep exploring to find recommended posts',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
