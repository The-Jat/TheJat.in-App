import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/constants.dart';
import '../../../core/controllers/config/config_controllers.dart';
import '../../../core/models/config.dart';
import '../../view_on_web/view_on_web_page.dart';
import 'setting_list_tile.dart';

class AboutSettings extends ConsumerWidget {
  const AboutSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDefaults.margin),
          child: Text(
            'about'.tr(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        SettingTile(
          label: 'terms_conditions',
          icon: IconlyLight.paper,
          iconColor: Colors.pink,
          trailing: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(IconlyLight.arrowRight2),
          ),
          onTap: () {
            final theURL = config?.termsAndServicesUrl ?? '';
            if (theURL.isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ViewOnWebPage(
                            title: 'terms_conditions'.tr(),
                            url: theURL,
                          )));
            } else {
              Fluttertoast.showToast(
                  msg: 'no_terms_provided'.tr());
            }
          },
        ),
        SettingTile(
          label: 'about',
          icon: IconlyLight.paper,
          iconColor: Colors.blueGrey,
          trailing: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(IconlyLight.arrowRight2),
          ),
          onTap: () {
            final theURL = config?.aboutPageUrl ?? '';

            if (theURL.isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ViewOnWebPage(
                            title: 'about'.tr(),
                            url: theURL,
                          )));
            } else {
              Fluttertoast.showToast(msg: 'no_about_provided'.tr());
            }
          },
        ),
        SettingTile(
          label: 'privacy_policy',
          icon: IconlyLight.lock,
          iconColor: Colors.green,
          trailing: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(IconlyLight.arrowRight2),
          ),
          onTap: () {
            final privacyPolicy = config?.privacyPolicyUrl ?? '';
            if (privacyPolicy.isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ViewOnWebPage(
                            title: 'privacy_policy'.tr(),
                            url: privacyPolicy,
                          )));
            } else {
              Fluttertoast.showToast(msg: 'no_privacy_provided'.tr());
            }
          },
        ),
        RatingTile(config: config),
        if (config!.appShareLink.isNotEmpty)
          SettingTile(
            label: 'share_this_app',
            icon: IconlyLight.send,
            iconColor: Colors.purple,
            trailing: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(IconlyLight.arrowRight2),
            ),
            onTap: () async {
              await SharePlus.instance.share(ShareParams(
                text: '${'checkout_app'.tr()} ${config.appShareLink}',
              ));
            },
          ),
      ],
    );
  }
}

class RatingTile extends StatelessWidget {
  const RatingTile({
    super.key,
    required this.config,
  });

  final NewsProConfig? config;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return SettingTile(
        label: 'rate_this_app',
        icon: IconlyLight.star,
        iconColor: Colors.blueAccent,
        trailing: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(IconlyLight.arrowRight2),
        ),
        onTap: () {
          final appstoreID = config?.appstoreAppID ?? '';
          try {
            InAppReview.instance.openStoreListing(appStoreId: appstoreID);
          } on Exception {
            Fluttertoast.showToast(msg: 'failed_open_store'.tr());
          }
        },
      );
    } else if (Platform.isIOS && config?.appstoreAppID != '') {
      return SettingTile(
        label: 'rate_this_app',
        icon: IconlyLight.star,
        iconColor: Colors.blueAccent,
        trailing: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(IconlyLight.arrowRight2),
        ),
        onTap: () {
          final appstoreID = config?.appstoreAppID ?? '';
          try {
            InAppReview.instance.openStoreListing(appStoreId: appstoreID);
          } on Exception {
            Fluttertoast.showToast(msg: 'failed_open_store'.tr());
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
