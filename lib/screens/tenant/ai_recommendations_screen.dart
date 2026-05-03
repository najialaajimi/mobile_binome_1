import 'package:flutter/material.dart';
import '../../models/listing.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/listing_card.dart';

class AiRecommendationsScreen extends StatefulWidget {
  const AiRecommendationsScreen({super.key});

  @override
  State<AiRecommendationsScreen> createState() =>
      _AiRecommendationsScreenState();
}

class _AiRecommendationsScreenState extends State<AiRecommendationsScreen> {
  final _aiService = AiService();
  final _authService = AuthService();

  List<MapEntry<Listing, int>> _recommendations = [];
  bool _hasPreferences = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final userId = _authService.getCurrentUser()?.id ?? '';
    final prefs = _aiService.getUserPreferences(userId);
    final listings = _aiService.getRecommendations(userId, limit: 20);
    setState(() {
      _hasPreferences = prefs != null;
      if (prefs != null) {
        _recommendations = listings
            .map((l) => MapEntry(l, _aiService.getCompatibilityScore(prefs, l)))
            .toList();
      } else {
        _recommendations = listings.map((l) => MapEntry(l, 50)).toList();
      }
    });
  }

  Color _badgeColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.secondary;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 Recommandé pour vous'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withAlpha(15),
            child: const Text(
              'Basé sur votre profil et historique',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          if (!_hasPreferences)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune,
                          size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text(
                        'Complétez votre profil de recherche',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pour recevoir des recommandations personnalisées, définissez vos préférences de logement.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.pushNamed(
                              context, AppRoutes.preferences);
                          _load();
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Définir mes préférences'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: _recommendations.isEmpty
                  ? const Center(
                      child: Text('Aucune recommandation disponible.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _recommendations.length,
                      itemBuilder: (_, i) {
                        final entry = _recommendations[i];
                        final score = entry.value;
                        return Stack(
                          children: [
                            ListingCard(listing: entry.key),
                            Positioned(
                              top: 18,
                              right: 50,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _badgeColor(score),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Match $score%',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _load,
        icon: const Icon(Icons.refresh),
        label: const Text('Actualiser'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
