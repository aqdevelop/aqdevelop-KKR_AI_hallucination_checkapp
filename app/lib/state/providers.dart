import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/factcheck_api.dart';
import '../data/api/mock_api.dart';
import '../data/models/models.dart';

const _useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

final factCheckApiProvider = Provider<FactCheckApi>((ref) => FactCheckApi());
final mockApiProvider = Provider<MockFactCheckApi>((ref) => MockFactCheckApi());

class CheckController extends StateNotifier<AsyncValue<FactCheckResult?>> {
  CheckController(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;

  Future<void> run(String text) async {
    state = const AsyncValue.loading();
    try {
      final result = _useMock
          ? await _ref.read(mockApiProvider).check(text)
          : await _ref.read(factCheckApiProvider).check(text);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final checkControllerProvider =
    StateNotifierProvider<CheckController, AsyncValue<FactCheckResult?>>(
  (ref) => CheckController(ref),
);
