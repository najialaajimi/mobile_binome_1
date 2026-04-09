import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/user_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/ai_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class TenantProfileScreen extends StatefulWidget {
  const TenantProfileScreen({super.key});

  @override
  State<TenantProfileScreen> createState() => _TenantProfileScreenState();
}

class _TenantProfileScreenState extends State<TenantProfileScreen> {
  final _authService = AuthService();
  final _aiService = AiService();
  AppUser? _user;
  UserPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final user = _authService.getCurrentUser();
    setState(() {
      _user = user;
      if (user != null) {
        _prefs = _aiService.getUserPreferences(user.id);
      }
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
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (user?.isStudent == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_outlined,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          user?.studyField != null
                              ? 'Étudiant en ${user!.studyField}'
                              : 'Étudiant',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                if (user?.isVerified == true) ...[
                  const SizedBox(height: 8),
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

          // AI preferences summary
          if (_prefs != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Profil IA de compatibilité',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (_prefs!.budgetMax != null)
                        _PrefChip(
                            icon: Icons.wallet_outlined,
                            label:
                                'Budget: ${_prefs!.budgetMax!.toInt()} TND'),
                      if (_prefs!.lifestyle != 'any')
                        _PrefChip(
                            icon: Icons.emoji_people_outlined,
                            label: _prefs!.lifestyle),
                      if (_prefs!.schedule != 'flexible')
                        _PrefChip(
                            icon: Icons.schedule_outlined,
                            label: _scheduleLabel(_prefs!.schedule)),
                      _PrefChip(
                          icon: Icons.cleaning_services_outlined,
                          label: 'Propreté: ${_prefs!.cleanlinessLevel}/5'),
                      if (_prefs!.smokingAllowed)
                        _PrefChip(
                            icon: Icons.smoking_rooms_outlined,
                            label: 'Fumeur'),
                      if (_prefs!.petsAllowed)
                        _PrefChip(
                            icon: Icons.pets_outlined,
                            label: 'Animaux OK'),
                      if (_prefs!.hobbies.isNotEmpty)
                        ..._prefs!.hobbies.take(3).map((h) =>
                            _PrefChip(
                                icon: Icons.interests_outlined,
                                label: h)),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
          _buildSection('Mon compte', [
            _ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Informations personnelles',
              subtitle: user != null
                  ? '${user.nationality ?? ''} · ${user.preferredLanguage == 'fr' ? 'Français' : user.preferredLanguage == 'ar' ? 'Arabe' : user.preferredLanguage}'
                  : null,
              onTap: () => _showPersonalInfoDialog(context),
            ),
            _ProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Changer le mot de passe',
              onTap: () => _showChangePasswordDialog(context),
            ),
            _ProfileMenuItem(
              icon: Icons.tune,
              title: 'Préférences de recherche',
              subtitle: 'Budget, logement, mode de vie…',
              onTap: () async {
                await Navigator.pushNamed(context, AppRoutes.preferences);
                _reload();
              },
            ),
            _ProfileMenuItem(
              icon: Icons.group_outlined,
              title: 'Trouver un colocataire compatible',
              subtitle: 'Matching IA par style de vie',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.roommateFinder),
            ),
          ]),
          const SizedBox(height: 8),
          _buildSection('Documents', [
            _ProfileMenuItem(
              icon: Icons.description_outlined,
              title: 'Mes documents',
              subtitle: 'Justificatifs, garanties…',
              onTap: () => _showDocumentsDialog(context),
            ),
          ]),
          const SizedBox(height: 8),
          _buildSection('Support', [
            _ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Aide et support',
              onTap: () => _showHelpDialog(context),
            ),
            _ProfileMenuItem(
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
                      color: AppColors.error, fontWeight: FontWeight.w600)),
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

  String _scheduleLabel(String s) {
    switch (s) {
      case 'morning':
        return 'Lève-tôt';
      case 'evening':
        return 'Soir';
      case 'night':
        return 'Noctambule';
      default:
        return 'Flexible';
    }
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

  // ── Dialogs ─────────────────────────────────────────────────────────

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
    final nationalityCtrl =
        TextEditingController(text: user.nationality ?? '');
    final studyFieldCtrl =
        TextEditingController(text: user.studyField ?? '');
    bool isStudent = user.isStudent;
    String selectedLang = user.preferredLanguage;

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
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Je suis étudiant(e)',
                      style: TextStyle(fontSize: 14)),
                  value: isStudent,
                  onChanged: (v) => setDState(() => isStudent = v),
                ),
                if (isStudent)
                  TextField(
                    controller: studyFieldCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Domaine d\'études'),
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
                  isStudent: isStudent,
                  studyField: isStudent
                      ? studyFieldCtrl.text.trim()
                      : null,
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
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ),
                TextField(
                  controller: currentCtrl,
                  obscureText: obscure,
                  decoration: const InputDecoration(
                      labelText: 'Mot de passe actuel'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newCtrl,
                  obscureText: obscure,
                  decoration: const InputDecoration(
                      labelText: 'Nouveau mot de passe'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscure,
                  decoration: const InputDecoration(
                      labelText: 'Confirmer le nouveau mot de passe'),
                ),
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
                  setDState(() =>
                      errorMsg = 'Mot de passe actuel incorrect.');
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

  void _showDocumentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mes documents'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DocItem(
                icon: Icons.badge_outlined,
                title: 'Pièce d\'identité',
                status: 'Non soumis'),
            SizedBox(height: 10),
            _DocItem(
                icon: Icons.receipt_long_outlined,
                title: 'Justificatif de revenus',
                status: 'Non soumis'),
            SizedBox(height: 10),
            _DocItem(
                icon: Icons.school_outlined,
                title: 'Certificat de scolarité',
                status: 'Non soumis'),
            SizedBox(height: 12),
            Text(
              'Soumettez vos documents pour augmenter vos chances d\'acceptation.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
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
                value: 'support@logement.tn'),
            SizedBox(height: 10),
            _HelpItem(
                icon: Icons.phone_outlined,
                title: 'Téléphone',
                value: '+216 71 000 000'),
            SizedBox(height: 10),
            _HelpItem(
                icon: Icons.schedule_outlined,
                title: 'Disponibilité',
                value: 'Lun–Ven, 9h–18h'),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer')),
        ],
      ),
    );
  }
}

// ── Small widgets ──────────────────────────────────────────────────────────

class _PrefChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PrefChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 13, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      backgroundColor: AppColors.primary.withAlpha(12),
      side: BorderSide(color: AppColors.primary.withAlpha(30)),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
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

class _DocItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  const _DocItem(
      {required this.icon, required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
            child:
                Text(title, style: const TextStyle(fontSize: 13))),
        Text(status,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
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
