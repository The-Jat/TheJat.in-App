import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../views/home/home_page/dialogs/notification_permission_dialog.dart';
import '../../repositories/others/notification_local.dart';
import '../../utils/ui_util.dart';
import 'notification_handler.dart';

final notificationStateProvider = StateNotifierProvider.family<
    NotificationToggleNotifier,
    NotificationState,
    BuildContext>((ref, context) {
  return NotificationToggleNotifier(context);
});

enum NotificationState { loading, on, off }

class NotificationToggleNotifier extends StateNotifier<NotificationState> {
  NotificationToggleNotifier(BuildContext context)
      : super(NotificationState.loading) {
    {
      init(context);
    }
  }

  final _repository = NotificationsRepository();

  Future<bool> init(BuildContext context) async {
    final empty = await _repository.isNotificationValueEmpty();
    if (empty) {
      final result = await turnOnNotifications();
      if (result) {
        state = NotificationState.on;
      } else {
        state = NotificationState.off;
      }
      return result;
    } else {
      bool isNotificaitonOn = await _repository.isNotificationOn();
      if (isNotificaitonOn) {
        state = NotificationState.on;
        return true;
      } else {
        state = NotificationState.off;
        return false;
      }
    }
  }

  /// Turn on Notifications
  Future<bool> turnOnNotifications() async {
    state = NotificationState.on;
    await OneSignal.consentGiven(true);
    final result = await OneSignal.Notifications.requestPermission(true);
    if (result) {
      await _repository.turnOnNotifications();
      await NotificationHandler.enableNotifications();
      Fluttertoast.showToast(msg: 'notification_on_message'.tr());
      return true;
    } else {
      return false;
    }
  }

  /// Turn off Notifications
  turnOffNotifications() async {
    state = NotificationState.off;
    await _repository.turnOffNotifications();
    await NotificationHandler.disableNotifications();
    Fluttertoast.showToast(msg: 'notification_off_message'.tr());
  }

  Future<bool?> checkNotificationPermission(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    final result = await UiUtil.openDialog(
      context: context,
      widget: const NotificationPermissionDialouge(),
      isDismissable: false,
    );

    return result;
  }
}
