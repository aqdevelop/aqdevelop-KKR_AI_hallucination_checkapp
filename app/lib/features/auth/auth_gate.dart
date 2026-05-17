import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_providers.dart';
import '../../state/prefs_provider.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final seenOnboarding = ref.watch(onboardingSeenProvider);
    return auth.when(
      data: (user) {
        if (user == null) return const LoginScreen();
        if (!seenOnboarding) return const OnboardingScreen();
        return const HomeScreen();
      },
      loading: () => const _Splash(),
      error: (_, __) => const LoginScreen(),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}
