import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/listing_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _listingService = ListingService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = _authService.getAllUsers();
    final listings = _listingService.getListings();
    final tenants =
        users.where((u) => u.role == AppConstants.roleTenant).length;
    final owners =
        users.where((u) => u.role == AppConstants.roleOwner).length;
    final activeListings =
        listings.where((l) => l.status == 'active').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.profileChoice);
              }
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tableau de bord',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      StatCard(
                        title: 'Locataires',
                        value: '$tenants',
                        icon: Icons.people_outline,
                        color: AppColors.primary,
                      ),
                      StatCard(
                        title: 'Propriétaires',
                        value: '$owners',
                        icon: Icons.business_outlined,
                        color: const Color(0xFF2E7D32),
                      ),
                      StatCard(
                        title: 'Annonces actives',
                        value: '$activeListings',
                        icon: Icons.home_outlined,
                        color: AppColors.secondary,
                      ),
                      StatCard(
                        title: 'Total annonces',
                        value: '${listings.length}',
                        icon: Icons.list_alt_outlined,
                        color: const Color(0xFF6A1B9A),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(text: 'Utilisateurs (${users.length})'),
                      Tab(text: 'Annonces (${listings.length})'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildUsersTab(users),
            _buildListingsTab(listings),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(List users) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final user = users[i];
        Color roleColor;
        String roleLabel;
        switch (user.role) {
          case AppConstants.roleAdmin:
            roleColor = const Color(0xFF6A1B9A);
            roleLabel = 'Admin';
            break;
          case AppConstants.roleOwner:
            roleColor = const Color(0xFF2E7D32);
            roleLabel = 'Propriétaire';
            break;
          default:
            roleColor = AppColors.primary;
            roleLabel = 'Locataire';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: roleColor.withAlpha(20),
              child: Text(
                user.initials,
                style: TextStyle(
                    color: roleColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Text(user.fullName,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                if (user.isVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified,
                      color: AppColors.primary, size: 14),
                ],
              ],
            ),
            subtitle: Text(user.email,
                style: const TextStyle(fontSize: 12)),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(roleLabel,
                  style: TextStyle(
                      color: roleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
            onLongPress: user.role != AppConstants.roleAdmin
                ? () => _showUserActions(context, user)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildListingsTab(List listings) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: listings.length,
      itemBuilder: (_, i) {
        final l = listings[i];
        final cardColor = AppConstants.listingColors[
            l.id.hashCode.abs() % AppConstants.listingColors.length];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cardColor, cardColor.withAlpha(180)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppConstants.propertyTypeIcons[l.type] ?? Icons.home,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(l.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            subtitle: Text(
                '${l.city} • ${l.price.toStringAsFixed(0)} €/mois',
                style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDeleteListing(context, l.id, l.title),
            ),
          ),
        );
      },
    );
  }

  void _showUserActions(BuildContext context, user) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Supprimer ${user.fullName}',
                  style: const TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(ctx);
                await _authService.deleteUser(user.id);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteListing(
      BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'annonce'),
        content: Text('Supprimer "$title" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _listingService.deleteListing(id);
              setState(() {});
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
