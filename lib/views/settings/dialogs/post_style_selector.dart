import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/controllers/ui/post_style_controller.dart';
import '../../../core/repositories/others/post_style_local.dart';

class PostStyleSelectorDialog extends ConsumerWidget {
  const PostStyleSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.watch(postStyleControllerProvider);
    final controller = ref.read(postStyleControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                IconlyLight.document,
                color: AppColors.primary,
              ),
              AppSizedBox.w8,
              Text(
                'post_reading_style'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSizedBox.h8,
          Text(
            'choose_reading_style'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          AppSizedBox.h24,
          
          // Style options
          ...PostDetailStyle.values.map((style) {
            return _StyleOption(
              style: style,
              isSelected: currentStyle == style,
              onTap: () async {
                await controller.changeStyle(style);
                Navigator.pop(context);
              },
            );
          }),
          
          AppSizedBox.h16,
          
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  const _StyleOption({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });
  
  final PostDetailStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDefaults.borderRadius,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary 
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: AppDefaults.borderRadius,
            color: isSelected 
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              // Style preview icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStyleColor(style).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStyleIcon(style),
                  color: _getStyleColor(style),
                  size: 20,
                ),
              ),
              AppSizedBox.w12,
              
              // Style info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStyleName(style),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSizedBox.h4,
                    Text(
                      _getStyleDescription(style),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey.withValues(alpha: 0.5),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

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

  String _getStyleDescription(PostDetailStyle style) {
    switch (style) {
      case PostDetailStyle.classic:
        return 'classic_desc'.tr();
      case PostDetailStyle.magazine:
        return 'magazine_desc'.tr();
      case PostDetailStyle.minimal:
        return 'minimal_desc'.tr();
      case PostDetailStyle.card:
        return 'card_desc'.tr();
      case PostDetailStyle.story:
        return 'story_desc'.tr();
    }
  }
}
