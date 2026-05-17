import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/factcheck_api.dart';
import '../data/api/mock_api.dart';
import '../data/check_history_repository.dart';
import '../data/models/models.dart';
import '../features/result/edited_result.dart';
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

final checkStatsProvider = StreamProvider.autoDispose<CheckStats>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(CheckStats.empty);
  return ref.watch(checkHistoryRepoProvider).watchStats(user.uid);
});

class CheckController extends StateNotifier<AsyncValue<FactCheckResult?>> {
  CheckController(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;

  Future<void> run(String text, {String? category}) async {
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
            .save(user.uid, result, category: category)
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

class EditedResultController extends StateNotifier<EditedResult?> {
  EditedResultController(EditedResult? initial) : super(initial);

  void applyFix(String id) {
    if (state == null) return;
    state = state!.applyFix(id);
  }

  void undoFix(String id) {
    if (state == null) return;
    state = state!.undoFix(id);
  }

  void applyAll() {
    if (state == null) return;
    state = state!.applyAll();
  }

  void undoAll() {
    if (state == null) return;
    state = state!.undoAll();
  }
}

final editedResultProvider =
    StateNotifierProvider.autoDispose<EditedResultController, EditedResult?>((ref) {
  final base = ref.watch(checkControllerProvider).valueOrNull;
  return EditedResultController(base == null ? null : EditedResult(base));
});
