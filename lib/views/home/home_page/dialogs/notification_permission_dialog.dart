import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/controllers/notifications/notification_toggle.dart';
import '../../../../core/utils/responsive.dart';

class NotificationPermissionDialouge extends ConsumerWidget {
  const NotificationPermissionDialouge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.width * 0.3,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppDefaults.borderRadius),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: SvgPicture.asset('assets/svgs/email_sent.svg'),
              ),
              Text(
                'stay_updated'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              AppSizedBox.h10,
              Text(
                'stay_updated_message'.tr(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              AppSizedBox.h10,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final controller = ref.read(
                              notificationStateProvider(context).notifier);
                          await controller.turnOffNotifications();
                          Navigator.pop(context, false);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                        ),
                        child: Text('cancel'.tr()),
                      ),
                    ),
                    AppSizedBox.w16,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final controller = ref.read(
                              notificationStateProvider(context).notifier);

                          _requestNotificationPermission(context, controller);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text('enable'.tr()),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _requestNotificationPermission(
      BuildContext context, NotificationToggleNotifier controller) async {
    var status = await OneSignal.Notifications.requestPermission(false);

    if (status == true) {
      Fluttertoast.showToast(msg: 'notification_on_message'.tr());
      await controller.turnOnNotifications();
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: 'notification_off_message'.tr());
      await controller.turnOffNotifications();
      Navigator.pop(context, false);
    }
  }
}
