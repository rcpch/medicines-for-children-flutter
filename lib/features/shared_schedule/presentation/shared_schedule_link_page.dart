// Shared schedule link/join screen UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/application/shared_schedule_providers.dart';

class SharedScheduleLinkPage extends ConsumerWidget {
  const SharedScheduleLinkPage({super.key, required this.linkToken});

  final String linkToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authResultAsync = ref.watch(
      sharedScheduleAuthResultProvider(linkToken),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Shared schedule link')),
      body: authResultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unable to verify this link right now.\n\n$error',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        data: (result) {
          if (result.success && result.hasUsableAuthToken) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(sharedScheduleSessionProvider.notifier).state = (
                apiId: result.sharedScheduleId,
                authToken: result.authToken!,
              );

              if (context.mounted) {
                context.goNamed(
                  AppRoute.sharedSchedule.name,
                  pathParameters: {'apiId': result.sharedScheduleId},
                );
              }
            });

            return const Center(child: CircularProgressIndicator());
          }

          final message = result.success
              ? 'This schedule is not ready yet (${result.message}).'
              : 'This link is not valid (${result.message}).';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text(
                  'If you think this is a mistake, ask the primary carer to resend the link.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
