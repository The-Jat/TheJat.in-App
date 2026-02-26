import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';

import 'config/wp_config.dart';
import 'core/localization/app_locales.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/on_generate_route.dart';
import 'core/themes/theme_constants.dart';
import 'core/utils/app_utils.dart';
import 'core/utils/extensions.dart';
import 'features/notification/data/models/notification_model.dart';
import 'features/others/update_page.dart';
import 'features/posts/data/repository/post_style_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppUtils.setDisplayToHighRefreshRate();
  await EasyLocalization.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  // Initialize Hive storage
  Directory appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);
  Hive.registerAdapter(NotificationModelAdapter());
  await PostStyleRepository().init();
  runApp(
    UpdatePage(
      child: ProviderScope(
        child: EasyLocalization(
          supportedLocales: AppLocales.supportedLocales,
          path: 'assets/translations',
          startLocale: AppLocales.english,
          fallbackLocale: AppLocales.english,
          child: NewsProApp(savedThemeMode: savedThemeMode),
        ),
      ),
    ),
  );
}

class NewsProApp extends StatelessWidget {
  const NewsProApp({super.key, this.savedThemeMode});
  final AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => GlobalLoaderOverlay(
        overlayColor: Colors.grey.withOpacityValue(0.4),
        child: MaterialApp(
          title: WPConfig.appName,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: theme,
          darkTheme: darkTheme,
          onGenerateRoute: RouteGenerator.onGenerate,
          initialRoute: AppRoutes.initial,
          onUnknownRoute: (_) => RouteGenerator.errorRoute(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
