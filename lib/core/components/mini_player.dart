import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_pod_player/last_pod_player.dart';

import '../constants/constants.dart';
import '../controllers/video/now_playing_state.dart';
import '../controllers/video/video_controller.dart';
import '../models/article.dart';
import '../routes/app_routes.dart';
import '../utils/responsive.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({
    super.key,
    this.articleModel,
    required this.isOnStack,
  });

  final ArticleModel? articleModel;
  final bool isOnStack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(playerProvider);
    final notifier = ref.watch(playerProvider.notifier);
    notifier.hideOverlay();

    if (!controller.initialLoaded) {
      return const SizedBox.shrink();
    } else if (articleModel == controller.article) {
      return const SizedBox.shrink();
    } else {
      if (isOnStack) {
        return Positioned(
          bottom: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniPlay(
                  articleModel: articleModel,
                  controller: controller,
                  notifier: notifier,
                ),
              ],
            ),
          ),
        );
      } else {
        return _MiniPlay(
          articleModel: articleModel,
          controller: controller,
          notifier: notifier,
        );
      }
    }
  }
}

class _MiniPlay extends StatelessWidget {
  const _MiniPlay({
    required this.articleModel,
    required this.controller,
    required this.notifier,
  });

  final ArticleModel? articleModel;
  final NowPlayingState controller;
  final PlayerState notifier;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (articleModel != controller.article) {
          Navigator.pushNamed(
            context,
            AppRoutes.post,
            arguments: controller.article,
          );
        }
      },
      child: Responsive(
        mobile: _MobilePlayer(
          controller: controller,
          notifier: notifier,
        ),
        tablet: _TabPlayer(
          controller: controller,
          notifier: notifier,
        ),
      ),
    );
  }
}

class _MobilePlayer extends StatelessWidget {
  const _MobilePlayer({
    required this.controller,
    required this.notifier,
  });

  final NowPlayingState controller;
  final PlayerState notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: AppDefaults.boxShadow,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: controller.podController != null
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: PodVideoPlayer(
                      controller: controller.podController!,
                      videoAspectRatio: 16 / 9,
                      podProgressBarConfig: const PodProgressBarConfig(
                        playingBarColor: Colors.blue,
                        circleHandlerColor: Colors.blue,
                        alwaysVisibleCircleHandler: false,
                      ),
                      matchFrameAspectRatioToVideo: true,
                      matchVideoAspectRatioToFrame: true,
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                controller.article?.title ?? '',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: notifier.togglePlayPause,
                  icon: controller.isPlayingNow
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  onPressed: notifier.disposePlayer,
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPlayer extends StatelessWidget {
  const _TabPlayer({
    required this.controller,
    required this.notifier,
  });

  final NowPlayingState controller;
  final PlayerState notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: AppDefaults.boxShadow,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: controller.podController != null
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: PodVideoPlayer(
                      controller: controller.podController!,
                      videoAspectRatio: 16 / 9,
                      podProgressBarConfig: const PodProgressBarConfig(
                        playingBarColor: Colors.blue,
                        circleHandlerColor: Colors.blue,
                        alwaysVisibleCircleHandler: false,
                      ),
                      matchFrameAspectRatioToVideo: true,
                      matchVideoAspectRatioToFrame: true,
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                controller.article?.title ?? '',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: notifier.togglePlayPause,
                  icon: controller.isPlayingNow
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  onPressed: notifier.disposePlayer,
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
