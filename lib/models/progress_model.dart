class ProgressModel {
  final String userId;
  final String procedureId;
  List<bool> completedSteps;

  ProgressModel({
    required this.userId,
    required this.procedureId,
    required int totalSteps,
  }) : completedSteps = List<bool>.filled(
          totalSteps,
          false,
        );

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    List<bool> steps = [];
    if (map['completed_steps'] != null && map['completed_steps'] is List) {
      steps = (map['completed_steps'] as List)
          .map((item) => item == true || item.toString().toLowerCase() == 'true')
          .toList();
    }

    final model = ProgressModel(
      userId: map['user_id']?.toString() ?? '',
      procedureId: map['procedure_id']?.toString() ?? '',
      totalSteps: steps.length,
    );
    model.completedSteps = steps;
    return model;
  }

  int get completedCount {
    return completedSteps.where((completed) => completed).length;
  }

  int get totalSteps {
    return completedSteps.length;
  }

  double get progress {
    if (totalSteps == 0) {
      return 0.0;
    }
    return (completedCount / totalSteps).clamp(0.0, 1.0);
  }

  int get percentage {
    return (progress * 100).round();
  }

  bool get isCompleted {
    return totalSteps > 0 && completedCount == totalSteps;
  }

  bool get isInProgress {
    return completedCount > 0 && completedCount < totalSteps;
  }

  void toggleStep(int index) {
    if (index < 0 || index >= completedSteps.length) {
      return;
    }
    completedSteps[index] = !completedSteps[index];
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'procedure_id': procedureId,
      'completed_steps': completedSteps,
      'total_steps': totalSteps,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}