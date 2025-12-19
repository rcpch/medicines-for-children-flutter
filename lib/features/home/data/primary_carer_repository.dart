import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';

abstract class PrimaryCarerRepository {
  Future<PrimaryCarer> fetchPrimaryCarer();
}

class LocalPrimaryCarerRepository implements PrimaryCarerRepository {
  LocalPrimaryCarerRepository({
    required this.authRepository,
    required this.profileData,
  });

  final AuthRepository authRepository;
  final ProfileDataLocalDataSource profileData;

  @override
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

final primaryCarerRepositoryProvider = Provider<PrimaryCarerRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  return LocalPrimaryCarerRepository(authRepository: authRepository, profileData: profileData);
});

