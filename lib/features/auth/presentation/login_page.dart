import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/data/credentials_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/data/local_auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  bool _hydrating = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _rememberMe = ref.read(credentialsRepositoryProvider).getRememberMeEnabled();
    _biometricEnabled = ref.read(credentialsRepositoryProvider).getBiometricEnabled();
    _hydrateFromStoredState();
  }

  Future<void> _hydrateFromStoredState() async {
    final credentialsRepo = ref.read(credentialsRepositoryProvider);
    final stored = await credentialsRepo.readCredentials();
    if (stored != null) {
      _emailController.text = stored.email;
    }
    final localAuth = ref.read(localAuthProvider);
    final canCheck = await localAuth.canCheckBiometrics;
    final isSupported = await localAuth.isDeviceSupported();
    if (!mounted) {
      return;
    }
    setState(() {
      _biometricSupported = canCheck && isSupported;
      if (!_biometricSupported) {
        _biometricEnabled = false;
      }
      _hydrating = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) => _emailRegex.hasMatch(value);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final success = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          persistCredentials: _rememberMe,
          clearStoredCredentials: !_rememberMe,
        );
    if (success && !_rememberMe) {
      setState(() {
        _biometricEnabled = false;
      });
    }
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (email.isEmpty || !_isValidEmail(email)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email to receive reset instructions.'),
        ),
      );
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(email: email);
    if (!mounted) {
      return;
    }
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'If an account exists, reset instructions have been sent.',
        ),
      ),
    );
  }

  void _goToSignup() {
    context.goNamed(AppRoute.signup.name);
  }

  Future<void> _toggleRememberMe(bool? value) async {
    final newValue = value ?? false;
    if (_rememberMe == newValue) {
      return;
    }
    setState(() {
      _rememberMe = newValue;
      if (!newValue) {
        _biometricEnabled = false;
      }
    });
    if (!newValue) {
      await ref.read(credentialsRepositoryProvider).setRememberMeEnabled(false);
    }
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (!_biometricSupported || _hydrating) {
      return;
    }
    if (value && !_rememberMe) {
      _showMessage('Enable "Stay signed in" before using biometrics.');
      return;
    }
    final repo = ref.read(credentialsRepositoryProvider);
    if (value) {
      final stored = await repo.readCredentials();
      if (stored == null) {
        _showMessage('Sign in once with your password so we can securely store it for biometrics.');
        return;
      }
      final localAuth = ref.read(localAuthProvider);
      try {
        final authenticated = await localAuth.authenticate(
          localizedReason: 'Confirm your identity to enable biometric login.',
          options: const AuthenticationOptions(biometricOnly: true),
        );
        if (!authenticated || !mounted) {
          return;
        }
        await repo.setBiometricEnabled(true);
        setState(() {
          _biometricEnabled = true;
        });
      } catch (_) {
        _showMessage('Biometric authentication is unavailable right now.');
      }
    } else {
      await repo.setBiometricEnabled(false);
      if (!mounted) {
        return;
      }
      setState(() {
        _biometricEnabled = false;
      });
    }
  }

  Future<void> _handleBiometricSignIn() async {
    final repo = ref.read(credentialsRepositoryProvider);
    final stored = await repo.readCredentials();
    if (stored == null) {
      _showMessage('We need a saved email and password before using biometrics.');
      return;
    }
    final localAuth = ref.read(localAuthProvider);
    try {
      final authenticated = await localAuth.authenticate(
        localizedReason: 'Authenticate to sign in',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!authenticated) {
        return;
      }
      await ref.read(authControllerProvider.notifier).signIn(
            email: stored.email,
            password: stored.password,
            persistCredentials: false,
            clearStoredCredentials: false,
          );
    } catch (_) {
      _showMessage('Unable to access biometric sensor.');
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null &&
          message.isNotEmpty &&
          message != previous?.errorMessage) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.medical_information_outlined, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to manage your child\'s medicines and schedules.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Enter your email address';
                        }
                        if (!_isValidEmail(trimmed)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : _handlePasswordReset,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    CheckboxListTile(
                      value: _rememberMe,
                      onChanged: authState.isLoading ? null : (value) => _toggleRememberMe(value),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Stay signed in on this device'),
                    ),
                    if (_biometricSupported)
                      SwitchListTile(
                        value: _biometricEnabled,
                        onChanged: (!_rememberMe || authState.isLoading)
                            ? null
                            : (value) => _handleBiometricToggle(value),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Use biometrics for quick access'),
                        subtitle: const Text('Face ID / Touch ID / fingerprint'),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                    if (_biometricSupported && _biometricEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: OutlinedButton.icon(
                          onPressed:
                              authState.isLoading ? null : _handleBiometricSignIn,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Sign in with biometrics'),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: authState.isLoading
                          ? null
                          : _goToSignup,
                      child: const Text('Create an account'),
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
}
