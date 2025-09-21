import 'package:flutter/material.dart';
import 'package:news_pro/core/utils/extensions.dart';

import '../constants/constants.dart';

class BottomSheetTopHandler extends StatelessWidget {
  const BottomSheetTopHandler({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.margin / 2),
      width: MediaQuery.of(context).size.width * 0.3,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.placeholder.withOpacityValue(0.3),
      ),
    );
  }
}
