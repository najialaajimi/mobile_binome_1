import 'package:flutter/material.dart';
import '../../models/listing.dart';
import '../../services/listing_service.dart';
import '../../services/favorites_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final _listingService = ListingService();
  final _favService = FavoritesService();
  final _authService = AuthService();

  Listing? _listing;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _listing = _listingService.getListingById(widget.listingId);
    if (_listing != null) {
      await _listingService.incrementViews(widget.listingId);
    }
    final userId = _authService.getCurrentUser()?.id ?? '';
    setState(() {
      _isFavorite = _favService.isFavorite(userId, widget.listingId);
    });
  }

  Color get _cardColor {
    final idx =
        widget.listingId.hashCode.abs() % AppConstants.listingColors.length;
    return AppConstants.listingColors[idx];
  }

  @override
  Widget build(BuildContext context) {
    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final l = _listing!;
    final userId = _authService.getCurrentUser()?.id ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_cardColor, _cardColor.withAlpha(180)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    AppConstants.propertyTypeIcons[l.type] ?? Icons.home,
                    size: 80,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  if (_isFavorite) {
                    await _favService.removeFavorite(userId, l.id);
                  } else {
                    await _favService.addFavorite(userId, l.id);
                  }
                  setState(() => _isFavorite = !_isFavorite);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _cardColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l.typeLabel,
                          style: TextStyle(
                              color: _cardColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (l.isFurnished) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Meublé',
                            style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${l.views} vues',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${l.address}, ${l.city} ${l.postalCode}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${l.price.toStringAsFixed(0)} €/mois',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                            icon: Icons.meeting_room_outlined,
                            value: '${l.rooms}',
                            label: 'Pièces'),
                        _StatItem(
                            icon: Icons.bed_outlined,
                            value: '${l.bedrooms}',
                            label: 'Chambres'),
                        _StatItem(
                            icon: Icons.bathtub_outlined,
                            value: '${l.bathrooms}',
                            label: 'SdB'),
                        _StatItem(
                            icon: Icons.straighten,
                            value: '${l.surface.toStringAsFixed(0)}m²',
                            label: 'Surface'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.description,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.6),
                  ),
                  if (l.amenities.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Équipements',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: l.amenities
                          .map((a) => Chip(
                                label: Text(a,
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor:
                                    AppColors.primary.withAlpha(15),
                                side: BorderSide(
                                    color:
                                        AppColors.primary.withAlpha(50)),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Propriétaire',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _OwnerCard(ownerId: l.ownerId),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, -3))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.conversations),
                icon: const Icon(Icons.message_outlined),
                label: const Text('Message'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showBookingDialog(context, l),
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Visiter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context, Listing listing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demander une visite'),
        content: const Text(
            'Souhaitez-vous demander une visite pour ce logement ? Le propriétaire vous contactera pour confirmer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande de visite envoyée !'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final String ownerId;
  const _OwnerCard({required this.ownerId});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final users = authService.getAllUsers();
    final ownerList = users.where((u) => u.id == ownerId).toList();
    final owner = ownerList.isNotEmpty ? ownerList.first : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withAlpha(20),
            child: Text(
              owner?.initials ?? '?',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      owner?.fullName ?? 'Propriétaire',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    if (owner?.isVerified == true) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: AppColors.primary, size: 16),
                    ],
                  ],
                ),
                const Text('Propriétaire',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined, color: AppColors.primary),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.conversations),
          ),
        ],
      ),
    );
  }
}
