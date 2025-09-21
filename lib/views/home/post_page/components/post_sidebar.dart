import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/core/utils/extensions.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/controllers/config/config_controllers.dart';
import '../../../../core/controllers/html/font_size_controller.dart';
import '../../../../core/controllers/ui/post_style_controller.dart';
import '../../../../core/repositories/others/post_style_local.dart';
import '../../../../core/themes/theme_manager.dart';

class PostSidebar extends ConsumerWidget {
  const PostSidebar({
    super.key,
    required this.link,
    required this.title,
  });

  final String link;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontsize = ref.watch(fontSizeProvider.notifier);
    final isdark = ref.watch(isDarkMode(context));
    final themeController = ref.read(themeModeProvider.notifier);
    final currentStyle = ref.watch(postStyleControllerProvider);
    final styleController = ref.read(postStyleControllerProvider.notifier);
    final hidePageStyle =
        ref.watch(configProvider).value?.hidePageStyle ?? false;

    return Positioned.directional(
      textDirection: Directionality.of(context),
      top: MediaQuery.sizeOf(context).height / 2.5,
      end: 0,
      child: Container(
        decoration: BoxDecoration(
          color:
              Theme.of(context).scaffoldBackgroundColor.withOpacityValue(0.5),
          border: Border.all(color: AppColors.placeholder, width: 0.3),
          boxShadow: AppDefaults.boxShadow,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppDefaults.radius),
            bottomStart: Radius.circular(AppDefaults.radius),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppDefaults.radius),
            bottomStart: Radius.circular(AppDefaults.radius),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    fontsize.increaseSize();
                  },
                  icon: const Icon(
                    Icons.text_increase_outlined,
                  ),
                  style: IconButton.styleFrom(padding: EdgeInsets.zero),
                  iconSize: 16,
                ),
                IconButton(
                  onPressed: () {
                    fontsize.decreaseSize();
                  },
                  icon: const Icon(
                    Icons.text_decrease_outlined,
                  ),
                  style: IconButton.styleFrom(padding: EdgeInsets.zero),
                  iconSize: 16,
                ),
                IconButton(
                  onPressed: () {
                    themeController.changeThemeMode(
                        isdark
                            ? AdaptiveThemeMode.light
                            : AdaptiveThemeMode.dark,
                        context);
                  },
                  icon: Icon(
                    isdark ? Icons.light_mode : Icons.dark_mode,
                  ),
                  style: IconButton.styleFrom(padding: EdgeInsets.zero),
                  iconSize: 16,
                ),
                if (!hidePageStyle)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color:
                          _getStyleColor(currentStyle).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            _getStyleColor(currentStyle).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _cyclePostStyle(styleController, currentStyle);
                      },
                      icon: Icon(
                        _getStyleIcon(currentStyle),
                        color: _getStyleColor(currentStyle),
                      ),
                      style: IconButton.styleFrom(padding: EdgeInsets.zero),
                      iconSize: 16,
                      tooltip:
                          '${'reading_style'.tr()}: ${_getStyleName(currentStyle)}\n${'tap_to_change'.tr()}',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to cycle through post styles
  void _cyclePostStyle(
      PostStyleController controller, PostDetailStyle currentStyle) {
    final styles = PostDetailStyle.values;
    final currentIndex = styles.indexOf(currentStyle);
    final nextIndex = (currentIndex + 1) % styles.length;
    controller.changeStyle(styles[nextIndex]);
  }

  // Get icon for each post style
  IconData _getStyleIcon(PostDetailStyle style) {
    switch (style) {
      case PostDetailStyle.classic:
        return IconlyLight.document;
      case PostDetailStyle.magazine:
        return IconlyLight.paper;
      case PostDetailStyle.minimal:
        return IconlyLight.editSquare;
      case PostDetailStyle.card:
        return IconlyLight.category;
      case PostDetailStyle.story:
        return IconlyLight.image;
    }
  }

  // Get name for each post style
  String _getStyleName(PostDetailStyle style) {
    switch (style) {
      case PostDetailStyle.classic:
        return 'classic'.tr();
      case PostDetailStyle.magazine:
        return 'magazine'.tr();
      case PostDetailStyle.minimal:
        return 'minimal'.tr();
      case PostDetailStyle.card:
        return 'card'.tr();
      case PostDetailStyle.story:
        return 'story'.tr();
    }
  }

  // Get color for each post style
  Color _getStyleColor(PostDetailStyle style) {
    switch (style) {
      case PostDetailStyle.classic:
        return Colors.blue;
      case PostDetailStyle.magazine:
        return Colors.orange;
      case PostDetailStyle.minimal:
        return Colors.green;
      case PostDetailStyle.card:
        return Colors.purple;
      case PostDetailStyle.story:
        return Colors.red;
    }
  }
}
