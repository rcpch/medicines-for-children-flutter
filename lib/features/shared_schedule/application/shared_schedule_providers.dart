// Providers for shared schedule state.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/network/api_client.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/data/shared_schedule_repository.dart';

typedef SharedScheduleSession = ({String apiId, String authToken});

final sharedScheduleSessionProvider = StateProvider<SharedScheduleSession?>((ref) {
  return null;
});

final sharedScheduleRepositoryProvider = Provider<SharedScheduleRepository>((ref) {
  final dio = ref.watch(securedApiClientProvider);
  return HttpSharedScheduleRepository(dio);
});

final sharedScheduleAuthResultProvider = FutureProvider.family<SharedScheduleAuthResult, String>((ref, linkToken) async {
  final repository = ref.watch(sharedScheduleRepositoryProvider);
  return repository.exchangeLinkToken(linkToken);
});

final sharedScheduleViewModelProvider = FutureProvider.family<SharedScheduleViewModel, SharedScheduleSession>((ref, session) async {
  final repository = ref.watch(sharedScheduleRepositoryProvider);
  return repository.fetchSharedSchedule(apiId: session.apiId, authToken: session.authToken);
});
