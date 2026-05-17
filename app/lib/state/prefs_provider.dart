import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('overridden in main()'),
);

const _kOnboardingSeenKey = 'onboarding_seen_v1';

class OnboardingController extends StateNotifier<bool> {
  OnboardingController(this._prefs)
      : super(_prefs.getBool(_kOnboardingSeenKey) ?? false);

  final SharedPreferences _prefs;

  Future<void> markSeen() async {
    await _prefs.setBool(_kOnboardingSeenKey, true);
    state = true;
  }
}

final onboardingSeenProvider =
    StateNotifierProvider<OnboardingController, bool>(
  (ref) => OnboardingController(ref.watch(sharedPrefsProvider)),
);
