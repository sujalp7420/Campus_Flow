import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isUser => _currentUser?.role == 'user';
  bool get isDemo => _currentUser?.isDemo ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(
    String email,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = response.user;

      if (authUser == null) {
        _errorMessage = 'Invalid login credentials.';
        return false;
      }

      try {
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', authUser.id)
            .single();

        _currentUser = UserModel.fromMap(profile, isDemo: false);
      } catch (_) {
        // Fallback if profile row is missing
        _currentUser = UserModel(
          id: authUser.id,
          name: authUser.userMetadata?['name']?.toString() ?? 'Student',
          email: authUser.email ?? email,
          role: email.toLowerCase().contains('admin') ? 'admin' : 'user',
          isDemo: false,
        );
      }

      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      _errorMessage = 'An unexpected error occurred. Please check your connection.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Quick demo sign-in helper for instant review/testing
  void loginAsDemoUser({bool asAdmin = false}) {
    _currentUser = UserModel(
      id: asAdmin ? 'demo-admin-id' : 'demo-student-id',
      name: asAdmin ? 'Campus Admin (Demo)' : 'Alex Johnson (Demo)',
      email: asAdmin ? 'admin@campus.edu' : 'alex.student@campus.edu',
      role: asAdmin ? 'admin' : 'user',
      isDemo: true,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}

    _currentUser = null;
    notifyListeners();
  }
}