// Local storage for primary carer profile.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';

class PrimaryCarerLocalDataSource {
  PrimaryCarerLocalDataSource(this._profileData);

  final ProfileDataLocalDataSource _profileData;

  PrimaryCarer? readForProfile(String profileId) {
    return _profileData.readPrimaryCarer(profileId);
  }

  Future<void> writeForProfile(
    String profileId,
    PrimaryCarer primaryCarer,
  ) async {
    await _profileData.writePrimaryCarer(profileId, primaryCarer);
  }

  Future<void> clearForProfile(String profileId) async {
    await _profileData.clearProfile(profileId);
  }
}

final primaryCarerLocalDataSourceProvider =
    Provider<PrimaryCarerLocalDataSource>((ref) {
      final profileData = ref.watch(profileDataLocalDataSourceProvider);
      return PrimaryCarerLocalDataSource(profileData);
    });
