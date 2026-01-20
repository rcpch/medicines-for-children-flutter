// Provider for onboarding draft state.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/onboarding/domain/onboarding_profile.dart';

// Manages draft onboarding data during multi-step entry.
class OnboardingDraftController extends Notifier<OnboardingDraft?> {
  @override
  // Starts with no draft until user input is provided.
  OnboardingDraft? build() {
    return null;
  }

  // Replaces the current draft with the latest snapshot.
  void setDraft(OnboardingDraft? draft) {
    state = draft;
  }

  // Clears any stored draft data.
  void clear() {
    state = null;
  }
}

// Mutable onboarding payload captured before saving profile data.
class OnboardingDraft {
  const OnboardingDraft({
    required this.carerFirstName,
    required this.carerLastName,
    required this.relationshipToChild,
    required this.phoneNumber,
    required this.childFirstName,
    required this.childLastName,
    required this.childCondition,
    required this.childAllergies,
    this.childDateOfBirth,
    this.childNotes,
  });

  // Creates a draft snapshot from a persisted onboarding profile.
  factory OnboardingDraft.fromProfile(OnboardingProfile profile) {
    return OnboardingDraft(
      carerFirstName: profile.carer.firstName,
      carerLastName: profile.carer.lastName,
      relationshipToChild: profile.carer.relationshipToChild,
      phoneNumber: profile.carer.phoneNumber,
      childFirstName: profile.child.firstName,
      childLastName: profile.child.lastName,
      childCondition: profile.child.condition,
      childAllergies: profile.child.allergies,
      childDateOfBirth: profile.child.dateOfBirth,
      childNotes: profile.child.notes,
    );
  }

  // Returns a copy with selective field overrides.
  OnboardingDraft copyWith({
    String? carerFirstName,
    String? carerLastName,
    String? relationshipToChild,
    String? phoneNumber,
    String? childFirstName,
    String? childLastName,
    String? childCondition,
    List<String>? childAllergies,
    DateTime? childDateOfBirth,
    bool clearChildDateOfBirth = false,
    String? childNotes,
  }) {
    return OnboardingDraft(
      carerFirstName: carerFirstName ?? this.carerFirstName,
      carerLastName: carerLastName ?? this.carerLastName,
      relationshipToChild: relationshipToChild ?? this.relationshipToChild,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      childFirstName: childFirstName ?? this.childFirstName,
      childLastName: childLastName ?? this.childLastName,
      childCondition: childCondition ?? this.childCondition,
      childAllergies: childAllergies ?? this.childAllergies,
      childDateOfBirth: clearChildDateOfBirth
          ? null
          : (childDateOfBirth ?? this.childDateOfBirth),
      childNotes: childNotes ?? this.childNotes,
    );
  }

  final String carerFirstName;
  final String carerLastName;
  final String relationshipToChild;
  final String phoneNumber;
  final String childFirstName;
  final String childLastName;
  final String childCondition;
  final List<String> childAllergies;
  final DateTime? childDateOfBirth;
  final String? childNotes;
}

// Exposes the onboarding draft state for the current session.
final onboardingDraftProvider =
    NotifierProvider<OnboardingDraftController, OnboardingDraft?>(
      OnboardingDraftController.new,
    );
