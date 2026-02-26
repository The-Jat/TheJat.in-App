import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScrollState {
  final ScrollController controller;
  final bool showBackToTopButton;

  ScrollState(this.controller, this.showBackToTopButton);
}

class ScrollControllerNotifier extends StateNotifier<ScrollState> {
  ScrollControllerNotifier() : super(ScrollState(ScrollController(), false)) {
    state.controller.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (state.controller.offset > 6 * 100 && !state.showBackToTopButton) {
      state = ScrollState(state.controller, true);
    } else if (state.controller.offset <= 6 * 100 &&
        state.showBackToTopButton) {
      state = ScrollState(state.controller, false);
    }
  }

  void scrollToTop() {
    state.controller.animateTo(
      0,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    state.controller.removeListener(_scrollListener);
    state.controller.dispose();
    super.dispose();
  }
}

final scrollControllerProviderFamily =
    StateNotifierProviderFamily<ScrollControllerNotifier, ScrollState, int>(
        (ref, id) {
  return ScrollControllerNotifier();
});
