import 'package:advertising_app/data/model/favorites_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:advertising_app/data/repository/favorites_repository.dart';
import 'package:advertising_app/data/model/favorite_item_interface_model.dart';
import 'package:advertising_app/data/web_services/api_service.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:advertising_app/constant/string.dart';

mixin FavoritesHelper<T extends StatefulWidget> on State<T> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FavoritesRepository _favoritesRepository = FavoritesRepository(ApiService());
  
  bool _isAddingToFavorites = false;
  Set<int> _favoriteAdIds = <int>{};

  bool get isAddingToFavorites => _isAddingToFavorites;
  
  /// Check if an ad is in favorites
  bool isAdInFavorites(int adId) {
    return _favoriteAdIds.contains(adId);
  }

  /// Load user's favorite ad IDs from storage or API
  Future<void> loadFavoriteIds() async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId != null) {
        // Here you could load from API or local storage
        // For now, we'll use a simple approach
        final favoriteIds = await _storage.read(key: 'favorite_ids_$userId');
        if (favoriteIds != null) {
          final ids = favoriteIds.split(',').map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toSet();
          setState(() {
            _favoriteAdIds = ids;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading favorite IDs: $e');
    }
  }

  /// Save favorite ad IDs to storage
  Future<void> _saveFavoriteIds() async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId != null) {
        final idsString = _favoriteAdIds.join(',');
        await _storage.write(key: 'favorite_ids_$userId', value: idsString);
      }
    } catch (e) {
      debugPrint('Error saving favorite IDs: $e');
    }
  }

  /// Handle add to favorite with authentication check
  Future<void> handleAddToFavorite(FavoriteItemInterface item, {VoidCallback? onSuccess}) async {
    // Check if user is authenticated
    final userId = await _storage.read(key: 'user_id');
    
    if (userId == null) {
      // Show guest user warning dialog
      _showGuestWarningDialog();
      return;
    }

    // Show confirmation dialog for authenticated users
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).add_to_favorite, style: const TextStyle(color: KTextColor, fontSize: 16)),
        content: Text(S.of(context).confirm_add_to_favorite, style: const TextStyle(color: KTextColor, fontSize: 18)),
        actions: [
          TextButton(
            child: Text(S.of(context).cancel, style: const TextStyle(color: KTextColor, fontSize: 20)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: _isAddingToFavorites 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(S.of(context).yes, style: const TextStyle(color: KTextColor, fontSize: 20)),
            onPressed: _isAddingToFavorites ? null : () async {
              await _addToFavorites(item, onSuccess: onSuccess);
            },
          ),
        ],
      ),
    );
  }

  /// Add item to favorites
  Future<void> _addToFavorites(FavoriteItemInterface item, {VoidCallback? onSuccess}) async {
    setState(() {
      _isAddingToFavorites = true;
    });

    try {
      // Get ad_id and category from the item
      int adId;
      String categorySlug;

      // Check if the item is a FavoriteItem (from favorites screen)
      if (item is FavoriteItem) {
        final favoriteItem = item as FavoriteItem;
        adId = favoriteItem.ad.id;
        categorySlug = favoriteItem.ad.addCategory;
      } else {
        // For other item types, try to get id from the interface
        final itemId = item.id;
        if (itemId is int) {
          adId = itemId;
        } else if (itemId is String) {
          adId = int.tryParse(itemId) ?? 0;
        } else {
          adId = 0;
        }
        
        categorySlug = item.addCategory;
      }

      if (adId == 0) {
        throw Exception('Invalid ad ID');
      }

      // Get user ID from storage
      final userIdString = await _storage.read(key: 'user_id');
      final userId = int.tryParse(userIdString ?? '0') ?? 0;
      
      if (userId == 0) {
        throw Exception('User ID not found');
      }

      // Call the API to add to favorites
      await _favoritesRepository.addToFavorites(
        adId: adId,
        categorySlug: categorySlug,
        userId: userId,
      );

      // Add to local favorites set
      setState(() {
        _favoriteAdIds.add(adId);
      });
      
      // Save to storage
      await _saveFavoriteIds();

      Navigator.pop(context); // Close dialog
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).added_to_favorite),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Call success callback
      onSuccess?.call();

    } catch (e) {
      Navigator.pop(context); // Close dialog
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to favorites: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isAddingToFavorites = false;
      });
    }
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(int adId) async {
    try {
      setState(() {
        _favoriteAdIds.remove(adId);
      });
      await _saveFavoriteIds();
      
      // Here you could also call API to remove from server
      // await _favoritesRepository.removeFromFavorites(adId: adId, userId: userId);
      
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
    }
  }

  /// Build the favorite icon based on current state
  Widget buildFavoriteIcon(FavoriteItemInterface item, {VoidCallback? onAddToFavorite, VoidCallback? onRemoveFromFavorite}) {
    final adId = _getAdId(item);
    final isFavorite = isAdInFavorites(adId);
    
    if (isFavorite) {
      // Show red filled heart for favorited items
      return IconButton(
        icon: const Icon(Icons.favorite, color: Colors.red),
        onPressed: () async {
          await removeFromFavorites(adId);
          onRemoveFromFavorite?.call();
        },
      );
    } else if (onAddToFavorite != null) {
      // Show empty heart for non-favorited items that can be added
      return IconButton(
        icon: const Icon(Icons.favorite_border, color: Colors.grey),
        onPressed: () => handleAddToFavorite(item, onSuccess: onAddToFavorite),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Get ad ID from item
  int _getAdId(FavoriteItemInterface item) {
    if (item is FavoriteItem) {
      return (item as FavoriteItem).ad.id;
    } else {
      final itemId = item.id;
      if (itemId is int) {
        return itemId;
      } else if (itemId is String) {
        return int.tryParse(itemId) ?? 0;
      } else {
        return 0;
      }
    }
  }

  void _showGuestWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الدخول مطلوب', style: TextStyle(color: KTextColor, fontSize: 18)),
        content: const Text('يجب تسجيل الدخول أولاً لإضافة الإعلانات إلى المفضلة', style: TextStyle(color: KTextColor, fontSize: 16)),
        actions: [
          TextButton(
            child: const Text('إلغاء', style: TextStyle(color: KTextColor, fontSize: 16)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('تسجيل الدخول', style: TextStyle(color: Colors.blue, fontSize: 16)),
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              // Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}