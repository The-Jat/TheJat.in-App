import 'package:last_pod_player/last_pod_player.dart';
import '../../models/article.dart';

class NowPlayingState {
  final bool isLoading;
  final bool initialLoaded;
  final bool isPlayingNow;
  final ArticleModel? article;
  final PodPlayerController? podController;
  final String initialUrl;

  NowPlayingState({
    required this.isLoading,
    required this.initialLoaded,
    required this.isPlayingNow,
    this.article,
    this.podController,
    required this.initialUrl,
  });

  factory NowPlayingState.initial() {
    return NowPlayingState(
      isLoading: false,
      initialLoaded: false,
      isPlayingNow: false,
      article: null,
      podController: null,
      initialUrl: '',
    );
  }

  NowPlayingState copyWith({
    bool? isLoading,
    bool? initialLoaded,
    bool? isPlayingNow,
    ArticleModel? article,
    PodPlayerController? podController,
    String? initialUrl,
  }) {
    return NowPlayingState(
      isLoading: isLoading ?? this.isLoading,
      initialLoaded: initialLoaded ?? this.initialLoaded,
      isPlayingNow: isPlayingNow ?? this.isPlayingNow,
      article: article ?? this.article,
      podController: podController ?? this.podController,
      initialUrl: initialUrl ?? this.initialUrl,
    );
  }

  static NowPlayingState loading() {
    return NowPlayingState(
      isLoading: true,
      initialLoaded: false,
      isPlayingNow: false,
      article: null,
      podController: null,
      initialUrl: '',
    );
  }

  static NowPlayingState play({
    required ArticleModel data,
    required PodPlayerController controller,
    required String initialUrl,
  }) {
    return NowPlayingState(
      isLoading: false,
      initialLoaded: true,
      isPlayingNow: false,
      article: data,
      podController: controller,
      initialUrl: initialUrl,
    );
  }
}
