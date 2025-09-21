import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:news_pro/core/components/mini_player.dart';

import '../../config/wp_config.dart';
import '../../core/components/app_logo.dart';
import '../../core/constants/constants.dart';
import '../../core/controllers/config/config_controllers.dart';
import '../../core/utils/app_utils.dart';

class ContactPage extends ConsumerWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value;
    final description = config?.appDescription ?? '';
    final email = config?.ownerEmail ?? 'no_email_provided'.tr();
    final name = config?.ownerName ?? 'no_name_provided'.tr();
    final phone = config?.ownerPhone ?? 'no_phone_provided'.tr();
    final address = config?.ownerAddress ?? 'no_address_provided'.tr();

    void copyData(String data) async {
      await Clipboard.setData(ClipboardData(text: data));
      Fluttertoast.showToast(msg: 'copied'.tr());
    }

    return Scaffold(
      appBar: AppBar(title: Text('contact_us'.tr())),
      body: Column(
        children: [
          const Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 100,
              width: 100,
              child: AppLogo(),
            ),
          ),
          AppSizedBox.h10,
          Text(
            WPConfig.appName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppDefaults.margin),
              child: Text(description),
            ),
          const Divider(),
          ListTile(
            title: Text('name'.tr()),
            subtitle: Text(name),
            leading: const Icon(Icons.person),
            onLongPress: () => copyData(name),
          ),
          const Divider(),
          ListTile(
            title: Text('email'.tr()),
            subtitle: Text(email),
            leading: const Icon(Icons.email),
            onLongPress: () => copyData(email),
            trailing: IconButton(
              onPressed: () {
                AppUtils.sendEmail(
                  email: email,
                  content: 'write_something_here'.tr(),
                  subject: 'newspro_subject'.tr(),
                );
              },
              icon: const Icon(Icons.send_outlined),
            ),
          ),
          if (phone.isNotEmpty)
            ListTile(
              title: Text('phone'.tr()),
              subtitle: Text(phone),
              leading: const Icon(Icons.phone),
              onLongPress: () => copyData(phone),
              trailing: IconButton(
                onPressed: () => copyData(phone),
                icon: const Icon(Icons.copy),
              ),
            ),
          if (address.isNotEmpty)
            ListTile(
              title: Text('address'.tr()),
              subtitle: Text(address),
              leading: const Icon(Icons.gps_fixed_rounded),
              onLongPress: () => copyData(address),
            ),
          const Divider(),
          const Spacer(),
          const MiniPlayer(isOnStack: false),
        ],
      ),
    );
  }
}
