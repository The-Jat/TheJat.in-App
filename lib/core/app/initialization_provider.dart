import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../firebase_options.dart';
import '../controllers/applinks/app_links_controller.dart';
import '../controllers/auth/auth_controller.dart';
import '../controllers/auth/auth_state.dart';
import '../controllers/internet/internet_state_provider.dart';
import '../controllers/notifications/notification_handler.dart';
import '../controllers/notifications/notification_local.dart';
import '../localization/app_locales.dart';
import '../logger/app_logger.dart';
import '../models/config.dart';
import '../models/notification_model.dart';
import '../repositories/auth/auth_repository.dart';
import '../repositories/others/onboarding_local.dart';
import '../repositories/others/post_style_local.dart';
import '../repositories/others/search_local.dart';

// Enum to represent app state
enum AppState {
  introNotDone,
  consentNotDone,
  loggedIn,
  loggedOut,
  initializing,
}

// For storing initialization status
class InitializationState {
  final bool isCriticalInitComplete;
  final bool isLazyInitComplete;
  final AppState currentAppState;
  final Object? error;
  final StackTrace? stackTrace;

  const InitializationState({
    this.isCriticalInitComplete = false,
    this.isLazyInitComplete = false,
    this.currentAppState = AppState.initializing,
    this.error,
    this.stackTrace,
  });

  InitializationState copyWith({
    bool? isCriticalInitComplete,
    bool? isLazyInitComplete,
    AppState? currentAppState,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return InitializationState(
      isCriticalInitComplete:
          isCriticalInitComplete ?? this.isCriticalInitComplete,
      isLazyInitComplete: isLazyInitComplete ?? this.isLazyInitComplete,
      currentAppState: currentAppState ?? this.currentAppState,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

// Arguments needed for initialization
class InitializationArgument {
  final NewsProConfig config;
  final BuildContext context;

  InitializationArgument({
    required this.config,
    required this.context,
  });
}

// Main provider for tracking initialization state
final appInitializationProvider =
    StateNotifierProvider<AppInitializer, InitializationState>((ref) {
  return AppInitializer(ref);
});

// Provider to expose just the AppState for UI consumers
final appStateProvider = Provider<AsyncValue<AppState>>((ref) {
  final initState = ref.watch(appInitializationProvider);

  if (initState.error != null) {
    return AsyncValue.error(initState.error!, initState.stackTrace!);
  }

  if (!initState.isCriticalInitComplete) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(initState.currentAppState);
});

// The actual initializer that manages the initialization process
class AppInitializer extends StateNotifier<InitializationState> {
  final Ref ref;

  AppInitializer(this.ref) : super(const InitializationState());

  // Initialize with config and context when available
  Future<void> initialize(InitializationArgument arg) async {
    if (state.isCriticalInitComplete) return;

    try {
      await _performCriticalInitialization(arg);

      // Determine app state based on config and onboarding status
      final appState = await _determineAppState(arg.config);

      // Update state with critical init complete and app state
      state = state.copyWith(
        isCriticalInitComplete: true,
        currentAppState: appState,
      );

      // Start lazy initialization in the background
      _performLazyInitialization(arg).then((_) {
        state = state.copyWith(isLazyInitComplete: true);
      }).catchError((e, st) {
        Log.error('Lazy initialization error: $e');
        // We don't fail the app for lazy init errors
      });
    } catch (e, st) {
      Log.fatal(error: e, stackTrace: st);
      state = state.copyWith(
        error: e,
        stackTrace: st,
      );
    }
  }

  // Critical initialization - required before app can be shown
  Future<void> _performCriticalInitialization(
      InitializationArgument arg) async {
    Log.info('Starting critical initialization');

    // Open essential boxes
    await Hive.openBox('settingsBox');
    await Hive.openBox<NotificationModel>('notifications');

    // Initialize connectivity monitoring
    ref.read(connectivityProvider);

    // Initialize notifications
    await NotificationHandler.init(arg.context);

    // Initialize onboarding repository
    await OnboardingRepository().init();

    // Initialize post style repository
    await PostStyleRepository().init();

    // Initialize auth controller
    await ref.read(authController.notifier).init();

    Log.info('Critical initialization complete');
  }

  // Lazy initialization - can happen after app is shown
  Future<void> _performLazyInitialization(InitializationArgument arg) async {
    Log.info('Starting lazy initialization');

    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Initialize authentication
    await ref.read(authRepositoryProvider).init();

    // Initialize search repository
    await SearchLocalRepo().init();

    // Initialize local notifications
    ref.read(localNotificationProvider);

    // Set locale messages
    AppLocales.setLocaleMessages();

    // Initialize app links
    ref.read(applinkNotifierProvider(arg.context));

    Log.info('Lazy initialization complete');
  }

  Future<AppState> _determineAppState(NewsProConfig? config) async {
    Log.info('Determining app state');

    final onboarding = await OnboardingRepository().init();
    final onboardingEnabled = config?.onboardingEnabled ?? false;
    final isOnboardingDone = onboarding.isIntroDone();
    final isLoggedIn = ref.read(authController) is AuthLoggedIn;

    Log.info('Onboarding Enabled: $onboardingEnabled');
    Log.info('Onboarding Done: $isOnboardingDone');
    Log.info('Logged In: $isLoggedIn');

    if (onboardingEnabled && !isOnboardingDone) {
      return AppState.introNotDone;
    }

    // Onboarding is either disabled or completed, check auth state
    return isLoggedIn ? AppState.loggedIn : AppState.loggedOut;
  }
}
