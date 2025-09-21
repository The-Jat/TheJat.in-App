import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:news_pro/core/controllers/internet/internet_state_provider.dart';

import '../../../../core/constants/constants.dart';

class InternetNotAvailablePage extends StatelessWidget {
  const InternetNotAvailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'no_internet_available'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.5,
              child:
                  Lottie.asset('assets/animations/no_internet_animation.json'),
            ),
            const SizedBox(height: AppDefaults.margin),
            Text(
              'no_internet_message'.tr(),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'enable_internet_message'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDefaults.margin),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi);
                  },
                  child: Text('open_settings'.tr()),
                ),
              ),
            ),
            AppSizedBox.h10,
            const ReconnectingWidget(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class ReconnectingWidget extends ConsumerWidget {
  const ReconnectingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconnnecting = ref.watch(connectivityProvider).reconnectingState;
    return Container(
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          AppSizedBox.w16,
          Text('${'reconnecting_in'.tr()} ${reconnnecting.secondsRemaining} ${'seconds'.tr()}'),
        ],
      ),
    );
  }
}
