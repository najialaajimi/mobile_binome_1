import 'package:flutter/material.dart';
import '../../models/listing.dart';
import '../../services/auth_service.dart';
import '../../services/listing_service.dart';
import '../../services/favorites_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/empty_state.dart';

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  final _authService = AuthService();
  final _listingService = ListingService();
  final _favService = FavoritesService();

  int _selectedIndex = 0;
  String? _selectedType;
  List<Listing> _listings = [];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  void _loadListings() {
    setState(() {
      _listings = _selectedType != null
          ? _listingService.searchListings(type: _selectedType)
          : _listingService.searchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();
    final pages = [
      _buildHome(user?.fullName ?? 'Utilisateur'),
      _buildSearchTab(),
      _buildFavoritesTab(user?.id ?? ''),
      _buildBookingsTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Recherche'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoris'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Visites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHome(String name) {
    return RefreshIndicator(
      onRefresh: () async => _loadListings(),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Bonjour, ${name.split(' ').first} 👋',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Trouvez votre logement idéal',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.message_outlined, color: Colors.white),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.conversations),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      const Text(
                        'Rechercher une ville, quartier...',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _TypeChip(
                    label: 'Tous',
                    isSelected: _selectedType == null,
                    onTap: () {
                      setState(() => _selectedType = null);
                      _loadListings();
                    },
                  ),
                  ...AppConstants.propertyTypeLabels.entries.map((e) =>
                      _TypeChip(
                        label: e.value,
                        isSelected: _selectedType == e.key,
                        onTap: () {
                          setState(() => _selectedType = e.key);
                          _loadListings();
                        },
                      )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  _AiCard(
                    icon: '🤖',
                    title: 'Recommandations IA',
                    subtitle: 'Découvrez des logements adaptés à votre profil',
                    buttonLabel: 'Voir mes recommandations',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.aiRecommendations),
                  ),
                  const SizedBox(height: 10),
                  _AiCard(
                    icon: '👥',
                    title: 'Trouver un binôme',
                    subtitle: 'Trouvez un colocataire compatible',
                    buttonLabel: 'Chercher un binôme',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.roommateFinder),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Annonces disponibles',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
            ),
          ),
          if (_listings.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.home_outlined,
                title: 'Aucune annonce',
                message: 'Aucun logement ne correspond à vos critères.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final listing = _listings[i];
                    final userId =
                        _authService.getCurrentUser()?.id ?? '';
                    return ListingCard(
                      listing: listing,
                      isFavorite: _favService.isFavorite(userId, listing.id),
                      onFavoriteToggle: () async {
                        if (_favService.isFavorite(userId, listing.id)) {
                          await _favService.removeFavorite(userId, listing.id);
                        } else {
                          await _favService.addFavorite(userId, listing.id);
                        }
                        setState(() {});
                      },
                    );
                  },
                  childCount: _listings.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _SearchTabPlaceholder(),
      ),
    );
  }

  Widget _buildFavoritesTab(String userId) {
    return _FavoritesTabContent(userId: userId);
  }

  Widget _buildBookingsTab() {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _BookingsTabPlaceholder(),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _ProfileTabPlaceholder(),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _FavoritesTabContent extends StatefulWidget {
  final String userId;
  const _FavoritesTabContent({required this.userId});

  @override
  State<_FavoritesTabContent> createState() => _FavoritesTabContentState();
}

class _FavoritesTabContentState extends State<_FavoritesTabContent> {
  final _listingService = ListingService();
  final _favService = FavoritesService();

  List<Listing> get _favorites {
    final ids = _favService.getFavorites(widget.userId);
    return ids
        .map((id) => _listingService.getListingById(id))
        .whereType<Listing>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final favs = _favorites;
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: favs.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_outline,
              title: 'Aucun favori',
              message:
                  'Ajoutez des logements à vos favoris en appuyant sur le cœur.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favs.length,
              itemBuilder: (_, i) => Dismissible(
                key: Key(favs[i].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error,
                  child:
                      const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await _favService.removeFavorite(
                      widget.userId, favs[i].id);
                  setState(() {});
                },
                child: ListingCard(
                  listing: favs[i],
                  isFavorite: true,
                  onFavoriteToggle: () async {
                    await _favService.removeFavorite(
                        widget.userId, favs[i].id);
                    setState(() {});
                  },
                ),
              ),
            ),
    );
  }
}

class _SearchTabPlaceholder extends StatelessWidget {
  const _SearchTabPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const TenantSearchWrapper(),
      ),
    );
  }
}

class TenantSearchWrapper extends StatelessWidget {
  const TenantSearchWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    // Import and use the real search screen
    return const _InlineSearchScreen();
  }
}

class _InlineSearchScreen extends StatefulWidget {
  const _InlineSearchScreen();
  @override
  State<_InlineSearchScreen> createState() => _InlineSearchScreenState();
}

class _InlineSearchScreenState extends State<_InlineSearchScreen> {
  final _listingService = ListingService();
  final _cityCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  String? _type;
  bool? _isFurnished;
  List<Listing> _results = [];
  bool _searched = false;

  void _search() {
    setState(() {
      _searched = true;
      _results = _listingService.searchListings(
        city: _cityCtrl.text,
        minPrice: double.tryParse(_minPriceCtrl.text),
        maxPrice: double.tryParse(_maxPriceCtrl.text),
        type: _type,
        isFurnished: _isFurnished,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _cityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ville ou quartier',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix min (TND)',
                          prefixIcon: Icon(Icons.monetization_on_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix max (TND)',
                          prefixIcon: Icon(Icons.monetization_on_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Tous types',
                        selected: _type == null,
                        onTap: () => setState(() => _type = null),
                      ),
                      ...AppConstants.propertyTypeLabels.entries.map(
                        (e) => _FilterChip(
                          label: e.value,
                          selected: _type == e.key,
                          onTap: () => setState(() => _type = e.key),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Meublé uniquement'),
                    const Spacer(),
                    Switch(
                      value: _isFurnished ?? false,
                      onChanged: (v) =>
                          setState(() => _isFurnished = v ? true : null),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _search,
                    icon: const Icon(Icons.search),
                    label: const Text('Rechercher'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _searched
                ? (_results.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'Aucun résultat',
                        message: 'Aucun logement ne correspond à votre recherche.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (_, i) =>
                            ListingCard(listing: _results[i]),
                      ))
                : const Center(
                    child: Text(
                      'Utilisez les filtres ci-dessus\npour rechercher un logement',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _BookingsTabPlaceholder extends StatelessWidget {
  const _BookingsTabPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const TenantBookingsWrapper();
  }
}

class TenantBookingsWrapper extends StatelessWidget {
  const TenantBookingsWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return const _InlineBookingsScreen();
  }
}

class _InlineBookingsScreen extends StatelessWidget {
  const _InlineBookingsScreen();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Visites'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'À venir'),
              Tab(text: 'Passées'),
              Tab(text: 'Annulées'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'Aucune visite à venir',
              message: 'Vous n\'avez pas de visites planifiées.',
            ),
            EmptyState(
              icon: Icons.history,
              title: 'Aucune visite passée',
              message: 'Vos visites passées apparaîtront ici.',
            ),
            EmptyState(
              icon: Icons.cancel_outlined,
              title: 'Aucune visite annulée',
              message: 'Vous n\'avez aucune visite annulée.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTabPlaceholder extends StatelessWidget {
  const _ProfileTabPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const TenantProfileWrapper();
  }
}

class TenantProfileWrapper extends StatelessWidget {
  const TenantProfileWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return const _InlineTenantProfileScreen();
  }
}

class _InlineTenantProfileScreen extends StatelessWidget {
  const _InlineTenantProfileScreen();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.getCurrentUser();
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: ListView(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (user?.isVerified == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Vérifié',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          _ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Informations personnelles',
              onTap: () {}),
          _ProfileMenuItem(
              icon: Icons.tune,
              title: 'Préférences',
              onTap: () {}),
          _ProfileMenuItem(
              icon: Icons.description_outlined,
              title: 'Mes documents',
              onTap: () {}),
          _ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Aide et support',
              onTap: () {}),
          _ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'À propos',
              onTap: () {}),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Se déconnecter',
                style: TextStyle(color: AppColors.error)),
            onTap: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.profileChoice);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class _AiCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;
  const _AiCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.buttonLabel,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(15),
            AppColors.primaryLight.withAlpha(10)
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(buttonLabel,
                style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
