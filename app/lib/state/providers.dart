import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/factcheck_api.dart';
import '../data/api/mock_api.dart';
import '../data/check_history_repository.dart';
import '../data/models/models.dart';
import 'auth_providers.dart';

const _useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

final factCheckApiProvider = Provider<FactCheckApi>((ref) => FactCheckApi());
final mockApiProvider = Provider<MockFactCheckApi>((ref) => MockFactCheckApi());

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final checkHistoryRepoProvider = Provider<CheckHistoryRepository>(
  (ref) => CheckHistoryRepository(ref.watch(firestoreProvider)),
);

final checkHistoryProvider = StreamProvider.autoDispose<List<CheckHistoryItem>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(checkHistoryRepoProvider).watch(user.uid);
});

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
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user != null) {
        // fire-and-forget: don't block UI on history save
        _ref
            .read(checkHistoryRepoProvider)
            .save(user.uid, result)
            .catchError((_) => '');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setResult(FactCheckResult result) {
    state = AsyncValue.data(result);
  }

  void reset() => state = const AsyncValue.data(null);
}

final checkControllerProvider =
    StateNotifierProvider<CheckController, AsyncValue<FactCheckResult?>>(
  (ref) => CheckController(ref),
);
