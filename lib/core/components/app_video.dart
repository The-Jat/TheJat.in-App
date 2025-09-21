import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_pod_player/pod_player.dart';

import '../constants/app_colors.dart';
import '../controllers/video/video_controller.dart';
import '../models/article.dart';
import 'app_loader.dart';
import 'network_image.dart';

class AppVideoHtmlRender extends ConsumerWidget {
  const AppVideoHtmlRender({
    super.key,
    required this.url,
    this.thumbnail,
    required this.aspectRatio,
    this.isVideoPage = false,
    required this.article,
    required this.isYoutube,
  });

  final String url;
  final String? thumbnail;
  final double aspectRatio;
  final bool isVideoPage;
  final ArticleModel article;
  final bool isYoutube;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    if (player.isLoading) {
      return _LoadingVideo(
        url: url,
        article: article,
        isYoutube: isYoutube,
        aspectRatio: aspectRatio,
        thumbnail: thumbnail,
      );
    } else if (player.article != null && player.article == article) {
      if (player.initialUrl == url) {
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: player.podController != null
              ? PodVideoPlayer(
                  controller: player.podController!,
                  matchFrameAspectRatioToVideo: true,
                  matchVideoAspectRatioToFrame: true,
                  videoAspectRatio: aspectRatio,
                )
              : const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
        );
      } else {
        return _VideoPlayingButDifferent(
          url: url,
          article: article,
          thumbnail: thumbnail,
          isYoutube: isYoutube,
        );
      }
    } else if (player.article == null) {
      return _NoVideoPlaying(
        url: url,
        article: article,
        isYoutube: isYoutube,
        aspectRatio: aspectRatio,
        thumbnail: thumbnail,
      );
    } else if (player.article != null && player.article != article) {
      return _VideoPlayingButDifferent(
        url: url,
        article: article,
        thumbnail: thumbnail,
        isYoutube: isYoutube,
      );
    } else {
      return const SizedBox();
    }
  }
}

class _VideoPlayingButDifferent extends ConsumerWidget {
  const _VideoPlayingButDifferent({
    required this.url,
    required this.article,
    required this.thumbnail,
    required this.isYoutube,
  });

  final String url;
  final ArticleModel article;
  final String? thumbnail;
  final bool isYoutube;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref
            .read(playerProvider.notifier)
            .changeVideo(url, article, isYoutube, false);
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            thumbnail == null
                ? const SizedBox.shrink()
                : NetworkImageWithLoader(
                    thumbnail!,
                    radius: 0,
                  ),
            Container(color: Colors.black38),
            const Icon(
              Icons.play_arrow,
              size: 60,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoVideoPlaying extends ConsumerWidget {
  const _NoVideoPlaying({
    required this.url,
    required this.article,
    required this.isYoutube,
    required this.aspectRatio,
    required this.thumbnail,
  });

  final String url;
  final ArticleModel article;
  final bool isYoutube;
  final double aspectRatio;
  final String? thumbnail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final state = ref.read(playerProvider);
        if (state.podController == null &&
            !state.isLoading &&
            !state.initialLoaded) {
          ref
              .read(playerProvider.notifier)
              .initializePlayer(url, article, isYoutube, false);
        }
      },
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            thumbnail == null
                ? const SizedBox.shrink()
                : NetworkImageWithLoader(
                    thumbnail!,
                    radius: 0,
                  ),
            Container(color: Colors.black38),
            const Icon(
              Icons.play_arrow,
              size: 60,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingVideo extends ConsumerWidget {
  const _LoadingVideo({
    required this.url,
    required this.article,
    required this.isYoutube,
    required this.aspectRatio,
    required this.thumbnail,
  });

  final String url;
  final ArticleModel article;
  final bool isYoutube;
  final double aspectRatio;
  final String? thumbnail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          thumbnail == null
              ? const SizedBox.shrink()
              : NetworkImageWithLoader(
                  thumbnail!,
                  radius: 0,
                ),
          Container(color: Colors.black38),
          const AppLoader(),
        ],
      ),
    );
  }
}
