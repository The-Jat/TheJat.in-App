import 'dart:io';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:news_pro/core/components/components.dart';

/// A widget wrapper that handles iOS App Tracking Transparency permissions.
/// Wrap any widget with this to show the tracking permission dialog when
/// the wrapped widget is displayed.
class IOSTrackingPermissionWrapper extends StatefulWidget {
  /// The child widget to display after handling tracking permissions
  final Widget child;

  /// Custom widget to explain why tracking is needed before showing system dialog
  final Widget? explainerDialog;

  /// Whether to show the permission request when this widget is displayed
  final bool requestOnDisplay;

  /// Callback triggered after permission request completes
  final Function(TrackingStatus status)? onPermissionComplete;

  const IOSTrackingPermissionWrapper({
    super.key,
    required this.child,
    this.explainerDialog,
    this.requestOnDisplay = true,
    this.onPermissionComplete,
  });

  @override
  IOSTrackingPermissionWrapperState createState() =>
      IOSTrackingPermissionWrapperState();
}

class IOSTrackingPermissionWrapperState
    extends State<IOSTrackingPermissionWrapper> {
  bool _permissionHandled = false;

  @override
  void initState() {
    super.initState();
    if (widget.requestOnDisplay) {
      _handleTrackingPermission();
    }
  }

  Future<void> _handleTrackingPermission() async {
    // Only proceed on iOS
    if (!Platform.isIOS) {
      setState(() => _permissionHandled = true);
      widget.onPermissionComplete?.call(TrackingStatus.notSupported);
      return;
    }

    // Check current status
    final currentStatus =
        await AppTrackingTransparency.trackingAuthorizationStatus;

    // If status is already determined, no need to request again
    if (currentStatus != TrackingStatus.notDetermined) {
      setState(() => _permissionHandled = true);
      widget.onPermissionComplete?.call(currentStatus);
      return;
    }

    // Show custom explainer dialog if provided
    if (widget.explainerDialog != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => widget.explainerDialog!,
      );

      // Wait for dialog animation to complete
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Request tracking authorization
    final status = await AppTrackingTransparency.requestTrackingAuthorization();

    setState(() => _permissionHandled = true);
    widget.onPermissionComplete?.call(status);
  }

  /// Manually request tracking permission
  Future<TrackingStatus> requestTracking() async {
    if (!Platform.isIOS) {
      return TrackingStatus.notSupported;
    } else if (Platform.isAndroid) {
      final result = await ConsentManager.gatherGdprConsent();
      if (result == true) {
        return TrackingStatus.authorized;
      } else {
        return TrackingStatus.denied;
      }
    }

    if (widget.explainerDialog != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => widget.explainerDialog!,
      );
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final status = await AppTrackingTransparency.requestTrackingAuthorization();
    widget.onPermissionComplete?.call(status);
    return status;
  }

  @override
  Widget build(BuildContext context) {
    // If we're still handling permissions and requestOnDisplay is true,
    // show a loading indicator
    if (!_permissionHandled && widget.requestOnDisplay) {
      return Scaffold(
        body: Center(
          child: AppLoader(),
        ),
      );
    }

    // Otherwise, show the child widget
    return widget.child;
  }
}

/// Default explainer dialog that follows Google's recommendations
class DefaultTrackingExplainerDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  const DefaultTrackingExplainerDialog({
    super.key,
    this.title = 'Personalized Ads',
    this.message =
        'We use this data to make your experience better by showing content that\'s relevant to you. This helps us keep our app free to use.',
    this.buttonText = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonText),
        ),
      ],
    );
  }
}
