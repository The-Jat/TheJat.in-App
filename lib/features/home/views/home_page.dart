import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/features/auth/providers/auth_state.dart';

import '../../../core/components/animated_page_switcher.dart';
import '../../../core/components/internet_wrapper.dart';
import '../../auth/providers/auth_controller.dart';
import '../../categories/data/models/category.dart';
import '../../categories/providers/categories_controller.dart';
import '../../config/providers/config_providers.dart';
import '../../notification/data/providers/notification_toggle.dart';
import '../../posts/providers/categories_post_controller.dart';
import '../../posts/providers/popular_posts_controller.dart';
import '../../recommendation/views/recommended_post_tab_view.dart';
import 'components/category_tab_view.dart';
import 'components/home_app_bar.dart';
import 'components/loading_feature_post.dart';
import 'components/loading_home_page.dart';
import 'components/trending_tab.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  List<CategoryModel> _feturedCategories = [];

  bool _isLoading = true;
  updateUI() {
    if (mounted) setState(() {});
  }

  /// Set Categories and update the UI
  _setCategories() async {
    _isLoading = true;
    updateUI();
    try {
      _feturedCategories =
          await ref.read(categoriesController.notifier).getFeaturedCategories();
      _tabController =
          TabController(length: _feturedCategories.length, vsync: this);
    } on Exception {
      _tabController = TabController(length: 1, vsync: this);
    }
    _isLoading = false;
    updateUI();
  }

  requestNotificationPermission() async {
    ref.read(notificationStateProvider(context));
  }

  /// Tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _setCategories();
    ref.read(authController);
    requestNotificationPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final popularPosts = ref.watch(popularPostsController);
    final showLogo =
        ref.watch(configProvider).value?.showTopLogoInHome ?? false;
    final isLoggedIn = ref.watch(authController) is AuthLoggedIn;
    if (_isLoading) {
      return LoadingHomePage(showLogoInHome: showLogo);
    } else {
      return InternetWrapper(
        loadingWidget: LoadingHomePage(showLogoInHome: showLogo),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            HomeAppBarWithTab(
              categories: _feturedCategories,
              tabController: _tabController,
              forceElevated: innerBoxIsScrolled,
              showLogoInHome: showLogo,
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: List.generate(
              _feturedCategories.length,
              (index) {
                if (index == 0) {
                  return TransitionWidget(
                    child: popularPosts.map(
                      data: ((data) => TrendingTabSection(
                            posts: data.value,
                          )),
                      error: (t) => Text(t.toString()),
                      loading: (t) => const LoadingFeaturePost(),
                    ),
                  );
                } else if (index == 1 && isLoggedIn) {
                  return Container(
                    color: Theme.of(context).cardColor,
                    child: RecommendedPostTabView(),
                  );
                } else {
                  return Container(
                    color: Theme.of(context).cardColor,
                    child: CategoryTabView(
                      arguments: CategoryPostsArguments(
                        categoryId: _feturedCategories[index].id,
                        isHome: true,
                      ),
                      key: ValueKey(_feturedCategories[index].slug),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
