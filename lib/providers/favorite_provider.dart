import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  final Map<String, Set<String>> _favorites = {};

  Set<String> _getUserFavorites(String userId) {
    return _favorites.putIfAbsent(
      userId,
      () => <String>{},
    );
  }

  Future<void> loadFavorites(String userId) async {
    try {
      final data = await _supabase
          .from('favorites')
          .select('procedure_id')
          .eq('user_id', userId);

      final favorites = _getUserFavorites(userId);
      favorites.clear();

      for (final item in data as List) {
        favorites.add(item['procedure_id'].toString());
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Load favorites error: $e');
    }
  }

  bool isFavorite({
    required String userId,
    required String procedureId,
  }) {
    return _favorites[userId]?.contains(procedureId) ?? false;
  }

  Future<void> toggleFavorite({
    required String userId,
    required String procedureId,
  }) async {
    final favorites = _getUserFavorites(userId);
    final wasFavorite = favorites.contains(procedureId);

    // Update local state optimistically
    if (wasFavorite) {
      favorites.remove(procedureId);
    } else {
      favorites.add(procedureId);
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('procedure_id', procedureId);
      } else {
        await _supabase.from('favorites').insert({
          'user_id': userId,
          'procedure_id': procedureId,
        });
      }
    } catch (e) {
      debugPrint('Toggle favorite Supabase error: $e');
      // Even if remote sync fails (e.g. offline or table creation delay), keep user state responsive
    }
  }

  Set<String> getFavoriteIds(String userId) {
    return Set.unmodifiable(
      _favorites[userId] ?? <String>{},
    );
  }
}