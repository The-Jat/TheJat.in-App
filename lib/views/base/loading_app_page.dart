import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/core/controllers/internet/internet_state_provider.dart';
import '../../core/app/initialization_provider.dart';
import '../../core/logger/app_logger.dart';

import '../../core/controllers/config/config_controllers.dart';
import '../../core/models/config.dart';
import '../../core/repositories/posts/offline_post_repository.dart';
import '../auth/login_intro_page.dart';
import '../offline/offline_posts_page.dart';
import '../onboarding/onboarding_page.dart';
import 'components/loading_dependency.dart';
import 'configuration_error_page.dart';
import 'core_error_page.dart';
import 'base_page.dart';

class LoadingAppPage extends ConsumerWidget {
  const LoadingAppPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final internetAvailable = ref.watch(connectivityProvider);
    ref.read(offlinePostRepoProvider).init();

    Log.info('Internet state: ${internetAvailable.internetState}');

    // Don't show any UI until internet state is determined
    if (internetAvailable.internetState == InternetState.loading) {
      return const LoadingDependencies();
    } else if (internetAvailable.internetState == InternetState.disconnected) {
      return const OfflinePostsPage();
    } else if (internetAvailable.internetState == InternetState.connected) {
      // Only initialize config when we have internet connectivity
      final configNotifier = ref.read(configProvider.notifier);
      final config = ref.watch(configProvider);

      // Initialize config only if it's still loading (first time)
      if (config.isLoading) {
        configNotifier.init();
      }

      return config.map(
        data: (data) {
          // Initialize the app when config is loaded
          _initializeApp(ref, data.value, context);

          // Watch the app state
          final appState = ref.watch(appStateProvider);

          return appState.when(
            data: (state) => _buildAppStateUI(state, data.value),
            loading: () => const LoadingDependencies(),
            error: (error, _) {
              Log.fatal(error: error, stackTrace: StackTrace.current);
              return const CoreErrorPage();
            },
          );
        },
        error: (t) => const ConfigErrorPage(),
        loading: (t) => const LoadingDependencies(),
      );
    } else {
      // Handle error state
      return const CoreErrorPage(errorMessage: 'Connection error');
    }
  }

  void _initializeApp(
      WidgetRef ref, NewsProConfig config, BuildContext context) {
    // Start the initialization process
    ref.read(appInitializationProvider.notifier).initialize(
          InitializationArgument(
            config: config,
            context: context,
          ),
        );
  }

  Widget _buildAppStateUI(AppState state, NewsProConfig config) {
    switch (state) {
      case AppState.introNotDone:
        return const OnboardingPage();
      case AppState.consentNotDone:
        if (config.isLoginEnabled) {
          return const LoginIntroPage();
        } else {
          return const EntryPointUI();
        }
      case AppState.loggedIn:
        return const EntryPointUI();
      case AppState.loggedOut:
        return const EntryPointUI();
      case AppState.initializing:
        return const LoadingDependencies();
    }
  }
}
