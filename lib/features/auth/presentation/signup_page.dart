import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/onboarding/application/onboarding_draft_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _childFirstNameController;
  late final TextEditingController _childLastNameController;
  late final TextEditingController _childConditionController;
  late final TextEditingController _childAllergiesController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _relationshipController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _childFirstNameController = TextEditingController();
    _childLastNameController = TextEditingController();
    _childConditionController = TextEditingController();
    _childAllergiesController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _childFirstNameController.dispose();
    _childLastNameController.dispose();
    _childConditionController.dispose();
    _childAllergiesController.dispose();
    super.dispose();
  }

  List<String> _parseAllergies(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final draft = OnboardingDraft(
      carerFirstName: _firstNameController.text.trim(),
      carerLastName: _lastNameController.text.trim(),
      relationshipToChild: _relationshipController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      childFirstName: _childFirstNameController.text.trim(),
      childLastName: _childLastNameController.text.trim(),
      childCondition: _childConditionController.text.trim(),
      childAllergies: _parseAllergies(_childAllergiesController.text),
    );
    ref.read(onboardingDraftProvider.notifier).state = draft;

    await ref.read(authControllerProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    if (authState.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Let\'s complete your profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message.isNotEmpty && message != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create an account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRoute.login.name),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'We\'ll start with a few details about you and your child. '
                      'You can refine everything later during onboarding.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Primary carer',
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'First name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Enter your first name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Last name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Enter your last name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _relationshipController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Relationship to child',
                            prefixIcon: Icon(Icons.family_restroom_outlined),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Describe your relationship to the child'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Mobile number (optional)',
                            prefixIcon: Icon(Icons.call_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Account security',
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email, AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (trimmed.isEmpty) {
                              return 'Enter an email address';
                            }
                            if (!regex.hasMatch(trimmed)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Create a password with at least 8 characters';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Re-enter your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'First child snapshot',
                      children: [
                        TextFormField(
                          controller: _childFirstNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Child first name',
                            prefixIcon: Icon(Icons.child_care_outlined),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Enter your child\'s first name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _childLastNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Child last name',
                            prefixIcon: Icon(Icons.child_care_outlined),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Enter your child\'s last name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _childConditionController,
                          decoration: const InputDecoration(
                            labelText: 'Primary condition or diagnosis',
                            prefixIcon: Icon(Icons.favorite_outline),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Describe the condition we should focus on'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _childAllergiesController,
                          decoration: const InputDecoration(
                            labelText: 'Allergies (comma separated)',
                            prefixIcon: Icon(Icons.medical_services_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create my account'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.goNamed(AppRoute.login.name),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
