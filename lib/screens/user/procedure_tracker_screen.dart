import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/procedure_model.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_theme.dart';

class ProcedureTrackerScreen extends StatelessWidget {
  final ProcedureModel procedure;

  const ProcedureTrackerScreen({
    super.key,
    required this.procedure,
  });

  void _showResetDialog(BuildContext context, ProgressProvider provider, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will uncheck all steps for this procedure. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.resetProgress(userId: userId, procedureId: procedure.id);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    final progress = progressProvider.startProcedure(
      userId: user.id,
      procedure: procedure,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Procedure Tracker'),
        actions: [
          if (progress.completedCount > 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
              tooltip: 'Reset Tracker',
              onPressed: () => _showResetDialog(context, progressProvider, user.id),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Procedure Title & Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                procedure.categoryName,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              procedure.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),

            // Progress Summary Card
            _ModernProgressCard(progress: progress),

            const SizedBox(height: 24),

            // Steps Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Checklist Steps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Tap any step to complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (procedure.steps.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: const Center(
                  child: Text(
                    'No procedure steps available.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              ...List.generate(
                procedure.steps.length,
                (index) {
                  final completed = index < progress.completedSteps.length && progress.completedSteps[index];
                  final isLast = index == procedure.steps.length - 1;

                  return _InteractiveTrackerStep(
                    number: index + 1,
                    title: procedure.steps[index],
                    completed: completed,
                    isLast: isLast,
                    onToggle: () async {
                      await progressProvider.toggleStep(
                        userId: user.id,
                        procedureId: procedure.id,
                        stepIndex: index,
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 20),

            if (progress.isCompleted) _ModernCompletedCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ModernProgressCard extends StatelessWidget {
  final ProgressModel progress;

  const _ModernProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Completion',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.completedCount} of ${progress.totalSteps} steps completed',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: progress.isCompleted
                      ? AppTheme.success.withValues(alpha: 0.12)
                      : AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${progress.percentage}%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: progress.isCompleted ? AppTheme.success : AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress.isCompleted ? AppTheme.success : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveTrackerStep extends StatelessWidget {
  final int number;
  final String title;
  final bool completed;
  final bool isLast;
  final VoidCallback onToggle;

  const _InteractiveTrackerStep({
    required this.number,
    required this.title,
    required this.completed,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: completed ? AppTheme.success : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: completed ? AppTheme.success : AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: completed
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                      : Text(
                          '$number',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 52,
                color: completed ? AppTheme.success.withValues(alpha: 0.5) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: completed ? AppTheme.success.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: completed ? AppTheme.success.withValues(alpha: 0.3) : AppTheme.borderLight,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: completed ? AppTheme.textSecondary : AppTheme.textPrimary,
                            decoration: completed ? TextDecoration.lineThrough : null,
                            height: 1.35,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: completed,
                        activeColor: AppTheme.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        onChanged: (_) => onToggle(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModernCompletedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.success.withValues(alpha: 0.12),
            AppTheme.success.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Procedure Completed! 🎉',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Congratulations! You have completed all the required steps for this procedure.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}