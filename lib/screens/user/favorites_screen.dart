import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/procedure_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
    final authProvider = context.watch<AuthProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final procedureProvider = context.watch<ProcedureProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    final favoriteIds = favoriteProvider.getFavoriteIds(user.id);
    final favoriteProcedures = procedureProvider.procedures
        .where((procedure) => favoriteIds.contains(procedure.id))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Saved Procedures'),
      ),
      body: favoriteProcedures.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Saved Procedures',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the bookmark icon on any procedure to save it here for quick offline access and tracking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.search);
                      },
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Explore Procedures'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProcedures.length,
              itemBuilder: (context, index) {
                final procedure = favoriteProcedures[index];
                final catColor = _getCategoryColor(procedure.categoryName);
                final catIcon = _getCategoryIcon(procedure.categoryName);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.procedureDetails,
                          arguments: procedure,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(catIcon, color: catColor, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    procedure.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${procedure.categoryName} • ${procedure.processingTime}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.bookmark_rounded,
                                color: Colors.red,
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
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}