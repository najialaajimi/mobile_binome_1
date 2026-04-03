import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/listing_service.dart';
import '../../services/booking_service.dart';
import '../../services/application_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/stat_card.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final _authService = AuthService();
  final _listingService = ListingService();
  final _bookingService = BookingService();
  final _appService = ApplicationService();

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      _buildListingsTab(),
      _buildApplicationsTab(),
      _buildAgendaTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Tableau de bord'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'Annonces'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Candidatures'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Agenda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final user = _authService.getCurrentUser();
    final ownerId = user?.id ?? '';
    final listings = _listingService.getListingsByOwner(ownerId);
    final activeListings =
        listings.where((l) => l.status == 'active').length;
    final bookings = _bookingService.getBookingsByOwner(ownerId);
    final pendingBookings = bookings
        .where((b) =>
            b.status == 'pending' &&
            b.scheduledAt.isAfter(DateTime.now()))
        .length;
    final applications = _appService.getApplicationsByOwner(ownerId);
    final pendingApps =
        applications.where((a) => a.status == 'pending').length;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
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
                    'Bonjour, ${user?.fullName.split(' ').first ?? ''} 👋',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Tableau de bord propriétaire',
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
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate([
              StatCard(
                title: 'Annonces actives',
                value: '$activeListings',
                icon: Icons.home_outlined,
                color: AppColors.primary,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              StatCard(
                title: 'Candidatures en attente',
                value: '$pendingApps',
                icon: Icons.assignment_outlined,
                color: AppColors.secondary,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              StatCard(
                title: 'Visites planifiées',
                value: '$pendingBookings',
                icon: Icons.calendar_today_outlined,
                color: AppColors.success,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
              StatCard(
                title: 'Total annonces',
                value: '${listings.length}',
                icon: Icons.list_alt_outlined,
                color: const Color(0xFF6A1B9A),
              ),
            ]),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activité récente',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                ...bookings.take(3).map((b) {
                  final listing =
                      _listingService.getListingById(b.listingId);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      listing?.title ?? 'Visite',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(b.statusLabel,
                        style: const TextStyle(fontSize: 12)),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListingsTab() {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => _OwnerListingsInline(
          onCreateTap: () {
            Navigator.pushNamed(context, AppRoutes.ownerCreateListing)
                .then((_) => setState(() {}));
          },
        ),
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _OwnerApplicationsInline(),
      ),
    );
  }

  Widget _buildAgendaTab() {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _OwnerAgendaInline(),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _OwnerProfileInline(),
      ),
    );
  }
}

// ---- Owner Listings Inline ----
class _OwnerListingsInline extends StatefulWidget {
  final VoidCallback? onCreateTap;
  const _OwnerListingsInline({this.onCreateTap});

  @override
  State<_OwnerListingsInline> createState() => _OwnerListingsInlineState();
}

class _OwnerListingsInlineState extends State<_OwnerListingsInline> {
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
    final color0 = AppColors.listingColors[0];

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Annonces')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
                context, AppRoutes.ownerCreateListing)
            .then((_) => setState(() {})),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: listings.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.home_outlined,
                      size: 60, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Aucune annonce',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Créez votre première annonce',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.ownerCreateListing)
                        .then((_) => setState(() {})),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une annonce'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              itemBuilder: (_, i) {
                final l = listings[i];
                final cardColor = AppConstants
                    .listingColors[l.id.hashCode.abs() %
                        AppConstants.listingColors.length];
                return Dismissible(
                  key: Key(l.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child:
                        const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (dir) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Supprimer l\'annonce'),
                        content: const Text(
                            'Êtes-vous sûr de vouloir supprimer cette annonce ?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(ctx, false),
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                  },
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
                          AppConstants.propertyTypeIcons[l.type] ??
                              Icons.home,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        l.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l.city} • ${l.price.toStringAsFixed(0)} €/mois',
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.remove_red_eye_outlined,
                                  size: 12,
                                  color: color0),
                              const SizedBox(width: 3),
                              Text('${l.views} vues',
                                  style: TextStyle(
                                      fontSize: 11, color: color0)),
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

// ---- Owner Applications Inline ----
class _OwnerApplicationsInline extends StatefulWidget {
  const _OwnerApplicationsInline();

  @override
  State<_OwnerApplicationsInline> createState() =>
      _OwnerApplicationsInlineState();
}

class _OwnerApplicationsInlineState
    extends State<_OwnerApplicationsInline>
    with SingleTickerProviderStateMixin {
  final _appService = ApplicationService();
  final _authService = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = _authService.getCurrentUser()?.id ?? '';
    final applications = _appService.getApplicationsByOwner(ownerId);
    final pending =
        applications.where((a) => a.status == 'pending').toList();
    final accepted =
        applications.where((a) => a.status == 'accepted').toList();
    final rejected =
        applications.where((a) => a.status == 'rejected').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidatures'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'En attente (${pending.length})'),
            Tab(text: 'Acceptées'),
            Tab(text: 'Refusées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppList(pending, showActions: true),
          _buildAppList(accepted),
          _buildAppList(rejected),
        ],
      ),
    );
  }

  Widget _buildAppList(List apps, {bool showActions = false}) {
    if (apps.isEmpty) {
      return const Center(
          child: Text('Aucune candidature',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (_, i) {
        final app = apps[i];
        final authService = AuthService();
        final users = authService.getAllUsers();
        final tenantList =
            users.where((u) => u.id == app.tenantId).toList();
        final tenant =
            tenantList.isNotEmpty ? tenantList.first : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          AppColors.primary.withAlpha(20),
                      child: Text(
                        tenant?.initials ?? '?',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant?.fullName ?? 'Candidat',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Entrée souhaitée : ${app.desiredMoveIn.day}/${app.desiredMoveIn.month}/${app.desiredMoveIn.year}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(app.message,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (app.tenantBadges.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: (app.tenantBadges as List<String>)
                        .map((b) => Chip(
                              label: Text(b,
                                  style:
                                      const TextStyle(fontSize: 11)),
                              visualDensity:
                                  VisualDensity.compact,
                              backgroundColor: AppColors.primary
                                  .withAlpha(15),
                            ))
                        .toList(),
                  ),
                ],
                if (showActions) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await _appService
                                .updateApplicationStatus(
                                    app.id, 'rejected');
                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(
                                color: AppColors.error),
                          ),
                          child: const Text('Refuser'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _appService
                                .updateApplicationStatus(
                                    app.id, 'accepted');
                            setState(() {});
                          },
                          child: const Text('Accepter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---- Owner Agenda Inline ----
class _OwnerAgendaInline extends StatefulWidget {
  const _OwnerAgendaInline();

  @override
  State<_OwnerAgendaInline> createState() => _OwnerAgendaInlineState();
}

class _OwnerAgendaInlineState extends State<_OwnerAgendaInline> {
  final _bookingService = BookingService();
  final _authService = AuthService();
  final _listingService = ListingService();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ownerId = _authService.getCurrentUser()?.id ?? '';
    final bookings = _bookingService.getBookingsByOwner(ownerId);
    final todayBookings = bookings
        .where((b) =>
            b.scheduledAt.year == _selectedDay.year &&
            b.scheduledAt.month == _selectedDay.month &&
            b.scheduledAt.day == _selectedDay.day)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Text(
                  'Visites du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: todayBookings.isEmpty
                ? const Center(
                    child: Text('Aucune visite ce jour',
                        style: TextStyle(
                            color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: todayBookings.length,
                    itemBuilder: (_, i) {
                      final b = todayBookings[i];
                      final listing = _listingService
                          .getListingById(b.listingId);
                      return ListTile(
                        leading: const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primary),
                        title: Text(
                            listing?.title ?? 'Visite',
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text(
                            '${b.scheduledAt.hour.toString().padLeft(2, '0')}h${b.scheduledAt.minute.toString().padLeft(2, '0')} - ${b.statusLabel}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = firstDay.weekday % 7;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_monthName(now.month)} ${now.year}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                .map((d) => Text(d,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.textSecondary)))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (_, i) {
              if (i < firstWeekday) return const SizedBox.shrink();
              final day = i - firstWeekday + 1;
              final date = DateTime(now.year, now.month, day);
              final isSelected = _selectedDay.day == day &&
                  _selectedDay.month == now.month &&
                  _selectedDay.year == now.year;
              final isToday = now.day == day &&
                  date.month == now.month &&
                  date.year == now.year;

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary.withAlpha(20)
                            : null,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isToday || isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }
}

// ---- Owner Profile Inline ----
class _OwnerProfileInline extends StatelessWidget {
  const _OwnerProfileInline();

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
            padding:
                const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user?.fullName ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
                if (user?.isVerified == true) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified,
                            color: Colors.white, size: 15),
                        SizedBox(width: 6),
                        Text('Propriétaire vérifié',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person_outline,
                color: AppColors.primary),
            title: const Text('Informations personnelles'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.business_outlined,
                color: AppColors.primary),
            title: const Text('Informations professionnelles'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.payment_outlined,
                color: AppColors.primary),
            title: const Text('Paiements et facturation'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline,
                color: AppColors.primary),
            title: const Text('Aide et support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Se déconnecter',
                style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600)),
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
