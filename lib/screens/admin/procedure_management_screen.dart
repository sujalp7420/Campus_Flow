import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/procedure_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/procedure_provider.dart';
import '../../theme/app_theme.dart';

class ProcedureManagementScreen extends StatefulWidget {
  final bool isTab;
  const ProcedureManagementScreen({super.key, this.isTab = false});

  @override
  State<ProcedureManagementScreen> createState() => _ProcedureManagementScreenState();
}

class _ProcedureManagementScreenState extends State<ProcedureManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDemoNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Demo Mode: Adding, editing, and deleting procedures is disabled. View-only access.',
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final procedureProvider = context.watch<ProcedureProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final isDemo = context.watch<AuthProvider>().isDemo;

    final categories = categoryProvider.categories;
    final allProcedures = procedureProvider.procedures;

    final filteredProcedures = allProcedures.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.categoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          p.categoryName.toLowerCase() == _selectedCategory.toLowerCase() ||
          p.categoryId.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Manage Procedures'),
        automaticallyImplyLeading: !widget.isTab,
      ),
      body: Column(
        children: [
          // Demo Banner if in Demo mode
          if (isDemo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.warning.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo Mode (View Only): Adding & modifying procedures is disabled.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search procedures, office, fees...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Category Filter Chips
          if (categories.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedCategory == 'All',
                      label: const Text('All'),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = 'All';
                        });
                      },
                      selectedColor: AppTheme.primaryLight,
                      labelStyle: TextStyle(
                        color: _selectedCategory == 'All' ? AppTheme.primaryColor : AppTheme.textPrimary,
                        fontWeight: _selectedCategory == 'All' ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...categories.map((cat) {
                    final isSelected = _selectedCategory == cat.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat.name),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat.name : 'All';
                          });
                        },
                        selectedColor: AppTheme.primaryLight,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

          Expanded(
            child: filteredProcedures.isEmpty
                ? Center(
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
                            _searchQuery.isEmpty && _selectedCategory == 'All'
                                ? 'No procedures found.'
                                : 'No matching procedures',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isEmpty && _selectedCategory == 'All'
                                ? 'Add your first campus procedure with steps and documents.'
                                : 'Try adjusting your search query or category filter.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProcedures.length,
                    itemBuilder: (context, index) {
                      final procedure = filteredProcedures[index];

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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      procedure.categoryName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    procedure.fee == 0 ? 'Free' : '₹${procedure.fee.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const Text(' • ', style: TextStyle(color: AppTheme.textSecondary)),
                                  Text(
                                    procedure.processingTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
                            onSelected: (value) {
                              if (isDemo) {
                                _showDemoNotice(context);
                                return;
                              }
                              if (value == 'edit') {
                                _showProcedureDialog(context, procedure: procedure);
                              }
                              if (value == 'delete') {
                                _deleteProcedure(context, procedure);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      isDemo ? Icons.lock_outline_rounded : Icons.edit_outlined,
                                      size: 18,
                                      color: isDemo ? AppTheme.textSecondary : AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(isDemo ? 'Edit (Disabled)' : 'Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      isDemo ? Icons.lock_outline_rounded : Icons.delete_outline_rounded,
                                      size: 18,
                                      color: isDemo ? AppTheme.textSecondary : AppTheme.danger,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      isDemo ? 'Delete (Disabled)' : 'Delete',
                                      style: TextStyle(
                                        color: isDemo ? AppTheme.textSecondary : AppTheme.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDemo ? Colors.grey.shade400 : AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          if (isDemo) {
            _showDemoNotice(context);
          } else {
            _showProcedureDialog(context);
          }
        },
        icon: Icon(isDemo ? Icons.lock_outline_rounded : Icons.add_rounded),
        label: Text(
          isDemo ? 'Add Procedure (Disabled)' : 'Add Procedure',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showProcedureDialog(
    BuildContext context, {
    ProcedureModel? procedure,
  }) {
    final bool isEditing = procedure != null;

    final titleController = TextEditingController(text: procedure?.title ?? '');
    final descriptionController = TextEditingController(text: procedure?.description ?? '');
    final processingTimeController = TextEditingController(text: procedure?.processingTime ?? '1-2 Days');
    final feeController = TextEditingController(
      text: procedure != null ? procedure.fee.toStringAsFixed(0) : '0',
    );
    final officeController = TextEditingController(text: procedure?.office ?? 'Student Section (Room 102)');
    final workingHoursController = TextEditingController(text: procedure?.workingHours ?? '10:00 AM - 4:00 PM');
    final documentsController = TextEditingController(
      text: procedure?.requiredDocuments.join('\n') ?? '',
    );
    final stepsController = TextEditingController(
      text: procedure?.steps.join('\n') ?? '',
    );

    final formKey = GlobalKey<FormState>();
    final categories = context.read<CategoryProvider>().categories;

    String? selectedCategoryId = procedure?.categoryId.isNotEmpty == true
        ? procedure?.categoryId
        : (categories.isNotEmpty ? categories.first.id : 'cert');

    String selectedCategoryName = procedure?.categoryName.isNotEmpty == true
        ? procedure!.categoryName
        : (categories.isNotEmpty ? categories.first.name : 'Certificates');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(
                isEditing ? 'Edit Procedure' : 'Add New Procedure',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Procedure Title',
                            hintText: 'e.g. Bonafide Certificate',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter procedure title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          initialValue: categories.any((c) => c.id == selectedCategoryId)
                              ? selectedCategoryId
                              : (categories.isNotEmpty ? categories.first.id : null),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedCategoryId = value;
                                final found = categories.firstWhere(
                                  (c) => c.id == value,
                                  orElse: () => categories.first,
                                );
                                selectedCategoryName = found.name;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Purpose and details of procedure',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: processingTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Processing Time',
                                  hintText: 'e.g. 2 Days',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: feeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Fee (₹)',
                                  hintText: '0',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: officeController,
                          decoration: const InputDecoration(
                            labelText: 'Office / Location',
                            hintText: 'e.g. Student Section Room 102',
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: workingHoursController,
                          decoration: const InputDecoration(
                            labelText: 'Working Hours',
                            hintText: 'e.g. 10:00 AM - 4:00 PM',
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: documentsController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Required Documents',
                            hintText: 'Enter one document per line',
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: stepsController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Procedure Steps Flow',
                            hintText: 'Enter one step per line',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final provider = context.read<ProcedureProvider>();
                    final double fee = double.tryParse(feeController.text.trim()) ?? 0.0;

                    final docs = documentsController.text
                        .split('\n')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    final steps = stepsController.text
                        .split('\n')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    try {
                      if (isEditing) {
                        await provider.updateProcedure(
                          id: procedure.id,
                          title: titleController.text.trim(),
                          categoryId: selectedCategoryId ?? 'cert',
                          categoryName: selectedCategoryName,
                          description: descriptionController.text.trim(),
                          processingTime: processingTimeController.text.trim(),
                          fee: fee,
                          office: officeController.text.trim(),
                          workingHours: workingHoursController.text.trim(),
                          requiredDocuments: docs,
                          steps: steps,
                        );
                      } else {
                        await provider.addProcedure(
                          title: titleController.text.trim(),
                          categoryId: selectedCategoryId ?? 'cert',
                          categoryName: selectedCategoryName,
                          description: descriptionController.text.trim(),
                          processingTime: processingTimeController.text.trim(),
                          fee: fee,
                          office: officeController.text.trim(),
                          workingHours: workingHoursController.text.trim(),
                          requiredDocuments: docs,
                          steps: steps,
                        );
                      }

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Add Procedure'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteProcedure(
    BuildContext context,
    ProcedureModel procedure,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Delete Procedure'),
          content: Text('Are you sure you want to delete "${procedure.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () async {
                try {
                  await context.read<ProcedureProvider>().deleteProcedure(procedure.id);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}