import 'package:flutter/material.dart';
import 'package:news_pro/core/constants/app_defaults.dart';
import 'package:shimmer/shimmer.dart';

class PreferenceLoadingShimmer extends StatelessWidget {
  const PreferenceLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Section Title
            Container(
              width: 120,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: AppDefaults.padding),
            // Categories Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                8,
                (index) => Container(
                  width: 100,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDefaults.padding * 2),

            // Tags Section Title
            Container(
              width: 100,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: AppDefaults.padding),
            // Tags Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                6,
                (index) => Container(
                  width: 80,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDefaults.padding * 2),

            // Authors Section Title
            Container(
              width: 140,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: AppDefaults.padding),
            // Authors Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                5,
                (index) => Container(
                  width: 110,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
