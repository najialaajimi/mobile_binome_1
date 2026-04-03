import 'package:flutter/material.dart';
import '../../services/application_service.dart';
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
            const Tab(text: 'Acceptées'),
            const Tab(text: 'Refusées'),
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

  Widget _buildList(List apps, {bool showActions = false}) {
    if (apps.isEmpty) {
      return const Center(
          child: Text('Aucune candidature',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    final authService = AuthService();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (_, i) {
        final app = apps[i];
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant?.fullName ?? 'Candidat',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Entrée : ${app.desiredMoveIn.day}/${app.desiredMoveIn.month}/${app.desiredMoveIn.year}',
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
                Text(
                  app.message,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((app.tenantBadges as List).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children:
                        (app.tenantBadges as List<String>).map((b) =>
                            Chip(
                              label: Text(b,
                                  style: const TextStyle(
                                      fontSize: 11)),
                              visualDensity:
                                  VisualDensity.compact,
                              backgroundColor:
                                  AppColors.primary.withAlpha(15),
                            )).toList(),
                  ),
                ],
                if (showActions) ...[
                  const SizedBox(height: 12),
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
