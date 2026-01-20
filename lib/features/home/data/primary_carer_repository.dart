// Primary carer data access layer.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';

// Interface for retrieving primary carer data.
abstract class PrimaryCarerRepository {
  // Fetches the primary carer record for the active profile.
  Future<PrimaryCarer> fetchPrimaryCarer();
}

// Local implementation that reads from profile data storage.
class LocalPrimaryCarerRepository implements PrimaryCarerRepository {
  LocalPrimaryCarerRepository({
    required this.authRepository,
    required this.profileData,
  });

  final AuthRepository authRepository;
  final ProfileDataLocalDataSource profileData;

  @override
  // Loads the primary carer from local storage for the active user.
  Future<PrimaryCarer> fetchPrimaryCarer() async {
    final user = await authRepository.currentUser();
    if (user == null) {
      throw StateError('Not signed in');
    }

    final carer = profileData.readPrimaryCarer(user.uid);
    if (carer == null) {
      throw StateError('No local profile data found');
    }

    return carer;
  }
}

// Provides the primary carer repository implementation.
final primaryCarerRepositoryProvider = Provider<PrimaryCarerRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  return LocalPrimaryCarerRepository(
    authRepository: authRepository,
    profileData: profileData,
  );
});
