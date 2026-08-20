import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/procedure_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/procedure_provider.dart';
import '../../providers/progress_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';

class UserHome extends StatefulWidget {
  final bool isPreview;
  const UserHome({super.key, this.isPreview = false});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _currentTabIndex = 0;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

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
    if (lower.contains('certif')) return const Color(0xFF8B5CF6); // Violet
    if (lower.contains('acad')) return const Color(0xFF4F46E5); // Indigo
    if (lower.contains('exam')) return const Color(0xFF06B6D4); // Cyan
    if (lower.contains('fin') || lower.contains('fee')) return const Color(0xFF10B981); // Emerald
    if (lower.contains('host')) return const Color(0xFFF59E0B); // Amber
    if (lower.contains('lib')) return const Color(0xFFEC4899); // Pink
    return AppTheme.primaryColor;
  }

  Future<void> _refreshData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    await Future.wait([
      context.read<CategoryProvider>().loadCategories(),
      context.read<ProcedureProvider>().loadProcedures(),
      if (userId != null) ...[
        context.read<FavoriteProvider>().loadFavorites(userId),
        context.read<ProgressProvider>().loadProgress(userId),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // If user selects Search tab or Favorites tab, render them in place with the bottom navigation
    final List<Widget> tabs = [
      _buildHomeDashboard(context),
      const SearchScreen(),
      const FavoritesScreen(),
      _buildMyTrackersTab(context),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        top: !widget.isPreview && (_currentTabIndex == 0 || _currentTabIndex == 3),
        child: Column(
          children: [
            // Preview Banner and Sub-tab selector when embedded in Admin mode
            if (widget.isPreview) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.08),
                  border: Border(bottom: BorderSide(color: AppTheme.accentColor.withValues(alpha: 0.2))),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_rounded, size: 16, color: AppTheme.accentColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Student Mode Preview',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.userHome);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Fullscreen',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.open_in_new_rounded, size: 10, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Segmented Sub-tab bar for Preview Mode
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    _buildPreviewTabPill(index: 0, icon: Icons.home_rounded, label: 'Home'),
                    const SizedBox(width: 6),
                    _buildPreviewTabPill(index: 1, icon: Icons.search_rounded, label: 'Search'),
                    const SizedBox(width: 6),
                    _buildPreviewTabPill(index: 2, icon: Icons.bookmark_rounded, label: 'Saved'),
                    const SizedBox(width: 6),
                    _buildPreviewTabPill(index: 3, icon: Icons.track_changes_rounded, label: 'Trackers'),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.borderLight),
            ],
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: tabs,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isPreview
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: const Border(top: BorderSide(color: AppTheme.borderLight, width: 1)),
              ),
              child: NavigationBar(
                selectedIndex: _currentTabIndex,
                backgroundColor: Colors.white,
                indicatorColor: AppTheme.primaryLight,
                elevation: 0,
                height: 65,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentTabIndex = index;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryColor),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_outlined),
                    selectedIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                    label: 'Search',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark_outline_rounded),
                    selectedIcon: Icon(Icons.bookmark_rounded, color: AppTheme.primaryColor),
                    label: 'Saved',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.track_changes_outlined),
                    selectedIcon: Icon(Icons.track_changes_rounded, color: AppTheme.primaryColor),
                    label: 'Trackers',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPreviewTabPill({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: Material(
        color: isSelected ? AppTheme.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              _currentTabIndex = index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final procedureProvider = context.watch<ProcedureProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();

    final user = authProvider.currentUser;
    final procedures = procedureProvider.procedures;
    final categories = categoryProvider.categories;
    final activeProgressList = user != null ? progressProvider.getActiveProgressList(user.id) : [];

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactScreen = screenWidth < 360;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar row for Home tab
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.accentColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'CampusFlow',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
                  tooltip: 'Log Out',
                  onPressed: () {
                    authProvider.logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // User Greeting Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isCompactScreen ? 14 : 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: Text(
                          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()},',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              user?.name ?? 'Student',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Search campus certificates, forms, and services with step-by-step mobile tracking.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Box Shortcut
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentTabIndex = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search certificates, hall tickets, fee waiver...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),

            // Active In-Progress Procedures Section
            if (activeProgressList.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'In-Progress Trackers',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${activeProgressList.length} Active',
                      style: const TextStyle(
                        color: AppTheme.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...activeProgressList.map((progress) {
                final procedure = procedures.firstWhere(
                  (p) => p.id == progress.procedureId,
                  orElse: () => ProcedureModel(
                    id: progress.procedureId,
                    title: 'Procedure #${progress.procedureId}',
                    categoryId: '',
                    categoryName: 'General',
                    description: '',
                    processingTime: '',
                    fee: 0,
                    office: '',
                    workingHours: '',
                    requiredDocuments: [],
                    steps: [],
                  ),
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.pending_actions_rounded,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  procedure.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${progress.completedCount} of ${progress.totalSteps} steps completed',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${progress.percentage}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.progress,
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.tracker,
                              arguments: procedure,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Resume Tracker',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primaryColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),

            // Categories Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Explore Categories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${categories.length} Categories',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dynamic Category Grid with adaptive aspect ratio for phones
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isCompactScreen ? 1.2 : 1.35,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final catColor = _getCategoryColor(cat.name);
                final catIcon = _getCategoryIcon(cat.name);
                final catProceduresCount = procedures.where((p) {
                  return p.categoryName.toLowerCase() == cat.name.toLowerCase() ||
                      p.categoryId.toLowerCase() == cat.id.toLowerCase();
                }).length;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
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
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.categoryProcedures,
                          arguments: cat,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    catIcon,
                                    color: catColor,
                                    size: 20,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$catProceduresCount procedures',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
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
            ),

            const SizedBox(height: 24),

            // Popular Procedures Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Procedures',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (procedures.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentTabIndex = 1;
                      });
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Popular Procedures List
            if (procedures.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: const Center(
                  child: Text(
                    'No procedures available yet.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              ...procedures.take(6).map((procedure) {
                final isFav = user != null &&
                    favoriteProvider.isFavorite(
                      userId: user.id,
                      procedureId: procedure.id,
                    );
                final catColor = _getCategoryColor(procedure.categoryName);
                final catIcon = _getCategoryIcon(procedure.categoryName);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.procedureDetails,
                          arguments: procedure,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                catIcon,
                                color: catColor,
                                size: 20,
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        procedure.categoryName,
                                        style: TextStyle(
                                          color: catColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const Text(' • ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                      Text(
                                        procedure.processingTime,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (user != null)
                              IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFav ? Colors.red : AppTheme.textSecondary,
                                  size: 20,
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
              }),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTrackersTab(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final procedureProvider = context.watch<ProcedureProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in'));
    }

    final allUserProgress = progressProvider.getAllUserProgress(user.id);
    final procedures = procedureProvider.procedures;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Procedure Trackers'),
        automaticallyImplyLeading: false,
      ),
      body: allUserProgress.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.track_changes_rounded,
                        size: 56,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Trackers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'When you start a procedure, it will show up here with live checklist progress.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentTabIndex = 1;
                        });
                      },
                      child: const Text('Explore Procedures'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allUserProgress.length,
              itemBuilder: (context, index) {
                final progress = allUserProgress[index];
                final procedure = procedures.firstWhere(
                  (p) => p.id == progress.procedureId,
                  orElse: () => ProcedureModel(
                    id: progress.procedureId,
                    title: 'Procedure #${progress.procedureId}',
                    categoryId: '',
                    categoryName: 'General',
                    description: '',
                    processingTime: '',
                    fee: 0,
                    office: '',
                    workingHours: '',
                    requiredDocuments: [],
                    steps: [],
                  ),
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: progress.isCompleted ? AppTheme.success.withValues(alpha: 0.3) : AppTheme.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            progress.isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                            color: progress.isCompleted ? AppTheme.success : AppTheme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
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
                                Text(
                                  '${progress.completedCount} of ${progress.totalSteps} steps completed',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: progress.isCompleted
                                  ? AppTheme.success.withValues(alpha: 0.12)
                                  : AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${progress.percentage}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: progress.isCompleted ? AppTheme.success : AppTheme.primaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress.isCompleted ? AppTheme.success : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.tracker,
                              arguments: procedure,
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: Text(progress.isCompleted ? 'View Checklist' : 'Continue Tracking'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}