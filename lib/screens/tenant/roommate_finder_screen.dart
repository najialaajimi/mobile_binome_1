import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/user_preferences.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class RoommateFinderScreen extends StatefulWidget {
  const RoommateFinderScreen({super.key});

  @override
  State<RoommateFinderScreen> createState() => _RoommateFinderScreenState();
}

class _RoommateFinderScreenState extends State<RoommateFinderScreen> {
  final _aiService = AiService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _roommates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final userId = _authService.getCurrentUser()?.id ?? '';
    setState(() {
      _roommates = _aiService.findCompatibleRoommates(userId);
    });
  }

  Color _scoreColor(int score) {
    if (score >= 70) return AppColors.success;
    if (score >= 50) return AppColors.secondary;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Trouver un binôme'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _roommates.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline,
                        size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun binôme compatible trouvé',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complétez vos préférences en cherchant une colocation pour trouver des binômes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.preferences),
                      child: const Text('Définir mes préférences'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _roommates.length,
              itemBuilder: (_, i) {
                final entry = _roommates[i];
                final user = entry['user'] as AppUser;
                final score = entry['score'] as int;
                final prefs = entry['preferences'] as UserPreferences;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  AppColors.primary.withAlpha(20),
                              child: Text(
                                user.initials,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(user.fullName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.textPrimary)),
                                  if (user.nationality != null)
                                    Text(user.nationality!,
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _scoreColor(score).withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _scoreColor(score)),
                              ),
                              child: Text(
                                '$score%',
                                style: TextStyle(
                                    color: _scoreColor(score),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (user.isStudent)
                              _infoChip(
                                  '🎓 Étudiant(e)', AppColors.primary),
                            if (user.studyField != null)
                              _infoChip('📚 ${user.studyField!}',
                                  AppColors.secondary),
                            _infoChip(
                                '💰 ${prefs.budgetMin?.toInt() ?? 0}-${prefs.budgetMax?.toInt() ?? '?'} TND',
                                AppColors.success),
                            _infoChip(_lifestyleLabel(prefs.lifestyle),
                                AppColors.textSecondary),
                            _infoChip(
                                _langLabel(prefs.preferredLanguage),
                                AppColors.primary),
                            _infoChip(_scheduleLabel(prefs.schedule),
                                AppColors.secondary),
                            _infoChip(
                                '🧹 ${prefs.cleanlinessLevel}/5',
                                AppColors.textSecondary),
                            if (prefs.smokingAllowed)
                              _infoChip('🚬 Fumeur', AppColors.error),
                            if (prefs.petsAllowed)
                              _infoChip('🐾 Animaux', AppColors.secondary),
                            ...prefs.hobbies.take(3).map((h) =>
                                _infoChip('🎯 $h', AppColors.primary)),
                          ],
                        ),
                        if (prefs.bio.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '"${prefs.bio}"',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.conversations),
                            icon: const Icon(Icons.message_outlined,
                                size: 16),
                            label: const Text('Contacter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _infoChip(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      );

  String _lifestyleLabel(String v) {
    switch (v) {
      case 'calme':
        return '🤫 Calme';
      case 'anime':
        return '🎉 Animé';
      default:
        return '🙂 Flexible';
    }
  }

  String _scheduleLabel(String v) {
    switch (v) {
      case 'morning':
        return '☀️ Lève-tôt';
      case 'evening':
        return '🌙 Soir';
      case 'night':
        return '🦉 Noctambule';
      default:
        return '⏱️ Flexible';
    }
  }

  String _langLabel(String v) {
    switch (v) {
      case 'fr':
        return '🇫🇷 Français';
      case 'en':
        return '🇬🇧 English';
      case 'ar':
        return '🇹🇳 Arabe';
      default:
        return '🌍 Toutes';
    }
  }
}
