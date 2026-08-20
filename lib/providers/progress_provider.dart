import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/progress_model.dart';
import '../models/procedure_model.dart';

class ProgressProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  final Map<String, ProgressModel> _progress = {};

  String _progressKey(String userId, String procedureId) {
    return '$userId-$procedureId';
  }

  Map<String, ProgressModel> get progressMap => _progress;

  List<ProgressModel> getActiveProgressList(String userId) {
    return _progress.values
        .where((p) => p.userId == userId && p.completedCount > 0 && !p.isCompleted)
        .toList();
  }

  List<ProgressModel> getAllUserProgress(String userId) {
    return _progress.values.where((p) => p.userId == userId).toList();
  }

  Future<void> loadProgress(String userId) async {
    try {
      final data = await _supabase
          .from('progress')
          .select()
          .eq('user_id', userId);

      for (final item in data as List) {
        final model = ProgressModel.fromMap(item);
        _progress[_progressKey(model.userId, model.procedureId)] = model;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Load progress error: $e');
    }
  }

  ProgressModel startProcedure({
    required String userId,
    required ProcedureModel procedure,
  }) {
    final key = _progressKey(userId, procedure.id);
    final existing = _progress[key];

    if (existing != null) {
      // Sync totalSteps if procedure steps changed
      if (existing.completedSteps.length != procedure.steps.length) {
        final newCompleted = List<bool>.filled(procedure.steps.length, false);
        for (int i = 0; i < procedure.steps.length && i < existing.completedSteps.length; i++) {
          newCompleted[i] = existing.completedSteps[i];
        }
        existing.completedSteps = newCompleted;
      }
      return existing;
    }

    final progress = ProgressModel(
      userId: userId,
      procedureId: procedure.id,
      totalSteps: procedure.steps.length,
    );

    _progress[key] = progress;
    _createProgress(progress);
    notifyListeners();

    return progress;
  }

  Future<void> _createProgress(ProgressModel progress) async {
    try {
      await _supabase.from('progress').upsert(
            progress.toMap(),
            onConflict: 'user_id,procedure_id',
          );
    } catch (e) {
      debugPrint('Create progress error: $e');
    }
  }

  ProgressModel? getProgress({
    required String userId,
    required String procedureId,
  }) {
    return _progress[_progressKey(userId, procedureId)];
  }

  Future<void> toggleStep({
    required String userId,
    required String procedureId,
    required int stepIndex,
  }) async {
    final key = _progressKey(userId, procedureId);
    final progress = _progress[key];

    if (progress == null) {
      return;
    }

    progress.toggleStep(stepIndex);
    notifyListeners();

    try {
      await _supabase.from('progress').upsert(
            progress.toMap(),
            onConflict: 'user_id,procedure_id',
          );
    } catch (e) {
      debugPrint('Toggle progress error: $e');
    }
  }

  Future<void> resetProgress({
    required String userId,
    required String procedureId,
  }) async {
    final key = _progressKey(userId, procedureId);
    final progress = _progress[key];

    if (progress != null) {
      progress.completedSteps = List<bool>.filled(progress.totalSteps, false);
      notifyListeners();
    }

    try {
      await _supabase
          .from('progress')
          .delete()
          .eq('user_id', userId)
          .eq('procedure_id', procedureId);

      _progress.remove(key);
      notifyListeners();
    } catch (e) {
      debugPrint('Reset progress error: $e');
    }
  }
}