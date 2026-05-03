import 'package:flutter/material.dart';
import '../../models/application.dart';
import '../../services/application_service.dart';
import '../../services/listing_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  final _appService = ApplicationService();
  final _authService = AuthService();
  final _listingService = ListingService();
  late TabController _tabController;

  List<RentalApplication> _applications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadApplications() {
    final ownerId = _authService.getCurrentUser()?.id ?? '';
    setState(() {
      _applications = _appService.getApplicationsByOwner(ownerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        _applications.where((a) => a.status == 'pending').toList();
    final accepted =
        _applications.where((a) => a.status == 'accepted').toList();
    final rejected =
        _applications.where((a) => a.status == 'rejected').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidatures'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'En attente (${pending.length})'),
            Tab(text: 'Acceptées (${accepted.length})'),
            Tab(text: 'Refusées (${rejected.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(pending, showActions: true),
          _buildList(accepted),
          _buildList(rejected),
        ],
      ),
    );
  }

  Widget _buildList(List<RentalApplication> apps,
      {bool showActions = false}) {
    if (apps.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Aucune candidature dans cette catégorie.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary)),
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (_, i) {
        final app = apps[i];
        final users = _authService.getAllUsers();
        final tenantList =
            users.where((u) => u.id == app.tenantId).toList();
        final tenant =
            tenantList.isNotEmpty ? tenantList.first : null;
        final listing =
            _listingService.getListingById(app.listingId);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing badge
                if (listing != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.home_outlined,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            listing.title,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                // Tenant row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant?.fullName ?? 'Candidat',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          if (tenant?.email != null)
                            Text(
                              tenant!.email,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
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
                    _StatusBadge(status: app.status),
                  ],
                ),
                const SizedBox(height: 10),
                // Tenant details
                if (tenant != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (tenant.isStudent)
                        _InfoChip(
                            icon: Icons.school_outlined,
                            label: tenant.studyField ?? 'Étudiant'),
                      if (tenant.nationality != null)
                        _InfoChip(
                            icon: Icons.flag_outlined,
                            label: tenant.nationality!),
                    ],
                  ),
                if ((app.tenantBadges).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: app.tenantBadges
                        .map((b) => Chip(
                              label: Text(b,
                                  style:
                                      const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              backgroundColor:
                                  AppColors.secondary.withAlpha(15),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  app.message,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showActions) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _appService
                                .updateApplicationStatus(
                                    app.id, 'rejected');
                            _loadApplications();
                          },
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Refuser'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(
                                color: AppColors.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _appService
                                .updateApplicationStatus(
                                    app.id, 'accepted');
                            _loadApplications();
                          },
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Accepter'),
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'accepted':
        color = AppColors.success;
        label = 'Acceptée';
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'Refusée';
        break;
      default:
        color = AppColors.secondary;
        label = 'En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 13, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      backgroundColor: AppColors.primary.withAlpha(10),
    );
  }
}


