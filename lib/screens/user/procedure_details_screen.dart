import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/procedure_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/progress_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class ProcedureDetailsScreen extends StatelessWidget {
  final ProcedureModel procedure;

  const ProcedureDetailsScreen({
    super.key,
    required this.procedure,
  });

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('certif')) return Icons.workspace_premium_rounded;
    if (lower.contains('acad')) return Icons.school_rounded;
    if (lower.contains('exam')) return Icons.quiz_rounded;
    if (lower.contains('fin') || lower.contains('fee')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('host')) return Icons.apartment_rounded;
    if (lower.contains('lib')) return Icons.local_library_rounded;
    return Icons.folder_rounded;
  }

  Color _getCategoryColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('certif')) return const Color(0xFF8B5CF6);
    if (lower.contains('acad')) return const Color(0xFF4F46E5);
    if (lower.contains('exam')) return const Color(0xFF06B6D4);
    if (lower.contains('fin') || lower.contains('fee')) return const Color(0xFF10B981);
    if (lower.contains('host')) return const Color(0xFFF59E0B);
    if (lower.contains('lib')) return const Color(0xFFEC4899);
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final favoriteProvider = context.watch<FavoriteProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    final isFavorite = user != null &&
        favoriteProvider.isFavorite(
          userId: user.id,
          procedureId: procedure.id,
        );

    final existingProgress = user != null
        ? progressProvider.getProgress(
            userId: user.id,
            procedureId: procedure.id,
          )
        : null;

    final catColor = _getCategoryColor(procedure.categoryName);
    final catIcon = _getCategoryIcon(procedure.categoryName);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Procedure Details'),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                favoriteProvider.toggleFavorite(
                  userId: user.id,
                  procedureId: procedure.id,
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(catIcon, size: 16, color: catColor),
                  const SizedBox(width: 6),
                  Text(
                    procedure.categoryName,
                    style: TextStyle(
                      color: catColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              procedure.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              procedure.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // Key Info Cards Grid
            Row(
              children: [
                Expanded(
                  child: _ModernInfoCard(
                    icon: Icons.timer_outlined,
                    iconColor: AppTheme.primaryColor,
                    title: 'Processing Time',
                    value: procedure.processingTime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModernInfoCard(
                    icon: Icons.payments_outlined,
                    iconColor: AppTheme.success,
                    title: 'Fee Required',
                    value: procedure.fee == 0 ? 'Free of Cost' : '₹${procedure.fee.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ModernInfoCard(
                    icon: Icons.location_on_outlined,
                    iconColor: AppTheme.accentColor,
                    title: 'Office / Location',
                    value: procedure.office,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModernInfoCard(
                    icon: Icons.schedule_rounded,
                    iconColor: AppTheme.warning,
                    title: 'Working Hours',
                    value: procedure.workingHours,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Required Documents Section
            const Row(
              children: [
                Icon(Icons.checklist_rounded, color: AppTheme.primaryColor, size: 22),
                SizedBox(width: 8),
                Text(
                  'Required Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (procedure.requiredDocuments.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: const Text('No special documents required.', style: TextStyle(color: AppTheme.textSecondary)),
              )
            else
              ...procedure.requiredDocuments.map((doc) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          doc,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 28),

            // Procedure Steps Flow Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.alt_route_rounded, color: AppTheme.primaryColor, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Step-by-Step Process',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${procedure.steps.length} Steps',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (procedure.steps.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: const Text('No procedure steps defined.', style: TextStyle(color: AppTheme.textSecondary)),
              )
            else
              ...List.generate(procedure.steps.length, (index) {
                final isLast = index == procedure.steps.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 48,
                            color: AppTheme.primaryLight,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Text(
                          procedure.steps[index],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppTheme.borderLight)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.tracker,
                  arguments: procedure,
                );
              },
              icon: Icon(
                existingProgress != null && existingProgress.completedCount > 0
                    ? Icons.trending_up_rounded
                    : Icons.play_arrow_rounded,
                size: 22,
              ),
              label: Text(
                existingProgress != null && existingProgress.completedCount > 0
                    ? 'Continue Tracker (${existingProgress.percentage}%)'
                    : 'Start Procedure Tracker',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _ModernInfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value.isNotEmpty ? value : 'N/A',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}