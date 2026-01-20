// Splash/loading screen UI.
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/MfC-logo-2021-RGB-900x300-1.png',
                    height: 72,
                    fit: BoxFit.contain,
                    semanticLabel: 'Medicines for Children logo',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Medicines For Children',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.error, width: 2),
                    ),
                    child: Text(
                      'PRE-ALPHA Evaluation Release',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircularProgressIndicator(color: colorScheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
