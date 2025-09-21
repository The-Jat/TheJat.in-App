import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/article.dart';
import '../../../view_on_web/view_on_web_page.dart';

class ViewOnWebsite extends StatelessWidget {
  const ViewOnWebsite({
    super.key,
    required this.article,
  });

  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewOnWebPage(
              title: article.title,
              url: article.link,
            ),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ),
        side: const BorderSide(color: AppColors.primary),
      ),
      label: Text('view_on_website'.tr()),
      icon: const Icon(Icons.language),
    );
  }
}
