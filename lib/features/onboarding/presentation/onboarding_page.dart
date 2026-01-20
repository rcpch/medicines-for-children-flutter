// Onboarding flow UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/theme/rcpch_colours.dart';
import 'package:medicines_for_children_flutter/core/data/storage/primary_carer_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/onboarding/application/onboarding_draft_provider.dart';
import 'package:medicines_for_children_flutter/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:medicines_for_children_flutter/features/onboarding/domain/onboarding_profile.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _stepKeys = List.generate(3, (_) => GlobalKey<FormState>());

  late final TextEditingController _carerFirstNameController;
  late final TextEditingController _carerLastNameController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _phoneController;
  late final TextEditingController _childFirstNameController;
  late final TextEditingController _childLastNameController;
  late final TextEditingController _childConditionController;
  late final TextEditingController _childAllergiesController;
  late final TextEditingController _childNotesController;
  late final TextEditingController _childDobController;

  DateTime? _childDob;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _carerFirstNameController = TextEditingController();
    _carerLastNameController = TextEditingController();
    _relationshipController = TextEditingController();
    _phoneController = TextEditingController();
    _childFirstNameController = TextEditingController();
    _childLastNameController = TextEditingController();
    _childConditionController = TextEditingController();
    _childAllergiesController = TextEditingController();
    _childNotesController = TextEditingController();
    _childDobController = TextEditingController();
    _hydrateFromDraft();
  }

  void _hydrateFromDraft() {
    final draft = ref.read(onboardingDraftProvider);
    final profileId = ref.read(authControllerProvider).user?.uid;
    final storedProfile = profileId == null
        ? null
        : ref.read(onboardingLocalDataSourceProvider).readProfile(profileId);
    final data =
        draft ??
        (storedProfile != null
            ? OnboardingDraft.fromProfile(storedProfile)
            : null);
    if (data == null) {
      return;
    }
    _carerFirstNameController.text = data.carerFirstName;
    _carerLastNameController.text = data.carerLastName;
    _relationshipController.text = data.relationshipToChild;
    _phoneController.text = data.phoneNumber;
    _childFirstNameController.text = data.childFirstName;
    _childLastNameController.text = data.childLastName;
    _childConditionController.text = data.childCondition;
    _childAllergiesController.text = data.childAllergies.join(', ');
    _childNotesController.text = data.childNotes ?? '';
    _childDob = data.childDateOfBirth;
    if (_childDob != null) {
      _childDobController.text = DateFormat('d MMM y').format(_childDob!);
    }
  }

  @override
  void dispose() {
    _carerFirstNameController.dispose();
    _carerLastNameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _childFirstNameController.dispose();
    _childLastNameController.dispose();
    _childConditionController.dispose();
    _childAllergiesController.dispose();
    _childNotesController.dispose();
    _childDobController.dispose();
    super.dispose();
  }

  List<String> _parseAllergies(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 18, now.month, now.day);
    final lastDate = DateTime(now.year, now.month, now.day);
    var initial = _childDob ?? DateTime(now.year - 8, now.month, now.day);
    if (initial.isBefore(firstDate)) {
      initial = firstDate;
    } else if (initial.isAfter(lastDate)) {
      initial = lastDate;
    }
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (selected != null) {
      setState(() {
        _childDob = selected;
        _childDobController.text = DateFormat('d MMM y').format(selected);
      });
    }
  }

  void _goBack() {
    if (_currentStep == 0) {
      return;
    }
    setState(() {
      _currentStep -= 1;
    });
  }

  void _handleContinue() {
    if (_currentStep < 2) {
      final form = _stepKeys[_currentStep].currentState;
      if (form?.validate() ?? false) {
        setState(() {
          _currentStep += 1;
        });
      }
      return;
    }
    _submit();
  }

  Future<void> _submit() async {
    final detailsForm = _stepKeys[0].currentState;
    final childForm = _stepKeys[1].currentState;
    final isValidDetails = detailsForm?.validate() ?? false;
    final isValidChild = childForm?.validate() ?? false;
    if (!isValidDetails || !isValidChild) {
      setState(() {
        _currentStep = !isValidDetails ? 0 : 1;
      });
      return;
    }
    final authState = ref.read(authControllerProvider);
    final profileId = authState.user?.uid;
    if (profileId == null || profileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a profile before completing onboarding.'),
        ),
      );
      return;
    }

    final profile = OnboardingProfile(
      carer: CarerProfile(
        firstName: _carerFirstNameController.text.trim(),
        lastName: _carerLastNameController.text.trim(),
        relationshipToChild: _relationshipController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: authState.user?.email ?? '',
      ),
      child: ChildProfile(
        firstName: _childFirstNameController.text.trim(),
        lastName: _childLastNameController.text.trim(),
        dateOfBirth: _childDob,
        condition: _childConditionController.text.trim(),
        allergies: _parseAllergies(_childAllergiesController.text),
        notes: _childNotesController.text.trim(),
      ),
    );

    final storage = ref.read(onboardingLocalDataSourceProvider);
    await storage.saveProfile(profileId: profileId, profile: profile);

    final primaryCarerStorage = ref.read(primaryCarerLocalDataSourceProvider);
    final child = Child(
      id: 'child-$profileId',
      firstName: profile.child.firstName,
      lastName: profile.child.lastName,
      dateOfBirth: profile.child.dateOfBirth ?? DateTime(1970, 1, 1),
      condition: profile.child.condition,
      allergies: profile.child.allergies,
      notes: profile.child.notes,
      medicines: const [],
      schedules: const [],
      asNeededSchedules: const [],
    );
    final primaryCarer = PrimaryCarer(
      id: profileId,
      firstName: profile.carer.firstName,
      lastName: profile.carer.lastName,
      email: profile.carer.email,
      relationshipToChild: profile.carer.relationshipToChild,
      children: [child],
    );
    await primaryCarerStorage.writeForProfile(profileId, primaryCarer);

    await ref
        .read(authControllerProvider.notifier)
        .completeOnboarding(
          displayName:
              '${_carerFirstNameController.text.trim()} ${_carerLastNameController.text.trim()}'
                  .trim(),
        );
    ref.read(onboardingDraftProvider.notifier).clear();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved. Welcome to Medicines for Children.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null &&
          message.isNotEmpty &&
          message != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Let\'s capture the essentials so we can personalise reminders, schedules and exports right away.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Stepper(
                        currentStep: _currentStep,
                        physics: const NeverScrollableScrollPhysics(),
                        controlsBuilder: (context, details) {
                          return Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: rcpchPink,
                                    foregroundColor: rcpchWhite,
                                    minimumSize: const Size.fromHeight(52),
                                  ),
                                  onPressed: authState.isLoading
                                      ? null
                                      : details.onStepContinue,
                                  child:
                                      authState.isLoading && _currentStep == 2
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              rcpchWhite,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          _currentStep == 2
                                              ? 'Finish onboarding'
                                              : 'Continue',
                                        ),
                                ),
                              ),
                              if (_currentStep > 0) const SizedBox(width: 12),
                              if (_currentStep > 0)
                                TextButton(
                                  onPressed: authState.isLoading
                                      ? null
                                      : details.onStepCancel,
                                  child: const Text('Back'),
                                ),
                            ],
                          );
                        },
                        onStepContinue: _handleContinue,
                        onStepCancel: _goBack,
                        steps: [
                          Step(
                            isActive: _currentStep >= 0,
                            title: const Text('About you'),
                            content: Form(
                              key: _stepKeys[0],
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _carerFirstNameController,
                                    label: 'First name',
                                    icon: Icons.badge_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    controller: _carerLastNameController,
                                    label: 'Last name',
                                    icon: Icons.badge_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    controller: _relationshipController,
                                    label: 'Relationship to child',
                                    icon: Icons.family_restroom_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone',
                                      prefixIcon: Icon(Icons.call_outlined),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Step(
                            isActive: _currentStep >= 1,
                            title: const Text('About your child'),
                            content: Form(
                              key: _stepKeys[1],
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _childFirstNameController,
                                    label: 'Child first name',
                                    icon: Icons.child_care_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    controller: _childLastNameController,
                                    label: 'Child last name',
                                    icon: Icons.child_care_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _childDobController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Date of birth',
                                      prefixIcon: Icon(Icons.cake_outlined),
                                    ),
                                    onTap: _pickDateOfBirth,
                                    validator: (_) => _childDob == null
                                        ? 'Choose a date of birth'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    controller: _childConditionController,
                                    label: 'Primary condition / notes',
                                    icon: Icons.favorite_outline,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _childAllergiesController,
                                    decoration: const InputDecoration(
                                      labelText: 'Allergies (comma separated)',
                                      prefixIcon: Icon(Icons.vaccines_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _childNotesController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Important notes for carers',
                                      prefixIcon: Icon(Icons.notes_outlined),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Step(
                            isActive: _currentStep >= 2,
                            title: const Text('Review & confirm'),
                            content: Form(
                              key: _stepKeys[2],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSummaryTile(
                                    title: 'Primary carer',
                                    lines: [
                                      '${_carerFirstNameController.text} ${_carerLastNameController.text}',
                                      _relationshipController.text,
                                      _phoneController.text,
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSummaryTile(
                                    title: 'Child',
                                    lines: [
                                      '${_childFirstNameController.text} ${_childLastNameController.text}',
                                      if (_childDob != null)
                                        'DOB: ${DateFormat('d MMM y').format(_childDob!)}',
                                      _childConditionController.text,
                                      if (_childAllergiesController.text
                                          .trim()
                                          .isNotEmpty)
                                        'Allergies: ${_childAllergiesController.text.trim()}',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter $label'.toLowerCase();
        }
        return null;
      },
    );
  }

  Widget _buildSummaryTile({
    required String title,
    required List<String> lines,
  }) {
    final visibleLines = lines.where((line) => line.trim().isNotEmpty).toList();
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final line in visibleLines)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(line),
              ),
          ],
        ),
      ),
    );
  }
}
