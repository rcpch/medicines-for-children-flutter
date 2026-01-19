// Splash/loading screen UI.
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.medical_services_outlined, size: 64),
            SizedBox(height: 16),
            Text(
              'Medicines for Children',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('Flutter port bootstrap in progress'),
          ],
        ),
      ),
    );
  }
}
