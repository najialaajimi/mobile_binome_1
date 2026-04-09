import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final _authService = AuthService();
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _user = _authService.getCurrentUser();
  }

  void _reload() {
    setState(() {
      _user = _authService.getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: ListView(
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding:
                const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              children: [
                Stack(
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showEditNameDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 14, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
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
          _buildSection('Mon compte', [
            _MenuItem(
              icon: Icons.person_outline,
              title: 'Informations personnelles',
              subtitle: user != null
                  ? '${user.nationality ?? ''} • ${user.preferredLanguage == 'fr' ? 'Français' : user.preferredLanguage == 'ar' ? 'Arabe' : user.preferredLanguage}'
                  : null,
              onTap: () => _showPersonalInfoDialog(context),
            ),
            _MenuItem(
              icon: Icons.lock_outline,
              title: 'Changer le mot de passe',
              onTap: () => _showChangePasswordDialog(context),
            ),
            _MenuItem(
              icon: Icons.business_outlined,
              title: 'Informations professionnelles',
              onTap: () => _showProfessionalInfoDialog(context),
            ),
          ]),
          const SizedBox(height: 8),
          _buildSection('Support', [
            _MenuItem(
              icon: Icons.help_outline,
              title: 'Aide et support',
              onTap: () => _showHelpDialog(context),
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'À propos',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Logement App',
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Se déconnecter',
                  style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600)),
              onTap: () async {
                await _authService.signOut();
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

  // ── Edit dialogs ────────────────────────────────────────────────

  void _showEditNameDialog(BuildContext context) {
    final user = _user;
    if (user == null) return;
    final nameCtrl = TextEditingController(text: user.fullName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nom complet'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await _authService
                  .updateUser(user.copyWith(fullName: nameCtrl.text.trim()));
              if (ctx.mounted) Navigator.pop(ctx);
              _reload();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showPersonalInfoDialog(BuildContext context) {
    final user = _user;
    if (user == null) return;
    final nameCtrl = TextEditingController(text: user.fullName);
    String selectedLang = user.preferredLanguage;
    String nationality = user.nationality ?? '';
    final nationalityCtrl = TextEditingController(text: nationality);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('Informations personnelles'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nom complet'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nationalityCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nationalité'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedLang,
                  decoration:
                      const InputDecoration(labelText: 'Langue préférée'),
                  items: const [
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'ar', child: Text('Arabe')),
                    DropdownMenuItem(value: 'en', child: Text('Anglais')),
                  ],
                  onChanged: (v) => setDState(() => selectedLang = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                final updated = user.copyWith(
                  fullName: nameCtrl.text.trim().isEmpty
                      ? user.fullName
                      : nameCtrl.text.trim(),
                  nationality: nationalityCtrl.text.trim(),
                  preferredLanguage: selectedLang,
                );
                await _authService.updateUser(updated);
                if (ctx.mounted) Navigator.pop(ctx);
                _reload();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure = true;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(errorMsg!,
                        style:
                            const TextStyle(color: AppColors.error, fontSize: 13)),
                  ),
                TextField(
                  controller: currentCtrl,
                  obscureText: obscure,
                  decoration:
                      const InputDecoration(labelText: 'Mot de passe actuel'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newCtrl,
                  obscureText: obscure,
                  decoration:
                      const InputDecoration(labelText: 'Nouveau mot de passe'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscure,
                  decoration:
                      const InputDecoration(labelText: 'Confirmer le nouveau mot de passe'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: !obscure,
                      onChanged: (v) =>
                          setDState(() => obscure = !(v ?? false)),
                    ),
                    const Text('Afficher', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (newCtrl.text != confirmCtrl.text) {
                  setDState(() => errorMsg =
                      'Les mots de passe ne correspondent pas.');
                  return;
                }
                if (newCtrl.text.length < 6) {
                  setDState(() =>
                      errorMsg = 'Minimum 6 caractères requis.');
                  return;
                }
                final ok = await _authService.updatePassword(
                    currentCtrl.text, newCtrl.text);
                if (!ok) {
                  setDState(
                      () => errorMsg = 'Mot de passe actuel incorrect.');
                  return;
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mot de passe modifié avec succès !'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfessionalInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Informations professionnelles'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'En tant que propriétaire vérifié, vos annonces bénéficient d\'une visibilité accrue et d\'un badge de confiance.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: 15, color: AppColors.primary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pour modifier vos documents professionnels, contactez le support.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aide et support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpItem(
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'support@logement.tn',
            ),
            SizedBox(height: 10),
            _HelpItem(
              icon: Icons.phone_outlined,
              title: 'Téléphone',
              value: '+216 71 000 000',
            ),
            SizedBox(height: 10),
            _HelpItem(
              icon: Icons.schedule_outlined,
              title: 'Disponibilité',
              value: 'Lun–Ven, 9h–18h',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _HelpItem(
      {required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
