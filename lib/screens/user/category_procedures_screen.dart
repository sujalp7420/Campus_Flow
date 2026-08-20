import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/procedure_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class CategoryProceduresScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryProceduresScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProceduresScreen> createState() => _CategoryProceduresScreenState();
}

class _CategoryProceduresScreenState extends State<CategoryProceduresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('certif')) return Icons.workspace_premium_rounded;
    if (lower.contains('acad')) return Icons.school_rounded;
    if (lower.contains('exam')) return Icons.quiz_rounded;
    if (lower.contains('fin') || lower.contains('fee')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('host')) return Icons.apartment_rounded;
    if (lower.contains('lib')) return Icons.local_library_rounded;
    return Icons.folder_open_rounded;
  }

  Color _getCategoryColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('certif')) return const Color(0xFF8B5CF6); // Purple
    if (lower.contains('acad')) return const Color(0xFF4F46E5); // Indigo
    if (lower.contains('exam')) return const Color(0xFF06B6D4); // Cyan
    if (lower.contains('fin') || lower.contains('fee')) return const Color(0xFF10B981); // Emerald
    if (lower.contains('host')) return const Color(0xFFF59E0B); // Amber
    if (lower.contains('lib')) return const Color(0xFFEC4899); // Pink
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final procedureProvider = context.watch<ProcedureProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final favoriteProvider = context.watch<FavoriteProvider>();

    final allCategoryProcedures = procedureProvider.getProceduresByCategory(widget.category.name);

    final filteredProcedures = allCategoryProcedures.where((p) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.office.toLowerCase().contains(q);
    }).toList();

    final catColor = _getCategoryColor(widget.category.name);
    final catIcon = _getCategoryIcon(widget.category.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          // Category Hero Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    catColor.withValues(alpha: 0.9),
                    catColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: catColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      catIcon,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.category.description.isNotEmpty
                              ? widget.category.description
                              : 'Explore procedures for ${widget.category.name}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${allCategoryProcedures.length} Procedures Available',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar inside Category
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search ${widget.category.name.toLowerCase()} procedures...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          // Procedure List
          filteredProcedures.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No procedures found for "$_searchQuery"'
                                : 'No procedures available in ${widget.category.name} yet.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final procedure = filteredProcedures[index];
                        final isFav = user != null &&
                            favoriteProvider.isFavorite(
                              userId: user.id,
                              procedureId: procedure.id,
                            );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
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
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: catColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            catIcon,
                                            color: catColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                procedure.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                procedure.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.textSecondary,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (user != null)
                                          IconButton(
                                            icon: Icon(
                                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                              color: isFav ? Colors.red : AppTheme.textSecondary,
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
                                    const SizedBox(height: 14),
                                    const Divider(height: 1, color: AppTheme.borderLight),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        // Fee
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: procedure.fee == 0
                                                ? AppTheme.success.withValues(alpha: 0.1)
                                                : AppTheme.primaryLight,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            procedure.fee == 0 ? 'FREE' : '₹${procedure.fee.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: procedure.fee == 0 ? AppTheme.success : AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Processing Time
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textSecondary),
                                              const SizedBox(width: 4),
                                              Text(
                                                procedure.processingTime,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        // Steps count
                                        Text(
                                          '${procedure.steps.length} Steps',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 12,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filteredProcedures.length,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}
