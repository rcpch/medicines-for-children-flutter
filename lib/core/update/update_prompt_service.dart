import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdatePromptService {
  UpdatePromptService(this._config);

  final AppConfig _config;
  bool _hasPrompted = false;

  Future<void> maybePrompt(BuildContext context) async {
    if (_hasPrompted) {
      return;
    }
    final latest = _config.latestAppVersion.trim();
    final minimum = _config.minimumAppVersion.trim();
    if (latest.isEmpty && minimum.isEmpty) {
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version.trim();

    final requiresUpdate = minimum.isNotEmpty && _compareVersions(currentVersion, minimum) < 0;
    final hasUpdate = latest.isNotEmpty && _compareVersions(currentVersion, latest) < 0;

    if (!requiresUpdate && !hasUpdate) {
      return;
    }

    _hasPrompted = true;
    if (!context.mounted) {
      return;
    }

    final title = requiresUpdate ? 'Update required' : 'Update available';
    final message = requiresUpdate
        ? 'This version is no longer supported. Please update to continue.'
        : 'A newer version of the app is available.';

    await showDialog<void>(
      context: context,
      barrierDismissible: !requiresUpdate,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (_config.appUpdateUrl.isNotEmpty)
            TextButton(
              onPressed: () => _copyUpdateLink(context),
              child: const Text('Copy update link'),
            ),
          if (!requiresUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  int _compareVersions(String current, String target) {
    final currentParts = _splitVersion(current);
    final targetParts = _splitVersion(target);
    final maxLength = currentParts.length > targetParts.length
        ? currentParts.length
        : targetParts.length;
    for (var i = 0; i < maxLength; i++) {
      final currentValue = i < currentParts.length ? currentParts[i] : 0;
      final targetValue = i < targetParts.length ? targetParts[i] : 0;
      if (currentValue != targetValue) {
        return currentValue.compareTo(targetValue);
      }
    }
    return 0;
  }

  List<int> _splitVersion(String version) {
    return version
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList(growable: false);
  }

  Future<void> _copyUpdateLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _config.appUpdateUrl));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update link copied.')),
    );
  }
}

final updatePromptServiceProvider = Provider<UpdatePromptService>((ref) {
  final config = ref.watch(appConfigProvider);
  return UpdatePromptService(config);
});
