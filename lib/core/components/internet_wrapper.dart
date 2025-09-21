import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../views/home/home_page/components/internet_not_available.dart';
import '../controllers/internet/internet_state_provider.dart';
import '../routes/unknown_page.dart';

class InternetWrapper extends ConsumerWidget {
  const InternetWrapper({
    super.key,
    required this.child,
    this.loadingWidget,
  });

  final Widget child;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final internetAvailable = ref.watch(connectivityProvider).internetState;
    switch (internetAvailable) {
      case InternetState.connected:
        return child;

      case InternetState.disconnected:
        return const InternetNotAvailablePage();

      case InternetState.loading:
        return loadingWidget ??
            const Center(
              child: CircularProgressIndicator(),
            );

      default:
        return const UnknownPage();
    }
  }
}
