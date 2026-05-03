import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class ProfileChoiceScreen extends StatelessWidget {
  const ProfileChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.home_rounded, size: 60, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenue ! Quel est votre profil ?',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 60),
                _ProfileCard(
                  icon: Icons.search_rounded,
                  title: 'Je cherche un logement',
                  subtitle: 'Trouvez votre appartement, maison ou studio idéal',
                  color: Colors.white,
                  textColor: AppColors.primary,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.signIn,
                    arguments: {'role': AppConstants.roleTenant},
                  ),
                ),
                const SizedBox(height: 20),
                _ProfileCard(
                  icon: Icons.apartment_rounded,
                  title: 'Je propose un logement',
                  subtitle: 'Publiez et gérez vos annonces immobilières',
                  color: Colors.white.withAlpha(30),
                  textColor: Colors.white,
                  borderColor: Colors.white.withAlpha(100),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.signIn,
                    arguments: {'role': AppConstants.roleOwner},
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.signIn,
                    arguments: {'role': AppConstants.roleAdmin},
                  ),
                  child: Text(
                    'Accès administrateur',
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: textColor.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 32, color: textColor),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withAlpha(180),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: textColor.withAlpha(150), size: 16),
          ],
        ),
      ),
    );
  }
}
