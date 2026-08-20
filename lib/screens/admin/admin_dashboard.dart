import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/procedure_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../user/user_home.dart';
import 'category_management_screen.dart';
import 'procedure_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  final int initialTabIndex;
  const AdminDashboard({super.key, this.initialTabIndex = 0});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<CategoryProvider>().loadCategories(),
      context.read<ProcedureProvider>().loadProcedures(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildDashboardOverview(context),
      const CategoryManagementScreen(isTab: true),
      const ProcedureManagementScreen(isTab: true),
      const UserHome(isPreview: true),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentTabIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
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
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryColor),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category_rounded, color: AppTheme.primaryColor),
              label: 'Category',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description_rounded, color: AppTheme.primaryColor),
              label: 'Procedure',
            ),
            NavigationDestination(
              icon: Icon(Icons.visibility_outlined),
              selectedIcon: Icon(Icons.visibility_rounded, color: AppTheme.primaryColor),
              label: 'Preview',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardOverview(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final procedureProvider = context.watch<ProcedureProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final user = authProvider.currentUser;
    final procedures = procedureProvider.procedures;
    final proceduresCount = procedures.length;
    final categoriesCount = categoryProvider.categories.length;
    final totalStepsCount = procedures.fold<int>(0, (sum, p) => sum + p.steps.length);
    final freeProceduresCount = procedures.where((p) => p.fee == 0).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Preview Student Mode',
            onPressed: () {
              setState(() {
                _currentTabIndex = 3;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Welcome, ${user?.name ?? 'Admin'} 👋',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (authProvider.isDemo) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade400,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'DEMO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authProvider.isDemo
                                ? 'Demo Mode (View Only): Preview procedures and categories without adding/modifying data.'
                                : 'Manage procedures, categories, and student workflows directly from your mobile tabs.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // System Overview Header
              const Text(
                'System Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 14),

              // Live Metrics Grid (Clickable to jump to tabs)
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.description_rounded,
                      iconColor: AppTheme.primaryColor,
                      title: 'Procedures',
                      value: '$proceduresCount',
                      subtitle: 'Tap to manage',
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 2; // Procedure Tab
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.category_rounded,
                      iconColor: AppTheme.accentColor,
                      title: 'Categories',
                      value: '$categoriesCount',
                      subtitle: 'Tap to manage',
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 1; // Category Tab
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.checklist_rounded,
                      iconColor: AppTheme.success,
                      title: 'Total Steps',
                      value: '$totalStepsCount',
                      subtitle: 'Active workflows',
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 2; // Procedure Tab
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.money_off_rounded,
                      iconColor: AppTheme.secondaryColor,
                      title: 'Free Procedures',
                      value: '$freeProceduresCount',
                      subtitle: '${proceduresCount > 0 ? ((freeProceduresCount / proceduresCount) * 100).toStringAsFixed(0) : 0}% of all',
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 2; // Procedure Tab
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Quick Actions Header
              const Text(
                'Quick Navigation & Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 14),

              _AdminActionTile(
                icon: Icons.category_rounded,
                iconColor: AppTheme.accentColor,
                title: 'Category Management',
                subtitle: 'Organize campus departments (Certificates, Academic, Hostels, etc.)',
                onTap: () {
                  setState(() {
                    _currentTabIndex = 1; // Category Tab
                  });
                },
              ),

              _AdminActionTile(
                icon: Icons.description_rounded,
                iconColor: AppTheme.primaryColor,
                title: 'Procedure Management',
                subtitle: 'Add, update, or remove student procedures and step-by-step checklists',
                onTap: () {
                  setState(() {
                    _currentTabIndex = 2; // Procedure Tab
                  });
                },
              ),

              _AdminActionTile(
                icon: Icons.visibility_rounded,
                iconColor: AppTheme.success,
                title: 'Live Student Preview Mode',
                subtitle: 'Interact with student search, saved procedures, and real-time trackers',
                onTap: () {
                  setState(() {
                    _currentTabIndex = 3; // Preview Tab
                  });
                },
              ),

              const SizedBox(height: 24),

              // Recent Procedures Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Procedures',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentTabIndex = 2; // Procedure Tab
                      });
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (procedures.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: const Center(
                    child: Text(
                      'No procedures added yet.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ...procedures.take(4).map((procedure) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryLight,
                        child: Text(
                          procedure.title.isNotEmpty ? procedure.title[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        procedure.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            procedure.categoryName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(' • ', style: TextStyle(color: AppTheme.textSecondary)),
                          Text(
                            procedure.fee == 0 ? 'Free' : '₹${procedure.fee.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 2; // Jump to Procedure tab
                        });
                      },
                    ),
                  );
                }),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppTheme.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}