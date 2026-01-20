// Local storage for primary carer profile.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';

/// Reads and writes primary carer data for a profile.
class PrimaryCarerLocalDataSource {
  PrimaryCarerLocalDataSource(this._profileData);

  final ProfileDataLocalDataSource _profileData;

  /// Loads the primary carer record for a profile.
  PrimaryCarer? readForProfile(String profileId) {
    return _profileData.readPrimaryCarer(profileId);
  }

  /// Persists the primary carer record for a profile.
  Future<void> writeForProfile(
    String profileId,
    PrimaryCarer primaryCarer,
  ) async {
    await _profileData.writePrimaryCarer(profileId, primaryCarer);
  }

  /// Clears the stored profile data for a profile.
  Future<void> clearForProfile(String profileId) async {
    await _profileData.clearProfile(profileId);
  }
}

/// Provides the primary carer local data source.
final primaryCarerLocalDataSourceProvider =
    Provider<PrimaryCarerLocalDataSource>((ref) {
      final profileData = ref.watch(profileDataLocalDataSourceProvider);
      return PrimaryCarerLocalDataSource(profileData);
    });
