import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../gen/l10n/app_localizations.dart';

class CameraPermission {
  const CameraPermission._();

  static Future<bool> ensureGranted(BuildContext context) async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.camera.request();
    if (result.isGranted) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      await _showSettingsDialog(context);
    } else {
      _showDeniedSnackBar(context);
    }
    return false;
  }

  static void _showDeniedSnackBar(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.cameraPermissionDenied)),
    );
  }

  static Future<void> _showSettingsDialog(BuildContext context) async {
    final s = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.cameraPermissionTitle),
        content: Text(s.cameraPermissionRationale),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.cameraPermissionNotNow),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: Text(s.cameraPermissionSettings),
          ),
        ],
      ),
    );
  }
}
