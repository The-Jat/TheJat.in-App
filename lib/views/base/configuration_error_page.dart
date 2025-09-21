import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

import '../../config/wp_config.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/app_utils.dart';

class ConfigErrorPage extends StatelessWidget {
  const ConfigErrorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                'no_config_found'.tr(),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              AppSizedBox.h16,
              Text(
                'https://${WPConfig.url}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                    ),
                textAlign: TextAlign.center,
              ),
              AppSizedBox.h16,
              Text(
                'config_required_message'.tr(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              AppSizedBox.h5,
              Text(
                'contact_author_message'.tr(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              AppSizedBox.h16,
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(IconlyLight.document),
                label: Text('newspro_v3_documentation'.tr()),
              ),
              AppSizedBox.h16,
              OutlinedButton.icon(
                onPressed: () =>
                    AppUtils.openLink('https://wa.me/+8801581721600'),
                icon: const Icon(FontAwesomeIcons.whatsapp),
                label: Text('contact_author'.tr()),
              ),
              AppSizedBox.h16,
              Text(
                'contact_via_email'.tr(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () {
                  AppUtils.sendEmail(
                    email: 'mdmomin322@gmail.com',
                    content:
                        'config_error_email_content'.tr(),
                    subject: 'config_error_subject'.tr(),
                  );
                },
                child: const Text('mdmomin322@gmail.com'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
