import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../core/logger/app_logger.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) return child;
    return _UpdatePageAlt(child: child);
  }
}

class _UpdatePageAlt extends StatefulWidget {
  final Widget child;
  const _UpdatePageAlt({required this.child});

  @override
  State<_UpdatePageAlt> createState() => _UpdatePageAltState();
}

class _UpdatePageAltState extends State<_UpdatePageAlt> {
  AppUpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    if (Platform.isAndroid) {
      try {
        final info = await InAppUpdate.checkForUpdate();
        Log.info('Update check completed: $info');
        setState(() {
          _updateInfo = info;
        });

        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          if (info.immediateUpdateAllowed) {
            Log.info('Performing immediate update');
            await InAppUpdate.performImmediateUpdate();
            Log.info('Update completed');
          } else if (info.flexibleUpdateAllowed) {
            Log.info('Starting flexible update');
            await InAppUpdate.startFlexibleUpdate();
            Log.info('Completing flexible update');
            await InAppUpdate.completeFlexibleUpdate();
            Log.info('Update completed');
          }
        }
      } catch (e) {
        debugPrint('Update check failed: $e');
        Log.error('Update check failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update, size: 64),
              const SizedBox(height: 16),
              Text(
                'new_update_available'.tr(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'update_message'.tr(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await InAppUpdate.performImmediateUpdate();
                  } catch (e) {
                    debugPrint('Update failed: $e');
                  }
                },
                child: Text('update_now'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
