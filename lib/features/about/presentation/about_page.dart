import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static final Uri _githubRepoUri = Uri.parse(
    'https://github.com/rcpch/medicines-for-children-flutter',
  );

  static final Uri _mfcWebsiteUri = Uri.parse(
    'https://www.medicinesforchildren.org.uk/',
  );

  Future<PackageInfo> _loadPackageInfo() => PackageInfo.fromPlatform();

  String _platformLabel() {
    if (kIsWeb) {
      return 'Web';
    }
    return defaultTargetPlatform.name;
  }

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: ${uri.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Image.asset(
              'assets/images/MfC-logo-2021-RGB-900x300-1.png',
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<PackageInfo>(
                future: _loadPackageInfo(),
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  final version = info == null
                      ? 'Loading…'
                      : '${info.version}+${info.buildNumber}';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicines for Children',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Version: $version'),
                      const SizedBox(height: 4),
                      Text('Platform: ${_platformLabel()}'),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  key: const ValueKey('about-github'),
                  leading: const FaIcon(FontAwesomeIcons.github),
                  title: const Text('GitHub repository'),
                  subtitle: Text(_githubRepoUri.toString()),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openExternal(context, _githubRepoUri),
                ),
                const Divider(height: 1),
                ListTile(
                  key: const ValueKey('about-mfc-website'),
                  leading: Image.asset(
                    'assets/images/MfC-logo-Favicon-RGB-300x300-1-192x192.png',
                    width: 24,
                    height: 24,
                  ),
                  title: const Text('Medicines for Children website'),
                  subtitle: Text(_mfcWebsiteUri.toString()),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openExternal(context, _mfcWebsiteUri),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
