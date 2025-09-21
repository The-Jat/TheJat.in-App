import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_defaults.dart';
import '../controllers/internet/internet_state_provider.dart';
import 'skeleton.dart';

class NetworkImageWithLoader extends ConsumerWidget {
  final BoxFit fit;

  /// This widget is used for displaying network image with a placeholder
  /// Enhanced with offline support and better caching
  const NetworkImageWithLoader(
    this.src, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = AppDefaults.radius,
    this.borderRadius,
    this.placeHolder,
    this.offlinePlaceholder,
    this.cacheHeight,
    this.cacheWidth,
  });

  final String src;
  final double radius;
  final BorderRadius? borderRadius;
  final Widget? placeHolder;
  final Widget? offlinePlaceholder;
  final int? cacheHeight;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final internetState = ref.watch(connectivityProvider).internetState;
    final isOffline = internetState == InternetState.disconnected;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        fit: fit,
        imageUrl: src,
        memCacheHeight: cacheHeight,
        memCacheWidth: cacheWidth,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
        placeholder: (context, url) => placeHolder ?? const Skeleton(),
        errorWidget: (context, url, error) {
          // Show different error widgets based on internet state
          if (isOffline) {
            return _buildOfflinePlaceholder();
          } else {
            return _buildErrorPlaceholder();
          }
        },
        // Enhanced caching options
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        // Use cached image when available, even if offline
        useOldImageOnUrlChange: true,
      ),
    );
  }

  Widget _buildOfflinePlaceholder() {
    if (offlinePlaceholder != null) {
      return offlinePlaceholder!;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(radius)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 30,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'Offline',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(radius)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 30,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'Image unavailable',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
