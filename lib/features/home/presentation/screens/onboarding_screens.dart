import 'package:flutter/material.dart';

class OnboardingScreens extends StatelessWidget {
  const OnboardingScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to Crav'n")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Center(child: Text('Onboarding content placeholder')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Get started'),
            ),
          ],
        ),
      ),
    );
  }
}
