import 'package:flutter/material.dart';
import '../../models/listing.dart';
import '../../services/favorites_service.dart';
import '../../services/listing_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/empty_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favService = FavoritesService();
  final _listingService = ListingService();
  final _authService = AuthService();

  List<Listing> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final userId = _authService.getCurrentUser()?.id ?? '';
    final ids = _favService.getFavorites(userId);
    setState(() {
      _favorites = ids
          .map((id) => _listingService.getListingById(id))
          .whereType<Listing>()
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.getCurrentUser()?.id ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: _favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_outline,
              title: 'Aucun favori',
              message:
                  'Ajoutez des logements à vos favoris en appuyant sur le cœur.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (_, i) {
                final listing = _favorites[i];
                return Dismissible(
                  key: Key(listing.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await _favService.removeFavorite(userId, listing.id);
                    _loadFavorites();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Retiré des favoris')),
                      );
                    }
                  },
                  child: ListingCard(
                    listing: listing,
                    isFavorite: true,
                    onFavoriteToggle: () async {
                      await _favService.removeFavorite(userId, listing.id);
                      _loadFavorites();
                    },
                  ),
                );
              },
            ),
    );
  }
}
