// Provider for onboarding draft state.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/onboarding/domain/onboarding_profile.dart';

class OnboardingDraftController extends Notifier<OnboardingDraft?> {
  @override
  OnboardingDraft? build() {
    return null;
  }

  void setDraft(OnboardingDraft? draft) {
    state = draft;
  }

  void clear() {
    state = null;
  }
}

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

final onboardingDraftProvider =
    NotifierProvider<OnboardingDraftController, OnboardingDraft?>(
      OnboardingDraftController.new,
    );
