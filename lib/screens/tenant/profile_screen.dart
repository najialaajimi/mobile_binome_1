import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class TenantProfileScreen extends StatelessWidget {
  const TenantProfileScreen({super.key});

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
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                        Icon(Icons.verified, color: Colors.white, size: 15),
                        SizedBox(width: 6),
                        Text('Compte vérifié',
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
          _buildSection('Mon compte', [
            _ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Informations personnelles',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              ),
            ),
            _ProfileMenuItem(
              icon: Icons.tune,
              title: 'Préférences de recherche',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              ),
            ),
            _ProfileMenuItem(
              icon: Icons.description_outlined,
              title: 'Mes documents',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          _buildSection('Support', [
            _ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Aide et support',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              ),
            ),
            _ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'À propos',
              onTap: () => _showAbout(context),
            ),
          ]),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Se déconnecter',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.profileChoice);
                }
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Logement App',
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
