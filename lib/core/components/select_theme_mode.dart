import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/core/utils/extensions.dart';

import '../constants/constants.dart';
import '../themes/theme_manager.dart';

class SelectThemeMode extends ConsumerWidget {
  const SelectThemeMode({
    super.key,
    this.backgroundColor,
  });

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final controller = ref.read(themeModeProvider.notifier);

    return Container(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'select_theme'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDefaults.padding,
              ),
              // Add container with border to group theme options
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDefaults.radius),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacityValue(0.1),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _ThemeModeSelector(
                        backgroundColor: AppColors.primary,
                        icon: Icons.phone_android,
                        isActive: themeMode == AdaptiveThemeMode.system,
                        themeName: 'System',
                        onTap: () {
                          controller.changeThemeMode(
                              AdaptiveThemeMode.system, context);
                        },
                      ),
                    ),
                    AppSizedBox.w16,
                    Expanded(
                      child: _ThemeModeSelector(
                        backgroundColor: Colors.orangeAccent,
                        icon: Icons.light_mode_rounded,
                        isActive: themeMode == AdaptiveThemeMode.light,
                        themeName: 'Light',
                        onTap: () {
                          controller.changeThemeMode(
                              AdaptiveThemeMode.light, context);
                        },
                      ),
                    ),
                    AppSizedBox.w16,
                    Expanded(
                      child: _ThemeModeSelector(
                        backgroundColor: Colors.black87,
                        icon: Icons.dark_mode_rounded,
                        isActive: themeMode == AdaptiveThemeMode.dark,
                        themeName: 'Dark',
                        onTap: () {
                          controller.changeThemeMode(
                              AdaptiveThemeMode.dark, context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.isActive,
    required this.themeName,
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
  });
  final bool isActive;
  final String themeName;
  final Color backgroundColor;
  final IconData icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppDefaults.radius),
      elevation: isActive ? 2 : 0, // Add elevation for selected theme
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDefaults.radius),
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: const BoxDecoration(),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      themeName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: AnimatedOpacity(
                opacity: isActive ? 1 : 0,
                duration: AppDefaults.duration,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppDefaults.radius),
                      bottomLeft: Radius.circular(AppDefaults.radius),
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
