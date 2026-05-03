import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/input/input_screen.dart';

void main() {
  runApp(const ProviderScope(child: FactCheckApp()));
}

class FactCheckApp extends StatelessWidget {
  const FactCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '할루시 체크',
      theme: buildTheme(),
      home: const InputScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
