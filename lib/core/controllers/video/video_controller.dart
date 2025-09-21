import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_pod_player/last_pod_player.dart';

import '../../models/article.dart';
import 'now_playing_state.dart';

class PlayerState extends StateNotifier<NowPlayingState> {
  PlayerState() : super(NowPlayingState.initial());

  Future<void> initializePlayer(
      String url, ArticleModel articleModel, bool isYoutube, bool live) async {
    if (state.podController != null) {
      if (state.article == articleModel) {
        return;
      }
      changeVideo(url, articleModel, isYoutube, live);
    } else {
      _initializeNewPlayer(url, articleModel, isYoutube, live);
    }
  }

  Future<void> _initializeNewPlayer(
      String url, ArticleModel articleModel, bool isYoutube, bool live) async {
    state = NowPlayingState.loading();

    final PodPlayerController controller = isYoutube
        ? PodPlayerController(
            playVideoFrom: PlayVideoFrom.youtube(url),
            podPlayerConfig: const PodPlayerConfig(
              isLooping: false,
            ),
          )
        : PodPlayerController(
            playVideoFrom: PlayVideoFrom.network(url),
            podPlayerConfig: const PodPlayerConfig(
              isLooping: false,
            ),
          );

    await controller.initialise();

    state = NowPlayingState.play(
      data: articleModel,
      controller: controller,
      initialUrl: url,
    );

    await play();
  }

  Future<void> changeVideo(
      String url, ArticleModel articleModel, bool isYoutube, bool live) async {
    if (isYoutube) {
      state = state.copyWith(
          article: articleModel,
          isPlayingNow: true,
          initialUrl: url,
          isLoading: true);
      await state.podController
          ?.changeVideo(playVideoFrom: PlayVideoFrom.youtube(url));
      state = state.copyWith(isLoading: false);
    } else {
      state = state.copyWith(
          article: articleModel,
          isPlayingNow: true,
          initialUrl: url,
          isLoading: true);
      await state.podController
          ?.changeVideo(playVideoFrom: PlayVideoFrom.network(url));
      state = state.copyWith(isLoading: false);
    }
  }

  void disposePlayer() {
    state.podController?.dispose();
    state = NowPlayingState.initial();
  }

  Future<void> play() async {
    if (!state.isPlayingNow) {
      state.podController?.play();
      state.podController?.hideOverlay();
      state = state.copyWith(isPlayingNow: true);
    }
  }

  Future<void> pause() async {
    if (state.isPlayingNow) {
      state.podController?.pause();
      state.podController?.hideOverlay();
      state = state.copyWith(isPlayingNow: false);
    }
  }

  void togglePlayPause() {
    if (state.isPlayingNow) {
      pause();
    } else {
      play();
    }
  }

  void hideOverlay() {
    if (state.podController != null) state.podController?.hideOverlay();
  }

  @override
  void dispose() {
    pause();
    state.podController?.dispose();
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider<PlayerState, NowPlayingState>(
  (ref) => PlayerState(),
);
