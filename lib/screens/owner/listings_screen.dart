import 'package:flutter/material.dart';
import '../../services/listing_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/empty_state.dart';

class OwnerListingsScreen extends StatefulWidget {
  const OwnerListingsScreen({super.key});

  @override
  State<OwnerListingsScreen> createState() => _OwnerListingsScreenState();
}

class _OwnerListingsScreenState extends State<OwnerListingsScreen> {
  final _listingService = ListingService();
  final _authService = AuthService();

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'draft':
        return AppColors.secondary;
      case 'archived':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Actif';
      case 'draft':
        return 'Brouillon';
      case 'archived':
        return 'Archivé';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = _authService.getCurrentUser()?.id ?? '';
    final listings = _listingService.getListingsByOwner(ownerId);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Annonces')),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.ownerCreateListing)
                .then((_) => setState(() {})),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: listings.isEmpty
          ? EmptyState(
              icon: Icons.home_outlined,
              title: 'Aucune annonce',
              message: 'Créez votre première annonce.',
              actionLabel: 'Créer une annonce',
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.ownerCreateListing)
                      .then((_) => setState(() {})),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              itemBuilder: (_, i) {
                final l = listings[i];
                final cardColor = AppConstants.listingColors[
                    l.id.hashCode.abs() % AppConstants.listingColors.length];

                return Dismissible(
                  key: Key(l.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Supprimer l\'annonce'),
                      content: const Text(
                          'Êtes-vous sûr de vouloir supprimer cette annonce ?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Annuler')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) async {
                    await _listingService.deleteListing(l.id);
                    setState(() {});
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cardColor, cardColor.withAlpha(180)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          AppConstants.propertyTypeIcons[l.type] ?? Icons.home,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      title: Text(l.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l.city} • ${l.price.toStringAsFixed(0)} TND/mois',
                              style: const TextStyle(fontSize: 12)),
                          Row(
                            children: [
                              const Icon(Icons.remove_red_eye_outlined,
                                  size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 3),
                              Text('${l.views} vues',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(l.status).withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(l.status),
                          style: TextStyle(
                              color: _statusColor(l.status),
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
