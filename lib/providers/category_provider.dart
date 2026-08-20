import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  final List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;

  // Default standard campus categories used if database hasn't been seeded yet
  static final List<CategoryModel> defaultCategories = [
    CategoryModel(id: 'cert', name: 'Certificates', description: 'Bonafide, Character, Degree, Leaving, and Migration certificates'),
    CategoryModel(id: 'acad', name: 'Academic', description: 'Course registration, transcripts, grade disputes, and credit transfer'),
    CategoryModel(id: 'exam', name: 'Examination', description: 'Exam hall tickets, re-evaluation, backlog exam forms, and verification'),
    CategoryModel(id: 'fin', name: 'Finance', description: 'Tuition fees, scholarship verification, refund, and fee receipts'),
    CategoryModel(id: 'host', name: 'Hostel', description: 'Hostel admission, room allocation, maintenance request, and mess waiver'),
    CategoryModel(id: 'lib', name: 'Library', description: 'Book issue, digital library pass, book renewal, and library no-dues'),
  ];

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('categories')
          .select()
          .order('created_at');

      final loadedList = (data as List)
          .map((item) => CategoryModel.fromMap(item))
          .toList();

      _categories.clear();
      if (loadedList.isNotEmpty) {
        _categories.addAll(loadedList);
      } else {
        // Fallback to default campus categories
        _categories.addAll(defaultCategories);
      }
    } catch (e) {
      debugPrint('Load categories error: $e');
      if (_categories.isEmpty) {
        _categories.addAll(defaultCategories);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory({
    required String name,
    required String description,
  }) async {
    try {
      await _supabase.from('categories').insert({
        'name': name,
        'description': description,
      });

      await loadCategories();
    } catch (e) {
      debugPrint('Add category error: $e');
      rethrow;
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      await _supabase.from('categories').update({
        'name': name,
        'description': description,
      }).eq('id', id);

      await loadCategories();
    } catch (e) {
      debugPrint('Update category error: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
      await loadCategories();
    } catch (e) {
      debugPrint('Delete category error: $e');
      rethrow;
    }
  }
}