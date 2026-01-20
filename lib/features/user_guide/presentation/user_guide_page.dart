// User guide list screen UI.
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/presentation/main_menu.dart';
import 'package:medicines_for_children_flutter/features/user_guide/domain/user_guide_content.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  static final Uri _repoIssuesUri = Uri.parse(
    'https://github.com/rcpch/medicines-for-children-flutter/issues',
  );

  Future<String> _deviceOsSummary() async {
    try {
      final plugin = DeviceInfoPlugin();

      if (kIsWeb) {
        final web = await plugin.webBrowserInfo;
        final browser = web.browserName.name;
        final platform = web.platform ?? 'web';
        return '$browser ($platform)';
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await plugin.androidInfo;
          final manufacturer = info.manufacturer;
          final model = info.model;
          final release = info.version.release;
          return '$manufacturer $model (Android $release)';
        case TargetPlatform.iOS:
          final info = await plugin.iosInfo;
          final model = info.modelName;
          final version = info.systemVersion;
          return '$model (iOS $version)';
        case TargetPlatform.macOS:
          final info = await plugin.macOsInfo;
          final model = info.model;
          final osVersion = info.osRelease;
          return '$model (macOS $osVersion)';
        case TargetPlatform.linux:
          final info = await plugin.linuxInfo;
          return info.prettyName;
        case TargetPlatform.windows:
          final info = await plugin.windowsInfo;
          final productName = info.productName;
          final buildNumber = info.buildNumber;
          return '$productName (build $buildNumber)';
        case TargetPlatform.fuchsia:
          return 'Fuchsia';
      }
    } catch (_) {
      return 'Unknown';
    }
  }

  Future<String> _appVersionSummary() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      final build = info.buildNumber;
      return build.isEmpty ? version : '$version+$build';
    } catch (_) {
      return 'Unknown';
    }
  }

  Future<Uri> _buildFeedbackUri() async {
    final deviceOs = await _deviceOsSummary();
    final appVersion = await _appVersionSummary();

    final body =
        '''## Summary

## What were you trying to do?

## What worked well?

## What could be improved?

## If this relates to medicines/schedules, what’s the context?
- Child age group (optional):
- Type of schedule (e.g. daily, alternating days, PRN/as needed):

## Environment
- Device/OS: $deviceOs
- App version: $appVersion

## Additional context
''';

    return Uri(
      scheme: 'https',
      host: 'github.com',
      path: '/rcpch/medicines-for-children-flutter/issues/new',
      queryParameters: {'template': 'app_feedback.md', 'body': body},
    );
  }

  Future<void> _openFeedback(BuildContext context) async {
    final uri = await _buildFeedbackUri();

    if (!context.mounted) {
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open feedback form. You can file feedback here: ${_repoIssuesUri.toString()}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User guide'),
        actions: const [MainMenu()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GuideHeader(
            title: 'Medicines for Children',
            subtitle:
                'A quick guide to managing medicines, schedules, and shared care.',
            accent: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          ...userGuideSections.map(
            (section) => _GuideSection(
              key: ValueKey('guide-section-${section.id}'),
              title: section.title,
              summary: section.summary,
              onTap: () => context.pushNamed(
                AppRoute.userGuideDetail.name,
                pathParameters: {'sectionId': section.id},
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const ValueKey('guide-feedback'),
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Feedback'),
              subtitle: const Text(
                'Report bugs or suggest improvements on GitHub.',
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openFeedback(context),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tip: keep schedules and medicine details updated after clinic visits so shared carers always see the latest instructions.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideHeader extends StatelessWidget {
  const _GuideHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.15),
            accent.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    super.key,
    required this.title,
    required this.summary,
    required this.onTap,
  });

  final String title;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(summary, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
