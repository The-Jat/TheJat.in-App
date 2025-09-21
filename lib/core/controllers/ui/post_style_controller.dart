import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/core/controllers/config/config_controllers.dart';

import '../../logger/app_logger.dart';
import '../../repositories/others/post_style_local.dart';

final postStyleControllerProvider =
    StateNotifierProvider<PostStyleController, PostDetailStyle>((ref) {
  final repository = ref.read(postStyleProvider);
  final config = ref.read(configProvider).value?.postDetailStyle;

  return PostStyleController(repository, config);
});

class PostStyleController extends StateNotifier<PostDetailStyle> {
  PostStyleController(this._repository, this.adminProvidedStyle)
      : super(adminProvidedStyle ?? PostDetailStyle.classic) {
    _loadSelectedStyle();
  }

  final PostStyleRepository _repository;
  final PostDetailStyle? adminProvidedStyle;

  void _loadSelectedStyle() {
    if (_repository.isUserHasNoStyle()) {
      Log.info('User has no style, using admin provided style');
      state = adminProvidedStyle ?? PostDetailStyle.classic;
    } else {
      state = _repository.getSelectedStyle();
    }
  }

  Future<void> changeStyle(PostDetailStyle newStyle) async {
    await _repository.saveSelectedStyle(newStyle);
    state = newStyle;
  }
}
