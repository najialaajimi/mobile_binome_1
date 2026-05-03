import 'storage_service.dart';

class FavoritesService {
  final StorageService _storage = StorageService.instance;

  String _keyFor(String userId) => 'favorites_$userId';

  List<String> getFavorites(String userId) =>
      _storage.getStringList(_keyFor(userId)) ?? [];

  Future<void> addFavorite(String userId, String listingId) async {
    final favs = getFavorites(userId);
    if (!favs.contains(listingId)) {
      favs.add(listingId);
      await _storage.setStringList(_keyFor(userId), favs);
    }
  }

  Future<void> removeFavorite(String userId, String listingId) async {
    final favs = getFavorites(userId);
    favs.remove(listingId);
    await _storage.setStringList(_keyFor(userId), favs);
  }

  bool isFavorite(String userId, String listingId) =>
      getFavorites(userId).contains(listingId);
}
