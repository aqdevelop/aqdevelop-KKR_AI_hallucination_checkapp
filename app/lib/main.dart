import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'features/auth/auth_gate.dart';
import 'firebase_options.dart';
import 'state/prefs_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    // Keep the user logged in across browser sessions (localStorage).
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const FactCheckApp(),
    ),
  );
}

class FactCheckApp extends StatelessWidget {
  const FactCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FactLens',
      theme: buildTheme(),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
