import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

import '../../config/wp_config.dart';
import '../../core/constants/constants.dart';
import '../../core/controllers/config/config_controllers.dart';
import '../../core/utils/app_utils.dart';

class CoreErrorPage extends ConsumerWidget {
  const CoreErrorPage({
    super.key,
    this.errorMessage,
  });

  final String? errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportEmail = ref.watch(configProvider).value?.reportEmail;
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.5,
                child: Lottie.asset(
                    'assets/animations/no_internet_animation.json'),
              ),
              const SizedBox(height: AppDefaults.margin),
              Text(
                errorMessage == null
                    ? 'something_gone_wrong'.tr()
                    : errorMessage!,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              AppSizedBox.h16,
              Text(
                'contact_administrator'.tr(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              AppSizedBox.h16,
              OutlinedButton.icon(
                onPressed: () {
                  if (supportEmail == null) {
                    Fluttertoast.showToast(
                        msg: 'support_email_unavailable'.tr());
                  } else {
                    AppUtils.sendEmail(
                      email: supportEmail,
                      content: 'app_crashed_content'.tr(),
                      subject: '${WPConfig.appName} ${'crashed_subject'.tr()}',
                    );
                  }
                },
                icon: const Icon(IconlyLight.send),
                label: Text('contact'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
